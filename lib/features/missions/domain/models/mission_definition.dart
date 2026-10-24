import 'package:flutter/material.dart';
import '../../../arcade_driving/domain/models/arcade_game_state.dart';
import '../../../arcade_driving/domain/models/game_mode.dart';
import '../../../arcade_driving/domain/models/player_car.dart';

/// Categories of gameplay objectives for missions
enum MissionType {
  distance,
  speed,
  survivalDuration,
  cleanDrive,
  nearMisses,
  timeTrialDistance,
}

/// A discrete challenge objective with progress evaluation and one-time rewards
class MissionDefinition {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final double targetValue;
  final int rewardPoints;
  final IconData icon;

  const MissionDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.rewardPoints,
    required this.icon,
  });

  /// Evaluates whether the mission objective has been successfully met in the current session
  bool isSatisfied({
    required ArcadeGameState state,
    required PlayerCar player,
  }) {
    switch (type) {
      case MissionType.distance:
        return state.distanceMeters >= targetValue;

      case MissionType.speed:
        return state.topSpeedMph >= targetValue || player.speedMph >= targetValue;

      case MissionType.survivalDuration:
        return state.timeElapsedSeconds >= targetValue && player.health > 0.0;

      case MissionType.cleanDrive:
        return state.distanceMeters >= targetValue && state.collisionsCount == 0;

      case MissionType.nearMisses:
        return state.nearMissCount >= targetValue.toInt();

      case MissionType.timeTrialDistance:
        return state.gameMode == GameMode.timeTrial && state.distanceMeters >= targetValue;
    }
  }

  /// Calculates real-time progress towards the objective (0.0 to 1.0)
  double computeProgress({
    required ArcadeGameState state,
    required PlayerCar player,
  }) {
    switch (type) {
      case MissionType.distance:
        return (state.distanceMeters / targetValue).clamp(0.0, 1.0);

      case MissionType.speed:
        final maxSpeed = state.topSpeedMph > player.speedMph ? state.topSpeedMph : player.speedMph;
        return (maxSpeed / targetValue).clamp(0.0, 1.0);

      case MissionType.survivalDuration:
        return (state.timeElapsedSeconds / targetValue).clamp(0.0, 1.0);

      case MissionType.cleanDrive:
        if (state.collisionsCount > 0) return 0.0;
        return (state.distanceMeters / targetValue).clamp(0.0, 1.0);

      case MissionType.nearMisses:
        return (state.nearMissCount / targetValue).clamp(0.0, 1.0);

      case MissionType.timeTrialDistance:
        if (state.gameMode != GameMode.timeTrial) return 0.0;
        return (state.distanceMeters / targetValue).clamp(0.0, 1.0);
    }
  }

  /// Formatted readout of current status against target
  String formatProgressText({
    required ArcadeGameState state,
    required PlayerCar player,
    required bool isCompleted,
  }) {
    if (isCompleted) {
      return 'COMPLETED';
    }

    switch (type) {
      case MissionType.distance:
        return '${state.distanceMeters.toInt()}m / ${targetValue.toInt()}m';

      case MissionType.speed:
        final currentSpeed = state.topSpeedMph > player.speedMph ? state.topSpeedMph : player.speedMph;
        return '${currentSpeed.toInt()} / ${targetValue.toInt()} MPH';

      case MissionType.survivalDuration:
        return '${state.timeElapsedSeconds.toStringAsFixed(1)}s / ${targetValue.toInt()}s';

      case MissionType.cleanDrive:
        if (state.collisionsCount > 0) {
          return 'FAILED (Impact detected)';
        }
        return '${state.distanceMeters.toInt()}m / ${targetValue.toInt()}m (0 Hits)';

      case MissionType.nearMisses:
        return '${state.nearMissCount} / ${targetValue.toInt()} Passes';

      case MissionType.timeTrialDistance:
        if (state.gameMode != GameMode.timeTrial) {
          return 'Play in Time Trial Mode';
        }
        return '${state.distanceMeters.toInt()}m / ${targetValue.toInt()}m';
    }
  }

  /// Predefined mission catalog with balanced progression across all skill tiers
  static const List<MissionDefinition> allMissions = [
    MissionDefinition(
      id: 'first_launch',
      title: 'FIRST LAUNCH',
      description: 'Travel at least 500 meters in a single driving run',
      type: MissionType.distance,
      targetValue: 500.0,
      rewardPoints: 1000,
      icon: Icons.rocket_launch_rounded,
    ),
    MissionDefinition(
      id: 'velocity_breaker',
      title: 'VELOCITY BREAKER',
      description: 'Push your hypercar speed beyond 170 MPH',
      type: MissionType.speed,
      targetValue: 170.0,
      rewardPoints: 1500,
      icon: Icons.speed_rounded,
    ),
    MissionDefinition(
      id: 'ghost_drift',
      title: 'GHOST DRIFT',
      description: 'Travel 400 meters with zero vehicle collisions',
      type: MissionType.cleanDrive,
      targetValue: 400.0,
      rewardPoints: 2000,
      icon: Icons.shield_rounded,
    ),
    MissionDefinition(
      id: 'endurance_test',
      title: 'ENDURANCE TEST',
      description: 'Survive on the cyber highway for at least 40 continuous seconds',
      type: MissionType.survivalDuration,
      targetValue: 40.0,
      rewardPoints: 1500,
      icon: Icons.timer_outlined,
    ),
    MissionDefinition(
      id: 'hazard_slicer',
      title: 'HAZARD SLICER',
      description: 'Execute 4 close near-miss overtakes through highway traffic',
      type: MissionType.nearMisses,
      targetValue: 4.0,
      rewardPoints: 2500,
      icon: Icons.alt_route_rounded,
    ),
    MissionDefinition(
      id: 'chrono_sprinter',
      title: 'CHRONO SPRINTER',
      description: 'Cover at least 800 meters in Time Trial mode before the clock runs out',
      type: MissionType.timeTrialDistance,
      targetValue: 800.0,
      rewardPoints: 3000,
      icon: Icons.alarm_on_rounded,
    ),
    MissionDefinition(
      id: 'circuit_overload',
      title: 'CIRCUIT OVERLOAD',
      description: 'Travel 1,800 meters through highway curves and elevations',
      type: MissionType.distance,
      targetValue: 1800.0,
      rewardPoints: 3500,
      icon: Icons.electric_bolt_rounded,
    ),
    MissionDefinition(
      id: 'flawless_vector',
      title: 'FLAWLESS VECTOR',
      description: 'Drive 800 meters with immaculate control and zero collisions',
      type: MissionType.cleanDrive,
      targetValue: 800.0,
      rewardPoints: 5000,
      icon: Icons.workspace_premium_rounded,
    ),
  ];

  static MissionDefinition? getById(String id) {
    for (final m in allMissions) {
      if (m.id == id) return m;
    }
    return null;
  }
}
