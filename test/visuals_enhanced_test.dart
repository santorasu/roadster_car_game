import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/obstacle_vehicle.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/player_car.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/painters/arcade_car_painter.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/painters/arcade_obstacle_painter.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/painters/arcade_road_painter.dart';

void main() {
  group('Feature 05: Enhanced Car & Road Visuals CustomPainter Tests', () {
    testWidgets('ArcadeRoadPainter paints multi-layered cyber highway without errors', (tester) async {
      final roadPainter = ArcadeRoadPainter(
        scrollOffset: 12.5,
        playerSpeedMph: 110.0,
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                key: const Key('test_road_paint'),
                size: const Size(400, 800),
                painter: roadPainter,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('test_road_paint')), findsOneWidget);
      expect(roadPainter.shouldRepaint(ArcadeRoadPainter(scrollOffset: 12.5, playerSpeedMph: 110.0)), isFalse);
      expect(roadPainter.shouldRepaint(ArcadeRoadPainter(scrollOffset: 13.0, playerSpeedMph: 110.0)), isTrue);
      expect(roadPainter.shouldRepaint(ArcadeRoadPainter(scrollOffset: 12.5, playerSpeedMph: 120.0)), isTrue);
    });

    testWidgets('ArcadeRoadPainter renders at extreme hyper speeds (> 160 MPH) activating vignette', (tester) async {
      final hyperRoadPainter = ArcadeRoadPainter(
        scrollOffset: 45.0,
        playerSpeedMph: 240.0, // Triggers both warp streaks and hyper speed vignette
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                key: const Key('test_hyper_road_paint'),
                size: const Size(400, 800),
                painter: hyperRoadPainter,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('test_hyper_road_paint')), findsOneWidget);
    });

    testWidgets('ArcadeCarPainter paints enhanced Roadster with wheels, canopy, and underglow', (tester) async {
      final player = PlayerCar(
        speedMph: 135.0, // triggers active spoiler
        lanePosition: 0.25,
        rollAngle: 0.05,
        isAccelerating: true,
        isBraking: false,
        collisionRecoveryTimer: 0.0,
      );

      final carPainter = ArcadeCarPainter(player: player);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                key: const Key('test_car_paint'),
                size: const Size(400, 800),
                painter: carPainter,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('test_car_paint')), findsOneWidget);
    });

    testWidgets('ArcadeCarPainter paints active braking and recovery shield aura', (tester) async {
      final player = PlayerCar(
        speedMph: 80.0,
        lanePosition: -0.5,
        rollAngle: -0.08,
        isAccelerating: false,
        isBraking: true, // triggers airbrake and brake blade
        collisionRecoveryTimer: 0.5, // triggers concentric shield aura
      );

      final carPainter = ArcadeCarPainter(player: player);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                key: const Key('test_car_braking_paint'),
                size: const Size(400, 800),
                painter: carPainter,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('test_car_braking_paint')), findsOneWidget);
    });

    testWidgets('ArcadeObstaclePainter paints all 4 obstacle types with shadows and headlights', (tester) async {
      final obstacles = [
        ObstacleVehicle(
          id: 'obs_sedan',
          type: ObstacleType.cyberSedan,
          color: Colors.cyan,
          lanePosition: -0.6,
          yProgress: 0.35,
          speedMph: 45.0,
        ),
        ObstacleVehicle(
          id: 'obs_truck',
          type: ObstacleType.cyberTruck,
          color: Colors.amber,
          lanePosition: 0.0,
          yProgress: 0.50,
          speedMph: 50.0,
        ),
        ObstacleVehicle(
          id: 'obs_hauler',
          type: ObstacleType.heavyHauler,
          color: Colors.blueGrey,
          lanePosition: 0.6,
          yProgress: 0.65,
          speedMph: 35.0,
        ),
        ObstacleVehicle(
          id: 'obs_barrier',
          type: ObstacleType.energyBarrier,
          color: Colors.orange,
          lanePosition: 0.0,
          yProgress: 0.20,
          speedMph: 0.0,
        ),
      ];

      final obstaclePainter = ArcadeObstaclePainter(obstacles: obstacles);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                key: const Key('test_obstacle_paint'),
                size: const Size(400, 800),
                painter: obstaclePainter,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('test_obstacle_paint')), findsOneWidget);
      expect(obstaclePainter.shouldRepaint(ArcadeObstaclePainter(obstacles: obstacles)), isTrue);
    });
  });
}
