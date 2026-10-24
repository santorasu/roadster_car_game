import 'package:flutter/material.dart';
import '../../../../core/storage/player_data_storage.dart';
import '../../../../core/theme/app_colors.dart';

/// Card displayed on the garage dashboard highlighting the driver's career achievements
class CareerRecordsCard extends StatelessWidget {
  const CareerRecordsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: PlayerDataService.changeNotifier,
      builder: (context, _, child) {
        return FutureBuilder<PlayerCareerData>(
          future: PlayerDataService.instance.loadCareerData(),
          builder: (context, snapshot) {
            final data = snapshot.data ?? const PlayerCareerData();
            final distanceKm = (data.bestDistanceMeters / 1000.0).toStringAsFixed(1);
            final milestonesCount = data.unlockedMilestones.length;
            final totalMilestones = CareerMilestone.allMilestones.length;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.military_tech_rounded, color: Color(0xFF00E5FF), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'DRIVER CAREER TELEMETRY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '$milestonesCount/$totalMilestones BADGES',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00E5FF),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.star_rounded,
                          iconColor: Colors.amber,
                          label: 'HIGH SCORE',
                          value: data.highScore.toString(),
                        ),
                      ),
                      Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.1)),
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.route_rounded,
                          iconColor: const Color(0xFF00E5FF),
                          label: 'BEST DIST',
                          value: '$distanceKm KM',
                        ),
                      ),
                      Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.1)),
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.speed_rounded,
                          iconColor: const Color(0xFFFF1744),
                          label: 'RECORD SPEED',
                          value: '${data.topSpeedMph.round()} MPH',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
