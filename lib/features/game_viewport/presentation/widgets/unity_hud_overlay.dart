import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/models/telemetry_data.dart';
import '../controllers/game_viewport_controller.dart';

class UnityHudOverlay extends StatelessWidget {
  final TelemetryData telemetry;
  final GameViewportController controller;
  final VoidCallback onExit;

  const UnityHudOverlay({
    super.key,
    required this.telemetry,
    required this.controller,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTopBar(context),
          _buildBottomCockpit(context),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final bridge = controller.bridgeService;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              IconButton(
                key: const Key('exit_viewport_button'),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface.withValues(alpha: 0.7),
                ),
                onPressed: onExit,
              ),

              // Action Toolbar: Camera, Color, Debug
              Row(
                children: [
                  IconButton(
                    key: const Key('cycle_camera_button'),
                    icon: const Icon(Icons.videocam_outlined, color: AppColors.cyberCyan),
                    tooltip: 'Camera: ${telemetry.cameraMode}',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface.withValues(alpha: 0.7),
                    ),
                    onPressed: controller.cycleCameraMode,
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    key: const Key('color_picker_button'),
                    icon: const Icon(Icons.palette_outlined, color: AppColors.roadsterRed),
                    tooltip: 'Change Color',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface.withValues(alpha: 0.7),
                    ),
                    onPressed: () => _showColorPicker(context),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    key: const Key('toggle_debug_panel_button'),
                    icon: const Icon(Icons.terminal_rounded, color: Colors.white),
                    tooltip: 'Bridge Logs',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface.withValues(alpha: 0.7),
                    ),
                    onPressed: controller.toggleDebugPanel,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Diagnostic Status Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const StatusBadge(
                label: 'BRIDGE v1.0.0',
                color: AppColors.electricLime,
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: '${bridge.unityFps} FPS',
                color: AppColors.cyberCyan,
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: '${bridge.lastPingMs}ms',
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCockpit(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Telemetry Readouts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Battery
              Column(
                children: [
                  Text('BATTERY', style: AppTypography.statLabel),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.electricLime,
                        size: 18,
                      ),
                      Text(
                        '${telemetry.batteryPercent.toStringAsFixed(1)}%',
                        style: AppTypography.statValue.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),

              // Main Speedometer
              Column(
                children: [
                  Text(
                    telemetry.speedMph.toInt().toString(),
                    style: AppTypography.statValue.copyWith(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                  Text(
                    'MPH',
                    style: AppTypography.statLabel.copyWith(
                      letterSpacing: 2.0,
                      color: AppColors.cyberCyan,
                    ),
                  ),
                ],
              ),

              // Gear & G-Force
              Column(
                children: [
                  Text('GEAR / G-FORCE', style: AppTypography.statLabel),
                  const SizedBox(height: 2),
                  Text(
                    '${telemetry.gear} • ${telemetry.gForce.toStringAsFixed(2)}G',
                    style: AppTypography.statValue.copyWith(
                      fontSize: 20,
                      color: AppColors.roadsterRed,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Steering & Drive Input Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Steering Left / Right
              Row(
                children: [
                  _steerButton(
                    key: 'steer_left_button',
                    icon: Icons.arrow_left_rounded,
                    onTapDown: () => controller.setSteering(-0.6),
                    onTapUp: () => controller.setSteering(0.0),
                  ),
                  const SizedBox(width: 8),
                  _steerButton(
                    key: 'steer_right_button',
                    icon: Icons.arrow_right_rounded,
                    onTapDown: () => controller.setSteering(0.6),
                    onTapUp: () => controller.setSteering(0.0),
                  ),
                ],
              ),

              // Camera Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'CAM: ${telemetry.cameraMode}',
                  style: AppTypography.mono.copyWith(fontSize: 11),
                ),
              ),

              // Brake & Throttle Pedals
              Row(
                children: [
                  _pedalButton(
                    key: 'brake_pedal_button',
                    label: 'BRAKE',
                    color: AppColors.error,
                    onTapDown: () => controller.setBrake(1.0),
                    onTapUp: () => controller.setBrake(0.0),
                  ),
                  const SizedBox(width: 8),
                  _pedalButton(
                    key: 'throttle_pedal_button',
                    label: 'DRIVE',
                    color: AppColors.electricLime,
                    onTapDown: () => controller.setThrottle(1.0),
                    onTapUp: () => controller.setThrottle(0.0),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _steerButton({
    required String key,
    required IconData icon,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
  }) {
    return GestureDetector(
      key: Key(key),
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: () => onTapUp(),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
        ),
        child: Icon(icon, color: Colors.white, size: 36),
      ),
    );
  }

  Widget _pedalButton({
    required String key,
    required String label,
    required Color color,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
  }) {
    return GestureDetector(
      key: Key(key),
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: () => onTapUp(),
      child: Container(
        width: 64,
        height: 54,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.titleSmall.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT VEHICLE FINISH',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _colorOption(context, 'Cyber Red', '#E82127', const Color(0xFFE82127)),
                    _colorOption(context, 'Electric Cyan', '#00E5FF', const Color(0xFF00E5FF)),
                    _colorOption(context, 'Quicksilver', '#D0D4DC', const Color(0xFFD0D4DC)),
                    _colorOption(context, 'Stealth Black', '#15171C', const Color(0xFF15171C)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _colorOption(
    BuildContext context,
    String name,
    String hex,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        controller.setVehicleColor(hex);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
