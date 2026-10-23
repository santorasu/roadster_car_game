import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyber_button.dart';

/// Pause overlay dialog with resume, restart, and exit actions.
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
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 28.w),
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                blurRadius: 24.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'SIMULATION PAUSED',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              Text(
                'MISSION ON HOLD',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),

              Text(
                'Arcade engine suspended. Choose an action to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),

              // Action Buttons
              CyberButton(
                key: const Key('resume_game_button'),
                text: 'Resume Drive',
                icon: Icons.play_arrow_rounded,
                variant: CyberButtonVariant.primary,
                height: 50.h,
                onPressed: onResume,
              ),
              SizedBox(height: 10.h),

              CyberButton(
                key: const Key('restart_game_button'),
                text: 'Restart Mission',
                icon: Icons.refresh_rounded,
                variant: CyberButtonVariant.outline,
                height: 46.h,
                onPressed: onRestart,
              ),
              SizedBox(height: 10.h),

              CyberButton(
                key: const Key('exit_game_button'),
                text: 'Exit to Garage',
                icon: Icons.exit_to_app_rounded,
                variant: CyberButtonVariant.secondary,
                height: 44.h,
                onPressed: onExit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
