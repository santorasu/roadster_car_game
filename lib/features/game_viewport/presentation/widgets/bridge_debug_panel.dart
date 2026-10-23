import 'package:flutter/material.dart';
import '../../../../core/bridge/bridge_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/game_viewport_controller.dart';

class BridgeDebugPanel extends StatelessWidget {
  final GameViewportController controller;

  const BridgeDebugPanel({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final messages = controller.bridgeService.recentMessages;

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.96),
        border: const Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.terminal_rounded,
                      color: AppColors.cyberCyan,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'BRIDGE PROTOCOL v1.0.0 LOG (${messages.length})',
                      style: AppTypography.mono.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      key: const Key('simulate_error_button'),
                      onPressed: () {
                        controller.simulateFailureNextConnect();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Simulated error armed for next reconnect.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        'ARM ERROR',
                        style: AppTypography.mono.copyWith(
                          fontSize: 11,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: controller.toggleDebugPanel,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceBorder),

          // Message list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final BridgeMessage msg = messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[${msg.action}]',
                        style: AppTypography.mono.copyWith(
                          fontSize: 11,
                          color: _getActionColor(msg.action),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          msg.payload.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.mono.copyWith(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    if (action.contains('HANDSHAKE')) return AppColors.cyberCyan;
    if (action.contains('ERROR')) return AppColors.error;
    if (action.contains('PONG')) return AppColors.electricLime;
    if (action.contains('TELEMETRY')) return AppColors.textMuted;
    return AppColors.roadsterRed;
  }
}
