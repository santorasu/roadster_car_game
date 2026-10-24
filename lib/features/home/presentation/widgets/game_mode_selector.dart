import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/audio/game_audio_service.dart';
import '../../../../core/storage/player_data_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../arcade_driving/domain/models/game_mode.dart';
import '../../../missions/domain/models/mission_definition.dart';
import '../../../missions/presentation/widgets/missions_sheet.dart';

/// Futuristic mode selector card allowing players to toggle between Endless Drive
/// and Time Trial modes, while displaying personal records and quick mission access.
class GameModeSelector extends StatelessWidget {
  final ValueChanged<GameMode>? onModeChanged;

  const GameModeSelector({
    super.key,
    this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: PlayerDataService.changeNotifier,
      builder: (context, _, child) {
        return FutureBuilder<PlayerCareerData>(
          future: PlayerDataService.instance.loadCareerData(),
          builder: (context, snapshot) {
            final data = snapshot.data ?? const PlayerCareerData();
            final isTimeTrial = data.selectedGameMode == 'time_trial';
            final completedMissionsCount = data.completedMissionIds.length;
            final totalMissionsCount = MissionDefinition.allMissions.length;

            return Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isTimeTrial
                      ? const Color(0xFFFFB300).withValues(alpha: 0.7)
                      : const Color(0xFF00E5FF).withValues(alpha: 0.7),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isTimeTrial
                        ? const Color(0xFFFFB300).withValues(alpha: 0.15)
                        : const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    blurRadius: 16.r,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sports_esports_rounded,
                              size: 15.r,
                              color: isTimeTrial ? const Color(0xFFFFB300) : const Color(0xFF00E5FF),
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                'GAME MODE',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6.w),
                      // Missions Quick Launch Pill
                      InkWell(
                        key: const Key('home_open_missions_button'),
                        borderRadius: BorderRadius.circular(6.r),
                        onTap: () {
                          GameAudioService.instance.playUiTap();
                          MissionsSheet.show(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: const Color(0xFF00E676).withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                size: 11.r,
                                color: const Color(0xFF00E676),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'MISSIONS ($completedMissionsCount/$totalMissionsCount)',
                                style: TextStyle(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                  color: const Color(0xFF00E676),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Mode Toggle Cards
                  Row(
                    children: [
                      // Endless Drive
                      Expanded(
                        child: _buildModeCard(
                          key: const Key('mode_card_endless'),
                          isSelected: !isTimeTrial,
                          title: 'ENDLESS DRIVE',
                          subtitle: 'Survive & Score',
                          icon: Icons.all_inclusive_rounded,
                          accentColor: const Color(0xFF00E5FF),
                          onTap: () {
                            GameAudioService.instance.playUiTap();
                            PlayerDataService.instance.saveGameMode('endless');
                            onModeChanged?.call(GameMode.endlessDrive);
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),

                      // Time Trial
                      Expanded(
                        child: _buildModeCard(
                          key: const Key('mode_card_time_trial'),
                          isSelected: isTimeTrial,
                          title: 'TIME TRIAL',
                          subtitle: '60s Countdown',
                          icon: Icons.timer_rounded,
                          accentColor: const Color(0xFFFFB300),
                          onTap: () {
                            GameAudioService.instance.playUiTap();
                            PlayerDataService.instance.saveGameMode('time_trial');
                            onModeChanged?.call(GameMode.timeTrial);
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // Mode Rules & Record Banner
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            isTimeTrial
                                ? '• 60s Timer • Near-miss overtakes add +1.5s'
                                : '• Infinite Highway • Survive and push top speed',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isTimeTrial ? 'BEST DISTANCE' : 'HIGH SCORE',
                              style: TextStyle(
                                fontSize: 7.5.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              isTimeTrial
                                  ? '${data.timeTrialBestDistanceMeters.toInt()} M'
                                  : data.highScore.toString(),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                color: isTimeTrial
                                    ? const Color(0xFFFFB300)
                                    : const Color(0xFF00E5FF),
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
        );
      },
    );
  }

  Widget _buildModeCard({
    required Key key,
    required bool isSelected,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.25),
                    blurRadius: 8.r,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 18.r,
                  color: isSelected ? accentColor : Colors.white70,
                ),
                Container(
                  width: 14.r,
                  height: 14.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? accentColor : Colors.white38,
                      width: 1.5,
                    ),
                    color: isSelected ? accentColor : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 9.r, color: Colors.black)
                      : null,
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 8.sp,
                color: isSelected ? accentColor : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
