import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/audio/game_audio_service.dart';
import '../../../../core/storage/player_data_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../domain/models/arcade_game_state.dart';
import '../../domain/models/player_car.dart';
import 'audio_settings_dialog.dart';

/// Game-over overlay screen displayed when vehicle hull integrity reaches zero.
class ArcadeGameOverDialog extends StatelessWidget {
  final ArcadeGameState state;
  final PlayerCar player;
  final List<String> newlyUnlockedMilestones;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const ArcadeGameOverDialog({
    super.key,
    required this.state,
    required this.player,
    this.newlyUnlockedMilestones = const [],
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
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 16.h),
            padding: EdgeInsets.all(20.r),
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

                SizedBox(height: 12.h),

                Text(
                  'MISSION FAILED',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10.h),

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
                  SizedBox(height: 10.h),
                ],

                // Run Telemetry Statistics Card (Distance, Speed, Sector Achievements)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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
                      Divider(color: Colors.white.withValues(alpha: 0.1), height: 10.h),
                      _buildStatRow('BEST SCORE', state.highScore.toString()),
                      Divider(color: Colors.white.withValues(alpha: 0.1), height: 10.h),
                      _buildStatRow('DISTANCE', '$distanceKm KM'),
                      Divider(color: Colors.white.withValues(alpha: 0.1), height: 10.h),
                      _buildStatRow('TOP SPEED', '${player.topSpeedMph.round()} MPH'),
                      Divider(color: Colors.white.withValues(alpha: 0.1), height: 10.h),
                      _buildStatRow(
                        'SECTOR REACHED',
                        'SEC 0${state.sectorIndex}: ${state.currentSectorName}',
                      ),
                      Divider(color: Colors.white.withValues(alpha: 0.1), height: 10.h),
                      _buildStatRow('MAX MULTIPLIER', '${state.comboMultiplier.toStringAsFixed(1)}x'),
                    ],
                  ),
                ),

                // Newly Unlocked Career Milestones
                if (newlyUnlockedMilestones.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.emoji_events_rounded, color: const Color(0xFF00E5FF), size: 14.r),
                            SizedBox(width: 4.w),
                            Text(
                              'CAREER MILESTONE UNLOCKED!',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF00E5FF),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: newlyUnlockedMilestones.map((id) {
                            final milestone = CareerMilestone.getById(id);
                            final title = milestone?.title ?? id.toUpperCase();
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(milestone?.icon ?? Icons.star, size: 10.r, color: const Color(0xFF00E5FF)),
                                  SizedBox(width: 4.w),
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 14.h),

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
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: isHighlight ? 15.sp : 12.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              color: isHighlight ? const Color(0xFF00E5FF) : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
