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

/// Driving behavior archetypes for traffic vehicles (Feature 10)
enum TrafficBehavior {
  cruiser,       // Maintains steady speed in current lane
  laneChanger,   // Changes lanes periodically when safe gap exists
  speedAdjuster, // Monitors obstacle ahead, brakes to avoid collision
  aggressive,    // Faster, weaves between lanes when blocked
  hazard,        // Stationary or fixed hazard (energy barrier)
}

/// Dynamic obstacle vehicle or road hazard with autonomous AI
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

  /// Has this obstacle already awarded a near-miss bonus?
  bool hasAwardedNearMiss;

  // Feature 10: Advanced Traffic AI & Behavior state
  TrafficBehavior behavior;
  double desiredSpeedMph;
  double initialLanePosition;
  double targetLanePosition;
  double laneChangeProgress; // -1.0 = not changing, 0.0 to 1.0 = transitioning
  double laneChangeDuration;
  double laneChangeTimer;    // Cooldown timer until next lane change attempt
  int laneChangeDirection;   // -1 = left, 1 = right, 0 = none
  double blinkTimer;         // Turn signal indicator animation
  bool isBraking;            // Active braking state due to vehicle ahead
  double safeGapY;           // Vertical gap threshold for following/changing lanes

  ObstacleVehicle({
    required this.id,
    required this.type,
    required this.color,
    required this.lanePosition,
    required this.yProgress,
    required this.speedMph,
    this.hasCollided = false,
    this.hasAwardedNearMiss = false,
    TrafficBehavior? behavior,
    double? desiredSpeedMph,
    this.laneChangeProgress = -1.0,
    double? initialLanePosition,
    double? targetLanePosition,
    this.laneChangeDuration = 1.4,
    this.laneChangeTimer = 2.5,
    this.laneChangeDirection = 0,
    this.blinkTimer = 0.0,
    this.isBraking = false,
    this.safeGapY = 0.14,
  })  : behavior = behavior ?? defaultBehaviorForType(type),
        desiredSpeedMph = desiredSpeedMph ?? speedMph,
        initialLanePosition = initialLanePosition ?? lanePosition,
        targetLanePosition = targetLanePosition ?? lanePosition;

  /// Whether this vehicle is currently actively transitioning between lanes
  bool get isChangingLane => laneChangeProgress >= 0.0 && laneChangeProgress < 1.0;

  static TrafficBehavior defaultBehaviorForType(ObstacleType type) {
    switch (type) {
      case ObstacleType.energyBarrier:
        return TrafficBehavior.hazard;
      case ObstacleType.heavyHauler:
        return TrafficBehavior.cruiser;
      case ObstacleType.cyberTruck:
        return TrafficBehavior.speedAdjuster;
      case ObstacleType.cyberSedan:
        return TrafficBehavior.laneChanger;
    }
  }

  /// Updates autonomous driving AI: speed adjustment, safe following, and controlled lane changes
  void updateAI(
    double dt,
    List<ObstacleVehicle> allObstacles,
    List<double> availableLanes,
    double playerLanePosition,
    double playerSpeedMph,
  ) {
    if (behavior == TrafficBehavior.hazard) return;

    blinkTimer += dt;

    // 1. Process Active Lane Change Transition
    if (isChangingLane) {
      laneChangeProgress += dt / math.max(0.2, laneChangeDuration);
      if (laneChangeProgress >= 1.0) {
        lanePosition = targetLanePosition;
        initialLanePosition = targetLanePosition;
        laneChangeProgress = -1.0;
        laneChangeDirection = 0;
        laneChangeTimer = 3.5 + (id.hashCode.abs() % 30) * 0.1;
      } else {
        final t = laneChangeProgress.clamp(0.0, 1.0);
        // Cubic smoothstep interpolation for smooth physical steering
        final smoothT = t * t * (3.0 - 2.0 * t);
        lanePosition = initialLanePosition + (targetLanePosition - initialLanePosition) * smoothT;
      }
    }

    // 2. Safe-Gap Following & Collision Avoidance (vehicles ahead on road)
    // On screen, yProgress increases downwards. A vehicle ahead of this obstacle has a LARGER yProgress.
    ObstacleVehicle? leadVehicle;
    double minGapToLead = double.infinity;

    for (final other in allObstacles) {
      if (other.id == id) continue;

      // Check if other vehicle is roughly in the same lane
      final inSameLane = (other.lanePosition - lanePosition).abs() < 0.35 ||
          (isChangingLane && (other.lanePosition - targetLanePosition).abs() < 0.35);

      if (inSameLane && other.yProgress > yProgress) {
        final gap = other.yProgress - yProgress;
        if (gap < minGapToLead) {
          minGapToLead = gap;
          leadVehicle = other;
        }
      }
    }

    if (leadVehicle != null && minGapToLead < safeGapY) {
      // Vehicle ahead is too close: brake to avoid collision
      isBraking = true;
      final targetSpeed = math.min(desiredSpeedMph, leadVehicle.speedMph * 0.95);
      if (speedMph > targetSpeed) {
        speedMph = math.max(15.0, speedMph - 45.0 * dt);
      }

      // Proactive lane change if blocked
      if (!isChangingLane && (behavior == TrafficBehavior.laneChanger || behavior == TrafficBehavior.aggressive)) {
        if (laneChangeTimer > 0.4) {
          laneChangeTimer = 0.4; // Expedite lane change
        }
      }
    } else {
      // Clear road ahead: smoothly accelerate back to cruise speed
      isBraking = false;
      if (speedMph < desiredSpeedMph) {
        speedMph = math.min(desiredSpeedMph, speedMph + 25.0 * dt);
      }
    }

    // 3. Periodic Lane Change Decision
    if (!isChangingLane && (behavior == TrafficBehavior.laneChanger || behavior == TrafficBehavior.aggressive)) {
      laneChangeTimer -= dt;

      if (laneChangeTimer <= 0.0) {
        laneChangeTimer = (behavior == TrafficBehavior.aggressive) ? 2.5 : 4.0;
        _evaluateAndInitiateLaneChange(allObstacles, availableLanes, playerLanePosition);
      }
    }
  }

  /// Evaluates adjacent lanes and initiates a transition if a safe gap is verified
  void _evaluateAndInitiateLaneChange(
    List<ObstacleVehicle> allObstacles,
    List<double> availableLanes,
    double playerLanePosition,
  ) {
    // Find closest current lane index
    int currentLaneIndex = 0;
    double minLaneDist = double.infinity;
    for (int i = 0; i < availableLanes.length; i++) {
      final dist = (availableLanes[i] - lanePosition).abs();
      if (dist < minLaneDist) {
        minLaneDist = dist;
        currentLaneIndex = i;
      }
    }

    // Identify candidate adjacent lanes
    final candidateIndices = <int>[];
    if (currentLaneIndex > 0) candidateIndices.add(currentLaneIndex - 1);
    if (currentLaneIndex < availableLanes.length - 1) candidateIndices.add(currentLaneIndex + 1);

    if (candidateIndices.isEmpty) return;

    // Shuffle to vary lane change decisions
    candidateIndices.shuffle();

    for (final candIdx in candidateIndices) {
      final candLane = availableLanes[candIdx];

      // Safe-gap verification in candidate lane
      bool isSafe = true;
      for (final other in allObstacles) {
        if (other.id == id) continue;

        // Check if other is currently in or moving into the candidate lane
        final otherInCand = (other.lanePosition - candLane).abs() < 0.35 ||
            (other.isChangingLane && (other.targetLanePosition - candLane).abs() < 0.35);

        if (otherInCand) {
          final verticalGap = (other.yProgress - yProgress).abs();
          if (verticalGap < safeGapY * 1.35) {
            isSafe = false;
            break;
          }
        }
      }

      // Safe check against player: don't aggressively cut off player when close beside
      if (isSafe && yProgress > 0.60 && yProgress < 0.88) {
        final playerInCand = (playerLanePosition - candLane).abs() < 0.35;
        if (playerInCand) {
          isSafe = false;
        }
      }

      if (isSafe) {
        // Safe gap verified: initiate lane change!
        initialLanePosition = lanePosition;
        targetLanePosition = candLane;
        laneChangeProgress = 0.0;
        laneChangeDirection = candLane > lanePosition ? 1 : -1;
        laneChangeDuration = (behavior == TrafficBehavior.aggressive) ? 1.0 : 1.5;
        blinkTimer = 0.0;
        return;
      }
    }
  }

  /// Get bounding rectangle in screen coordinates, accounting for road curvature and elevation
  Rect getBoundingRect(
    double screenWidth,
    double screenHeight, [
    double curveOffset = 0.0,
    double elevationOffset = 0.0,
  ]) {
    final horizonY = screenHeight * 0.18;
    final baseCenterY = screenHeight * yProgress;
    final t = ((baseCenterY - horizonY) / (screenHeight - horizonY)).clamp(0.0, 1.0);

    // Lateral displacement of road centerline due to curvature at depth t
    final maxHorizonShift = screenWidth * 0.28;
    final curveShift = curveOffset * maxHorizonShift * math.pow(1.0 - t, 2.0);

    // Vertical displacement of road centerline due to elevation at depth t
    final maxElevationShift = screenHeight * 0.12;
    final elevationShift = elevationOffset * maxElevationShift * math.pow(1.0 - t, 2.0);
    final centerY = baseCenterY - elevationShift;

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
