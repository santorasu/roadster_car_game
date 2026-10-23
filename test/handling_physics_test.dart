import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/game_engine/arcade_game_engine.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/obstacle_vehicle.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/widgets/arcade_touch_controls.dart';

void main() {
  group('Feature 03: Advanced Driving Controls & Handling Physics Tests', () {
    late ArcadeGameEngine engine;

    setUp(() {
      engine = ArcadeGameEngine();
      engine.start();
    });

    test('Progressive acceleration curve delivers high initial torque and drag-limited top end', () {
      final lowSpeedTorque = engine.computeAccelerationRate(30.0);
      final highSpeedAccel = engine.computeAccelerationRate(220.0);

      // Low speed acceleration should be substantially higher than at 220 MPH
      expect(lowSpeedTorque, greaterThan(75.0));
      expect(highSpeedAccel, lessThan(35.0));
      expect(lowSpeedTorque, greaterThan(highSpeedAccel * 2.0));
    });

    test('Progressive braking curve scales stopping power with speed', () {
      final lowSpeedBrake = engine.computeBrakingRate(30.0);
      final highSpeedBrake = engine.computeBrakingRate(220.0);

      expect(highSpeedBrake, greaterThan(lowSpeedBrake));
      expect(lowSpeedBrake, greaterThan(70.0));
      expect(highSpeedBrake, greaterThan(130.0));
    });

    test('Speed-sensitive steering keeps hypercar controllable at high speeds', () {
      final lowSpeedSteerRatio = engine.computeSpeedSteerRatio(35.0);
      final highSpeedSteerRatio = engine.computeSpeedSteerRatio(240.0);

      // Agile at low speeds (~1.05), damped at high speeds (~0.48)
      expect(lowSpeedSteerRatio, greaterThan(1.0));
      expect(highSpeedSteerRatio, lessThan(0.55));
      expect(lowSpeedSteerRatio, greaterThan(highSpeedSteerRatio * 1.8));
    });

    test('Controlled return toward neutral position when steering input is released', () {
      // Place car off-center in the right lane
      engine.player.lanePosition = 0.60;
      engine.player.lateralVelocity = 0.0;
      engine.player.steerInput = 0.0; // neutral input

      // Simulate 1.5 seconds of coasting with neutral steering
      for (int i = 0; i < 30; i++) {
        engine.tick(0.05, 400.0, 800.0);
      }

      // Lane position should have drifted smoothly back towards 0.0
      expect(engine.player.lanePosition, lessThan(0.60));
      expect(engine.player.lanePosition, greaterThan(0.0));
    });

    test('Road boundary soft resistance, friction dampening, and strict limits', () {
      engine.player.lanePosition = 0.85;
      engine.player.speedMph = 100.0;

      // Steer hard right into the verge
      engine.player.steerInput = 1.0;

      for (int i = 0; i < 20; i++) {
        engine.tick(0.05, 400.0, 800.0);
      }

      // Should detect boundary contact
      expect(engine.player.isAtRoadBoundary, isTrue);

      // Strict limit: car must NEVER exceed the max playable road boundary (1.0)
      expect(engine.player.lanePosition, lessThanOrEqualTo(ArcadeGameEngine.maxPlayableBoundary));
      expect(engine.player.lanePosition, greaterThanOrEqualTo(-ArcadeGameEngine.maxPlayableBoundary));

      // Boundary verge friction should have dampened speed
      expect(engine.player.speedMph, lessThan(100.0));
    });

    test('Collision recovery window prevents multi-frame damage and stabilizes handling', () {
      engine.player.speedMph = 120.0;
      engine.player.health = 1.0;
      engine.player.lanePosition = 0.0;

      final obstacle = ObstacleVehicle(
        id: 'impact_obs',
        type: ObstacleType.cyberSedan,
        color: Colors.cyan,
        lanePosition: 0.0,
        yProgress: 0.74,
        speedMph: 40.0,
      );
      engine.obstacles.add(obstacle);

      // First impact
      engine.tick(0.05, 400.0, 800.0);

      expect(engine.player.health, equals(0.80)); // 0.20 damage
      expect(engine.player.collisionRecoveryTimer, greaterThan(0.0));
      expect(engine.player.speedMph, closeTo(120.0 * 0.65, 5.0));

      // Attempt second collision during recovery window
      final obstacle2 = ObstacleVehicle(
        id: 'impact_obs_2',
        type: ObstacleType.cyberSedan,
        color: Colors.cyan,
        lanePosition: 0.0,
        yProgress: 0.74,
        speedMph: 40.0,
      );
      engine.obstacles.add(obstacle2);

      engine.tick(0.05, 400.0, 800.0);

      // Health should NOT have dropped again due to grace recovery window
      expect(engine.player.health, equals(0.80));
    });

    test('Frame-rate-independent physics integration', () {
      final engineA = ArcadeGameEngine()..start();
      final engineB = ArcadeGameEngine()..start();

      engineA.player.speedMph = 50.0;
      engineB.player.speedMph = 50.0;
      engineA.player.isAccelerating = true;
      engineB.player.isAccelerating = true;
      engineA.player.steerInput = 0.75;
      engineB.player.steerInput = 0.75;

      // Engine A runs at 100 FPS (10 steps of 0.01s = 0.10s)
      for (int i = 0; i < 10; i++) {
        engineA.tick(0.01, 400.0, 800.0);
      }

      // Engine B runs at 20 FPS (2 steps of 0.05s = 0.10s)
      for (int i = 0; i < 2; i++) {
        engineB.tick(0.05, 400.0, 800.0);
      }

      // Speeds and lateral positions should closely match within tight numerical tolerance
      expect((engineA.player.speedMph - engineB.player.speedMph).abs(), lessThan(1.5));
      expect((engineA.player.lanePosition - engineB.player.lanePosition).abs(), lessThan(0.05));
    });
  });

  group('Feature 03: Simultaneous Multi-Touch Handling Widget Tests', () {
    testWidgets('Touch controls register simultaneous steering and acceleration without conflict',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      double latestSteer = 0.0;
      bool latestThrottle = false;
      bool latestBrake = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: ArcadeTouchControls(
                onSteerChanged: (val) => latestSteer = val,
                onThrottleChanged: (val) => latestThrottle = val,
                onBrakeChanged: (val) => latestBrake = val,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Press and hold Steer Left (pointer 1)
      final steerLeftFinder = find.byKey(const Key('steer_left_button'));
      expect(steerLeftFinder, findsOneWidget);
      final gesture1 = await tester.startGesture(tester.getCenter(steerLeftFinder), pointer: 1);
      await tester.pump();

      expect(latestSteer, equals(-1.0));
      expect(latestThrottle, isFalse);

      // While holding Steer Left, press and hold Drive (pointer 2)
      final driveFinder = find.byKey(const Key('accelerate_button'));
      expect(driveFinder, findsOneWidget);
      final gesture2 = await tester.startGesture(tester.getCenter(driveFinder), pointer: 2);
      await tester.pump();

      // Both inputs should be simultaneously active
      expect(latestSteer, equals(-1.0));
      expect(latestThrottle, isTrue);

      // Release Steer Left, Drive should remain active
      await gesture1.up();
      await tester.pump();

      expect(latestSteer, equals(0.0));
      expect(latestThrottle, isTrue);

      // Release Drive
      await gesture2.up();
      await tester.pump();

      expect(latestThrottle, isFalse);

      // Verify brake button triggers latestBrake
      expect(latestBrake, isFalse);
      final brakeFinder = find.byKey(const Key('brake_button'));
      expect(brakeFinder, findsOneWidget);
      final brakeGesture = await tester.startGesture(tester.getCenter(brakeFinder), pointer: 3);
      await tester.pump();
      expect(latestBrake, isTrue);
      await brakeGesture.up();
      await tester.pump();
      expect(latestBrake, isFalse);
    });
  });
}
