import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/storage/player_data_storage.dart';
import '../../domain/game_engine/arcade_game_engine.dart';
import '../../domain/models/arcade_game_state.dart';
import '../../domain/models/game_mode.dart';
import '../../domain/models/game_particle.dart';
import '../../domain/models/obstacle_vehicle.dart';
import '../../domain/models/player_car.dart';
import '../../../garage/domain/models/vehicle_definition.dart';
import '../../../missions/domain/models/mission_definition.dart';

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
  GameMode get gameMode => engine.state.gameMode;

  List<String> newlyUnlockedMilestones = [];
  Set<String> completedMissionIdsAtStart = {};
  final List<MissionDefinition> newlyCompletedMissions = [];
  MissionDefinition? activeToastMission;
  double toastTimer = 0.0;

  bool _isGameOverRecorded = false;

  /// Initializes the ticker and starts the simulation
  void init({required double width, required double height, GameMode? mode}) {
    screenWidth = width;
    screenHeight = height;
    _lastTick = Duration.zero;
    _isGameOverRecorded = false;
    newlyUnlockedMilestones.clear();
    newlyCompletedMissions.clear();
    activeToastMission = null;
    toastTimer = 0.0;

    _loadCareerData();

    _ticker?.dispose();
    _ticker = createTicker(_onTick);
    _ticker!.start();

    engine.start(mode: mode);
    _notifyListeners();
  }

  void _loadCareerData() {
    PlayerDataService.instance.loadCareerData().then((careerData) {
      if (careerData.highScore > state.highScore) {
        state.highScore = careerData.highScore;
      }
      completedMissionIdsAtStart = Set<String>.from(careerData.completedMissionIds);
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

    // Mission evaluation during active gameplay
    if (engine.state.status == ArcadeGameStatus.playing) {
      _evaluateMissions(clampedDt);
    }

    if (!wasGameOver && isGameOverNow && !_isGameOverRecorded) {
      _isGameOverRecorded = true;
      _recordGameOver();
    }

    _notifyListeners();
  }

  @visibleForTesting
  void evaluateMissionsForTesting(double dt) => _evaluateMissions(dt);

  void _evaluateMissions(double dt) {
    if (toastTimer > 0.0) {
      toastTimer -= dt;
      if (toastTimer <= 0.0) {
        activeToastMission = null;
      }
    }

    final currentCompletedIds = newlyCompletedMissions.map((m) => m.id).toSet();

    for (final mission in MissionDefinition.allMissions) {
      if (completedMissionIdsAtStart.contains(mission.id) ||
          currentCompletedIds.contains(mission.id)) {
        continue;
      }

      if (mission.isSatisfied(state: state, player: player)) {
        newlyCompletedMissions.add(mission);
        activeToastMission = mission;
        toastTimer = 3.0;

        // Persist immediately to prevent duplicate rewards and guarantee persistence
        PlayerDataService.instance.completeMission(
          missionId: mission.id,
          rewardPoints: mission.rewardPoints,
        );
      }
    }
  }

  Future<void> _recordGameOver() async {
    try {
      final modeStr = state.gameMode == GameMode.timeTrial ? 'time_trial' : 'endless';
      final unlocked = await PlayerDataService.instance.recordSession(
        score: state.score,
        distanceMeters: state.distanceMeters,
        topSpeedMph: state.topSpeedMph,
        sectorsCleared: state.sectorIndex,
        gameMode: modeStr,
        timeTrialDistance: state.distanceMeters,
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

  void restart({GameMode? mode}) {
    _lastTick = Duration.zero;
    _isGameOverRecorded = false;
    newlyUnlockedMilestones.clear();
    newlyCompletedMissions.clear();
    activeToastMission = null;
    toastTimer = 0.0;
    engine.reset(mode: mode ?? engine.state.gameMode);
    engine.start(mode: mode ?? engine.state.gameMode);
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
