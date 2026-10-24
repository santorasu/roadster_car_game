import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'audio_settings.dart';
import '../storage/player_data_storage.dart';


/// Centralized audio controller handling BGM, dynamic electric motor synthesis/looping,
/// collision SFX, and UI feedback with graceful fallbacks for missing assets or headless environments.
class GameAudioService {
  static final GameAudioService _instance = GameAudioService._internal();
  static GameAudioService get instance => _instance;

  final AudioSettings settings;

  // Audio Players
  AudioPlayer? _bgmPlayer;
  AudioPlayer? _enginePlayer;
  AudioPlayer? _collisionPlayer;
  AudioPlayer? _sparkPlayer;
  AudioPlayer? _uiPlayer;

  bool _isInitialized = false;
  bool _isPlayingBgm = false;
  bool _isEngineLooping = false;
  bool _isSuspended = false;

  // Debouncing & Throttling
  DateTime _lastCollisionSoundTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastSparkSoundTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastEngineUpdateTime = DateTime.fromMillisecondsSinceEpoch(0);

  // Test mode flag allows running under flutter_test without MissingPluginException
  bool isTestMode = false;

  GameAudioService._internal({AudioSettings? customSettings})
      : settings = customSettings ?? AudioSettings() {
    settings.addListener(_onSettingsChanged);
  }

  /// Factory constructor allowing injection for testing
  factory GameAudioService.custom({AudioSettings? settings, bool isTestMode = false}) {
    final service = GameAudioService._internal(customSettings: settings);
    service.isTestMode = isTestMode;
    return service;
  }

  /// Lazily initialize players with safe error handling
  Future<void> initialize() async {
    if (_isInitialized || isTestMode) return;

    try {
      final careerData = await PlayerDataService.instance.loadCareerData();
      settings.loadFromCareerData(careerData);

      _bgmPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
      _enginePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
      _collisionPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      _sparkPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      _uiPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

      _isInitialized = true;
    } catch (e) {
      debugPrint('GameAudioService: Initialization error (running in fallback mode): $e');
    }
  }

  void _onSettingsChanged() {
    if (isTestMode) return;

    try {
      if (_bgmPlayer != null) {
        _bgmPlayer!.setVolume(settings.effectiveMusicVolume);
      }
      if (_enginePlayer != null) {
        final baseEngineVol = settings.effectiveSfxVolume * 0.75;
        _enginePlayer!.setVolume(baseEngineVol);
      }
    } catch (e) {
      debugPrint('GameAudioService: Volume adjustment fallback: $e');
    }
  }

  /// Start playing the cyber synthwave soundtrack
  Future<void> startBgm() async {
    if (isTestMode || _isPlayingBgm || _isSuspended) return;
    await initialize();

    try {
      final vol = settings.effectiveMusicVolume;
      await _bgmPlayer?.setVolume(vol);
      await _bgmPlayer?.play(AssetSource('audio/bgm_cyber_drive.wav'));
      _isPlayingBgm = true;
    } catch (e) {
      debugPrint('GameAudioService: BGM asset playback fallback: $e');
      _isPlayingBgm = false;
    }
  }

  /// Stop or pause background music
  Future<void> stopBgm() async {
    if (isTestMode || !_isPlayingBgm) return;
    try {
      await _bgmPlayer?.stop();
    } catch (e) {
      debugPrint('GameAudioService: Stop BGM fallback: $e');
    } finally {
      _isPlayingBgm = false;
    }
  }

  /// Update electric hypercar motor whine pitch and amplitude based on speed and throttle
  Future<void> updateEngineSound({
    required double speedMph,
    required bool isAccelerating,
    required bool isBraking,
  }) async {
    if (isTestMode || _isSuspended) return;

    final now = DateTime.now();
    if (now.difference(_lastEngineUpdateTime).inMilliseconds < 120) {
      return; // Throttle rate adjustments to prevent audio buffer underruns
    }
    _lastEngineUpdateTime = now;

    await initialize();

    try {
      if (!_isEngineLooping && _enginePlayer != null) {
        await _enginePlayer!.setVolume(settings.effectiveSfxVolume * 0.6);
        await _enginePlayer!.play(AssetSource('audio/sfx_engine_loop.wav'));
        _isEngineLooping = true;
      }

      // Pitch modulation: 0.8x at 20 MPH up to 1.9x at 250 MPH
      final speedRatio = (speedMph / 250.0).clamp(0.0, 1.0);
      final targetPlaybackRate = 0.8 + 1.1 * speedRatio;
      await _enginePlayer?.setPlaybackRate(targetPlaybackRate);

      // Volume responds dynamically to drive pedal boost
      double engineVolumeFactor = 0.5 + 0.3 * speedRatio;
      if (isAccelerating) {
        engineVolumeFactor = math.min(1.0, engineVolumeFactor + 0.25);
      } else if (isBraking) {
        engineVolumeFactor = math.max(0.3, engineVolumeFactor - 0.2);
      }

      await _enginePlayer?.setVolume(settings.effectiveSfxVolume * engineVolumeFactor);
    } catch (e) {
      debugPrint('GameAudioService: Engine sound modulation fallback: $e');
    }
  }

