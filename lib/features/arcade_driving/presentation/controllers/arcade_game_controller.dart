import 'package:flutter/scheduler.dart';
import '../../domain/game_engine/arcade_game_engine.dart';
import '../../domain/models/arcade_game_state.dart';
import '../../domain/models/game_particle.dart';
import '../../domain/models/obstacle_vehicle.dart';
import '../../domain/models/player_car.dart';

/// Presentation controller bridging the Flutter UI to the ArcadeGameEngine loop.
class ArcadeGameController extends TickerProvider {
  final ArcadeGameEngine engine = ArcadeGameEngine();
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  // Viewport dimensions
  double screenWidth = 390.0;
  double screenHeight = 844.0;

  // Listeners
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  // Getters
  PlayerCar get player => engine.player;
  ArcadeGameState get state => engine.state;
  List<ObstacleVehicle> get obstacles => engine.obstacles;
  List<GameParticle> get particles => engine.particles;
  double get roadScrollOffset => engine.roadScrollOffset;

  /// Initializes the ticker and starts the simulation
  void init({required double width, required double height}) {
    screenWidth = width;
    screenHeight = height;
    _lastTick = Duration.zero;

    _ticker?.dispose();
    _ticker = createTicker(_onTick);
    _ticker!.start();

    engine.start();
    _notifyListeners();
  }

  void updateDimensions(double width, double height) {
    screenWidth = width;
    screenHeight = height;
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }

    final dt = (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;

    // Clamp dt to prevent huge leaps if frame dropped
    final clampedDt = dt.clamp(0.001, 0.05);

    engine.tick(clampedDt, screenWidth, screenHeight);
    _notifyListeners();
  }

  // Controls
  void setSteer(double value) {
    engine.player.steerInput = value.clamp(-1.0, 1.0);
  }

  void setThrottle(bool isPressed) {
    engine.player.isAccelerating = isPressed;
  }

  void setBrake(bool isPressed) {
    engine.player.isBraking = isPressed;
  }

  void togglePause() {
    if (engine.state.status == ArcadeGameStatus.playing) {
      engine.pause();
    } else if (engine.state.status == ArcadeGameStatus.paused) {
      engine.resume();
    }
    _notifyListeners();
  }

  void restart() {
    _lastTick = Duration.zero;
    engine.reset();
    engine.start();
    _notifyListeners();
  }

  void dispose() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
    _listeners.clear();
  }

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
