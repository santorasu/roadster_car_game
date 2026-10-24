import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/storage/player_data_storage.dart';
import '../../domain/game_engine/arcade_game_engine.dart';
import '../../domain/models/arcade_game_state.dart';
import '../../domain/models/game_particle.dart';
import '../../domain/models/obstacle_vehicle.dart';
import '../../domain/models/player_car.dart';
import '../../../garage/domain/models/vehicle_definition.dart';

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

  List<String> newlyUnlockedMilestones = [];
  bool _isGameOverRecorded = false;

  /// Initializes the ticker and starts the simulation
  void init({required double width, required double height}) {
    screenWidth = width;
    screenHeight = height;
    _lastTick = Duration.zero;
    _isGameOverRecorded = false;
    newlyUnlockedMilestones.clear();

    _loadCareerData();

    _ticker?.dispose();
    _ticker = createTicker(_onTick);
    _ticker!.start();

    engine.start();
    _notifyListeners();
  }

  void _loadCareerData() {
    PlayerDataService.instance.loadCareerData().then((careerData) {
      if (careerData.highScore > state.highScore) {
        state.highScore = careerData.highScore;
      }
      engine.player.customization = VehicleCustomization(
        vehicleId: careerData.selectedVehicleId,
        paintColorId: careerData.selectedPaintColorId,
        wheelStyleId: careerData.selectedWheelStyleId,
        underglowColorId: careerData.selectedUnderglowColorId,
      );
      _notifyListeners();
    }).catchError((_) {});
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

    final wasGameOver = engine.state.status == ArcadeGameStatus.gameOver;
    engine.tick(clampedDt, screenWidth, screenHeight);
    final isGameOverNow = engine.state.status == ArcadeGameStatus.gameOver;

    if (!wasGameOver && isGameOverNow && !_isGameOverRecorded) {
      _isGameOverRecorded = true;
      _recordGameOver();
    }

    _notifyListeners();
  }

  Future<void> _recordGameOver() async {
    try {
      final unlocked = await PlayerDataService.instance.recordSession(
        score: state.score,
        distanceMeters: state.distanceMeters,
        topSpeedMph: state.topSpeedMph,
        sectorsCleared: state.sectorIndex,
      );
      newlyUnlockedMilestones = unlocked;
      _notifyListeners();
    } catch (e) {
      debugPrint('ArcadeGameController: Record game over error: $e');
    }
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
    _isGameOverRecorded = false;
    newlyUnlockedMilestones.clear();
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
