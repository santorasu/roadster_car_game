import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tesla_roadster_game/core/storage/player_data_storage.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/game_engine/arcade_game_engine.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/obstacle_vehicle.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/player_car.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/painters/arcade_car_painter.dart';
import 'package:tesla_roadster_game/features/garage/domain/models/vehicle_definition.dart';
import 'package:tesla_roadster_game/features/garage/presentation/painters/garage_car_preview_painter.dart';
import 'package:tesla_roadster_game/features/garage/presentation/widgets/garage_vehicle_selector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 08: Vehicle Catalog & Unlock Milestone Logic Tests', () {
    test('Vehicle catalog contains at least 3 distinct electric sports cars', () {
      expect(VehicleCatalog.vehicles.length, greaterThanOrEqualTo(3));

      final ids = VehicleCatalog.vehicles.map((v) => v.id).toList();
      expect(ids, containsAll(['cyber_roadster', 'apex_gte', 'hyperion_phantom']));
    });

    test('Cyber Roadster is unlocked by default without prerequisites', () {
      final roadster = VehicleDefinition.getById('cyber_roadster');
      expect(roadster.requiredMilestoneId, isNull);
      expect(roadster.isUnlocked({}), isTrue);
      expect(roadster.bodyStyle, equals(VehicleBodyStyle.roadster));
      expect(roadster.topSpeedMph, equals(250.0));
      expect(roadster.accelerationMultiplier, equals(1.00));
      expect(roadster.baseSteeringMultiplier, equals(1.00));
      expect(roadster.damageMultiplier, equals(1.00));
    });

    test('Apex GT-E unlocks only when century milestone (100+ MPH) is earned', () {
      final apex = VehicleDefinition.getById('apex_gte');
      expect(apex.requiredMilestoneId, equals('century'));
      expect(apex.isUnlocked({}), isFalse);
      expect(apex.isUnlocked({'endurance'}), isFalse);
      expect(apex.isUnlocked({'century'}), isTrue);
      expect(apex.isUnlocked({'century', 'warp_speed'}), isTrue);

      expect(apex.bodyStyle, equals(VehicleBodyStyle.valkyrieAero));
      expect(apex.topSpeedMph, equals(242.0));
      expect(apex.accelerationMultiplier, equals(1.15));
      expect(apex.baseSteeringMultiplier, equals(1.18));
      expect(apex.damageMultiplier, equals(1.25));
    });

    test('Hyperion Phantom unlocks only when warp_speed milestone (150+ MPH) is earned', () {
      final hyperion = VehicleDefinition.getById('hyperion_phantom');
      expect(hyperion.requiredMilestoneId, equals('warp_speed'));
      expect(hyperion.isUnlocked({}), isFalse);
      expect(hyperion.isUnlocked({'century'}), isFalse);
      expect(hyperion.isUnlocked({'warp_speed'}), isTrue);

      expect(hyperion.bodyStyle, equals(VehicleBodyStyle.titanStealth));
      expect(hyperion.topSpeedMph, equals(268.0));
      expect(hyperion.accelerationMultiplier, equals(0.88));
      expect(hyperion.baseSteeringMultiplier, equals(0.88));
      expect(hyperion.damageMultiplier, equals(0.68));
    });

    test('Customization accessories have valid milestone requirements', () {
      // Paints
      final crimson = VehicleCatalog.paints.firstWhere((p) => p.id == 'cyber_crimson');
      final solar = VehicleCatalog.paints.firstWhere((p) => p.id == 'solar_flare');
      expect(crimson.isUnlocked({}), isTrue);
      expect(solar.isUnlocked({}), isFalse);
      expect(solar.isUnlocked({'warp_speed'}), isTrue);

      // Wheels
      final turbine = VehicleCatalog.wheels.firstWhere((w) => w.id == 'turbine_aero');
      final starfire = VehicleCatalog.wheels.firstWhere((w) => w.id == 'starfire_split');
      expect(turbine.isUnlocked({}), isTrue);
      expect(starfire.isUnlocked({}), isFalse);
      expect(starfire.isUnlocked({'century'}), isTrue);

      // Underglow
      final cyanGlow = VehicleCatalog.underglows.firstWhere((u) => u.id == 'neon_cyan');
      final violetGlow = VehicleCatalog.underglows.firstWhere((u) => u.id == 'pulse_violet');
      expect(cyanGlow.isUnlocked({}), isTrue);
      expect(violetGlow.isUnlocked({}), isFalse);
      expect(violetGlow.isUnlocked({'century'}), isTrue);
    });
  });

  group('Feature 08: PlayerDataStorage Persistence Tests', () {
    late InMemoryPlayerDataStorage storage;

    setUp(() {
      storage = InMemoryPlayerDataStorage();
    });

    test('Default storage data returns Cyber Roadster and default customization', () async {
      final data = await storage.loadCareerData();
      expect(data.selectedVehicleId, equals('cyber_roadster'));
      expect(data.selectedPaintColorId, equals('cyber_crimson'));
      expect(data.selectedWheelStyleId, equals('turbine_aero'));
      expect(data.selectedUnderglowColorId, equals('neon_cyan'));
    });

    test('Saving vehicle customization updates and persists player selections', () async {
      await storage.saveVehicleCustomization(
        vehicleId: 'apex_gte',
        paintColorId: 'electric_cyan',
        wheelStyleId: 'starfire_split',
        underglowColorId: 'laser_red',
      );

      final loaded = await storage.loadCareerData();
      expect(loaded.selectedVehicleId, equals('apex_gte'));
      expect(loaded.selectedPaintColorId, equals('electric_cyan'));
      expect(loaded.selectedWheelStyleId, equals('starfire_split'));
      expect(loaded.selectedUnderglowColorId, equals('laser_red'));
    });
  });

  group('Feature 08: Gameplay Engine Stat Integration Tests', () {
    test('Vehicle stats consistently affect top speed and handling', () {
      final engine = ArcadeGameEngine();
      engine.start();

      // Default: Cyber Roadster
      expect(engine.topSpeed, equals(250.0));
      expect(engine.baseSteeringSpeed, equals(2.4 * 1.00));

      // Switch to Apex GT-E
      engine.player.customization = const VehicleCustomization(vehicleId: 'apex_gte');
      expect(engine.topSpeed, equals(242.0));
      expect(engine.baseSteeringSpeed, closeTo(2.4 * 1.18, 0.001));

      // Switch to Hyperion Phantom
      engine.player.customization = const VehicleCustomization(vehicleId: 'hyperion_phantom');
      expect(engine.topSpeed, equals(268.0));
      expect(engine.baseSteeringSpeed, closeTo(2.4 * 0.88, 0.001));
    });

    test('Vehicle acceleration torque scaling differentiates velocity gain', () {
      // 1. Cyber Roadster Acceleration
      final roadsterEngine = ArcadeGameEngine();
      roadsterEngine.start();
      roadsterEngine.player.speedMph = 50.0;
      roadsterEngine.player.isAccelerating = true;
      roadsterEngine.tick(1.0, 400.0, 800.0);
      final roadsterGain = roadsterEngine.player.speedMph - 50.0;

      // 2. Apex GT-E Acceleration (+15% torque)
      final apexEngine = ArcadeGameEngine();
      apexEngine.start();
      apexEngine.player.customization = const VehicleCustomization(vehicleId: 'apex_gte');
      apexEngine.player.speedMph = 50.0;
      apexEngine.player.isAccelerating = true;
      apexEngine.tick(1.0, 400.0, 800.0);
      final apexGain = apexEngine.player.speedMph - 50.0;

      // 3. Hyperion Phantom Acceleration (-12% torque)
      final hyperionEngine = ArcadeGameEngine();
      hyperionEngine.start();
      hyperionEngine.player.customization = const VehicleCustomization(vehicleId: 'hyperion_phantom');
      hyperionEngine.player.speedMph = 50.0;
      hyperionEngine.player.isAccelerating = true;
      hyperionEngine.tick(1.0, 400.0, 800.0);
      final hyperionGain = hyperionEngine.player.speedMph - 50.0;

      expect(apexGain, greaterThan(roadsterGain));
      expect(roadsterGain, greaterThan(hyperionGain));
    });

    test('Vehicle durability multiplier alters collision damage impact', () {
      // Create test engines for all 3 cars
      final roadsterEngine = ArcadeGameEngine();
      roadsterEngine.start();

      final apexEngine = ArcadeGameEngine();
      apexEngine.start();
      apexEngine.player.customization = const VehicleCustomization(vehicleId: 'apex_gte');

      final hyperionEngine = ArcadeGameEngine();
      hyperionEngine.start();
      hyperionEngine.player.customization = const VehicleCustomization(vehicleId: 'hyperion_phantom');

      // Add identical collision obstacle right in front of each
      final obstacleRoadster = ObstacleVehicle(
        id: '1',
        type: ObstacleType.cyberSedan,
        color: Colors.blue,
        lanePosition: 0.0,
        yProgress: 0.78,
        speedMph: 20.0,
      );
      roadsterEngine.obstacles.add(obstacleRoadster);
      roadsterEngine.player.speedMph = 100.0;
      roadsterEngine.tick(0.05, 400.0, 800.0);
      final roadsterHealthLoss = 1.0 - roadsterEngine.player.health;

      final obstacleApex = ObstacleVehicle(
        id: '2',
        type: ObstacleType.cyberSedan,
        color: Colors.blue,
        lanePosition: 0.0,
        yProgress: 0.78,
        speedMph: 20.0,
      );
      apexEngine.obstacles.add(obstacleApex);
      apexEngine.player.speedMph = 100.0;
      apexEngine.tick(0.05, 400.0, 800.0);
      final apexHealthLoss = 1.0 - apexEngine.player.health;

      final obstacleHyperion = ObstacleVehicle(
        id: '3',
        type: ObstacleType.cyberSedan,
        color: Colors.blue,
        lanePosition: 0.0,
        yProgress: 0.78,
        speedMph: 20.0,
      );
      hyperionEngine.obstacles.add(obstacleHyperion);
      hyperionEngine.player.speedMph = 100.0;
      hyperionEngine.tick(0.05, 400.0, 800.0);
      final hyperionHealthLoss = 1.0 - hyperionEngine.player.health;

      // Apex takes more damage (1.25x), Hyperion takes less damage (0.68x)
      expect(apexHealthLoss, greaterThan(roadsterHealthLoss));
      expect(roadsterHealthLoss, greaterThan(hyperionHealthLoss));
    });
  });

  group('Feature 08: CustomPainter Visual Rendering Tests', () {
    test('GarageCarPreviewPainter renders all vehicles, paint gradients, wheels, and underglows', () {
      for (final vehicle in VehicleCatalog.vehicles) {
        for (final paint in VehicleCatalog.paints) {
          final painter = GarageCarPreviewPainter(
            vehicle: vehicle,
            paintColor: paint,
            wheelStyle: VehicleCatalog.wheels.first,
            underglow: VehicleCatalog.underglows.first,
            turntableAngle: 0.25,
          );

          final recorder = PictureRecorder();
          final canvas = Canvas(recorder);
          expect(() => painter.paint(canvas, const Size(400, 300)), returnsNormally);
        }
      }
    });

    test('ArcadeCarPainter renders custom vehicles and active aero at speed', () {
      final player = PlayerCar();

      for (final vehicle in VehicleCatalog.vehicles) {
        player.customization = VehicleCustomization(vehicleId: vehicle.id);

        // At low speed
        player.speedMph = 60.0;
        final painterLow = ArcadeCarPainter(player: player);
        final recorderLow = PictureRecorder();
        expect(() => painterLow.paint(Canvas(recorderLow), const Size(400, 800)), returnsNormally);

        // At high speed with active aero spoiler deployment
        player.speedMph = 150.0;
        player.isBraking = true;
        final painterAero = ArcadeCarPainter(player: player);
        final recorderAero = PictureRecorder();
        expect(() => painterAero.paint(Canvas(recorderAero), const Size(400, 800)), returnsNormally);
      }
    });
  });

  group('Feature 08: Garage Vehicle Selector Widget Interaction Tests', () {
    late InMemoryPlayerDataStorage inMemoryStorage;

    setUp(() {
      inMemoryStorage = InMemoryPlayerDataStorage();
      PlayerDataService.instance = inMemoryStorage;
    });

    testWidgets('Renders garage dashboard with default car and enables car switching',
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
            body: SingleChildScrollView(
              child: GarageVehicleSelector(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initial car is Cyber Roadster (equipped)
      expect(find.text('CYBER ROADSTER'), findsOneWidget);
      expect(find.text('EQUIPPED'), findsOneWidget);
      expect(find.text('MAX SPEED'), findsOneWidget);
      expect(find.text('ACCELERATION'), findsOneWidget);
      expect(find.text('HANDLING'), findsOneWidget);
      expect(find.text('DURABILITY'), findsOneWidget);

      // Tap next car button -> APEX GT-E
      await tester.tap(find.byKey(const Key('garage_next_car_button')));
      await tester.pump();

      expect(find.text('APEX GT-E'), findsOneWidget);
      // Since no milestone is achieved in empty storage, it shows LOCKED
      expect(find.text('LOCKED'), findsOneWidget);
      expect(find.textContaining('REQUIREMENT:'), findsOneWidget);

      // Tap next car button -> HYPERION PHANTOM
      await tester.tap(find.byKey(const Key('garage_next_car_button')));
      await tester.pump();

      expect(find.text('HYPERION PHANTOM'), findsOneWidget);
      expect(find.text('LOCKED'), findsOneWidget);

      // Tap previous car button -> returns to APEX GT-E
      await tester.tap(find.byKey(const Key('garage_prev_car_button')));
      await tester.pump();
      expect(find.text('APEX GT-E'), findsOneWidget);
    });

    testWidgets('Customization tab switching and paint selection interaction',
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
            body: SingleChildScrollView(
              child: GarageVehicleSelector(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Switch to WHEELS tab
      await tester.tap(find.byKey(const Key('garage_tab_wheels')));
      await tester.pump();
      expect(find.byKey(const Key('wheel_option_turbine_aero')), findsOneWidget);

      // Switch to UNDERGLOW tab
      await tester.tap(find.byKey(const Key('garage_tab_underglow')));
      await tester.pump();
      expect(find.byKey(const Key('underglow_option_neon_cyan')), findsOneWidget);

      // Switch back to PAINT tab and select Electric Cyan
      await tester.tap(find.byKey(const Key('garage_tab_paint')));
      await tester.pump();

      final cyanOption = find.byKey(const Key('paint_option_electric_cyan'));
      expect(cyanOption, findsOneWidget);
      await tester.tap(cyanOption);
      await tester.pump();

      // Verify persisted in storage
      final data = await inMemoryStorage.loadCareerData();
      expect(data.selectedPaintColorId, equals('electric_cyan'));
    });
  });
}
