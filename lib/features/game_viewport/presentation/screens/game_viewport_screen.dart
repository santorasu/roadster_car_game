import 'package:flutter/material.dart';
import '../../domain/models/game_session_state.dart';
import '../controllers/game_viewport_controller.dart';
import '../widgets/bridge_debug_panel.dart';
import '../widgets/interactive_3d_viewport.dart';
import '../widgets/unity_error_overlay.dart';
import '../widgets/unity_hud_overlay.dart';
import '../widgets/unity_loading_overlay.dart';

class GameViewportScreen extends StatefulWidget {
  const GameViewportScreen({super.key});

  @override
  State<GameViewportScreen> createState() => _GameViewportScreenState();
}

class _GameViewportScreenState extends State<GameViewportScreen> {
  late final GameViewportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameViewportController();
    _controller.addListener(_onControllerUpdate);
    // Begin connection sequence on entrance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.startSession();
    });
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _controller.sessionState;
    final isError = session.phase == GamePhase.error;
    final isInitializing = session.phase == GamePhase.initializing ||
        session.phase == GamePhase.uninitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 3D Viewport Surface (Render target)
          Interactive3DViewport(telemetry: _controller.telemetry),

          // HUD Overlay when ready or driving
          if (!isError && !isInitializing)
            UnityHudOverlay(
              telemetry: _controller.telemetry,
              controller: _controller,
              onExit: () => Navigator.of(context).pop(),
            ),

          // Loading Overlay during initialization
          if (isInitializing)
            UnityLoadingOverlay(sessionState: session),

          // Error Overlay when bridge or engine fails
          if (isError)
            UnityErrorOverlay(
              sessionState: session,
              onRetry: _controller.retry,
            ),

          // Bridge Debug Logs Drawer
          if (_controller.isDebugPanelOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BridgeDebugPanel(controller: _controller),
            ),
        ],
      ),
    );
  }
}
