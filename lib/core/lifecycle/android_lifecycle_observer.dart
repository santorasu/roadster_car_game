import 'package:flutter/widgets.dart';
import '../bridge/unity_bridge_service.dart';

/// Monitors Android host lifecycle and memory events, coordinating with the Unity engine.
class AndroidLifecycleObserver with WidgetsBindingObserver {
  final UnityBridgeService _bridgeService;
  bool _isPaused = false;

  AndroidLifecycleObserver({UnityBridgeService? bridgeService})
      : _bridgeService = bridgeService ?? UnityBridgeService();

  void register() {
    WidgetsBinding.instance.addObserver(this);
  }

  void unregister() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[AndroidLifecycle] AppLifecycleState changed to: $state');

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        if (!_isPaused) {
          _isPaused = true;
          _bridgeService.pause();
          debugPrint('[AndroidLifecycle] Dispatched PAUSE to Unity subsystem');
        }
        break;

      case AppLifecycleState.resumed:
        if (_isPaused) {
          _isPaused = false;
          _bridgeService.resume();
          debugPrint('[AndroidLifecycle] Dispatched RESUME to Unity subsystem');
        }
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _bridgeService.pause();
        break;
    }
  }

  @override
  void didHaveMemoryPressure() {
    debugPrint('[AndroidLifecycle] System low memory pressure detected on Android');
    // UnityBridgeService will dispatch low memory notice if needed
  }
}
