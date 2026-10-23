import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/arcade_game_state.dart';
import '../controllers/arcade_game_controller.dart';
import '../painters/arcade_car_painter.dart';
import '../painters/arcade_obstacle_painter.dart';
import '../painters/arcade_particle_painter.dart';
import '../painters/arcade_road_painter.dart';
import '../widgets/arcade_game_over_dialog.dart';
import '../widgets/arcade_hud.dart';
import '../widgets/arcade_pause_dialog.dart';
import '../widgets/arcade_touch_controls.dart';

/// Fullscreen arcade driving game screen executing Flutter-only physics and rendering.
class ArcadeGameScreen extends StatefulWidget {
  const ArcadeGameScreen({super.key});

  @override
  State<ArcadeGameScreen> createState() => _ArcadeGameScreenState();
}

class _ArcadeGameScreenState extends State<ArcadeGameScreen> {
  late final ArcadeGameController _controller;
  bool _initialized = false;
  final math.Random _shakeRandom = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = ArcadeGameController();
    _controller.addListener(_onControllerTick);
  }

  void _onControllerTick() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final size = MediaQuery.of(context).size;
      _controller.init(width: size.width, height: size.height);
      _initialized = true;
    } else {
      final size = MediaQuery.of(context).size;
      _controller.updateDimensions(size.width, size.height);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerTick);
    _controller.dispose();
    super.dispose();
  }

  Offset _computeScreenShake() {
    final intensity = _controller.state.screenShakeIntensity;
    if (intensity <= 0.0) return Offset.zero;

    final maxOffset = intensity * 12.0;
    return Offset(
      (_shakeRandom.nextDouble() * 2.0 - 1.0) * maxOffset,
      (_shakeRandom.nextDouble() * 2.0 - 1.0) * maxOffset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shakeOffset = _computeScreenShake();
    final status = _controller.state.status;

    return PopScope(
      canPop: status != ArcadeGameStatus.playing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && status == ArcadeGameStatus.playing) {
          _controller.togglePause();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // 1. Shaking Game Canvas Viewport
            Transform.translate(
              offset: shakeOffset,
              child: SizedBox.expand(
                child: CustomPaint(
                  painter: ArcadeRoadPainter(
                    scrollOffset: _controller.roadScrollOffset,
                    playerSpeedMph: _controller.player.speedMph,
                  ),
                  foregroundPainter: null,
                  child: Stack(
                    children: [
                      // Obstacles
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ArcadeObstaclePainter(
                            obstacles: _controller.obstacles,
                          ),
                        ),
                      ),

                      // Player Supercar
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ArcadeCarPainter(
                            player: _controller.player,
                          ),
                        ),
                      ),

                      // Sparks and Speed Lines
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ArcadeParticlePainter(
                            particles: _controller.particles,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Heads-Up Display (Score, Speedometer, Hull, Distance, Pause)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ArcadeHud(
                player: _controller.player,
                state: _controller.state,
                onPausePressed: () {
                  HapticFeedback.lightImpact();
                  _controller.togglePause();
                },
              ),
            ),

            // 3. Ergonomic Touch Controls (Steering, Gas, Brake)
            if (status == ArcadeGameStatus.playing)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ArcadeTouchControls(
                  onSteerChanged: _controller.setSteer,
                  onThrottleChanged: _controller.setThrottle,
                  onBrakeChanged: _controller.setBrake,
                ),
              ),

            // 4. Paused Modal Dialog Overlay
            if (status == ArcadeGameStatus.paused)
              Positioned.fill(
                child: ArcadePauseDialog(
                  onResume: () {
                    HapticFeedback.lightImpact();
                    _controller.togglePause();
                  },
                  onRestart: () {
                    HapticFeedback.mediumImpact();
                    _controller.restart();
                  },
                  onExit: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),

            // 5. Game Over Modal Dialog Overlay
            if (status == ArcadeGameStatus.gameOver)
              Positioned.fill(
                child: ArcadeGameOverDialog(
                  state: _controller.state,
                  player: _controller.player,
                  onRestart: () {
                    HapticFeedback.heavyImpact();
                    _controller.restart();
                  },
                  onExit: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
