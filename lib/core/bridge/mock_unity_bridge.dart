import 'dart:async';
import 'dart:math' as math;
import 'bridge_message.dart';
import 'bridge_protocol.dart';
import 'unity_bridge_interface.dart';

/// Interactive high-fidelity Unity engine bridge simulator.
/// Provides deterministic responses for development, emulator testing, and unit tests.
class MockUnityBridge implements IUnityBridge {
  final StreamController<BridgeConnectionStatus> _statusController =
      StreamController<BridgeConnectionStatus>.broadcast();
  final StreamController<BridgeMessage> _messageController =
      StreamController<BridgeMessage>.broadcast();

  BridgeConnectionStatus _currentStatus = BridgeConnectionStatus.disconnected;
  String? _lastErrorMessage;
  bool _simulateError = false;

  Timer? _telemetryTimer;
  Timer? _pingTimer;

  // Simulated vehicle state
  double _speedMph = 0.0;
  double _throttle = 0.0;
  double _steering = 0.0;
  double _brake = 0.0;
  double _batteryPercent = 98.4;
  String _gear = 'P';
  String _cameraMode = 'CHASE';
  String _vehicleColorHex = '#E82127';

  @override
  BridgeConnectionStatus get currentStatus => _currentStatus;

  @override
  Stream<BridgeConnectionStatus> get statusStream => _statusController.stream;

  @override
  Stream<BridgeMessage> get messageStream => _messageController.stream;

  @override
  String? get lastErrorMessage => _lastErrorMessage;

  @override
  void setSimulateError(bool simulate) {
    _simulateError = simulate;
  }

