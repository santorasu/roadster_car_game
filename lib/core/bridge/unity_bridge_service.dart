import 'dart:async';
import 'package:flutter/foundation.dart';
import 'bridge_message.dart';
import 'bridge_protocol.dart';
import 'mock_unity_bridge.dart';
import 'unity_bridge_interface.dart';

/// Central singleton service providing versioned Flutter-Unity bridge communication.
class UnityBridgeService extends ChangeNotifier {
  static final UnityBridgeService _instance = UnityBridgeService._internal();
  factory UnityBridgeService() => _instance;

  UnityBridgeService._internal() {
    _bridge = MockUnityBridge();
    _initBridgeListeners();
  }

  late IUnityBridge _bridge;
  StreamSubscription<BridgeConnectionStatus>? _statusSub;
  StreamSubscription<BridgeMessage>? _messageSub;

  final List<BridgeMessage> _recentMessages = [];
  int _lastPingMs = 0;
  int _unityFps = 60;
  int _unityMemoryMB = 145;

  IUnityBridge get bridge => _bridge;
  BridgeConnectionStatus get status => _bridge.currentStatus;
  String? get errorMessage => _bridge.lastErrorMessage;
  List<BridgeMessage> get recentMessages => List.unmodifiable(_recentMessages);
  int get lastPingMs => _lastPingMs;
  int get unityFps => _unityFps;
  int get unityMemoryMB => _unityMemoryMB;

  void _initBridgeListeners() {
    _statusSub?.cancel();
    _messageSub?.cancel();

    _statusSub = _bridge.statusStream.listen((status) {
      notifyListeners();
    });

    _messageSub = _bridge.messageStream.listen((msg) {
      _recordMessage(msg);
      _handleSpecialMessage(msg);
      notifyListeners();
    });
  }

  void _recordMessage(BridgeMessage msg) {
    _recentMessages.insert(0, msg);
    if (_recentMessages.length > 50) {
      _recentMessages.removeLast();
    }
  }

  void _handleSpecialMessage(BridgeMessage msg) {
    if (msg.action == BridgeProtocol.actionPong) {
      final clientTs = msg.payload['clientTs'] as num?;
      if (clientTs != null) {
        _lastPingMs = DateTime.now().millisecondsSinceEpoch - clientTs.toInt();
      } else {
        _lastPingMs = 16;
      }
      _unityFps = (msg.payload['fps'] as num?)?.toInt() ?? 60;
      _unityMemoryMB = (msg.payload['memoryMB'] as num?)?.toInt() ?? 145;
    }
  }

  Future<void> connect() async {
    await _bridge.connect();
  }

  Future<void> retry() async {
    await _bridge.retryConnection();
  }

  Future<void> disconnect() async {
    await _bridge.disconnect();
  }

  Future<void> sendDriveInput({
    required double throttle,
    required double steering,
    required double brake,
  }) async {
    await _bridge.sendMessage(BridgeMessage(
      action: BridgeProtocol.actionDriveInput,
      payload: {
        'throttle': throttle,
        'steering': steering,
        'brake': brake,
      },
    ));
  }

  Future<void> setCameraMode(String mode) async {
    await _bridge.sendMessage(BridgeMessage(
      action: BridgeProtocol.actionSetCameraMode,
      payload: {'mode': mode},
    ));
  }

  Future<void> setVehicleColor(String hexColor) async {
    await _bridge.sendMessage(BridgeMessage(
      action: BridgeProtocol.actionSetVehicleColor,
      payload: {'hexColor': hexColor},
    ));
  }

  Future<void> sendPing() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _bridge.sendMessage(BridgeMessage(
      action: BridgeProtocol.actionPing,
      payload: {'clientTs': now},
    ));
  }

  Future<void> pause() async {
    await _bridge.sendMessage(BridgeMessage(
      action: BridgeProtocol.actionPause,
    ));
  }

  Future<void> resume() async {
    await _bridge.sendMessage(BridgeMessage(
      action: BridgeProtocol.actionResume,
    ));
  }

  void setSimulateError(bool simulate) {
    _bridge.setSimulateError(simulate);
    notifyListeners();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _messageSub?.cancel();
    super.dispose();
  }
}
