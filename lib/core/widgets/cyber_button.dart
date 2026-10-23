import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum CyberButtonVariant { primary, secondary, outline, danger }

class CyberButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final CyberButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double? width;

  const CyberButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = CyberButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.height = 54,
    this.width,
  });

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    Color bg;
    Color border;
    Color textColor;
    List<BoxShadow>? shadows;

    switch (widget.variant) {
      case CyberButtonVariant.primary:
        bg = AppColors.roadsterRed;
        border = const Color(0xFFFF5252);
        textColor = Colors.white;
        shadows = isEnabled
            ? [
                BoxShadow(
                  color: AppColors.roadsterRed.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null;
        break;

      case CyberButtonVariant.secondary:
        bg = AppColors.surfaceElevated;
        border = AppColors.cyberCyan.withValues(alpha: 0.5);
        textColor = AppColors.cyberCyan;
        shadows = [
          BoxShadow(
            color: AppColors.cyberCyan.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ];
        break;

      case CyberButtonVariant.outline:
        bg = Colors.transparent;
        border = AppColors.surfaceBorder;
        textColor = AppColors.textPrimary;
        break;

      case CyberButtonVariant.danger:
        bg = AppColors.error;
        border = const Color(0xFFFF6B6B);
        textColor = Colors.white;
        shadows = [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ];
        break;
    }

    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: isEnabled ? bg : bg.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isEnabled ? border : border.withValues(alpha: 0.2),
            width: 1.2,
          ),
          boxShadow: shadows,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: isEnabled
                ? () {
                    widget.onPressed?.call();
                  }
                : null,
            onTapDown: (_) => isEnabled ? _animCtrl.forward() : null,
            onTapUp: (_) => isEnabled ? _animCtrl.reverse() : null,
            onTapCancel: () => isEnabled ? _animCtrl.reverse() : null,
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 20, color: textColor),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          widget.text.toUpperCase(),
                          style: AppTypography.titleSmall.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
