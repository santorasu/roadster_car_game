import 'package:flutter/material.dart';
import '../../../../core/bridge/unity_bridge_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/status_badge.dart';

class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UnityBridgeService(),
      builder: (context, _) {
        final bridge = UnityBridgeService();

        return GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.developer_board_rounded,
                          color: AppColors.cyberCyan,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ANDROID RUNTIME INTEGRATION',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleSmall.copyWith(
                              fontSize: 12,
                              letterSpacing: 1.0,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    label: bridge.status.name.toUpperCase(),
                    color: AppColors.electricLime,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _statusRow(
                'Bridge Protocol',
                'v1.0.0 (Bidirectional JSON)',
                AppColors.electricLime,
              ),
              const SizedBox(height: 8),
              _statusRow(
                'Graphics Pipeline',
                'Vulkan 1.3 / OpenGLES3',
                AppColors.cyberCyan,
              ),
              const SizedBox(height: 8),
              _statusRow(
                'Engine Subsystem',
                'Unity 2022.3 LTS Bridge',
                AppColors.textPrimary,
              ),
              const SizedBox(height: 8),
              _statusRow(
                'Lifecycle & RAM Guard',
                'Active (MinSdk 24 / NDK 25)',
                AppColors.electricLime,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusRow(String key, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(key, style: AppTypography.bodySmall),
        Text(
          value,
          style: AppTypography.mono.copyWith(
            fontSize: 11,
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
