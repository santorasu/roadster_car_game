import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/audio/audio_settings.dart';
import '../../../../core/audio/game_audio_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Modal dialog for tuning Master, Music, and SFX volume levels and mute states.
class AudioSettingsDialog extends StatelessWidget {
  final AudioSettings settings;

  const AudioSettingsDialog({
    super.key,
    required this.settings,
  });

  static Future<void> show(BuildContext context, {AudioSettings? settings}) {
    final audioSettings = settings ?? GameAudioService.instance.settings;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => AudioSettingsDialog(settings: audioSettings),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: AnimatedBuilder(
        animation: settings,
        builder: (context, _) {
          return Container(
            constraints: BoxConstraints(maxWidth: 420.w),
            padding: EdgeInsets.all(22.r),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                  blurRadius: 28.r,
                  spreadRadius: 2.r,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            settings.masterMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                            color: settings.masterMuted ? AppColors.roadsterRed : const Color(0xFF00E5FF),
                            size: 22.r,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'AUDIO CONTROL',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      key: const Key('close_audio_settings_button'),
                      icon: Icon(Icons.close_rounded, color: Colors.white70, size: 22.r),
                      onPressed: () {
                        GameAudioService.instance.playUiTap();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Master Mute Switch Pill
                _buildToggleCard(
                  key: const Key('master_mute_toggle'),
                  title: 'MASTER AUDIO',
                  subtitle: settings.masterMuted ? 'ALL AUDIO MUTED' : 'SYSTEM ONLINE',
                  isMuted: settings.masterMuted,
                  onToggle: () {
                    GameAudioService.instance.playUiTap();
                    settings.toggleMasterMute();
                  },
                ),

                SizedBox(height: 14.h),

                // Master Volume Slider
                _buildVolumeSlider(
                  key: const Key('master_volume_slider'),
                  label: 'MASTER VOLUME',
                  value: settings.masterVolume,
                  isDisabled: settings.masterMuted,
                  color: const Color(0xFF00E5FF),
                  onChanged: (val) => settings.setMasterVolume(val),
                ),

                SizedBox(height: 12.h),

                // Music Volume Slider & Mute
                _buildVolumeSlider(
                  key: const Key('music_volume_slider'),
                  label: 'CYBER BGM',
                  value: settings.musicVolume,
                  isDisabled: settings.masterMuted || settings.musicMuted,
                  isMuted: settings.musicMuted,
                  color: const Color(0xFF7C4DFF),
                  onToggleMute: () {
                    GameAudioService.instance.playUiTap();
                    settings.toggleMusicMute();
                  },
                  onChanged: (val) => settings.setMusicVolume(val),
                ),

                SizedBox(height: 12.h),

                // SFX Volume Slider & Mute
                _buildVolumeSlider(
                  key: const Key('sfx_volume_slider'),
                  label: 'ENGINE & SFX',
                  value: settings.sfxVolume,
                  isDisabled: settings.masterMuted || settings.sfxMuted,
                  isMuted: settings.sfxMuted,
                  color: AppColors.roadsterRed,
                  onToggleMute: () {
                    GameAudioService.instance.playUiTap();
                    settings.toggleSfxMute();
                  },
                  onChanged: (val) => settings.setSfxVolume(val),
                ),

                SizedBox(height: 18.h),

                // Reset Button
                OutlinedButton.icon(
                  key: const Key('reset_audio_defaults_button'),
                  onPressed: () {
                    GameAudioService.instance.playUiTap();
                    settings.resetDefaults();
                  },
                  icon: Icon(Icons.refresh_rounded, size: 16.r, color: Colors.white70),
                  label: Text(
                    'RESTORE DEFAULTS',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.white70,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white24, width: 1.2),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleCard({
    required Key key,
    required String title,
    required String subtitle,
    required bool isMuted,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isMuted ? AppColors.roadsterRed.withValues(alpha: 0.15) : const Color(0xFF00E5FF).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isMuted ? AppColors.roadsterRed.withValues(alpha: 0.5) : const Color(0xFF00E5FF).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: isMuted ? AppColors.roadsterRed : const Color(0xFF00E5FF),
                ),
              ),
            ],
          ),
          IconButton(
            key: key,
            onPressed: onToggle,
            icon: Icon(
              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: isMuted ? AppColors.roadsterRed : const Color(0xFF00E5FF),
              size: 24.r,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider({
    required Key key,
    required String label,
    required double value,
    required bool isDisabled,
    required Color color,
    required ValueChanged<double> onChanged,
    bool isMuted = false,
    VoidCallback? onToggleMute,
  }) {
    final pct = (value * 100).round();
    final effectiveColor = isDisabled ? Colors.white30 : color;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.surfaceBorder.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (onToggleMute != null)
                    GestureDetector(
                      onTap: onToggleMute,
                      child: Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: Icon(
                          isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                          size: 16.r,
                          color: isMuted ? AppColors.roadsterRed : Colors.white70,
                        ),
                      ),
                    ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: isDisabled ? Colors.white38 : Colors.white70,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                isDisabled ? 'MUTED' : '$pct%',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  color: effectiveColor,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: effectiveColor,
              inactiveTrackColor: Colors.white12,
              thumbColor: effectiveColor,
              overlayColor: effectiveColor.withValues(alpha: 0.2),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.r),
              trackHeight: 3.h,
            ),
            child: Slider(
              key: key,
              value: value,
              min: 0.0,
              max: 1.0,
              onChanged: isDisabled ? null : onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
