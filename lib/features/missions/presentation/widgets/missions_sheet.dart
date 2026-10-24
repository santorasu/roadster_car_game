import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/audio/game_audio_service.dart';
import '../../../../core/storage/player_data_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../domain/models/mission_definition.dart';

/// Interactive modal sheet displaying career missions, real-time objectives,
/// progress states, and one-time earned reward points.
class MissionsSheet extends StatelessWidget {
  const MissionsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MissionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: PlayerDataService.changeNotifier,
      builder: (context, _, child) {
        return FutureBuilder<PlayerCareerData>(
          future: PlayerDataService.instance.loadCareerData(),
          builder: (context, snapshot) {
            final data = snapshot.data ?? const PlayerCareerData();
            final completedIds = data.completedMissionIds;
            final completedCount = completedIds.length;
            final totalCount = MissionDefinition.allMissions.length;

            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.88,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
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
                    SizedBox(height: 12.h),

                    // Sheet Grab Handle
                    Center(
                      child: Container(
                        width: 44.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Header & Summary Counter
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                              ),
                            ),
                            child: Icon(
                              Icons.assignment_turned_in_rounded,
                              color: const Color(0xFF00E5FF),
                              size: 20.r,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CAREER MISSIONS & CHALLENGES',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Complete objectives to earn credits and prove your mastery',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Progress Overview Card
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            AppColors.surface.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSummaryStat(
                              label: 'COMPLETED',
                              value: '$completedCount / $totalCount',
                              icon: Icons.check_circle_outline_rounded,
                              color: const Color(0xFF00E676),
                            ),
                          ),
                          Container(
                            height: 32.h,
                            width: 1,
                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          Expanded(
                            child: _buildSummaryStat(
                              label: 'REWARD POINTS',
                              value: '${data.totalRewardPoints} PTS',
                              icon: Icons.stars_rounded,
                              color: const Color(0xFFFFB300),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Missions List
                    Flexible(
                      child: ListView.separated(
                        key: const Key('missions_list_view'),
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                        itemCount: MissionDefinition.allMissions.length,
                        separatorBuilder: (_, index) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final mission = MissionDefinition.allMissions[index];
                          final isCompleted = completedIds.contains(mission.id);

                          return Container(
                            key: Key('mission_item_${mission.id}'),
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? const Color(0xFF00E676).withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isCompleted
                                    ? const Color(0xFF00E676).withValues(alpha: 0.5)
                                    : Colors.white.withValues(alpha: 0.12),
                                width: isCompleted ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon
                                Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? const Color(0xFF00E676).withValues(alpha: 0.2)
                                        : Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: isCompleted
                                          ? const Color(0xFF00E676)
                                          : Colors.white.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Icon(
                                    mission.icon,
                                    size: 18.r,
                                    color: isCompleted ? const Color(0xFF00E676) : Colors.white70,
                                  ),
                                ),
                                SizedBox(width: 10.w),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              mission.title,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11.5.sp,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6.w,
                                              vertical: 2.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isCompleted
                                                  ? const Color(0xFF00E676).withValues(alpha: 0.2)
                                                  : const Color(0xFFFFB300).withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4.r),
                                              border: Border.all(
                                                color: isCompleted
                                                    ? const Color(0xFF00E676)
                                                    : const Color(0xFFFFB300),
                                              ),
                                            ),
                                            child: Text(
                                              isCompleted
                                                  ? 'CLAIMED'
                                                  : '+${mission.rewardPoints} PTS',
                                              style: TextStyle(
                                                fontSize: 8.5.sp,
                                                fontWeight: FontWeight.w900,
                                                color: isCompleted
                                                    ? const Color(0xFF00E676)
                                                    : const Color(0xFFFFB300),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        mission.description,
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: AppColors.textSecondary,
                                          height: 1.3,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),

                                      // Status Badge
                                      Row(
                                        children: [
                                          Icon(
                                            isCompleted
                                                ? Icons.check_circle_rounded
                                                : Icons.radio_button_unchecked_rounded,
                                            size: 11.r,
                                            color: isCompleted
                                                ? const Color(0xFF00E676)
                                                : AppColors.textSecondary,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            isCompleted ? 'COMPLETED' : 'INCOMPLETE',
                                            style: TextStyle(
                                              fontSize: 8.5.sp,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                              color: isCompleted
                                                  ? const Color(0xFF00E676)
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Close Button
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                      child: CyberButton(
                        key: const Key('missions_close_button'),
                        text: 'Dismiss',
                        icon: Icons.close_rounded,
                        variant: CyberButtonVariant.secondary,
                        height: 46.h,
                        onPressed: () {
                          GameAudioService.instance.playUiTap();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.r, color: color),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
