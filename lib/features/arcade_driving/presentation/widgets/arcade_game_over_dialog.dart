import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/audio/game_audio_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../domain/models/arcade_game_state.dart';
import '../../domain/models/player_car.dart';
import 'audio_settings_dialog.dart';

/// Game-over overlay screen displayed when vehicle hull integrity reaches zero.
class ArcadeGameOverDialog extends StatelessWidget {
  final ArcadeGameState state;
  final PlayerCar player;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const ArcadeGameOverDialog({
    super.key,
    required this.state,
    required this.player,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final isNewRecord = state.score >= state.highScore && state.score > 0;
    final distanceKm = (state.distanceMeters / 1000.0).toStringAsFixed(2);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 22.w),
          padding: EdgeInsets.all(22.r),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColors.roadsterRed,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.roadsterRed.withValues(alpha: 0.4),
                blurRadius: 32.r,
                spreadRadius: 3.r,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.roadsterRed.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: AppColors.roadsterRed.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.roadsterRed,
                      size: 14.r,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        'HULL CRITICALLY COMPROMISED',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.roadsterRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              Text(
                'MISSION FAILED',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),

              if (isNewRecord) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 16.r),
                      SizedBox(width: 4.w),
                      Text(
                        'NEW RECORD SCORE!',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.amber,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.star_rounded, color: Colors.amber, size: 16.r),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
              ],

              // Run Telemetry Statistics Card
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _buildStatRow('FINAL SCORE', state.score.toString(), isHighlight: true),
                    Divider(color: Colors.white.withValues(alpha: 0.1), height: 14.h),
                    _buildStatRow('BEST SCORE', state.highScore.toString()),
                    Divider(color: Colors.white.withValues(alpha: 0.1), height: 14.h),
                    _buildStatRow('DISTANCE', '$distanceKm KM'),
                    Divider(color: Colors.white.withValues(alpha: 0.1), height: 14.h),
                    _buildStatRow('TOP SPEED', '${player.topSpeedMph.round()} MPH'),
                    Divider(color: Colors.white.withValues(alpha: 0.1), height: 14.h),
                    _buildStatRow('MAX MULTIPLIER', '${state.comboMultiplier.toStringAsFixed(1)}x'),
                  ],

                ),
              ),
              SizedBox(height: 18.h),

              // Action Buttons
              CyberButton(
                key: const Key('game_over_restart_button'),
                text: 'Repair & Retry',
                icon: Icons.refresh_rounded,
                variant: CyberButtonVariant.primary,
                height: 50.h,
                onPressed: () {
                  GameAudioService.instance.playUiTap();
                  onRestart();
                },
              ),
              SizedBox(height: 8.h),

              Row(
                children: [
                  Expanded(
                    child: CyberButton(
                      key: const Key('game_over_audio_settings_button'),
                      text: 'Audio',
                      icon: Icons.tune_rounded,
                      variant: CyberButtonVariant.secondary,
                      height: 44.h,
                      onPressed: () {
                        GameAudioService.instance.playUiTap();
                        AudioSettingsDialog.show(context);
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: CyberButton(
                      key: const Key('game_over_exit_button'),
                      text: 'Garage',
                      icon: Icons.home_rounded,
                      variant: CyberButtonVariant.outline,
                      height: 44.h,
                      onPressed: () {
                        GameAudioService.instance.playUiTap();
                        onExit();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 15.sp : 12.sp,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
            color: isHighlight ? const Color(0xFF00E5FF) : Colors.white,
          ),
        ),
      ],
    );
  }
}
