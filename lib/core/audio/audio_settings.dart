import 'package:flutter/foundation.dart';
import '../storage/player_data_storage.dart';

/// Manages volume levels, mute states, and audio persistence preferences.
class AudioSettings extends ChangeNotifier {
  bool _masterMuted = false;
  double _masterVolume = 0.80;

  bool _musicMuted = false;
  double _musicVolume = 0.65;

  bool _sfxMuted = false;
  double _sfxVolume = 0.85;

  // Getters
  bool get masterMuted => _masterMuted;
  double get masterVolume => _masterVolume;

  bool get musicMuted => _musicMuted;
  double get musicVolume => _musicVolume;

  bool get sfxMuted => _sfxMuted;
  double get sfxVolume => _sfxVolume;

  /// Effective background music volume factoring master mute and master volume.
  double get effectiveMusicVolume {
    if (_masterMuted || _musicMuted) return 0.0;
    return (_masterVolume * _musicVolume).clamp(0.0, 1.0);
  }

  /// Effective sound effects volume factoring master mute and master volume.
  double get effectiveSfxVolume {
    if (_masterMuted || _sfxMuted) return 0.0;
    return (_masterVolume * _sfxVolume).clamp(0.0, 1.0);
  }

  void loadFromCareerData(PlayerCareerData data) {
    _masterVolume = data.masterVolume;
    _musicVolume = data.musicVolume;
    _sfxVolume = data.sfxVolume;
    _masterMuted = data.masterMuted;
    _musicMuted = data.musicMuted;
    _sfxMuted = data.sfxMuted;
    notifyListeners();
  }

  void _persist() {
    PlayerDataService.instance.saveAudioSettings(
      masterVolume: _masterVolume,
      musicVolume: _musicVolume,
      sfxVolume: _sfxVolume,
      masterMuted: _masterMuted,
      musicMuted: _musicMuted,
      sfxMuted: _sfxMuted,
    );
  }

  // Setters
  void setMasterMuted(bool muted) {
    if (_masterMuted == muted) return;
    _masterMuted = muted;
    _persist();
    notifyListeners();
  }

  void toggleMasterMute() => setMasterMuted(!_masterMuted);

  void setMasterVolume(double volume) {
    final clamped = volume.clamp(0.0, 1.0);
    if ((_masterVolume - clamped).abs() < 0.001) return;
    _masterVolume = clamped;
    _persist();
    notifyListeners();
  }

  void setMusicMuted(bool muted) {
    if (_musicMuted == muted) return;
    _musicMuted = muted;
    _persist();
    notifyListeners();
  }

  void toggleMusicMute() => setMusicMuted(!_musicMuted);

  void setMusicVolume(double volume) {
    final clamped = volume.clamp(0.0, 1.0);
    if ((_musicVolume - clamped).abs() < 0.001) return;
    _musicVolume = clamped;
    _persist();
    notifyListeners();
  }

  void setSfxMuted(bool muted) {
    if (_sfxMuted == muted) return;
    _sfxMuted = muted;
    _persist();
    notifyListeners();
  }

  void toggleSfxMute() => setSfxMuted(!_sfxMuted);

  void setSfxVolume(double volume) {
    final clamped = volume.clamp(0.0, 1.0);
    if ((_sfxVolume - clamped).abs() < 0.001) return;
    _sfxVolume = clamped;
    _persist();
    notifyListeners();
  }

  void resetDefaults() {
    _masterMuted = false;
    _masterVolume = 0.80;
    _musicMuted = false;
    _musicVolume = 0.65;
    _sfxMuted = false;
    _sfxVolume = 0.85;
    _persist();
    notifyListeners();
  }
}
