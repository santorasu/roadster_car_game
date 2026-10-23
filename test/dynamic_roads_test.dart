import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/game_engine/arcade_game_engine.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/arcade_game_state.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/obstacle_vehicle.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/player_car.dart';
import 'package:tesla_roadster_game/features/arcade_driving/domain/models/road_section.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/painters/arcade_car_painter.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/painters/arcade_obstacle_painter.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/painters/arcade_road_painter.dart';
import 'package:tesla_roadster_game/features/arcade_driving/presentation/widgets/arcade_hud.dart';

void main() {
  group('Feature 06: TrackProgressionManager & Curve Geometry Tests', () {
    test('TrackProgressionManager provides structured sectors and distances', () {
      final manager = TrackProgressionManager();
      expect(manager.sections.length, greaterThanOrEqualTo(5));

      final sec1 = manager.getSectionForDistance(0.0);
      expect(sec1.name, 'NEON HIGHWAY');
      expect(sec1.curveType, RoadCurveType.straight);
      expect(sec1.targetCurvature, 0.0);

      final sec2 = manager.getSectionForDistance(250.0);
      expect(sec2.name, 'CYBER SWEEP');
      expect(sec2.curveType, RoadCurveType.gentleRight);
      expect(sec2.targetCurvature, 0.48);

      final sec4 = manager.getSectionForDistance(700.0);
      expect(sec4.name, 'NIGHT CANYON');
      expect(sec4.curveType, RoadCurveType.gentleLeft);
      expect(sec4.targetCurvature, -0.55);
    });

    test('Curve entry and exit transitions ease smoothly between straight and turn', () {
      final manager = TrackProgressionManager();

      // Sector 2 starts at 100m and ends at 400m (targetCurvature = 0.48)
      // At start (100m): curvature should be 0.0
      final curveAtStart = manager.computeCurvatureAt(100.0);
      expect(curveAtStart, closeTo(0.0, 0.01));

      // At entry (130m): curvature should be ramping up
      final curveEntry = manager.computeCurvatureAt(130.0);
      expect(curveEntry, greaterThan(0.0));
      expect(curveEntry, lessThan(0.48));

      // At apex midpoint (250m): curvature should be at sustained target 0.48
      final curveApex = manager.computeCurvatureAt(250.0);
      expect(curveApex, closeTo(0.48, 0.01));

      // Near exit (390m): curvature should be ramping back down towards 0.0
      final curveExit = manager.computeCurvatureAt(390.0);
      expect(curveExit, lessThan(0.48));
      expect(curveExit, greaterThan(0.0));
    });

    test('Data Chicane / S-Curve oscillates between left and right curvature', () {
      final manager = TrackProgressionManager();
      // Sector 5 (1000m to 1500m) is an S-Curve
      final curve1 = manager.computeCurvatureAt(1100.0); // First positive turn lobe
      final curve2 = manager.computeCurvatureAt(1250.0); // Middle negative turn lobe

      // Oscillation creates opposing curvature signs along the chicane
      expect(curve1.sign, isNot(equals(0.0)));
      expect(curve2.sign, isNot(equals(0.0)));
      expect(curve1.sign, isNot(equals(curve2.sign)));
    });
  });

  group('Feature 06: Road Geometry & Coordinate Alignment Tests', () {
    test('ArcadeRoadPainter coordinate math calculates accurate road offsets', () {
      final roadPainter = ArcadeRoadPainter(
        scrollOffset: 0.0,
        playerSpeedMph: 100.0,
        curveOffset: 0.5, // 50% right curve
      );

      const screenW = 400.0;
      const screenH = 800.0;
      final horizonY = screenH * 0.18;
      expect(roadPainter.getRoadY(0.0, screenH, horizonY), horizonY);
      expect(roadPainter.getRoadY(1.0, screenH, horizonY), screenH);

      // At bottom of screen (t = 1.0), curve shift is zero
      expect(roadPainter.getCurveShift(1.0, screenW), 0.0);
      expect(roadPainter.getRoadCenterX(1.0, screenW), 200.0);

      // At horizon (t = 0.0), curve shift is max to the right
      final horizonShift = roadPainter.getCurveShift(0.0, screenW);
      expect(horizonShift, closeTo(0.5 * 400.0 * 0.28, 0.01));
      expect(roadPainter.getRoadCenterX(0.0, screenW), closeTo(200.0 + horizonShift, 0.01));

      // Road width grows from top to bottom
      final topWidth = roadPainter.getRoadWidth(0.0, screenW);
      final botWidth = roadPainter.getRoadWidth(1.0, screenW);
      expect(botWidth, greaterThan(topWidth));

      // Road left and right edges are symmetric around road center
      final centerMid = roadPainter.getRoadCenterX(0.5, screenW);
      final leftMid = roadPainter.getRoadLeftX(0.5, screenW);
      final rightMid = roadPainter.getRoadRightX(0.5, screenW);
      expect(centerMid - leftMid, closeTo(rightMid - centerMid, 0.01));
    });

    test('PlayerCar and ObstacleVehicle bounding rects shift with road curvature', () {
      final player = PlayerCar(lanePosition: 0.0);
      final obstacle = ObstacleVehicle(
        id: 'obs_1',
        type: ObstacleType.cyberSedan,
        color: Colors.cyan,
        lanePosition: 0.0,
        yProgress: 0.4,
        speedMph: 60.0,
      );

      const w = 400.0;
      const h = 800.0;

      // Straight road baseline
      final playerStraightRect = player.getBoundingRect(w, h, 0.0);
      final obstacleStraightRect = obstacle.getBoundingRect(w, h, 0.0);

      expect(playerStraightRect.center.dx, closeTo(200.0, 1.0));
      expect(obstacleStraightRect.center.dx, closeTo(200.0, 1.0));

      // Right-curving road (curveOffset = 0.6)
      final playerRightRect = player.getBoundingRect(w, h, 0.6);
      final obstacleRightRect = obstacle.getBoundingRect(w, h, 0.6);

      // Both should shift to the right of screen center
      expect(playerRightRect.center.dx, greaterThan(playerStraightRect.center.dx));
      expect(obstacleRightRect.center.dx, greaterThan(obstacleStraightRect.center.dx));

      // Obstacle further up the road (yProgress = 0.4 < 0.75) experiences greater lateral curve shift
      final playerShift = playerRightRect.center.dx - playerStraightRect.center.dx;
      final obstacleShift = obstacleRightRect.center.dx - obstacleStraightRect.center.dx;
      expect(obstacleShift, greaterThan(playerShift));
    });
  });

  group('Feature 06: Curvature Physics & Centrifugal Drift Tests', () {
    test('Curved road exerts outward centrifugal force on player vehicle', () {
      final engine = ArcadeGameEngine();
      engine.start();
      engine.player.speedMph = 120.0;
      engine.player.lanePosition = 0.0;
      engine.player.lateralVelocity = 0.0;
      engine.player.steerInput = 0.0; // Hands off the wheel

      // Manually set distance to apex of Sector 2 (Cyber Sweep, right curve, curvature = 0.48)
      engine.player.distanceTraveledMeters = 250.0;

      // Simulate 0.25 seconds of driving in a right curve
      engine.tick(0.25, 400, 800);

      // Right curve pulls outward to the left (negative lateral velocity and lane position)
      expect(engine.state.currentCurvature, closeTo(0.48, 0.01));
      expect(engine.player.lateralVelocity, lessThan(0.0));
      expect(engine.player.lanePosition, lessThan(0.0));
    });

    test('Player steering counters centrifugal force and maintains lane', () {
      final engine = ArcadeGameEngine();
      engine.start();
      engine.player.speedMph = 120.0;
      engine.player.lanePosition = 0.0;
      engine.player.distanceTraveledMeters = 250.0; // In right curve (pulls left)

      // Steer to the right to counter centrifugal pull
      engine.player.steerInput = 0.6;
      engine.tick(0.25, 400, 800);

      // Steering right successfully overcomes centrifugal drift
      expect(engine.player.lateralVelocity, greaterThan(0.0));
      expect(engine.player.lanePosition, greaterThan(0.0));
    });

    test('Stationary vehicle does not experience centrifugal force', () {
      final engine = ArcadeGameEngine();
      engine.start();
      engine.player.speedMph = 0.0;
      engine.player.lanePosition = 0.0;
      engine.player.lateralVelocity = 0.0;
      engine.player.steerInput = 0.0;
      engine.player.distanceTraveledMeters = 250.0;

      engine.tick(0.25, 400, 800);
      expect(engine.player.lateralVelocity, 0.0);
    });
  });

  group('Feature 06: Sector Progression & HUD Notification Widget Tests', () {
    test('Distance progression triggers sector announcements and score bonuses', () {
      final engine = ArcadeGameEngine();
      engine.start();
      engine.player.speedMph = 100.0;
      expect(engine.state.currentSectorName, 'NEON HIGHWAY');
      expect(engine.state.sectorIndex, 1);

      // Fast-forward player distance into Sector 2 (100m+)
      engine.player.distanceTraveledMeters = 110.0;
      final initialScore = engine.state.score;

      engine.tick(0.05, 400, 800);

      expect(engine.state.sectorIndex, 2);
      expect(engine.state.currentSectorName, 'CYBER SWEEP');
      expect(engine.state.sectorNotificationTimer, greaterThan(2.0));
      expect(engine.state.score, greaterThan(initialScore)); // Bonus points awarded
    });

    testWidgets('ArcadeHud displays sector notification banner during sector transition', (tester) async {
      final player = PlayerCar(speedMph: 100.0);
      final state = ArcadeGameState(
        currentSectorName: 'CYBER SWEEP',
        sectorIndex: 2,
        currentCurvature: 0.45,
        sectorNotificationTimer: 2.5, // Active notification
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: ArcadeHud(
                player: player,
                state: state,
                onPausePressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('hud_sector_announcement_banner')), findsOneWidget);
      expect(find.text('SECTOR 02: CYBER SWEEP'), findsOneWidget);
    });

    testWidgets('CustomPainters render curved road, obstacles, and car without errors', (tester) async {
      final roadPainter = ArcadeRoadPainter(
        scrollOffset: 15.0,
        playerSpeedMph: 120.0,
        curveOffset: 0.6,
      );

      final obstaclePainter = ArcadeObstaclePainter(
        obstacles: [
          ObstacleVehicle(
            id: 'obs_c1',
            type: ObstacleType.cyberSedan,
            color: Colors.cyan,
            lanePosition: -0.5,
            yProgress: 0.5,
            speedMph: 60.0,
          ),
        ],
        curveOffset: 0.6,
      );

      final carPainter = ArcadeCarPainter(
        player: PlayerCar(speedMph: 120.0, lanePosition: 0.2),
        curveOffset: 0.6,
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  CustomPaint(
                    key: const Key('curved_road_paint'),
                    size: const Size(400, 800),
                    painter: roadPainter,
                  ),
                  CustomPaint(
                    key: const Key('curved_obs_paint'),
                    size: const Size(400, 800),
                    painter: obstaclePainter,
                  ),
                  CustomPaint(
                    key: const Key('curved_car_paint'),
                    size: const Size(400, 800),
                    painter: carPainter,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('curved_road_paint')), findsOneWidget);
      expect(find.byKey(const Key('curved_obs_paint')), findsOneWidget);
      expect(find.byKey(const Key('curved_car_paint')), findsOneWidget);
    });
  });
}
