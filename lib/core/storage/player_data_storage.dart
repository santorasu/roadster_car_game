import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Milestone achievements unlocked during arcade driving career
class CareerMilestone {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const CareerMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  static const List<CareerMilestone> allMilestones = [
    CareerMilestone(
      id: 'initiation',
      title: 'TEST PILOT',
      description: 'Completed your first simulation run',
      icon: Icons.flag_rounded,
    ),
    CareerMilestone(
      id: 'century',
      title: 'CENTURY CLUB',
      description: 'Exceeded 100 MPH driving speed',
      icon: Icons.speed_rounded,
    ),
    CareerMilestone(
      id: 'warp_speed',
      title: 'WARP VELOCITY',
      description: 'Pushed hypercar beyond 150 MPH',
      icon: Icons.bolt_rounded,
    ),
    CareerMilestone(
      id: 'hyperdrive',
      title: 'HYPERDRIVE',
      description: 'Achieved blistering 200+ MPH top speed',
      icon: Icons.rocket_launch_rounded,
    ),
    CareerMilestone(
      id: 'endurance',
      title: 'ENDURANCE TIER I',
      description: 'Traveled over 1,000 meters in a single run',
      icon: Icons.route_rounded,
    ),
    CareerMilestone(
      id: 'circuit_master',
      title: 'CIRCUIT MASTER',
      description: 'Completed a full 3,000m track circuit loop',
      icon: Icons.all_inclusive_rounded,
    ),
    CareerMilestone(
      id: 'high_roller',
      title: 'HIGH ROLLER',
      description: 'Accumulated over 25,000 points in one session',
      icon: Icons.stars_rounded,
    ),
    CareerMilestone(
      id: 'cyber_legend',
      title: 'CYBER LEGEND',
      description: 'Mastered the arcade grid with 50,000+ points',
      icon: Icons.military_tech_rounded,
    ),
    CareerMilestone(
      id: 'overpass_climber',
      title: 'OVERPASS CLIMBER',
      description: 'Conquered the Sector 6 Circuit Overpass elevation climb',
      icon: Icons.terrain_rounded,
    ),
  ];

  static CareerMilestone? getById(String id) {
    for (final m in allMilestones) {
      if (m.id == id) return m;
    }
    return null;
  }
}

/// Immutable snapshot of persistent player career records and audio preferences
class PlayerCareerData {
  final int highScore;
  final double bestDistanceMeters;
  final double topSpeedMph;
  final int totalRaces;
  final int sectorsCleared;
  final Set<String> unlockedMilestones;

  // Persisted audio settings
  final double masterVolume;
  final double musicVolume;
  final double sfxVolume;
  final bool masterMuted;
  final bool musicMuted;
  final bool sfxMuted;

  const PlayerCareerData({
    this.highScore = 0,
    this.bestDistanceMeters = 0.0,
    this.topSpeedMph = 0.0,
    this.totalRaces = 0,
    this.sectorsCleared = 0,
    this.unlockedMilestones = const {},
    this.masterVolume = 0.80,
    this.musicVolume = 0.65,
    this.sfxVolume = 0.85,
    this.masterMuted = false,
    this.musicMuted = false,
    this.sfxMuted = false,
  });

  PlayerCareerData copyWith({
    int? highScore,
    double? bestDistanceMeters,
    double? topSpeedMph,
    int? totalRaces,
    int? sectorsCleared,
    Set<String>? unlockedMilestones,
    double? masterVolume,
    double? musicVolume,
    double? sfxVolume,
    bool? masterMuted,
    bool? musicMuted,
    bool? sfxMuted,
  }) {
    return PlayerCareerData(
      highScore: highScore ?? this.highScore,
      bestDistanceMeters: bestDistanceMeters ?? this.bestDistanceMeters,
      topSpeedMph: topSpeedMph ?? this.topSpeedMph,
      totalRaces: totalRaces ?? this.totalRaces,
      sectorsCleared: sectorsCleared ?? this.sectorsCleared,
      unlockedMilestones: unlockedMilestones ?? this.unlockedMilestones,
      masterVolume: masterVolume ?? this.masterVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      masterMuted: masterMuted ?? this.masterMuted,
      musicMuted: musicMuted ?? this.musicMuted,
      sfxMuted: sfxMuted ?? this.sfxMuted,
    );
  }
}

/// Abstract contract for player data persistence
abstract class PlayerDataStorage {
  Future<PlayerCareerData> loadCareerData();
  Future<void> saveCareerData(PlayerCareerData data);

  /// Evaluates session metrics, updates all-time bests, saves data,
  /// and returns the list of newly unlocked milestone IDs.
  Future<List<String>> recordSession({
    required int score,
    required double distanceMeters,
    required double topSpeedMph,
    required int sectorsCleared,
  });

