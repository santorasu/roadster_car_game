import 'package:flutter/material.dart';

/// Supported arcade game modes
enum GameMode {
  endlessDrive,
  timeTrial,
}

/// Metadata and gameplay parameters for each game mode
class GameModeInfo {
  final GameMode mode;
  final String id;
  final String title;
  final String shortTitle;
  final String tagline;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final double defaultTimeLimitSeconds;
  final double nearMissBonusSeconds;

  const GameModeInfo({
    required this.mode,
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.primaryColor,
    this.defaultTimeLimitSeconds = 0.0,
    this.nearMissBonusSeconds = 0.0,
  });

  static const GameModeInfo endless = GameModeInfo(
    mode: GameMode.endlessDrive,
    id: 'endless',
    title: 'ENDLESS DRIVE',
    shortTitle: 'ENDLESS',
    tagline: 'Survive the cyber highway and maximize score',
    description: 'Push your electric hypercar to the limit. Overtake traffic, navigate hazardous curves and elevations, and accumulate combo multipliers until hull depletion.',
    icon: Icons.all_inclusive_rounded,
    primaryColor: Color(0xFF00E5FF), // Cyan
    defaultTimeLimitSeconds: 0.0,
    nearMissBonusSeconds: 0.0,
  );

  static const GameModeInfo timeTrial = GameModeInfo(
    mode: GameMode.timeTrial,
    id: 'time_trial',
    title: 'TIME TRIAL (60s)',
    shortTitle: 'TIME TRIAL',
    tagline: 'Race against the clock to maximize distance',
    description: 'Sprint across the cyber grid with a 60-second countdown. Perform near-miss overtakes to gain +1.5s time extensions and cover maximum distance before time expires.',
    icon: Icons.timer_outlined,
    primaryColor: Color(0xFFFF9100), // Amber
    defaultTimeLimitSeconds: 60.0,
    nearMissBonusSeconds: 1.5,
  );

  static const List<GameModeInfo> allModes = [endless, timeTrial];

  static GameModeInfo getByMode(GameMode mode) {
    return mode == GameMode.timeTrial ? timeTrial : endless;
  }

  static GameModeInfo getById(String id) {
    return id == 'time_trial' ? timeTrial : endless;
  }
}