  void _setStatus(BridgeConnectionStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  @override
  Future<void> connect() async {
    if (_currentStatus == BridgeConnectionStatus.connecting ||
        _currentStatus == BridgeConnectionStatus.connected) {
      return;
    }

    _lastErrorMessage = null;
    _setStatus(BridgeConnectionStatus.connecting);

    // Realistic multi-stage initialization
    await Future.delayed(const Duration(milliseconds: 350));

    if (_simulateError) {
      _lastErrorMessage =
          'VULKAN_INIT_FAILED: Unity Vulkan surface failed to negotiate swapchain on Android window (API 35). Check GPU acceleration settings.';
      _setStatus(BridgeConnectionStatus.error);
      _emitMessage(BridgeMessage(
        action: BridgeProtocol.actionError,
        payload: {
          'code': 'VULKAN_INIT_FAILED',
          'message': _lastErrorMessage,
        },
      ));
      return;
    }

    await Future.delayed(const Duration(milliseconds: 400));
    _emitMessage(BridgeMessage(
      action: BridgeProtocol.actionSceneLoaded,
      payload: {'sceneName': 'BootstrapScene', 'status': 'INITIALIZED'},
    ));

    await Future.delayed(const Duration(milliseconds: 300));
    _emitMessage(BridgeMessage(
      action: BridgeProtocol.actionHandshakeAck,
      payload: {
        'unityVersion': '2022.3.20f1',
        'protocolVersion': BridgeProtocol.version,
        'scene': 'BootstrapScene',
        'renderApi': 'OpenGLES3_VulkanFallback',
        'targetPlatform': 'Android-ARM64',
      },
    ));

    await Future.delayed(const Duration(milliseconds: 250));
    _emitMessage(BridgeMessage(
      action: BridgeProtocol.actionVehicleSpawned,
      payload: {
        'vehicleId': 'roadster_prototype_01',
        'model': 'Tesla Roadster Inspired Cyber-Red',
        'dualMotor': true,
      },
    ));

    _setStatus(BridgeConnectionStatus.connected);
    _startTelemetryLoop();
    _startPingHeartbeat();
  }

  @override
  Future<void> retryConnection() async {
    _simulateError = false;
    await disconnect();
    await connect();
  }

  @override
  Future<void> disconnect() async {
    _stopTelemetryLoop();
    _stopPingHeartbeat();
    _setStatus(BridgeConnectionStatus.disconnected);
  }

  @override
  Future<void> sendMessage(BridgeMessage message) async {
    if (_currentStatus != BridgeConnectionStatus.connected) {
      return;
    }

    _handleIncomingAction(message);
  }

  @override
  Future<BridgeMessage> sendRequest(
    String action, [
    Map<String, dynamic>? payload,
  ]) async {
    final Completer<BridgeMessage> completer = Completer<BridgeMessage>();
    late final StreamSubscription<BridgeMessage> sub;

    sub = messageStream.listen((msg) {
      if ((action == BridgeProtocol.actionPing &&
              msg.action == BridgeProtocol.actionPong) ||
          (action == BridgeProtocol.actionHandshakeSyn &&
              msg.action == BridgeProtocol.actionHandshakeAck)) {
        sub.cancel();
        if (!completer.isCompleted) {
          completer.complete(msg);
        }
      }
    });

    await sendMessage(BridgeMessage(action: action, payload: payload ?? {}));

    return completer.future.timeout(
      const Duration(seconds: 4),
      onTimeout: () {
        sub.cancel();
        throw TimeoutException('Request $action timed out waiting for response');
      },
    );
  }

  void _handleIncomingAction(BridgeMessage msg) {
    switch (msg.action) {
      case BridgeProtocol.actionPing:
        _emitMessage(BridgeMessage(
          action: BridgeProtocol.actionPong,
          payload: {
            'fps': 60,
            'memoryMB': 148,
            'clientTs': msg.timestamp,
            'serverTs': DateTime.now().millisecondsSinceEpoch,
          },
        ));
        break;

      case BridgeProtocol.actionDriveInput:
        final p = msg.payload;
        _throttle = (p['throttle'] as num?)?.toDouble() ?? 0.0;
        _steering = (p['steering'] as num?)?.toDouble() ?? 0.0;
        _brake = (p['brake'] as num?)?.toDouble() ?? 0.0;
        break;

      case BridgeProtocol.actionSetCameraMode:
        _cameraMode = msg.payload['mode'] as String? ?? 'CHASE';
        break;

      case BridgeProtocol.actionSetVehicleColor:
        _vehicleColorHex = msg.payload['hexColor'] as String? ?? '#E82127';
        break;

      case BridgeProtocol.actionPause:
        _stopTelemetryLoop();
        break;

      case BridgeProtocol.actionResume:
        _startTelemetryLoop();
        break;
    }
  }

  void _emitMessage(BridgeMessage msg) {
    if (!_messageController.isClosed) {
      _messageController.add(msg);
    }
  }

  void _startTelemetryLoop() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _simulateVehiclePhysics();
      _emitMessage(BridgeMessage(
        action: BridgeProtocol.actionTelemetryUpdate,
        payload: {
          'speedMph': double.parse(_speedMph.toStringAsFixed(1)),
          'rpm': (_speedMph * 70.0 + 800).clamp(800, 18000).toInt(),
          'batteryPercent':
              double.parse(_batteryPercent.toStringAsFixed(1)),
          'gear': _gear,
          'gForce': double.parse(
              (_throttle > 0 ? 0.2 + (_throttle * 1.3) : 0.05)
                  .toStringAsFixed(2)),
          'cameraMode': _cameraMode,
          'color': _vehicleColorHex,
          'steering': _steering,
          'throttle': _throttle,
        },
      ));
    });
  }

  void _stopTelemetryLoop() {
    _telemetryTimer?.cancel();
    _telemetryTimer = null;
  }

  void _startPingHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(BridgeProtocol.pingInterval, (_) {
      if (_currentStatus == BridgeConnectionStatus.connected) {
        _emitMessage(BridgeMessage(
          action: BridgeProtocol.actionPong,
          payload: {
            'fps': 58 + math.Random().nextInt(4),
            'memoryMB': 142 + math.Random().nextInt(12),
            'serverTs': DateTime.now().millisecondsSinceEpoch,
          },
        ));
      }
    });
  }

  void _stopPingHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _simulateVehiclePhysics() {
    if (_throttle > 0.0) {
      _speedMph = math.min(250.0, _speedMph + (_throttle * 4.5));
      _gear = 'D';
      _batteryPercent = math.max(5.0, _batteryPercent - 0.003);
    } else if (_brake > 0.0) {
      _speedMph = math.max(0.0, _speedMph - (_brake * 7.5));
    } else {
      _speedMph = math.max(0.0, _speedMph - 0.8);
    }

    if (_speedMph <= 0.1 && _throttle == 0.0 && _brake == 0.0) {
      _gear = 'P';
    }
  }

  void dispose() {
    disconnect();
    _statusController.close();
    _messageController.close();
  }
}
