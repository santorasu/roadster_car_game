import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/audio/game_audio_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/arcade_game_state.dart';
import '../../domain/models/game_mode.dart';
import '../controllers/arcade_game_controller.dart';
import '../painters/arcade_car_painter.dart';
import '../painters/arcade_obstacle_painter.dart';
import '../painters/arcade_particle_painter.dart';
import '../painters/arcade_road_painter.dart';
import '../widgets/arcade_game_over_dialog.dart';
import '../widgets/arcade_hud.dart';
import '../widgets/arcade_pause_dialog.dart';
import '../widgets/arcade_touch_controls.dart';

/// Fullscreen arcade driving game screen executing Flutter-only physics and rendering,
/// integrated with dynamic electric audio modulation, collision FX, and lifecycle management.
class ArcadeGameScreen extends StatefulWidget {
  final GameMode? initialMode;

  const ArcadeGameScreen({
    super.key,
    this.initialMode,
  });

  @override
  State<ArcadeGameScreen> createState() => _ArcadeGameScreenState();
}

class _ArcadeGameScreenState extends State<ArcadeGameScreen> with WidgetsBindingObserver {
  late final ArcadeGameController _controller;
  bool _initialized = false;
  final math.Random _shakeRandom = math.Random();
  int _lastCollisionsCount = 0;
  ArcadeGameStatus _lastStatus = ArcadeGameStatus.playing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = ArcadeGameController();
    _controller.addListener(_onControllerTick);
    _lastCollisionsCount = _controller.state.collisionsCount;
    _lastStatus = _controller.state.status;

    // Start background cyber drive music
    GameAudioService.instance.startBgm();
  }

  void _onControllerTick() {
    final status = _controller.state.status;

    if (status == ArcadeGameStatus.playing) {
      // Dynamic audio feedback: Check for collision impact
      if (_controller.state.collisionsCount > _lastCollisionsCount) {
        GameAudioService.instance.playCollision();
        _lastCollisionsCount = _controller.state.collisionsCount;
      }

      // Check for road boundary friction sparks
      if (_controller.player.isAtRoadBoundary) {
        GameAudioService.instance.playVergeSpark();
      }

      // Modulate electric motor pitch and throttle sound
      GameAudioService.instance.updateEngineSound(
        speedMph: _controller.player.speedMph,
        isAccelerating: _controller.player.isAccelerating,
        isBraking: _controller.player.isBraking,
      );
    } else if (status == ArcadeGameStatus.gameOver && _lastStatus != ArcadeGameStatus.gameOver) {
      GameAudioService.instance.stopEngineSound();
    }

    _lastStatus = status;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    GameAudioService.instance.handleLifecycleChange(state);
    if (state == AppLifecycleState.paused && _controller.state.status == ArcadeGameStatus.playing) {
      _controller.togglePause();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final size = MediaQuery.of(context).size;
      _controller.init(
        width: size.width,
        height: size.height,
        mode: widget.initialMode,
      );
      _initialized = true;
    } else {
      final size = MediaQuery.of(context).size;
      _controller.updateDimensions(size.width, size.height);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onControllerTick);
    _controller.dispose();

    // Clean up audio streams
    GameAudioService.instance.stopBgm();
    GameAudioService.instance.stopEngineSound();

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

  void _handlePauseToggle() {
    HapticFeedback.lightImpact();
    GameAudioService.instance.playUiTap();
    final wasPlaying = _controller.state.status == ArcadeGameStatus.playing;
    _controller.togglePause();
    if (wasPlaying) {
      GameAudioService.instance.pauseAll();
    } else {
      GameAudioService.instance.resumeAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shakeOffset = _computeScreenShake();
    final status = _controller.state.status;

    return PopScope(
      canPop: status != ArcadeGameStatus.playing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && status == ArcadeGameStatus.playing) {
          _handlePauseToggle();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // 1. Shaking Game Canvas Viewport wrapped in RepaintBoundary for 60 FPS performance
            RepaintBoundary(
              child: Transform.translate(
                offset: shakeOffset,
                child: SizedBox.expand(
                  child: CustomPaint(
                    painter: ArcadeRoadPainter(
                      scrollOffset: _controller.roadScrollOffset,
                      playerSpeedMph: _controller.player.speedMph,
                      curveOffset: _controller.state.currentCurvature,
                      elevationOffset: _controller.state.currentElevation,
                    ),
                    foregroundPainter: null,
                    child: Stack(
                      children: [
                        // Obstacles
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ArcadeObstaclePainter(
                              obstacles: _controller.obstacles,
                              curveOffset: _controller.state.currentCurvature,
                              elevationOffset: _controller.state.currentElevation,
                            ),
                          ),
                        ),

                        // Player Supercar
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ArcadeCarPainter(
                              player: _controller.player,
                              curveOffset: _controller.state.currentCurvature,
                              elevationOffset: _controller.state.currentElevation,
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
            ),

            // 2. Heads-Up Display (Score, Speedometer, Hull, Distance, Audio, Pause, Mission Toast)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: RepaintBoundary(
                child: ArcadeHud(
                  player: _controller.player,
                  state: _controller.state,
                  activeToastMission: _controller.activeToastMission,
                  onPausePressed: _handlePauseToggle,
                ),
              ),
            ),

            // 3. Ergonomic Multi-Touch Controls (Steering, Gas, Brake)
            if (status == ArcadeGameStatus.playing)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: RepaintBoundary(
                  child: ArcadeTouchControls(
                    onSteerChanged: _controller.setSteer,
                    onThrottleChanged: _controller.setThrottle,
                    onBrakeChanged: _controller.setBrake,
                  ),
                ),
              ),


            // 4. Paused Modal Dialog Overlay
            if (status == ArcadeGameStatus.paused)
              Positioned.fill(
                child: ArcadePauseDialog(
                  onResume: _handlePauseToggle,
                  onRestart: () {
                    HapticFeedback.mediumImpact();
                    GameAudioService.instance.playUiTap();
                    _controller.restart(mode: widget.initialMode ?? _controller.state.gameMode);
                    _lastCollisionsCount = 0;
                    GameAudioService.instance.resumeAll();
                  },
                  onExit: () {
                    GameAudioService.instance.playUiTap();
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
                  newlyUnlockedMilestones: _controller.newlyUnlockedMilestones,
                  newlyCompletedMissions: _controller.newlyCompletedMissions,
                  onRestart: () {
                    HapticFeedback.heavyImpact();
                    GameAudioService.instance.playUiTap();
                    _controller.restart(mode: widget.initialMode ?? _controller.state.gameMode);
                    _lastCollisionsCount = 0;
                    GameAudioService.instance.resumeAll();
                  },
                  onExit: () {
                    GameAudioService.instance.playUiTap();
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
