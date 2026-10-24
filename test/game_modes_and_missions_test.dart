import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tesla_roadster_game/core/storage/player_data_storage.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/game_engine/arcade_game_engine.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/arcade_game_state.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/game_mode.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/obstacle_vehicle.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/player_car.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/controllers/arcade_game_controller.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/widgets/arcade_game_over_dialog.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/widgets/arcade_hud.dart';
import 'package:tesla_roadster_game/features/home/presentation/widgets/game_mode_selector.dart';
import 'package:tesla_roadster_game/features/missions/domain/models/mission_definition.dart';
import 'package:tesla_roadster_game/features/missions/presentation/widgets/missions_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 09: Game Modes & Info Definitions', () {
    test('GameModeInfo provides correct metadata for Endless Drive and Time Trial', () {
      final endlessInfo = GameModeInfo.getByMode(GameMode.endlessDrive);
      expect(endlessInfo.title, equals('ENDLESS DRIVE'));
      expect(endlessInfo.defaultTimeLimitSeconds, equals(0.0));

      final timeTrialInfo = GameModeInfo.getByMode(GameMode.timeTrial);
      expect(timeTrialInfo.shortTitle, equals('TIME TRIAL'));
      expect(timeTrialInfo.defaultTimeLimitSeconds, equals(60.0));
      expect(timeTrialInfo.nearMissBonusSeconds, equals(1.5));
    });
  });

  group('Feature 09: Mission Definition & Satisfaction Logic', () {
    test('MissionDefinition.allMissions has 8 unique missions with valid reward points', () {
      expect(MissionDefinition.allMissions.length, equals(8));
      final ids = MissionDefinition.allMissions.map((m) => m.id).toSet();
      expect(ids.length, equals(8));
      for (final m in MissionDefinition.allMissions) {
        expect(m.rewardPoints, greaterThan(0));
        expect(m.targetValue, greaterThan(0));
      }
    });

    test('Distance mission evaluates satisfaction and computes normalized progress', () {
      final mission = MissionDefinition.getById('first_launch')!;
      expect(mission.type, equals(MissionType.distance));
      expect(mission.targetValue, equals(500.0));

      final state = ArcadeGameState();
      final player = PlayerCar();

      state.distanceMeters = 250.0;
      expect(mission.isSatisfied(state: state, player: player), isFalse);
      expect(mission.computeProgress(state: state, player: player), closeTo(0.5, 0.01));
      expect(
        mission.formatProgressText(state: state, player: player, isCompleted: false),
        equals('250m / 500m'),
      );

      state.distanceMeters = 500.0;
      expect(mission.isSatisfied(state: state, player: player), isTrue);
      state.distanceMeters = 700.0;
      expect(mission.computeProgress(state: state, player: player), equals(1.0));
    });

    test('Speed mission satisfies only when target velocity is met or exceeded', () {
      final mission = MissionDefinition.getById('velocity_breaker')!;
      expect(mission.type, equals(MissionType.speed));
      expect(mission.targetValue, equals(170.0));

      final state = ArcadeGameState();
      final player = PlayerCar();

      player.speedMph = 140.0;
      expect(mission.isSatisfied(state: state, player: player), isFalse);

      player.speedMph = 175.0;
      expect(mission.isSatisfied(state: state, player: player), isTrue);
    });

    test('Clean drive mission fails if collisions occur even if distance is reached', () {
      final mission = MissionDefinition.getById('ghost_drift')!;
      expect(mission.type, equals(MissionType.cleanDrive));
      expect(mission.targetValue, equals(400.0));

      final state = ArcadeGameState();
      final player = PlayerCar();

      // Reached distance with 0 collisions -> satisfied
      state.distanceMeters = 450.0;
      state.collisionsCount = 0;
      expect(mission.isSatisfied(state: state, player: player), isTrue);

      // Reached distance but had 1 collision -> NOT satisfied
      state.collisionsCount = 1;
      expect(mission.isSatisfied(state: state, player: player), isFalse);

      // Collisions count > 0 shows FAILED progress text
      expect(
        mission.formatProgressText(state: state, player: player, isCompleted: false),
        equals('FAILED (Impact detected)'),
      );
    });

    test('Survival duration and near misses missions evaluate correctly', () {
      final state = ArcadeGameState();
      final player = PlayerCar();

      final survival = MissionDefinition.getById('endurance_test')!;
      expect(survival.type, equals(MissionType.survivalDuration));
      state.timeElapsedSeconds = 35.0;
      expect(survival.isSatisfied(state: state, player: player), isFalse);
      state.timeElapsedSeconds = 41.0;
      expect(survival.isSatisfied(state: state, player: player), isTrue);

      final nearMiss = MissionDefinition.getById('hazard_slicer')!;
      expect(nearMiss.type, equals(MissionType.nearMisses));
      state.nearMissCount = 2;
      expect(nearMiss.isSatisfied(state: state, player: player), isFalse);
      state.nearMissCount = 4;
      expect(nearMiss.isSatisfied(state: state, player: player), isTrue);
    });

    test('Time Trial distance mission requires Time Trial mode', () {
      final chrono = MissionDefinition.getById('chrono_sprinter')!;
      expect(chrono.type, equals(MissionType.timeTrialDistance));
      expect(chrono.targetValue, equals(800.0));

      final state = ArcadeGameState();
      final player = PlayerCar();

      // Endless mode reaching 900m -> Not satisfied
      state.gameMode = GameMode.endlessDrive;
      state.distanceMeters = 900.0;
      expect(chrono.isSatisfied(state: state, player: player), isFalse);

      // Time Trial mode reaching 800m -> Satisfied
      state.gameMode = GameMode.timeTrial;
      state.distanceMeters = 800.0;
      expect(chrono.isSatisfied(state: state, player: player), isTrue);
    });
  });

  group('Feature 09: Storage & Progression Persistence', () {
    late InMemoryPlayerDataStorage storage;

    setUp(() {
      storage = InMemoryPlayerDataStorage();
    });

    test('CareerData default values include Time Trial records, 0 missions and 0 points', () async {
      final career = await storage.loadCareerData();
      expect(career.timeTrialBestDistanceMeters, equals(0.0));
      expect(career.completedMissionIds, isEmpty);
      expect(career.totalRewardPoints, equals(0));
      expect(career.selectedGameMode, equals('endless'));
    });

    test('saveGameMode persists selected mode', () async {
      await storage.saveGameMode('time_trial');
      final career = await storage.loadCareerData();
      expect(career.selectedGameMode, equals('time_trial'));
    });

    test('completeMission awards points once and prevents duplicate rewards', () async {
      final mission = MissionDefinition.allMissions.first;
      final reward = mission.rewardPoints;

      // First completion
      final updated1 = await storage.completeMission(
        missionId: mission.id,
        rewardPoints: reward,
      );
      expect(updated1, isTrue);
      final career1 = await storage.loadCareerData();
      expect(career1.completedMissionIds, contains(mission.id));
      expect(career1.totalRewardPoints, equals(reward));

      // Second completion attempt for the same mission
      final updated2 = await storage.completeMission(
        missionId: mission.id,
        rewardPoints: reward,
      );
      expect(updated2, isFalse);
      final career2 = await storage.loadCareerData();
      expect(career2.completedMissionIds.length, equals(1));
      expect(career2.totalRewardPoints, equals(reward)); // Points not duplicated
    });

    test('recordSession tracks Time Trial distance separately from Endless high distance', () async {
      await storage.recordSession(
        score: 1500,
        distanceMeters: 3200.0,
        topSpeedMph: 140.0,
        sectorsCleared: 4,
        gameMode: 'time_trial',
        timeTrialDistance: 3200.0,
      );

      final career = await storage.loadCareerData();
      expect(career.timeTrialBestDistanceMeters, equals(3200.0));
      expect(career.bestDistanceMeters, equals(3200.0));
      expect(career.highScore, equals(1500));
    });

    test('PlayerCareerData copyWith preserves and updates state accurately', () {
      final original = const PlayerCareerData(
        highScore: 2400,
        bestDistanceMeters: 5500.0,
        topSpeedMph: 185.0,
        totalRaces: 12,
        sectorsCleared: 5,
        timeTrialBestDistanceMeters: 2800.0,
        completedMissionIds: {'first_launch', 'ghost_drift'},
        totalRewardPoints: 1250,
        selectedGameMode: 'time_trial',
      );

      final modified = original.copyWith(
        totalRewardPoints: 2250,
        timeTrialBestDistanceMeters: 3100.0,
      );

      expect(modified.highScore, equals(2400));
      expect(modified.timeTrialBestDistanceMeters, equals(3100.0));
      expect(modified.completedMissionIds, equals({'first_launch', 'ghost_drift'}));
      expect(modified.totalRewardPoints, equals(2250));
      expect(modified.selectedGameMode, equals('time_trial'));
    });
  });

  group('Feature 09: ArcadeGameEngine Game Mode Execution & Mechanics', () {
    late ArcadeGameEngine engine;

    setUp(() {
      engine = ArcadeGameEngine();
    });

    test('Endless Drive mode initializes with default time remaining and standard behavior', () {
      engine.start(mode: GameMode.endlessDrive);
      expect(engine.state.gameMode, equals(GameMode.endlessDrive));
      expect(engine.state.timeRemainingSeconds, equals(0.0));
      expect(engine.state.nearMissCount, equals(0));

      engine.tick(1.0, 400.0, 800.0);
      expect(engine.state.timeRemainingSeconds, equals(0.0));
      expect(engine.state.timeElapsedSeconds, closeTo(1.0, 0.01));
      expect(engine.state.status, equals(ArcadeGameStatus.playing));
    });

    test('Time Trial mode starts with 60.0s and expires at zero with gameOverReason', () {
      engine.start(mode: GameMode.timeTrial);
      expect(engine.state.gameMode, equals(GameMode.timeTrial));
      expect(engine.state.timeRemainingSeconds, equals(60.0));

      // Tick 10 seconds
      engine.tick(10.0, 400.0, 800.0);
      expect(engine.state.timeRemainingSeconds, closeTo(50.0, 0.01));
      expect(engine.state.status, equals(ArcadeGameStatus.playing));

      // Tick remaining 51 seconds to expire timer
      engine.tick(51.0, 400.0, 800.0);
      expect(engine.state.timeRemainingSeconds, equals(0.0));
      expect(engine.state.status, equals(ArcadeGameStatus.gameOver));
      expect(engine.state.gameOverReason, equals('TIME EXPIRED'));
    });

    test('Near-miss overtaking awards bonus time in Time Trial and increments count', () {
      engine.start(mode: GameMode.timeTrial);
      final initialTime = engine.state.timeRemainingSeconds;

      // Position player car at center
      engine.player.lanePosition = 0.0;
      engine.player.speedMph = 100.0;

      // Spawn an obstacle in near-miss zone (yProgress 0.91)
      final obstacle = ObstacleVehicle(
        id: 'obs_test_1',
        type: ObstacleType.cyberSedan,
        color: const Color(0xFF00E5FF),
        lanePosition: 0.35,
        yProgress: 0.91,
        speedMph: 40.0,
      );
      engine.obstacles.add(obstacle);

      // Tick a small step
      engine.tick(0.01, 400.0, 800.0);

      expect(engine.state.nearMissCount, equals(1));
      expect(obstacle.hasAwardedNearMiss, isTrue);
      expect(engine.state.bonusTimeFlashTimer, closeTo(1.0, 0.1));
      // Time remaining increased by 1.5s minus elapsed time (0.01s)
      expect(engine.state.timeRemainingSeconds, greaterThan(initialTime));

      // Subsequent tick on same vehicle does NOT re-trigger near-miss
      final countBefore = engine.state.nearMissCount;
      engine.tick(0.01, 400.0, 800.0);
      expect(engine.state.nearMissCount, equals(countBefore));
    });

    test('Vehicle critical damage sets gameOverReason to VEHICLE CRITICAL DAMAGE', () {
      engine.start(mode: GameMode.endlessDrive);
      engine.player.health = 0.0; // Critical damage

      engine.tick(0.05, 400.0, 800.0);
      expect(engine.state.status, equals(ArcadeGameStatus.gameOver));
      expect(engine.state.gameOverReason, equals('VEHICLE CRITICAL DAMAGE'));
    });
  });

  group('Feature 09: ArcadeGameController Real-Time Mission Evaluation', () {
    late InMemoryPlayerDataStorage storage;
    late ArcadeGameController controller;

    setUp(() {
      storage = InMemoryPlayerDataStorage();
      PlayerDataService.instance = storage;
      controller = ArcadeGameController();
      controller.init(width: 400.0, height: 800.0, mode: GameMode.endlessDrive);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Detects completed distance mission and shows toast for 3 seconds', () async {
      expect(controller.newlyCompletedMissions, isEmpty);
      expect(controller.activeToastMission, isNull);

      // Force distance to 600m (satisfies first_launch target 500m & ghost_drift 400m clean drive)
      controller.engine.state.distanceMeters = 600.0;

      // Evaluate missions
      controller.evaluateMissionsForTesting(0.1);

      expect(controller.newlyCompletedMissions.length, equals(2));
      expect(controller.newlyCompletedMissions.map((m) => m.id), containsAll(['first_launch', 'ghost_drift']));
      expect(controller.activeToastMission, isNotNull);

      // Verify immediate persistence in storage
      final career = await storage.loadCareerData();
      expect(career.completedMissionIds, contains('first_launch'));
      expect(career.totalRewardPoints, equals(3000)); // 1000 + 2000

      // Tick 3.5 seconds to expire toast
      controller.evaluateMissionsForTesting(3.5);
      expect(controller.activeToastMission, isNull);
    });
  });

  group('Feature 09: UI Widget Tests', () {
    late InMemoryPlayerDataStorage storage;

    setUp(() {
      storage = InMemoryPlayerDataStorage();
      PlayerDataService.instance = storage;
    });

    testWidgets('GameModeSelector displays current mode, toggles, and opens MissionsSheet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      GameMode? switchedMode;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: GameModeSelector(
                onModeChanged: (newMode) {
                  switchedMode = newMode;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially Endless Drive is selected
      expect(find.text('ENDLESS DRIVE'), findsWidgets);
      expect(find.text('TIME TRIAL'), findsWidgets);
      expect(find.textContaining('MISSIONS'), findsOneWidget);

      // Tap Time Trial
      await tester.tap(find.text('TIME TRIAL'));
      await tester.pumpAndSettle();
      expect(switchedMode, equals(GameMode.timeTrial));

      // Tap Missions button to open bottom sheet
      await tester.tap(find.textContaining('MISSIONS'));
      await tester.pumpAndSettle();

      // Verify modal sheet appears with mission titles
      expect(find.text('CAREER MISSIONS & CHALLENGES'), findsOneWidget);
      expect(find.text('FIRST LAUNCH'), findsOneWidget);
      expect(find.text('VELOCITY BREAKER'), findsOneWidget);
    });

    testWidgets('MissionsSheet displays completed vs in-progress states',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Mark one mission as completed in storage
      await storage.completeMission(
        missionId: 'first_launch',
        rewardPoints: 1000,
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => MissionsSheet.show(context),
                  child: const Text('OPEN'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      // Check summary stats
      expect(find.text('1 / 8'), findsOneWidget);
      expect(find.text('CLAIMED'), findsOneWidget);
      expect(find.text('INCOMPLETE'), findsWidgets);
    });

    testWidgets('ArcadeHud displays Time Trial timer and mission completed toast',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final state = ArcadeGameState();
      state.gameMode = GameMode.timeTrial;
      state.timeRemainingSeconds = 48.2;
      final player = PlayerCar();
      final completedMission = MissionDefinition.allMissions.first;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: ArcadeHud(
                state: state,
                player: player,
                onPausePressed: () {},
                activeToastMission: completedMission,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify Time Trial timer banner is rendered
      expect(find.byKey(const Key('hud_time_trial_timer')), findsOneWidget);
      expect(find.textContaining('TIME REMAINING: 48.2s'), findsOneWidget);

      // Verify mission completed toast is rendered
      expect(find.byKey(const Key('hud_mission_completed_toast')), findsOneWidget);
      expect(find.textContaining('MISSION COMPLETED:'), findsOneWidget);
      expect(find.textContaining(completedMission.title), findsOneWidget);
    });

    testWidgets('ArcadeGameOverDialog displays mode-specific details and newly completed missions',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final state = ArcadeGameState();
      state.gameMode = GameMode.timeTrial;
      state.distanceMeters = 2450.0;
      state.score = 3800;
      state.timeElapsedSeconds = 64.5;
      state.gameOverReason = 'TIME EXPIRED';
      final player = PlayerCar()..health = 0.8; // Survived without fatal crash
      final completedMission = MissionDefinition.allMissions.first;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: ArcadeGameOverDialog(
                state: state,
                player: player,
                newlyCompletedMissions: [completedMission],
                onRestart: () {},
                onExit: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Title should be TIME TRIAL RESULTS because health > 0 and isTimeTrial
      expect(find.text('TIME TRIAL RESULTS'), findsOneWidget);
      expect(find.text('TIME EXPIRED'), findsOneWidget);

      // Verify newly completed missions section
      expect(find.byKey(const Key('game_over_completed_missions_list')), findsOneWidget);
      expect(find.text('MISSION COMPLETED!'), findsOneWidget);
      expect(find.text(completedMission.title.toUpperCase()), findsOneWidget);
      expect(find.text('+${completedMission.rewardPoints} PTS'), findsOneWidget);
    });
  });
}
