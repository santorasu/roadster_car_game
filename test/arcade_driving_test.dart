import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tesla_roadster_game/app/app.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/game_engine/arcade_game_engine.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/arcade_game_state.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/obstacle_vehicle.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/screens/arcade_game_screen.dart';

void main() {
  group('Feature 02: Arcade Driving Engine Physics & Logic Tests', () {
    late ArcadeGameEngine engine;

    setUp(() {
      engine = ArcadeGameEngine();
      engine.start();
    });

    test('Engine starts in playing state with initial rolling speed', () {
      expect(engine.state.status, equals(ArcadeGameStatus.playing));
      expect(engine.player.speedMph, greaterThanOrEqualTo(20.0));
      expect(engine.player.health, equals(1.0));
      expect(engine.state.score, equals(0));
      expect(engine.state.distanceMeters, equals(0.0));
    });

    test('Acceleration increases speed up towards top speed', () {
      final initialSpeed = engine.player.speedMph;
      engine.player.isAccelerating = true;

      // Tick 1 second
      engine.tick(1.0, 400.0, 800.0);

      expect(engine.player.speedMph, greaterThan(initialSpeed));
      expect(engine.player.speedMph, lessThanOrEqualTo(engine.topSpeed));
    });

    test('Braking decelerates the vehicle', () {
      engine.player.speedMph = 120.0;
      engine.player.isBraking = true;

      // Tick 0.5 seconds
      engine.tick(0.5, 400.0, 800.0);

      expect(engine.player.speedMph, lessThan(120.0));
    });

    test('Steering input moves car lane position within road boundaries', () {
      expect(engine.player.lanePosition, equals(0.0));

      // Steer right
      engine.player.steerInput = 1.0;
      engine.tick(0.5, 400.0, 800.0);
      expect(engine.player.lanePosition, greaterThan(0.0));
      expect(engine.player.rollAngle, greaterThan(0.0));

      // Steer left
      engine.player.steerInput = -1.0;
      engine.tick(1.0, 400.0, 800.0);
      expect(engine.player.lanePosition, lessThan(0.5));
      expect(engine.player.lanePosition, greaterThanOrEqualTo(-1.0));
    });

    test('Collision with obstacle reduces health, drops speed, and spawns sparks', () {
      engine.player.lanePosition = 0.0;
      engine.player.speedMph = 80.0;

      // Manually inject obstacle directly in player's path
      final obstacle = ObstacleVehicle(
        id: 'test_obs',
        type: ObstacleType.cyberSedan,
        color: Colors.cyan,
        lanePosition: 0.0,
        yProgress: 0.74, // Direct overlap with player
        speedMph: 40.0,
      );
      engine.obstacles.add(obstacle);

      expect(engine.player.health, equals(1.0));
      expect(engine.particles, isEmpty);

      // Tick simulation to trigger collision
      engine.tick(0.05, 400.0, 800.0);

      expect(obstacle.hasCollided, isTrue);
      expect(engine.player.health, lessThan(1.0));
      expect(engine.state.collisionsCount, equals(1));
      expect(engine.particles, isNotEmpty);
      expect(engine.state.screenShakeIntensity, greaterThan(0.0));
    });

    test('Fatal collision reduces health to 0 and triggers game over', () {
      engine.player.health = 0.15; // Critical low health
      engine.player.lanePosition = 0.0;

      final heavyHauler = ObstacleVehicle(
        id: 'fatal_obs',
        type: ObstacleType.heavyHauler,
        color: Colors.grey,
        lanePosition: 0.0,
        yProgress: 0.75,
        speedMph: 30.0,
      );
      engine.obstacles.add(heavyHauler);

      engine.tick(0.05, 400.0, 800.0);

      expect(engine.player.health, equals(0.0));
      expect(engine.state.status, equals(ArcadeGameStatus.gameOver));
    });

    test('Pause, resume, and restart behave accurately', () {
      engine.pause();
      expect(engine.state.status, equals(ArcadeGameStatus.paused));

      // Tick while paused should not advance distance
      final dist = engine.state.distanceMeters;
      engine.tick(0.5, 400.0, 800.0);
      expect(engine.state.distanceMeters, equals(dist));

      engine.resume();
      expect(engine.state.status, equals(ArcadeGameStatus.playing));

      engine.state.highScore = 5000;
      engine.restart();
      expect(engine.state.status, equals(ArcadeGameStatus.playing));
      expect(engine.player.health, equals(1.0));
      expect(engine.state.score, equals(0));
      expect(engine.state.highScore, equals(5000)); // High score preserved
    });
  });

  group('Feature 02: Flutter UI & Interactive Widget Tests', () {
    testWidgets('HomeScreen launches ArcadeGameScreen with HUD and touch controls',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const TeslaRoadsterGameApp());
      await tester.pump();

      final arcadeButton = find.byKey(const Key('play_arcade_game_button'));
      expect(arcadeButton, findsOneWidget);

      await tester.tap(arcadeButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify we are inside ArcadeGameScreen
      expect(find.byType(ArcadeGameScreen), findsOneWidget);

      // Verify HUD readouts
      expect(find.text('SCORE'), findsOneWidget);
      expect(find.text('DISTANCE'), findsOneWidget);
      expect(find.text('MPH'), findsOneWidget);
      expect(find.text('HULL INTEGRITY'), findsOneWidget);

      // Verify touch control buttons
      expect(find.byKey(const Key('steer_left_button')), findsOneWidget);
      expect(find.byKey(const Key('steer_right_button')), findsOneWidget);
      expect(find.byKey(const Key('brake_button')), findsOneWidget);
      expect(find.byKey(const Key('accelerate_button')), findsOneWidget);
    });

    testWidgets('Tapping pause button presents pause dialog with resume and restart',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const TeslaRoadsterGameApp());
      await tester.pump();

      await tester.tap(find.byKey(const Key('play_arcade_game_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap pause button
      final pauseBtn = find.byKey(const Key('arcade_pause_button'));
      expect(pauseBtn, findsOneWidget);
      await tester.tap(pauseBtn);
      await tester.pump();

      // Verify pause modal
      expect(find.text('SIMULATION PAUSED'), findsOneWidget);
      expect(find.byKey(const Key('resume_game_button')), findsOneWidget);
      expect(find.byKey(const Key('restart_game_button')), findsOneWidget);
      expect(find.byKey(const Key('exit_game_button')), findsOneWidget);

      // Resume game
      await tester.tap(find.byKey(const Key('resume_game_button')));
      await tester.pump();

      // Pause modal should disappear
      expect(find.text('SIMULATION PAUSED'), findsNothing);
    });
  });
}
