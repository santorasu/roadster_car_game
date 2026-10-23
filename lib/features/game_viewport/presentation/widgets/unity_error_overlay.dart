import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../domain/models/game_session_state.dart';

class UnityErrorOverlay extends StatelessWidget {
  final GameSessionState sessionState;
  final VoidCallback onRetry;

  const UnityErrorOverlay({
    super.key,
    required this.sessionState,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withValues(alpha: 0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withValues(alpha: 0.12),
                  border: Border.all(color: AppColors.error, width: 2),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 42,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'BRIDGE CONNECTION ERROR',
                style: AppTypography.titleLarge.copyWith(
                  letterSpacing: 1.5,
                  color: AppColors.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  sessionState.errorMessage ?? 'Unknown bridge timeout or render surface error.',
                  textAlign: TextAlign.center,
                  style: AppTypography.mono.copyWith(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              CyberButton(
                key: const Key('retry_connection_button'),
                text: 'Retry Connection',
                icon: Icons.refresh_rounded,
                variant: CyberButtonVariant.primary,
                width: double.infinity,
                onPressed: onRetry,
              ),
              const SizedBox(height: 14),

              Text(
                'Target: Android OpenGLES3 / Vulkan • API 24-35',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
