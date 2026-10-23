import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Ergonomic Android touch controls for arcade steering, acceleration, and braking.
class ArcadeTouchControls extends StatefulWidget {
  final ValueChanged<double> onSteerChanged;
  final ValueChanged<bool> onThrottleChanged;
  final ValueChanged<bool> onBrakeChanged;

  const ArcadeTouchControls({
    super.key,
    required this.onSteerChanged,
    required this.onThrottleChanged,
    required this.onBrakeChanged,
  });

  @override
  State<ArcadeTouchControls> createState() => _ArcadeTouchControlsState();
}

class _ArcadeTouchControlsState extends State<ArcadeTouchControls> {
  bool _steerLeftPressed = false;
  bool _steerRightPressed = false;
  bool _throttlePressed = false;
  bool _brakePressed = false;

  void _updateSteer() {
    if (_steerLeftPressed && !_steerRightPressed) {
      widget.onSteerChanged(-1.0);
    } else if (_steerRightPressed && !_steerLeftPressed) {
      widget.onSteerChanged(1.0);
    } else {
      widget.onSteerChanged(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Left Thumb: Dual Steering Pads
            Row(
              children: [
                _buildControlButton(
                  key: const Key('steer_left_button'),
                  label: 'STEER L',
                  icon: Icons.keyboard_arrow_left_rounded,
                  isPressed: _steerLeftPressed,
                  color: const Color(0xFF00E5FF),
                  size: 64,
                  onPointerDown: () {
                    setState(() => _steerLeftPressed = true);
                    _updateSteer();
                  },
                  onPointerUp: () {
                    setState(() => _steerLeftPressed = false);
                    _updateSteer();
                  },
                ),
                SizedBox(width: 10.w),
                _buildControlButton(
                  key: const Key('steer_right_button'),
                  label: 'STEER R',
                  icon: Icons.keyboard_arrow_right_rounded,
                  isPressed: _steerRightPressed,
                  color: const Color(0xFF00E5FF),
                  size: 64,
                  onPointerDown: () {
                    setState(() => _steerRightPressed = true);
                    _updateSteer();
                  },
                  onPointerUp: () {
                    setState(() => _steerRightPressed = false);
                    _updateSteer();
                  },
                ),
              ],
            ),

            // Right Thumb: Brake & Drive Pedals
            Row(
              children: [
                // Regenerative Brake
                _buildControlButton(
                  key: const Key('brake_button'),
                  label: 'BRAKE',
                  icon: Icons.pan_tool_rounded,
                  isPressed: _brakePressed,
                  color: const Color(0xFFFF5252),
                  size: 64,
                  onPointerDown: () {
                    setState(() => _brakePressed = true);
                    widget.onBrakeChanged(true);
                  },
                  onPointerUp: () {
                    setState(() => _brakePressed = false);
                    widget.onBrakeChanged(false);
                  },
                ),
                SizedBox(width: 12.w),

                // Drive / Boost Pedal
                _buildControlButton(
                  key: const Key('accelerate_button'),
                  label: 'DRIVE',
                  icon: Icons.bolt_rounded,
                  isPressed: _throttlePressed,
                  color: AppColors.roadsterRed,
                  size: 76,
                  isPrimary: true,
                  onPointerDown: () {
                    setState(() => _throttlePressed = true);
                    widget.onThrottleChanged(true);
                  },
                  onPointerUp: () {
                    setState(() => _throttlePressed = false);
                    widget.onThrottleChanged(false);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required Key key,
    required String label,
    required IconData icon,
    required bool isPressed,
    required Color color,
    required double size,
    required VoidCallback onPointerDown,
    required VoidCallback onPointerUp,
    bool isPrimary = false,
  }) {
    final buttonDiameter = size.r;
    return Listener(
      key: key,
      onPointerDown: (_) => onPointerDown(),
      onPointerUp: (_) => onPointerUp(),
      onPointerCancel: (_) => onPointerUp(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        width: buttonDiameter,
        height: buttonDiameter,
        decoration: BoxDecoration(
          color: isPressed
              ? color.withValues(alpha: 0.45)
              : (isPrimary ? color.withValues(alpha: 0.22) : AppColors.surface.withValues(alpha: 0.7)),
          shape: BoxShape.circle,
          border: Border.all(
            color: isPressed ? Colors.white : color.withValues(alpha: isPrimary ? 0.9 : 0.6),
            width: isPressed ? 2.5 : (isPrimary ? 2.0 : 1.5),
          ),
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 16.r,
                    spreadRadius: 2.r,
                  ),
                ]
              : (isPrimary
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.25),
                        blurRadius: 10.r,
                      ),
                    ]
                  : null),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPressed ? Colors.white : (isPrimary ? Colors.white : color),
                size: buttonDiameter * 0.42,
              ),
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: isPressed ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
