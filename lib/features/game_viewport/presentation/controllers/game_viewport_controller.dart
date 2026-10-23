import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/bridge/bridge_message.dart';
import '../../../../core/bridge/bridge_protocol.dart';
import '../../../../core/bridge/unity_bridge_interface.dart';
import '../../../../core/bridge/unity_bridge_service.dart';
import '../../domain/models/game_session_state.dart';
import '../../domain/models/telemetry_data.dart';

class GameViewportController extends ChangeNotifier {
  final UnityBridgeService _bridgeService;
  StreamSubscription<BridgeMessage>? _messageSub;
  StreamSubscription<BridgeConnectionStatus>? _statusSub;

  GameSessionState _sessionState = const GameSessionState();
  TelemetryData _telemetry = const TelemetryData();
  bool _isDebugPanelOpen = false;

  GameViewportController({UnityBridgeService? bridgeService})
      : _bridgeService = bridgeService ?? UnityBridgeService() {
    _init();
  }

  GameSessionState get sessionState => _sessionState;
  TelemetryData get telemetry => _telemetry;
  bool get isDebugPanelOpen => _isDebugPanelOpen;
  UnityBridgeService get bridgeService => _bridgeService;

  void _init() {
    _statusSub = _bridgeService.bridge.statusStream.listen((status) {
      _updateStatus(status);
    });

    _messageSub = _bridgeService.bridge.messageStream.listen((msg) {
      _handleMessage(msg);
    });
  }

  void _updateStatus(BridgeConnectionStatus status) {
    switch (status) {
      case BridgeConnectionStatus.disconnected:
        _sessionState = _sessionState.copyWith(
          phase: GamePhase.uninitialized,
          initializationStep: 0,
          stepDescription: 'Disconnected from Unity engine',
        );
        break;

      case BridgeConnectionStatus.connecting:
        _sessionState = _sessionState.copyWith(
          phase: GamePhase.initializing,
          initializationStep: 1,
          stepDescription: 'Negotiating Bridge Protocol v1.0.0...',
        );
        break;

      case BridgeConnectionStatus.connected:
        _sessionState = _sessionState.copyWith(
          phase: GamePhase.ready,
          initializationStep: 4,
          stepDescription: 'Unity Engine & Vehicle Ready',
        );
        break;

      case BridgeConnectionStatus.error:
        _sessionState = _sessionState.copyWith(
          phase: GamePhase.error,
          errorMessage: _bridgeService.errorMessage ?? 'Bridge connection error',
          stepDescription: 'Connection Failure',
        );
        break;
    }
    notifyListeners();
  }

  void _handleMessage(BridgeMessage msg) {
    switch (msg.action) {
      case BridgeProtocol.actionSceneLoaded:
        _sessionState = _sessionState.copyWith(
          initializationStep: 2,
          currentScene: msg.payload['sceneName'] as String? ?? 'BootstrapScene',
          stepDescription: 'BootstrapScene loaded on Android target',
        );
        break;

      case BridgeProtocol.actionHandshakeAck:
        _sessionState = _sessionState.copyWith(
          initializationStep: 3,
          stepDescription: 'Handshake ACK received (Render API: ${msg.payload['renderApi'] ?? 'Vulkan'})',
        );
        break;

      case BridgeProtocol.actionVehicleSpawned:
        _sessionState = _sessionState.copyWith(
          initializationStep: 4,
          activeVehicle: msg.payload['model'] as String? ?? 'Roadster',
          stepDescription: 'Roadster prototype spawned',
        );
        break;

      case BridgeProtocol.actionTelemetryUpdate:
        _telemetry = TelemetryData.fromMap(msg.payload);
        if (_sessionState.phase != GamePhase.driving && _telemetry.speedMph > 0.5) {
          _sessionState = _sessionState.copyWith(phase: GamePhase.driving);
        }
        break;

      case BridgeProtocol.actionError:
        _sessionState = _sessionState.copyWith(
          phase: GamePhase.error,
          errorMessage: msg.payload['message'] as String? ?? 'Bridge reported error',
        );
        break;
    }
    notifyListeners();
  }

  Future<void> startSession() async {
    if (_bridgeService.status != BridgeConnectionStatus.disconnected) {
      await _bridgeService.disconnect();
    }
    await _bridgeService.connect();
  }

  Future<void> retry() async {
    _sessionState = _sessionState.copyWith(
      phase: GamePhase.initializing,
      errorMessage: null,
      initializationStep: 1,
      stepDescription: 'Retrying connection...',
    );
    notifyListeners();
    await _bridgeService.retry();
  }

  void setThrottle(double value) {
    _bridgeService.sendDriveInput(
      throttle: value,
      steering: _telemetry.steering,
      brake: 0.0,
    );
  }

  void setBrake(double value) {
    _bridgeService.sendDriveInput(
      throttle: 0.0,
      steering: _telemetry.steering,
      brake: value,
    );
  }

  void setSteering(double value) {
    _bridgeService.sendDriveInput(
      throttle: _telemetry.throttle,
      steering: value,
      brake: 0.0,
    );
  }

  void cycleCameraMode() {
    final modes = ['CHASE', 'ORBIT', 'COCKPIT'];
    final currentIdx = modes.indexOf(_telemetry.cameraMode);
    final nextMode = modes[(currentIdx + 1) % modes.length];
    _bridgeService.setCameraMode(nextMode);
  }

  void setVehicleColor(String hexColor) {
    _bridgeService.setVehicleColor(hexColor);
  }

  void toggleDebugPanel() {
    _isDebugPanelOpen = !_isDebugPanelOpen;
    notifyListeners();
  }

  void simulateFailureNextConnect() {
    _bridgeService.setSimulateError(true);
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _statusSub?.cancel();
    _bridgeService.disconnect();
    super.dispose();
  }
}