  Future<void> saveAudioSettings({
    required double masterVolume,
    required double musicVolume,
    required double sfxVolume,
    required bool masterMuted,
    required bool musicMuted,
    required bool sfxMuted,
  });
}

/// SharedPreferences implementation for on-device local Android storage
class SharedPreferencesPlayerDataStorage implements PlayerDataStorage {
  static const String _keyHighScore = 'roadster_career_high_score';
  static const String _keyBestDistance = 'roadster_career_best_distance';
  static const String _keyTopSpeed = 'roadster_career_top_speed';
  static const String _keyTotalRaces = 'roadster_career_total_races';
  static const String _keySectorsCleared = 'roadster_career_sectors_cleared';
  static const String _keyMilestones = 'roadster_career_milestones';

  static const String _keyMasterVol = 'roadster_audio_master_vol';
  static const String _keyMusicVol = 'roadster_audio_music_vol';
  static const String _keySfxVol = 'roadster_audio_sfx_vol';
  static const String _keyMasterMuted = 'roadster_audio_master_muted';
  static const String _keyMusicMuted = 'roadster_audio_music_muted';
  static const String _keySfxMuted = 'roadster_audio_sfx_muted';

  @override
  Future<PlayerCareerData> loadCareerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final milestonesList = prefs.getStringList(_keyMilestones) ?? [];

      return PlayerCareerData(
        highScore: prefs.getInt(_keyHighScore) ?? 0,
        bestDistanceMeters: prefs.getDouble(_keyBestDistance) ?? 0.0,
        topSpeedMph: prefs.getDouble(_keyTopSpeed) ?? 0.0,
        totalRaces: prefs.getInt(_keyTotalRaces) ?? 0,
        sectorsCleared: prefs.getInt(_keySectorsCleared) ?? 0,
        unlockedMilestones: milestonesList.toSet(),
        masterVolume: prefs.getDouble(_keyMasterVol) ?? 0.80,
        musicVolume: prefs.getDouble(_keyMusicVol) ?? 0.65,
        sfxVolume: prefs.getDouble(_keySfxVol) ?? 0.85,
        masterMuted: prefs.getBool(_keyMasterMuted) ?? false,
        musicMuted: prefs.getBool(_keyMusicMuted) ?? false,
        sfxMuted: prefs.getBool(_keySfxMuted) ?? false,
      );
    } catch (e) {
      debugPrint('SharedPreferencesPlayerDataStorage load error (using defaults): $e');
      return const PlayerCareerData();
    }
  }

  @override
  Future<void> saveCareerData(PlayerCareerData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyHighScore, data.highScore);
      await prefs.setDouble(_keyBestDistance, data.bestDistanceMeters);
      await prefs.setDouble(_keyTopSpeed, data.topSpeedMph);
      await prefs.setInt(_keyTotalRaces, data.totalRaces);
      await prefs.setInt(_keySectorsCleared, data.sectorsCleared);
      await prefs.setStringList(_keyMilestones, data.unlockedMilestones.toList());
      await prefs.setDouble(_keyMasterVol, data.masterVolume);
      await prefs.setDouble(_keyMusicVol, data.musicVolume);
      await prefs.setDouble(_keySfxVol, data.sfxVolume);
      await prefs.setBool(_keyMasterMuted, data.masterMuted);
      await prefs.setBool(_keyMusicMuted, data.musicMuted);
      await prefs.setBool(_keySfxMuted, data.sfxMuted);
      PlayerDataService.notifyDataChanged();
    } catch (e) {
      debugPrint('SharedPreferencesPlayerDataStorage save error: $e');
    }
  }

  @override
  Future<List<String>> recordSession({
    required int score,
    required double distanceMeters,
    required double topSpeedMph,
    required int sectorsCleared,
  }) async {
    final current = await loadCareerData();

    final newHighScore = score > current.highScore ? score : current.highScore;
    final newBestDist = distanceMeters > current.bestDistanceMeters
        ? distanceMeters
        : current.bestDistanceMeters;
    final newTopSpeed = topSpeedMph > current.topSpeedMph ? topSpeedMph : current.topSpeedMph;
    final newTotalRaces = current.totalRaces + 1;
    final newSectors = current.sectorsCleared + sectorsCleared;

    final updatedMilestones = Set<String>.from(current.unlockedMilestones);
    final newlyUnlocked = <String>[];

    void checkMilestone(String id, bool condition) {
      if (condition && !updatedMilestones.contains(id)) {
        updatedMilestones.add(id);
        newlyUnlocked.add(id);
      }
    }

    checkMilestone('initiation', true);
    checkMilestone('century', topSpeedMph >= 100.0);
    checkMilestone('warp_speed', topSpeedMph >= 150.0);
    checkMilestone('hyperdrive', topSpeedMph >= 200.0);
    checkMilestone('endurance', distanceMeters >= 1000.0);
    checkMilestone('circuit_master', distanceMeters >= 3000.0);
    checkMilestone('high_roller', score >= 25000);
    checkMilestone('cyber_legend', score >= 50000);
    checkMilestone('overpass_climber', distanceMeters >= 1500.0);

    final updated = current.copyWith(
      highScore: newHighScore,
      bestDistanceMeters: newBestDist,
      topSpeedMph: newTopSpeed,
      totalRaces: newTotalRaces,
      sectorsCleared: newSectors,
      unlockedMilestones: updatedMilestones,
    );

    await saveCareerData(updated);
    return newlyUnlocked;
  }

  @override
  Future<void> saveAudioSettings({
    required double masterVolume,
    required double musicVolume,
    required double sfxVolume,
    required bool masterMuted,
    required bool musicMuted,
    required bool sfxMuted,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyMasterVol, masterVolume);
      await prefs.setDouble(_keyMusicVol, musicVolume);
      await prefs.setDouble(_keySfxVol, sfxVolume);
      await prefs.setBool(_keyMasterMuted, masterMuted);
      await prefs.setBool(_keyMusicMuted, musicMuted);
      await prefs.setBool(_keySfxMuted, sfxMuted);
    } catch (e) {
      debugPrint('SharedPreferencesPlayerDataStorage audio save error: $e');
    }
  }
}

