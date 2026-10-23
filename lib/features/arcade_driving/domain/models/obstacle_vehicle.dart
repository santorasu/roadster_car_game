import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Type of obstacle appearing on the arcade road
enum ObstacleType {
  cyberSedan,
  heavyHauler,
  cyberTruck,
  energyBarrier,
}

/// Dynamic obstacle vehicle or road hazard
class ObstacleVehicle {
  final String id;
  final ObstacleType type;
  final Color color;

  /// Horizontal lane position (-1.0 to 1.0)
  double lanePosition;

  /// Vertical progress down the screen (0.0 = horizon at top, 1.0 = bottom behind player)
  double yProgress;

  /// Obstacle forward cruising speed in MPH
  double speedMph;

  /// Has this obstacle already dealt collision damage?
  bool hasCollided;

  ObstacleVehicle({
    required this.id,
    required this.type,
    required this.color,
    required this.lanePosition,
    required this.yProgress,
    required this.speedMph,
    this.hasCollided = false,
  });

  /// Get bounding rectangle in screen coordinates, accounting for road curvature
  Rect getBoundingRect(double screenWidth, double screenHeight, [double curveOffset = 0.0]) {
    final horizonY = screenHeight * 0.18;
    final centerY = screenHeight * yProgress;
    final t = ((centerY - horizonY) / (screenHeight - horizonY)).clamp(0.0, 1.0);

    // Lateral displacement of road centerline due to curvature at depth t
    final maxHorizonShift = screenWidth * 0.28;
    final curveShift = curveOffset * maxHorizonShift * math.pow(1.0 - t, 2.0);

    // Perspective road width at obstacle's vertical depth
    final roadTopWidth = screenWidth * 0.32;
    final roadBottomWidth = screenWidth * 0.78;
    final roadWidthAtDepth = roadTopWidth + (roadBottomWidth - roadTopWidth) * t;

    // Perspective scaling: obstacles near horizon are smaller than near bottom
    final perspectiveScale = 0.45 + (0.55 * t);

    double baseWidth;
    double baseHeight;

    switch (type) {
      case ObstacleType.heavyHauler:
        baseWidth = roadWidthAtDepth * 0.23 * perspectiveScale;
        baseHeight = baseWidth * 2.4;
        break;
      case ObstacleType.cyberTruck:
        baseWidth = roadWidthAtDepth * 0.20 * perspectiveScale;
        baseHeight = baseWidth * 2.1;
        break;
      case ObstacleType.cyberSedan:
        baseWidth = roadWidthAtDepth * 0.17 * perspectiveScale;
        baseHeight = baseWidth * 1.9;
        break;
      case ObstacleType.energyBarrier:
        baseWidth = roadWidthAtDepth * 0.26 * perspectiveScale;
        baseHeight = baseWidth * 0.8;
        break;
    }

    final roadCenterX = (screenWidth / 2) + curveShift;
    final centerX = roadCenterX + (lanePosition * (roadWidthAtDepth / 2 - baseWidth * 0.6));

    return Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: baseWidth * 0.85,
      height: baseHeight * 0.85,
    );
  }
}
