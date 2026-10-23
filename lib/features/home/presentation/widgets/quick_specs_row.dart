import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';

class QuickSpecsRow extends StatelessWidget {
  const QuickSpecsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _specItem('0-60 MPH', '< 1.9s', AppColors.cyberCyan),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _specItem('TOP SPEED', '250+ MPH', AppColors.roadsterRed),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _specItem('RANGE', '620 MI', AppColors.electricLime),
        ),
      ],
    );
  }

  Widget _specItem(String label, String value, Color accent) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.statLabel.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