/// In-memory storage implementation for deterministic, isolated unit and widget tests
class InMemoryPlayerDataStorage implements PlayerDataStorage {
  PlayerCareerData data;

  InMemoryPlayerDataStorage([PlayerCareerData? initialData])
      : data = initialData ?? const PlayerCareerData();

  @override
  Future<PlayerCareerData> loadCareerData() async => data;

  @override
  Future<void> saveCareerData(PlayerCareerData updated) async {
    data = updated;
  }

  @override
  Future<List<String>> recordSession({
    required int score,
    required double distanceMeters,
    required double topSpeedMph,
    required int sectorsCleared,
  }) async {
    final newHighScore = score > data.highScore ? score : data.highScore;
    final newBestDist = distanceMeters > data.bestDistanceMeters
        ? distanceMeters
        : data.bestDistanceMeters;
    final newTopSpeed = topSpeedMph > data.topSpeedMph ? topSpeedMph : data.topSpeedMph;
    final newTotalRaces = data.totalRaces + 1;
    final newSectors = data.sectorsCleared + sectorsCleared;

    final updatedMilestones = Set<String>.from(data.unlockedMilestones);
    final newlyUnlocked = <String>[];

    void checkMilestone(String id, bool condition) {
      if (condition && !updatedMilestones.contains(id)) {
        updatedMilestones.add(id);
        newlyUnlocked.add(id);
      }
    }

    checkMilestone('initiation', true);
    checkMilestone('century', topSpeedMph >= 100.0);
    checkMilestone('warp_speed', topSpeedMph >= 150.0);
    checkMilestone('hyperdrive', topSpeedMph >= 200.0);
    checkMilestone('endurance', distanceMeters >= 1000.0);
    checkMilestone('circuit_master', distanceMeters >= 3000.0);
    checkMilestone('high_roller', score >= 25000);
    checkMilestone('cyber_legend', score >= 50000);
    checkMilestone('overpass_climber', distanceMeters >= 1500.0);

    data = data.copyWith(
      highScore: newHighScore,
      bestDistanceMeters: newBestDist,
      topSpeedMph: newTopSpeed,
      totalRaces: newTotalRaces,
      sectorsCleared: newSectors,
      unlockedMilestones: updatedMilestones,
    );

    PlayerDataService.notifyDataChanged();
    return newlyUnlocked;
  }

  @override
  Future<void> saveAudioSettings({
    required double masterVolume,
    required double musicVolume,
    required double sfxVolume,
    required bool masterMuted,
    required bool musicMuted,
    required bool sfxMuted,
  }) async {
    data = data.copyWith(
      masterVolume: masterVolume,
      musicVolume: musicVolume,
      sfxVolume: sfxVolume,
      masterMuted: masterMuted,
      musicMuted: musicMuted,
      sfxMuted: sfxMuted,
    );
    PlayerDataService.notifyDataChanged();
  }
}

/// Service locator for player career data storage
class PlayerDataService {
  static PlayerDataStorage instance = SharedPreferencesPlayerDataStorage();
  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  static void notifyDataChanged() {
    changeNotifier.value++;
  }
}
