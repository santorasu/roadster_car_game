import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/arcade_game_state.dart';
import '../../domain/models/player_car.dart';

/// Heads-Up Display rendering speed, distance, score, multiplier, and hull integrity.
class ArcadeHud extends StatelessWidget {
  final PlayerCar player;
  final ArcadeGameState state;
  final VoidCallback onPausePressed;

  const ArcadeHud({
    super.key,
    required this.player,
    required this.state,
    required this.onPausePressed,
  });

  @override
  Widget build(BuildContext context) {
    final speed = player.speedMph.round();
    final distanceKm = (state.distanceMeters / 1000.0).toStringAsFixed(2);
    final healthPct = player.health.clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.black.withValues(alpha: 0.35),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Top Bar: Score, Multiplier, and Pause Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score & Multiplier Pill
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.surfaceBorder.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SCORE',
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            state.score.toString().padLeft(6, '0'),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      if (state.comboMultiplier > 1.0) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.roadsterRed,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '${state.comboMultiplier.toStringAsFixed(1)}x',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Distance Tracker
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.85),
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
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '$distanceKm KM',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                          color: const Color(0xFF00E5FF),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pause Button
                IconButton(
                  key: const Key('arcade_pause_button'),
                  onPressed: onPausePressed,
                  icon: Container(
                    padding: EdgeInsets.all(8.r),
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
                      size: 20.r,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Speedometer Arc & Hull Bar Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cyber Speedometer Pill
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: speed > 150
                          ? AppColors.roadsterRed
                          : const Color(0xFF00E5FF).withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
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
                          color: speed > 150 ? AppColors.roadsterRed : const Color(0xFF00E5FF),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vehicle Hull Integrity Bar
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'HULL INTEGRITY',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              '${(healthPct * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w900,
                                color: healthPct < 0.35
                                    ? AppColors.roadsterRed
                                    : (healthPct < 0.70 ? Colors.amber : const Color(0xFF00E5FF)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: Container(
                            height: 6.h,
                            color: Colors.white.withValues(alpha: 0.1),
                            child: LinearProgressIndicator(
                              value: healthPct,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                healthPct < 0.35
                                    ? AppColors.roadsterRed
                                    : (healthPct < 0.70 ? Colors.amber : const Color(0xFF00E5FF)),
                              ),
                            ),
                          ),
                        ),
                      ],
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
