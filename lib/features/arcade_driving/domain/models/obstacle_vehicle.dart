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

  /// Get bounding rectangle in screen coordinates
  Rect getBoundingRect(double screenWidth, double screenHeight) {
    final roadWidth = screenWidth * 0.72;
    // Perspective scaling: obstacles near horizon (yProgress near 0.1) are smaller than near bottom
    final perspectiveScale = 0.5 + (0.5 * yProgress.clamp(0.0, 1.0));

    double baseWidth;
    double baseHeight;

    switch (type) {
      case ObstacleType.heavyHauler:
        baseWidth = roadWidth * 0.22 * perspectiveScale;
        baseHeight = baseWidth * 2.4;
        break;
      case ObstacleType.cyberTruck:
        baseWidth = roadWidth * 0.19 * perspectiveScale;
        baseHeight = baseWidth * 2.1;
        break;
      case ObstacleType.cyberSedan:
        baseWidth = roadWidth * 0.16 * perspectiveScale;
        baseHeight = baseWidth * 1.9;
        break;
      case ObstacleType.energyBarrier:
        baseWidth = roadWidth * 0.24 * perspectiveScale;
        baseHeight = baseWidth * 0.8;
        break;
    }

    final centerX = (screenWidth / 2) + (lanePosition * (roadWidth / 2 - baseWidth * 0.6));
    final centerY = screenHeight * yProgress;

    return Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: baseWidth * 0.85,
      height: baseHeight * 0.85,
    );
  }
}
