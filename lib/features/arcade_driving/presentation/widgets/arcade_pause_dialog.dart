import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/audio/game_audio_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyber_button.dart';
import 'audio_settings_dialog.dart';

/// Pause overlay dialog with audio settings, resume, restart, and exit actions.
class ArcadePauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const ArcadePauseDialog({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.all(22.r),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.94),
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
            children: [
              // Header Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pause_circle_outline_rounded,
                      color: const Color(0xFF00E5FF),
                      size: 15.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'SIMULATION PAUSED',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: const Color(0xFF00E5FF),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              Text(
                'MISSION ON HOLD',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6.h),

              Text(
                'Hypercar drive loop suspended. Adjust audio or choose navigation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20.h),

              // Action Buttons
              CyberButton(
                key: const Key('resume_game_button'),
                text: 'Resume Drive',
                icon: Icons.play_arrow_rounded,
                variant: CyberButtonVariant.primary,
                height: 50.h,
                onPressed: () {
                  GameAudioService.instance.playUiTap();
                  onResume();
                },
              ),
              SizedBox(height: 10.h),

              CyberButton(
                key: const Key('pause_audio_settings_button'),
                text: 'Audio & Sound FX',
                icon: Icons.tune_rounded,
                variant: CyberButtonVariant.secondary,
                height: 46.h,
                onPressed: () {
                  GameAudioService.instance.playUiTap();
                  AudioSettingsDialog.show(context);
                },
              ),
              SizedBox(height: 10.h),

              CyberButton(
                key: const Key('restart_game_button'),
                text: 'Restart Mission',
                icon: Icons.refresh_rounded,
                variant: CyberButtonVariant.outline,
                height: 46.h,
                onPressed: () {
                  GameAudioService.instance.playUiTap();
                  onRestart();
                },
              ),
              SizedBox(height: 10.h),

              CyberButton(
                key: const Key('exit_game_button'),
                text: 'Exit to Garage',
                icon: Icons.exit_to_app_rounded,
                variant: CyberButtonVariant.outline,
                height: 44.h,
                onPressed: () {
                  GameAudioService.instance.playUiTap();
                  onExit();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
