import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/audio/game_audio_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/arcade_game_state.dart';
import '../../domain/models/game_mode.dart';
import '../../domain/models/player_car.dart';
import '../../../missions/domain/models/mission_definition.dart';
import 'audio_settings_dialog.dart';

/// Heads-Up Display rendering speed, distance, score, multiplier, audio access, and hull integrity.
class ArcadeHud extends StatelessWidget {
  final PlayerCar player;
  final ArcadeGameState state;
  final VoidCallback onPausePressed;
  final MissionDefinition? activeToastMission;

  const ArcadeHud({
    super.key,
    required this.player,
    required this.state,
    required this.onPausePressed,
    this.activeToastMission,
  });

  Color _getSpeedColor(double speed) {
    if (speed > 180.0) return const Color(0xFFFF1744); // Hyper Red
    if (speed > 115.0) return const Color(0xFFFFB300); // Electric Amber
    return const Color(0xFF00E5FF);                    // Cyber Cyan
  }

  Color _getHealthColor(double health) {
    if (health <= 0.25) return AppColors.roadsterRed;
    if (health <= 0.65) return Colors.amber;
    return const Color(0xFF00E5FF);
  }

  @override
  Widget build(BuildContext context) {
    final speed = player.speedMph.round();
    final distanceKm = (state.distanceMeters / 1000.0).toStringAsFixed(2);
    final healthPct = player.health.clamp(0.0, 1.0);
    final speedColor = _getSpeedColor(player.speedMph);
    final healthColor = _getHealthColor(healthPct);
    final isCritical = healthPct <= 0.25 && healthPct > 0.0;
    final powerRatio = (player.speedMph / 250.0).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.88),
            Colors.black.withValues(alpha: 0.40),
            Colors.transparent,
          ],
          stops: const [0.0, 0.75, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar: Score, Multiplier, Audio, and Pause Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Score & Multiplier Pill
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: state.comboMultiplier > 1.0
                            ? AppColors.roadsterRed.withValues(alpha: 0.6)
                            : AppColors.surfaceBorder.withValues(alpha: 0.5),
                        width: state.comboMultiplier > 1.0 ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SCORE',
                              style: TextStyle(
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              state.score.toString().padLeft(6, '0'),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        if (state.comboMultiplier > 1.0) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                              ),
                              borderRadius: BorderRadius.circular(4.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.roadsterRed.withValues(alpha: 0.6),
                                  blurRadius: 6.r,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt_rounded, size: 10.r, color: Colors.white),
                                Text(
                                  '${state.comboMultiplier.toStringAsFixed(1)}x',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Distance Tracker
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.surfaceBorder.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'DISTANCE',
                          style: TextStyle(
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          '$distanceKm KM',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            color: const Color(0xFF00E5FF),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Controls: Audio Settings & Pause Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Audio Quick Tune Button
                      IconButton(
                        key: const Key('hud_audio_settings_button'),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tightFor(width: 36.r, height: 36.r),
                        onPressed: () {
                          GameAudioService.instance.playUiTap();
                          AudioSettingsDialog.show(context);
                        },
                        icon: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surfaceBorder.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: const Color(0xFF00E5FF),
                            size: 16.r,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),

                      // Pause Button
                      IconButton(
                        key: const Key('arcade_pause_button'),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tightFor(width: 36.r, height: 36.r),
                        onPressed: onPausePressed,
                        icon: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surfaceBorder.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Icon(
                            Icons.pause_rounded,
                            color: Colors.white,
                            size: 16.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Time Trial Countdown Timer Banner (Prominent Center)
              if (state.gameMode == GameMode.timeTrial) ...[
                SizedBox(height: 4.h),
                Center(
                  child: Container(
                    key: const Key('hud_time_trial_timer'),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: state.timeRemainingSeconds <= 10.0
                          ? const Color(0xFFFF1744).withValues(alpha: 0.25)
                          : AppColors.surface.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: state.timeRemainingSeconds <= 10.0
                            ? const Color(0xFFFF1744)
                            : const Color(0xFFFFB300),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: state.timeRemainingSeconds <= 10.0
                              ? const Color(0xFFFF1744).withValues(alpha: 0.6)
                              : const Color(0xFFFFB300).withValues(alpha: 0.35),
                          blurRadius: 10.r,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14.r,
                          color: state.timeRemainingSeconds <= 10.0
                              ? const Color(0xFFFF1744)
                              : const Color(0xFFFFB300),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'TIME REMAINING: ${state.timeRemainingSeconds.toStringAsFixed(1)}s',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            color: state.timeRemainingSeconds <= 10.0
                                ? const Color(0xFFFF1744)
                                : Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (state.bonusTimeFlashTimer > 0.0) ...[
                          SizedBox(width: 6.w),
                          Text(
                            '+1.5s',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF00E5FF),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              // Real-time Mission Objective Completion Toast
              if (activeToastMission != null) ...[
                SizedBox(height: 4.h),
                Center(
                  child: Container(
                    key: const Key('hud_mission_completed_toast'),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                      ),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withValues(alpha: 0.6),
                          blurRadius: 10.r,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          activeToastMission!.icon,
                          size: 13.r,
                          color: Colors.black,
                        ),
                        SizedBox(width: 5.w),
                        Flexible(
                          child: Text(
                            'MISSION COMPLETED: ${activeToastMission!.title} (+${activeToastMission!.rewardPoints} PTS)',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Dynamic Sector Transition Announcement Banner
              if (state.sectorNotificationTimer > 0.0) ...[
                SizedBox(height: 4.h),
                Center(
                  child: Container(
                    key: const Key('hud_sector_announcement_banner'),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00F0FF).withValues(alpha: 0.25),
                          const Color(0xFF00E5FF).withValues(alpha: 0.92),
                          const Color(0xFF00F0FF).withValues(alpha: 0.25),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: const Color(0xFF00F0FF),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F0FF).withValues(alpha: 0.6),
                          blurRadius: 10.r,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.currentCurvature > 0.05
                              ? Icons.turn_right_rounded
                              : (state.currentCurvature < -0.05
                                  ? Icons.turn_left_rounded
                                  : Icons.straight_rounded),
                          size: 14.r,
                          color: Colors.black,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'SECTOR 0${state.sectorIndex}: ${state.currentSectorName}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (state.currentElevation.abs() > 0.1) ...[
                          SizedBox(width: 6.w),
                          Icon(
                            state.currentElevation > 0
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 13.r,
                            color: Colors.black,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            state.currentElevation > 0 ? 'UPHILL' : 'DOWNHILL',
                            style: TextStyle(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: 6.h),

              // Speedometer Arc, Power Gauge & Hull Bar Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cyber Speedometer Pill with Power Output Arc
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: speedColor.withValues(alpha: speed > 180 ? 0.9 : 0.6),
                        width: 1.5,
                      ),
                      boxShadow: speed > 150
                          ? [
                              BoxShadow(
                                color: speedColor.withValues(alpha: 0.4),
                                blurRadius: 14.r,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$speed',
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'MPH',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: speedColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        // Power Output KW / Torque bar
                        Container(
                          width: 82.w,
                          height: 3.h,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: powerRatio,
                            child: Container(
                              decoration: BoxDecoration(
                                color: speedColor,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vehicle Hull Integrity Bar with Critical Warning Pulse
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 14.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isCritical
                              ? AppColors.roadsterRed.withValues(alpha: 0.18)
                              : Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isCritical
                                ? AppColors.roadsterRed.withValues(alpha: 0.8)
                                : AppColors.surfaceBorder.withValues(alpha: 0.4),
                            width: isCritical ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      if (isCritical) ...[
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          size: 11.r,
                                          color: AppColors.roadsterRed,
                                        ),
                                        SizedBox(width: 3.w),
                                      ],
                                      Flexible(
                                        child: Text(
                                          isCritical ? 'CRITICAL HULL' : 'HULL INTEGRITY',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 8.5.sp,
                                            fontWeight: FontWeight.w800,
                                            color: isCritical ? AppColors.roadsterRed : AppColors.textSecondary,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${(healthPct * 100).toInt()}%',

                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                    color: healthColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: Container(
                                height: 6.h,
                                color: Colors.white.withValues(alpha: 0.1),
                                child: LinearProgressIndicator(
                                  value: healthPct,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
