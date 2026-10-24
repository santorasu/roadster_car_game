import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tesla_roadster_game/core/audio/game_audio_service.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/game_engine/arcade_game_engine.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/arcade_game_state.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/game_mode.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/obstacle_vehicle.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/widgets/arcade_hud.dart';
import 'package:tesla_roadster_game/features/missions/domain/models/mission_definition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GameAudioService.instance.isTestMode = true;

  group('Feature 10: Traffic Behavior & AI Archetypes', () {
    test('Default behaviors assigned appropriately to vehicle types', () {
      expect(
        ObstacleVehicle.defaultBehaviorForType(ObstacleType.energyBarrier),
        equals(TrafficBehavior.hazard),
      );
      expect(
        ObstacleVehicle.defaultBehaviorForType(ObstacleType.heavyHauler),
        equals(TrafficBehavior.cruiser),
      );
      expect(
        ObstacleVehicle.defaultBehaviorForType(ObstacleType.cyberTruck),
        equals(TrafficBehavior.speedAdjuster),
      );
      expect(
        ObstacleVehicle.defaultBehaviorForType(ObstacleType.cyberSedan),
        equals(TrafficBehavior.laneChanger),
      );
    });

    test('Lane change performs smooth non-linear interpolation and completes accurately', () {
      final vehicle = ObstacleVehicle(
        id: 'test_changer',
        type: ObstacleType.cyberSedan,
        color: const Color(0xFF00E5FF),
        lanePosition: 0.0,
        yProgress: 0.4,
        speedMph: 60.0,
        behavior: TrafficBehavior.laneChanger,
      );

      // Manually trigger a lane change to right lane (0.65)
      vehicle.initialLanePosition = 0.0;
      vehicle.targetLanePosition = 0.65;
      vehicle.laneChangeProgress = 0.0;
      vehicle.laneChangeDuration = 1.0;
      vehicle.laneChangeDirection = 1;

      expect(vehicle.isChangingLane, isTrue);

      // Step 0.5s (halfway through transition)
      vehicle.updateAI(0.5, [vehicle], [-0.65, 0.0, 0.65], 0.0, 100.0);
      expect(vehicle.isChangingLane, isTrue);
      // Smoothstep at t=0.5: 0.5 * 0.5 * (3 - 2 * 0.5) = 0.25 * 2.0 = 0.5
      expect(vehicle.lanePosition, closeTo(0.325, 0.02));

      // Step another 0.6s (completing the transition past 1.0)
      vehicle.updateAI(0.6, [vehicle], [-0.65, 0.0, 0.65], 0.0, 100.0);
      expect(vehicle.isChangingLane, isFalse);
      expect(vehicle.lanePosition, equals(0.65));
      expect(vehicle.laneChangeProgress, equals(-1.0));
      expect(vehicle.laneChangeDirection, equals(0));
    });

    test('Safe-gap check detects slower lead vehicle ahead in same lane and brakes', () {
      final leadVehicle = ObstacleVehicle(
        id: 'lead',
        type: ObstacleType.heavyHauler,
        color: const Color(0xFF78909C),
        lanePosition: 0.0,
        yProgress: 0.50, // Ahead on road
        speedMph: 35.0,
      );

      final trailingVehicle = ObstacleVehicle(
        id: 'trailer',
        type: ObstacleType.cyberTruck,
        color: const Color(0xFFFFB300),
        lanePosition: 0.0,
        yProgress: 0.42, // Behind lead vehicle (gap = 0.08 < safeGapY 0.14)
        speedMph: 65.0,
        desiredSpeedMph: 65.0,
        behavior: TrafficBehavior.speedAdjuster,
      );

      final obstacles = [leadVehicle, trailingVehicle];
      expect(trailingVehicle.isBraking, isFalse);

      // Update AI
      trailingVehicle.updateAI(0.2, obstacles, [-0.65, 0.0, 0.65], -0.65, 100.0);

      // Trailing vehicle should detect lead, activate braking, and reduce speed
      expect(trailingVehicle.isBraking, isTrue);
      expect(trailingVehicle.speedMph, lessThan(65.0));
    });

    test('Safe-gap check aborts lane change if candidate adjacent lane is occupied', () {
      final changer = ObstacleVehicle(
        id: 'changer',
        type: ObstacleType.cyberSedan,
        color: const Color(0xFF00E5FF),
        lanePosition: 0.0,
        yProgress: 0.40,
        speedMph: 60.0,
        behavior: TrafficBehavior.laneChanger,
        laneChangeTimer: 0.05, // Almost ready to change lane
      );

      // Block both left (-0.65) and right (0.65) lanes at the same vertical position
      final blockerLeft = ObstacleVehicle(
        id: 'block_left',
        type: ObstacleType.cyberTruck,
        color: const Color(0xFFFFB300),
        lanePosition: -0.65,
        yProgress: 0.41,
        speedMph: 60.0,
      );
      final blockerRight = ObstacleVehicle(
        id: 'block_right',
        type: ObstacleType.cyberTruck,
        color: const Color(0xFFFFB300),
        lanePosition: 0.65,
        yProgress: 0.39,
        speedMph: 60.0,
      );

      final allObstacles = [changer, blockerLeft, blockerRight];

      // Update AI past timer
      changer.updateAI(0.1, allObstacles, [-0.65, 0.0, 0.65], 0.0, 100.0);

      // Lane change should NOT have initiated because no adjacent lane was safe
      expect(changer.isChangingLane, isFalse);
      expect(changer.lanePosition, equals(0.0));
    });
  });

  group('Feature 10: Near-Miss System & Scoring Integration', () {
    late ArcadeGameEngine engine;

    setUp(() {
      engine = ArcadeGameEngine();
    });

    test('Near-miss awards score, increments count, and activates notification timer', () {
      engine.start(mode: GameMode.endlessDrive);
      engine.player.lanePosition = 0.0;
      engine.player.speedMph = 150.0; // At 150 MPH (>140), combo multiplier is 2.0x
      engine.state.comboMultiplier = 2.0;

      // Spawn vehicle at close lateral distance (0.30) and near-miss depth (0.91)
      final obstacle = ObstacleVehicle(
        id: 'close_pass_1',
        type: ObstacleType.cyberSedan,
        color: const Color(0xFF00E5FF),
        lanePosition: 0.30,
        yProgress: 0.91,
        speedMph: 45.0,
      );
      engine.obstacles.add(obstacle);

      final initialScore = engine.state.score;
      engine.tick(0.01, 400.0, 800.0);

      expect(engine.state.nearMissCount, equals(1));
      expect(obstacle.hasAwardedNearMiss, isTrue);
      // Combo multiplier 2.0 * 250 = 500 bonus points
      expect(engine.state.lastNearMissBonusScore, equals(500));
      expect(engine.state.score, greaterThanOrEqualTo(initialScore + 500));
      expect(engine.state.nearMissNotificationTimer, closeTo(1.2, 0.1));

      // Duplicate protection: ticking again does not re-award near-miss
      final nearMissesAfter = engine.state.nearMissCount;
      engine.tick(0.01, 400.0, 800.0);
      expect(engine.state.nearMissCount, equals(nearMissesAfter));
    });

    test('Far pass across highway lanes does NOT trigger near-miss bonus', () {
      engine.start(mode: GameMode.endlessDrive);
      engine.player.lanePosition = -0.65; // Left lane
      engine.player.speedMph = 100.0;

      // Obstacle far away on right lane (0.65, lateral distance = 1.30 > 0.52)
      final farObstacle = ObstacleVehicle(
        id: 'far_pass',
        type: ObstacleType.cyberSedan,
        color: const Color(0xFF00E5FF),
        lanePosition: 0.65,
        yProgress: 0.91,
        speedMph: 45.0,
      );
      engine.obstacles.add(farObstacle);

      engine.tick(0.01, 400.0, 800.0);

      expect(engine.state.nearMissCount, equals(0));
      expect(farObstacle.hasAwardedNearMiss, isFalse);
      expect(engine.state.nearMissNotificationTimer, equals(0.0));
    });

    test('Time Trial mode extends time limit on near-miss', () {
      engine.start(mode: GameMode.timeTrial);
      final initialTime = engine.state.timeRemainingSeconds;
      engine.player.lanePosition = 0.0;
      engine.player.speedMph = 100.0;

      final obstacle = ObstacleVehicle(
        id: 'time_trial_pass',
        type: ObstacleType.cyberSedan,
        color: const Color(0xFF00E5FF),
        lanePosition: 0.35,
        yProgress: 0.91,
        speedMph: 40.0,
      );
      engine.obstacles.add(obstacle);

      // Tick 0.01s
      engine.tick(0.01, 400.0, 800.0);

      expect(engine.state.nearMissCount, equals(1));
      expect(engine.state.bonusTimeFlashTimer, closeTo(1.0, 0.1));
      // Net time remaining should be extended by roughly 1.5s - 0.01s = +1.49s
      expect(engine.state.timeRemainingSeconds, greaterThan(initialTime));
    });

    test('HAZARD SLICER mission tracks near misses and completes on reaching target', () {
      final mission = MissionDefinition.getById('hazard_slicer')!;
      expect(mission.type, equals(MissionType.nearMisses));
      expect(mission.targetValue, equals(4.0));

      final state = ArcadeGameState();
      final player = engine.player;

      state.nearMissCount = 2;
      expect(mission.isSatisfied(state: state, player: player), isFalse);
      expect(mission.computeProgress(state: state, player: player), closeTo(0.5, 0.01));

      // Reach 4 near misses
      state.nearMissCount = 4;
      expect(mission.isSatisfied(state: state, player: player), isTrue);
      expect(mission.computeProgress(state: state, player: player), equals(1.0));
    });
  });

  group('Feature 10: Arcade HUD Near-Miss Banner Widget Test', () {
    testWidgets('ArcadeHud displays near-miss toast banner when timer is active', (tester) async {
      final engine = ArcadeGameEngine();
      engine.state.nearMissNotificationTimer = 1.0;
      engine.state.lastNearMissBonusScore = 500;
      engine.state.gameMode = GameMode.endlessDrive;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: ArcadeHud(
                player: engine.player,
                state: engine.state,
                onPausePressed: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify the near miss toast is rendered
      expect(find.byKey(const Key('hud_near_miss_toast')), findsOneWidget);
      expect(find.textContaining('⚡ NEAR MISS! +500 PTS'), findsOneWidget);

      // Change to Time Trial mode and verify (+1.5s) bonus is displayed
      engine.state.gameMode = GameMode.timeTrial;
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: ArcadeHud(
                player: engine.player,
                state: engine.state,
                onPausePressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('⚡ NEAR MISS! +500 PTS (+1.5s)'), findsOneWidget);
    });
  });
}
