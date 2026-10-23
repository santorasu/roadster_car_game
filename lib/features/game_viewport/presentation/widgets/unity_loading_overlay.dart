import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/game_session_state.dart';

class UnityLoadingOverlay extends StatelessWidget {
  final GameSessionState sessionState;

  const UnityLoadingOverlay({
    super.key,
    required this.sessionState,
  });

  @override
  Widget build(BuildContext context) {
    final step = sessionState.initializationStep;
    final progress = (step / 4.0).clamp(0.1, 1.0);

    return Container(
      color: AppColors.background.withValues(alpha: 0.92),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing Ring Loader
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3.5,
                      backgroundColor: AppColors.surfaceBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.roadsterRed,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.electric_bolt_rounded,
                    color: AppColors.cyberCyan,
                    size: 38,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text(
                'INITIALIZING UNITY SUBSYSTEM',
                style: AppTypography.titleSmall.copyWith(
                  letterSpacing: 2.0,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                sessionState.stepDescription,
                textAlign: TextAlign.center,
                style: AppTypography.mono.copyWith(
                  fontSize: 12,
                  color: AppColors.cyberCyan,
                ),
              ),
              const SizedBox(height: 24),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.roadsterRed,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Step indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stepBadge('1. Bridge v1.0', step >= 1),
                  _stepBadge('2. Scene', step >= 2),
                  _stepBadge('3. Handshake', step >= 3),
                  _stepBadge('4. Vehicle', step >= 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepBadge(String text, bool active) {
    return Text(
      text,
      style: AppTypography.mono.copyWith(
        fontSize: 10,
        color: active ? AppColors.cyberCyan : AppColors.textMuted,
        fontWeight: active ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
