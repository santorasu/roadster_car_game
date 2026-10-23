import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';

class RoadsterHeroBanner extends StatelessWidget {
  const RoadsterHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      backgroundColor: AppColors.surface,
      borderColor: AppColors.roadsterRed.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.roadsterRed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PROTOTYPE 01 • ALL-WHEEL DRIVE',
                    style: AppTypography.mono.copyWith(
                      fontSize: 10,
                      color: AppColors.roadsterRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ANDROID ONLY',
                  style: AppTypography.mono.copyWith(
                    fontSize: 9,
                    color: AppColors.cyberCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'CYBER ROADSTER',
            style: AppTypography.displayLarge.copyWith(
              fontSize: 28,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            'Electric Hypercar 3D Simulation Platform',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Stylized Vector Silhouette Illustration
          Center(
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: CustomPaint(
                painter: _RoadsterSilhouettePainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadsterSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ambient red floor glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.roadsterRed.withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.4, w, h * 0.6));
    canvas.drawOval(Rect.fromLTWH(w * 0.1, h * 0.55, w * 0.8, h * 0.4), glowPaint);

    // Sleek Coupe Silhouette Path
    final path = Path();
    // Start at front nose
    path.moveTo(w * 0.08, h * 0.72);
    // Hood sweep
    path.quadraticBezierTo(w * 0.22, h * 0.58, w * 0.35, h * 0.52);
    // Windshield rake
    path.quadraticBezierTo(w * 0.44, h * 0.26, w * 0.54, h * 0.24);
    // Targa roofline
    path.lineTo(w * 0.65, h * 0.24);
    // Fastback rear deck
    path.quadraticBezierTo(w * 0.76, h * 0.35, w * 0.86, h * 0.56);
    // Kamm-tail aero spoiler
    path.lineTo(w * 0.94, h * 0.58);
    // Rear bumper
    path.lineTo(w * 0.92, h * 0.72);
    // Ground diffuser back to front
    path.lineTo(w * 0.08, h * 0.72);
    path.close();

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE82127),
          Color(0xFF8A0A0E),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bodyPaint);

    // Glowing Neon Character Line
    final linePaint = Paint()
      ..color = const Color(0xFFFF5252)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // Wheels
    final wheelPaint = Paint()
      ..color = const Color(0xFF141720)
      ..style = PaintingStyle.fill;
    final rimPaint = Paint()
      ..color = AppColors.cyberCyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final frontWheelCenter = Offset(w * 0.25, h * 0.72);
    final rearWheelCenter = Offset(w * 0.76, h * 0.72);

    canvas.drawCircle(frontWheelCenter, 18, wheelPaint);
    canvas.drawCircle(frontWheelCenter, 18, rimPaint);
    canvas.drawCircle(frontWheelCenter, 5, Paint()..color = Colors.white);

    canvas.drawCircle(rearWheelCenter, 18, wheelPaint);
    canvas.drawCircle(rearWheelCenter, 18, rimPaint);
    canvas.drawCircle(rearWheelCenter, 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
