import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tesla_roadster_game/core/storage/player_data_storage.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/game_engine/arcade_game_engine.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/arcade_game_state.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/obstacle_vehicle.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/player_car.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/road_section.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/painters/arcade_car_painter.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/painters/arcade_obstacle_painter.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/painters/arcade_road_painter.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/widgets/arcade_game_over_dialog.dart';
import 'package:tesla_roadster_game/features/home/presentation/widgets/career_records_card.dart';

void main() {
  group('Feature 07: Track Elevation & Sector Progression Tests', () {
    late TrackProgressionManager trackManager;

    setUp(() {
      trackManager = TrackProgressionManager();
    });

    test('Default sectors include flat, uphill, downhill, and undulating profiles', () {
      expect(trackManager.sections.length, 7);
      expect(trackManager.sections[0].elevationType, RoadElevationType.flat);
      expect(trackManager.sections[0].targetElevation, 0.0);

      expect(trackManager.sections[1].elevationType, RoadElevationType.gentleUphill);
      expect(trackManager.sections[1].targetElevation, greaterThan(0.0));

      expect(trackManager.sections[2].elevationType, RoadElevationType.gentleDownhill);
      expect(trackManager.sections[2].targetElevation, lessThan(0.0));

      expect(trackManager.sections[3].elevationType, RoadElevationType.steepUphill);
      expect(trackManager.sections[3].targetElevation, greaterThan(0.5));

      expect(trackManager.sections[4].elevationType, RoadElevationType.undulating);
      expect(trackManager.sections[5].elevationType, RoadElevationType.steepUphill);
      expect(trackManager.sections[6].elevationType, RoadElevationType.steepDownhill);
    });

    test('Sector 1 Neon Highway computes 0.0 elevation across straight flatway', () {
      expect(trackManager.computeElevationAt(0.0), 0.0);
      expect(trackManager.computeElevationAt(50.0), 0.0);
      expect(trackManager.computeElevationAt(99.0), 0.0);
    });

    test('Sector 2 Cyber Sweep transitions smoothly into uphill climb and sustains apex', () {
      final sec2 = trackManager.sections[1];
      expect(sec2.startDistanceMeters, 100.0);
      expect(sec2.endDistanceMeters, 400.0);

      // Entry transition (first 18% of 300m = 54m, i.e. 100m to 154m)
      final earlyEntry = trackManager.computeElevationAt(120.0);
      final lateEntry = trackManager.computeElevationAt(145.0);
      expect(earlyEntry, greaterThan(0.0));
      expect(lateEntry, greaterThan(earlyEntry));

      // Sustained apex slope (160m to 340m)
      final apexElevation = trackManager.computeElevationAt(250.0);
      expect(apexElevation, closeTo(sec2.targetElevation, 0.001));

      // Exit transition smoothly returns toward neutral
      final exitElevation = trackManager.computeElevationAt(395.0);
      expect(exitElevation, lessThan(apexElevation));
      expect(exitElevation, greaterThan(0.0));
    });

    test('Sector 5 Data Chicane alternates through undulating crests and dips', () {
      // Data chicane is undulating between 1000m and 1500m
      final midElevation1 = trackManager.computeElevationAt(1125.0); // 25% through section (crest)
      final midElevation2 = trackManager.computeElevationAt(1250.0); // 50% through section (dip)

      // Sine wave should oscillate positive and negative
      expect(midElevation1, greaterThan(0.0));
      expect(midElevation2, lessThan(0.0));
    });

    test('Circuit loops seamlessly past 3,000 meters', () {
      final loop0 = trackManager.computeElevationAt(50.0);
      final loop1 = trackManager.computeElevationAt(3050.0);
      expect(loop0, loop1);

      final sec2Loop0 = trackManager.computeElevationAt(250.0);
      final sec2Loop1 = trackManager.computeElevationAt(3250.0);
      expect(sec2Loop0, closeTo(sec2Loop1, 0.001));
    });
  });

  group('Feature 07: Perspective Road Coordinate & Hitbox Alignment Tests', () {
    test('getRoadY is strictly monotonic for all depth t across elevations', () {
      final painter = ArcadeRoadPainter(
        scrollOffset: 0.0,
        playerSpeedMph: 100.0,
        curveOffset: 0.4,
        elevationOffset: 0.75, // Steep uphill
      );

      const h = 800.0;
      const horizonY = 144.0; // 18% of 800

      double prevY = painter.getRoadY(0.0, h, horizonY);
      for (double t = 0.05; t <= 1.0; t += 0.05) {
        final currentY = painter.getRoadY(t, h, horizonY);
        expect(currentY, greaterThan(prevY), reason: 'Failed monotonicity at t=$t');
        prevY = currentY;
      }
    });

    test('Elevation shifts horizon vanishing point Y and anchors at screen bottom', () {
      const h = 1000.0;
      const horizonY = 180.0;

      final flatPainter = ArcadeRoadPainter(scrollOffset: 0.0, playerSpeedMph: 0.0, elevationOffset: 0.0);
      final uphillPainter = ArcadeRoadPainter(scrollOffset: 0.0, playerSpeedMph: 0.0, elevationOffset: 0.6);
      final downhillPainter = ArcadeRoadPainter(scrollOffset: 0.0, playerSpeedMph: 0.0, elevationOffset: -0.6);

      // At bottom t = 1.0, all painters must anchor identically at h
      expect(flatPainter.getRoadY(1.0, h, horizonY), closeTo(h, 0.001));
      expect(uphillPainter.getRoadY(1.0, h, horizonY), closeTo(h, 0.001));
      expect(downhillPainter.getRoadY(1.0, h, horizonY), closeTo(h, 0.001));

      // At horizon t = 0.0, uphill raises horizon (smaller Y), downhill lowers horizon (larger Y)
      final flatHorizon = flatPainter.getRoadY(0.0, h, horizonY);
      final uphillHorizon = uphillPainter.getRoadY(0.0, h, horizonY);
      final downhillHorizon = downhillPainter.getRoadY(0.0, h, horizonY);

      expect(flatHorizon, horizonY);
      expect(uphillHorizon, lessThan(flatHorizon));
      expect(downhillHorizon, greaterThan(flatHorizon));
    });

    test('PlayerCar and Obstacle bounding rect centers track elevated road coordinates exactly', () {
      final player = PlayerCar();
      final obstacle = ObstacleVehicle(
        id: 'test_obs',
        type: ObstacleType.cyberSedan,
        color: Colors.cyan,
        lanePosition: 0.0,
        yProgress: 0.75,
        speedMph: 60.0,
      );

      const w = 400.0;
      const h = 800.0;

      final flatPlayerRect = player.getBoundingRect(w, h, 0.0, 0.0);
      final uphillPlayerRect = player.getBoundingRect(w, h, 0.0, 0.6);
      final downhillPlayerRect = player.getBoundingRect(w, h, 0.0, -0.6);

      // On uphill, player car center Y is higher (smaller Y)
      expect(uphillPlayerRect.center.dy, lessThan(flatPlayerRect.center.dy));
      // On downhill, player car center Y is lower (larger Y)
      expect(downhillPlayerRect.center.dy, greaterThan(flatPlayerRect.center.dy));

      final flatObsRect = obstacle.getBoundingRect(w, h, 0.0, 0.0);
      final uphillObsRect = obstacle.getBoundingRect(w, h, 0.0, 0.6);
      final downhillObsRect = obstacle.getBoundingRect(w, h, 0.0, -0.6);

      expect(uphillObsRect.center.dy, lessThan(flatObsRect.center.dy));
      expect(downhillObsRect.center.dy, greaterThan(flatObsRect.center.dy));
    });
  });

  group('Feature 07: Elevation Driving Physics Tests', () {
    late ArcadeGameEngine engine;

    setUp(() {
      engine = ArcadeGameEngine();
      engine.start();
    });

    test('Uphill elevation reduces vehicle speed when coasting', () {
      engine.player.speedMph = 100.0;
      engine.player.isAccelerating = false;
      engine.player.isBraking = false;

      // Force uphill slope in state
      engine.state.currentElevation = 0.50;

      // Single tick
      const dt = 0.05;
      final speedBefore = engine.player.speedMph;
      engine.tick(dt, 400, 800);

      expect(engine.player.speedMph, lessThan(speedBefore));
    });

    test('Downhill slope provides gravity acceleration momentum', () {
      engine.player.speedMph = 50.0;
      engine.player.isAccelerating = true;
      engine.player.distanceTraveledMeters = 50.0; // Flat sector 1

      // Flat run tick
      engine.tick(0.05, 400, 800);
      final flatSpeedGain = engine.player.speedMph - 50.0;

      // Reset and run on downhill sector 3 (Grid Connector, 500m)
      engine.player.speedMph = 50.0;
      engine.player.distanceTraveledMeters = 500.0; // Downhill slope
      engine.tick(0.05, 400, 800);
      final downhillSpeedGain = engine.player.speedMph - 50.0;

      expect(downhillSpeedGain, greaterThan(flatSpeedGain));
    });

    test('Stationary vehicle does not roll backward from elevation gravity', () {
      engine.player.speedMph = 0.0;
      engine.player.isAccelerating = false;
      engine.state.currentElevation = 0.70;

      engine.tick(0.05, 400, 800);
      expect(engine.player.speedMph, greaterThanOrEqualTo(0.0));
    });
  });

  group('Feature 07: Player Data Persistence & Milestone Tests', () {
    late InMemoryPlayerDataStorage storage;

    setUp(() {
      storage = InMemoryPlayerDataStorage();
      PlayerDataService.instance = storage;
    });

    test('Initial career data contains clean baseline stats', () async {
      final data = await storage.loadCareerData();
      expect(data.highScore, 0);
      expect(data.bestDistanceMeters, 0.0);
      expect(data.topSpeedMph, 0.0);
      expect(data.totalRaces, 0);
      expect(data.unlockedMilestones.isEmpty, isTrue);
    });

    test('Recording session updates high score, best distance, and unlocks milestones', () async {
      final unlocked = await storage.recordSession(
        score: 30000,
        distanceMeters: 1600.0,
        topSpeedMph: 165.0,
        sectorsCleared: 6,
      );

      final data = await storage.loadCareerData();
      expect(data.highScore, 30000);
      expect(data.bestDistanceMeters, 1600.0);
      expect(data.topSpeedMph, 165.0);
      expect(data.totalRaces, 1);
      expect(data.sectorsCleared, 6);

      // Verify unlocked milestone IDs
      expect(unlocked.contains('initiation'), isTrue);
      expect(unlocked.contains('century'), isTrue);
      expect(unlocked.contains('warp_speed'), isTrue);
      expect(unlocked.contains('endurance'), isTrue);
      expect(unlocked.contains('high_roller'), isTrue);
      expect(unlocked.contains('overpass_climber'), isTrue);

      // Hyperdrive (>200) and Circuit Master (>3000) not unlocked yet
      expect(unlocked.contains('hyperdrive'), isFalse);
      expect(unlocked.contains('circuit_master'), isFalse);
    });

    test('Subsequent session retains existing milestones without duplication', () async {
      await storage.recordSession(
        score: 10000,
        distanceMeters: 500.0,
        topSpeedMph: 110.0,
        sectorsCleared: 2,
      );

      // Second session hitting 220 MPH
      final newlyUnlocked = await storage.recordSession(
        score: 60000,
        distanceMeters: 3200.0,
        topSpeedMph: 225.0,
        sectorsCleared: 7,
      );

      // Only new milestones should be reported as newly unlocked
      expect(newlyUnlocked.contains('initiation'), isFalse);
      expect(newlyUnlocked.contains('century'), isFalse);
      expect(newlyUnlocked.contains('hyperdrive'), isTrue);
      expect(newlyUnlocked.contains('circuit_master'), isTrue);
      expect(newlyUnlocked.contains('cyber_legend'), isTrue);

      final data = await storage.loadCareerData();
      expect(data.highScore, 60000);
      expect(data.bestDistanceMeters, 3200.0);
      expect(data.topSpeedMph, 225.0);
      expect(data.totalRaces, 2);
    });

    test('Audio settings save and restore via PlayerDataStorage', () async {
      await storage.saveAudioSettings(
        masterVolume: 0.50,
        musicVolume: 0.40,
        sfxVolume: 0.70,
        masterMuted: true,
        musicMuted: false,
        sfxMuted: false,
      );

      final data = await storage.loadCareerData();
      expect(data.masterVolume, 0.50);
      expect(data.musicVolume, 0.40);
      expect(data.sfxVolume, 0.70);
      expect(data.masterMuted, isTrue);
    });
  });

  group('Feature 07: Session Summary & Career UI Widget Tests', () {
    late InMemoryPlayerDataStorage mockStorage;

    setUp(() {
      mockStorage = InMemoryPlayerDataStorage(
        const PlayerCareerData(
          highScore: 75000,
          bestDistanceMeters: 2800.0,
          topSpeedMph: 215.0,
          totalRaces: 5,
          sectorsCleared: 28,
          unlockedMilestones: {'initiation', 'century', 'warp_speed'},
        ),
      );
      PlayerDataService.instance = mockStorage;
    });

    testWidgets('ArcadeGameOverDialog displays complete session summary and milestone badges',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final player = PlayerCar()..topSpeedMph = 168.0;
      final state = ArcadeGameState()
        ..score = 38500
        ..highScore = 75000
        ..distanceMeters = 1850.0
        ..comboMultiplier = 2.0
        ..sectorIndex = 6
        ..currentSectorName = 'CIRCUIT OVERPASS';

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: ArcadeGameOverDialog(
                state: state,
                player: player,
                newlyUnlockedMilestones: const ['endurance', 'overpass_climber'],
                onRestart: () {},
                onExit: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify Session Summary Statistics
      expect(find.text('FINAL SCORE'), findsOneWidget);
      expect(find.text('38500'), findsOneWidget);
      expect(find.text('BEST SCORE'), findsOneWidget);
      expect(find.text('75000'), findsOneWidget);
      expect(find.text('DISTANCE'), findsOneWidget);
      expect(find.text('1.85 KM'), findsOneWidget);
      expect(find.text('TOP SPEED'), findsOneWidget);
      expect(find.text('168 MPH'), findsOneWidget);
      expect(find.text('SECTOR REACHED'), findsOneWidget);
      expect(find.text('SEC 06: CIRCUIT OVERPASS'), findsOneWidget);

      // Verify Milestones Unlocked Card
      expect(find.text('CAREER MILESTONE UNLOCKED!'), findsOneWidget);
      expect(find.text('ENDURANCE TIER I'), findsOneWidget);
      expect(find.text('OVERPASS CLIMBER'), findsOneWidget);
    });

    testWidgets('CareerRecordsCard displays persistent career telemetry on garage dashboard',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CareerRecordsCard(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DRIVER CAREER TELEMETRY'), findsOneWidget);
      expect(find.text('3/9 BADGES'), findsOneWidget);
      expect(find.text('75000'), findsOneWidget);
      expect(find.text('2.8 KM'), findsOneWidget);
      expect(find.text('215 MPH'), findsOneWidget);
    });

    testWidgets('ArcadeRoadPainter, CarPainter, and ObstaclePainter paint cleanly with elevation',
        (WidgetTester tester) async {
      final player = PlayerCar();
      final obstacle = ObstacleVehicle(
        id: 'obs_1',
        type: ObstacleType.cyberTruck,
        color: Colors.amber,
        lanePosition: 0.0,
        yProgress: 0.5,
        speedMph: 50.0,
      );

      final roadPainter = ArcadeRoadPainter(
        scrollOffset: 0.5,
        playerSpeedMph: 120.0,
        curveOffset: 0.45,
        elevationOffset: 0.65,
      );

      final carPainter = ArcadeCarPainter(
        player: player,
        curveOffset: 0.45,
        elevationOffset: 0.65,
      );

      final obsPainter = ArcadeObstaclePainter(
        obstacles: [obstacle],
        curveOffset: 0.45,
        elevationOffset: 0.65,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: CustomPaint(
                painter: roadPainter,
                child: CustomPaint(
                  painter: obsPainter,
                  child: CustomPaint(
                    painter: carPainter,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