  /// Stop engine loop
  Future<void> stopEngineSound() async {
    if (isTestMode || !_isEngineLooping) return;
    try {
      await _enginePlayer?.stop();
    } catch (e) {
      debugPrint('GameAudioService: Stop engine fallback: $e');
    } finally {
      _isEngineLooping = false;
    }
  }

  /// Trigger obstacle collision impact sound
  Future<void> playCollision() async {
    if (isTestMode || _isSuspended) return;

    final now = DateTime.now();
    if (now.difference(_lastCollisionSoundTime).inMilliseconds < 180) {
      return; // Debounce multiple simultaneous physics contact points
    }
    _lastCollisionSoundTime = now;

    await initialize();

    try {
      await _collisionPlayer?.setVolume(settings.effectiveSfxVolume);
      await _collisionPlayer?.stop();
      await _collisionPlayer?.play(AssetSource('audio/sfx_collision.wav'));
    } catch (e) {
      debugPrint('GameAudioService: Collision sound fallback: $e');
    }
  }

  /// Trigger road boundary spark sizzle sound
  Future<void> playVergeSpark() async {
    if (isTestMode || _isSuspended) return;

    final now = DateTime.now();
    if (now.difference(_lastSparkSoundTime).inMilliseconds < 150) {
      return; // Debounce continuous verge sparks
    }
    _lastSparkSoundTime = now;

    await initialize();

    try {
      await _sparkPlayer?.setVolume(settings.effectiveSfxVolume * 0.7);
      await _sparkPlayer?.stop();
      await _sparkPlayer?.play(AssetSource('audio/sfx_verge_spark.wav'));
    } catch (e) {
      debugPrint('GameAudioService: Spark sound fallback: $e');
    }
  }

  /// Trigger futuristic UI button tap sound
  Future<void> playUiTap() async {
    if (isTestMode || _isSuspended) return;
    await initialize();

    try {
      await _uiPlayer?.setVolume(settings.effectiveSfxVolume);
      await _uiPlayer?.stop();
      await _uiPlayer?.play(AssetSource('audio/sfx_ui_tap.wav'));
    } catch (e) {
      debugPrint('GameAudioService: UI tap sound fallback: $e');
    }
  }

  /// Suspend all audio (when paused or app sent to background)
  Future<void> pauseAll() async {
    if (isTestMode) return;
    _isSuspended = true;

    try {
      await _bgmPlayer?.pause();
      await _enginePlayer?.pause();
      await _collisionPlayer?.stop();
      await _sparkPlayer?.stop();
      await _uiPlayer?.stop();
    } catch (e) {
      debugPrint('GameAudioService: Pause all fallback: $e');
    }
  }

  /// Resume active audio streams (when resumed from pause or foregrounded)
  Future<void> resumeAll() async {
    if (isTestMode) return;
    _isSuspended = false;

    try {
      if (_isPlayingBgm) {
        await _bgmPlayer?.resume();
      }
      if (_isEngineLooping) {
        await _enginePlayer?.resume();
      }
    } catch (e) {
      debugPrint('GameAudioService: Resume all fallback: $e');
    }
  }

  /// Handle Android OS lifecycle state changes
  void handleLifecycleChange(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      pauseAll();
    } else if (state == AppLifecycleState.resumed) {
      resumeAll();
    }
  }

  /// Cleanly release all audio players and resources
  Future<void> dispose() async {
    settings.removeListener(_onSettingsChanged);
    _isPlayingBgm = false;
    _isEngineLooping = false;

    if (!isTestMode) {
      try {
        await _bgmPlayer?.dispose();
        await _enginePlayer?.dispose();
        await _collisionPlayer?.dispose();
        await _sparkPlayer?.dispose();
        await _uiPlayer?.dispose();
      } catch (e) {
        debugPrint('GameAudioService: Dispose fallback: $e');
      }
    }

    _bgmPlayer = null;
    _enginePlayer = null;
    _collisionPlayer = null;
    _sparkPlayer = null;
    _uiPlayer = null;
    _isInitialized = false;
  }
}
