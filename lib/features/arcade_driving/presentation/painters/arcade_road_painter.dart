import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders a dynamic pseudo-3D perspective road with scrolling lane markings,
/// glowing neon barriers, and a cyberpunk horizon.
class ArcadeRoadPainter extends CustomPainter {
  final double scrollOffset;
  final double playerSpeedMph;

  ArcadeRoadPainter({
    required this.scrollOffset,
    required this.playerSpeedMph,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Horizon line (vanishing point at ~18% screen height)
    final horizonY = h * 0.18;

    // 1. Cyber Sky & Horizon Gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF03050B),
          Color(0xFF0A0F1D),
          Color(0xFF141A2E),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, horizonY));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, horizonY), skyPaint);

    // Distant Cyber City Silhouette & Horizon Glow
    _drawHorizonBackdrop(canvas, w, horizonY);

    // 2. Off-Road Ground Grid
    final groundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF070B14),
          Color(0xFF0A0E1A),
          Color(0xFF060912),
        ],
      ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY));
    canvas.drawRect(Rect.fromLTWH(0, horizonY, w, h - horizonY), groundPaint);

    // Draw perspective grid lines off-road
    _drawOffRoadGrid(canvas, w, h, horizonY);

    // 3. Perspective Road Surface
    // Road width at horizon: 32% of screen; at bottom: 78% of screen
    final roadTopWidth = w * 0.32;
    final roadBottomWidth = w * 0.78;

    final roadTopLeft = (w - roadTopWidth) / 2;
    final roadTopRight = roadTopLeft + roadTopWidth;
    final roadBottomLeft = (w - roadBottomWidth) / 2;
    final roadBottomRight = roadBottomLeft + roadBottomWidth;

    final roadPath = Path()
      ..moveTo(roadTopLeft, horizonY)
      ..lineTo(roadTopRight, horizonY)
      ..lineTo(roadBottomRight, h)
      ..lineTo(roadBottomLeft, h)
      ..close();

    // Road asphalt gradient
    final roadPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF10141E),
          Color(0xFF161B26),
          Color(0xFF1E2330),
        ],
      ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY));
    canvas.drawPath(roadPath, roadPaint);

    // 4. Glowing Neon Road Borders
    _drawNeonBorders(canvas, roadTopLeft, roadTopRight, roadBottomLeft, roadBottomRight, horizonY, h);

    // 5. Scrolling Lane Dividers (3 lanes = 2 dividers)
    _drawLaneDividers(canvas, roadTopLeft, roadTopRight, roadBottomLeft, roadBottomRight, horizonY, h);
  }

  void _drawHorizonBackdrop(Canvas canvas, double w, double horizonY) {
    // Horizon glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, 1.0),
        radius: 1.0,
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.25),
          const Color(0xFFE02424).withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, horizonY * 1.5));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, horizonY), glowPaint);

    // Simple geometric cyber building silhouettes
    final cityPaint = Paint()..color = const Color(0xFF0F1524);
    final rng = math.Random(42); // deterministic skyline
    double x = 0;
    while (x < w) {
      final bWidth = 14.0 + rng.nextDouble() * 26.0;
      final bHeight = 15.0 + rng.nextDouble() * 35.0;
      canvas.drawRect(Rect.fromLTWH(x, horizonY - bHeight, bWidth, bHeight), cityPaint);
      x += bWidth + 2.0;
    }
  }

  void _drawOffRoadGrid(Canvas canvas, double w, double h, double horizonY) {
    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Diagonal terrain lines radiating from horizon
    final centerX = w / 2;
    for (int i = -6; i <= 6; i++) {
      if (i.abs() <= 2) continue; // Skip road area
      final bottomX = centerX + (i * (w / 6));
      canvas.drawLine(Offset(centerX, horizonY), Offset(bottomX, h), gridPaint);
    }
  }

  void _drawNeonBorders(
    Canvas canvas,
    double topLeft,
    double topRight,
    double bottomLeft,
    double bottomRight,
    double topY,
    double bottomY,
  ) {
    // Left barrier glow
    final leftGlowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.45)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final leftSolidPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(topLeft, topY), Offset(bottomLeft, bottomY), leftGlowPaint);
    canvas.drawLine(Offset(topLeft, topY), Offset(bottomLeft, bottomY), leftSolidPaint);

    // Right barrier glow (Hot Magenta / Red)
    final rightGlowPaint = Paint()
      ..color = const Color(0xFFFF1744).withValues(alpha: 0.45)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final rightSolidPaint = Paint()
      ..color = const Color(0xFFFF1744)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(topRight, topY), Offset(bottomRight, bottomY), rightGlowPaint);
    canvas.drawLine(Offset(topRight, topY), Offset(bottomRight, bottomY), rightSolidPaint);
  }

  void _drawLaneDividers(
    Canvas canvas,
    double topLeft,
    double topRight,
    double bottomLeft,
    double bottomRight,
    double topY,
    double bottomY,
  ) {
    final topRoadW = topRight - topLeft;
    final botRoadW = bottomRight - bottomLeft;

    // 3 equal lanes -> 2 divider lines at 1/3 and 2/3
    final dividerFractions = [1.0 / 3.0, 2.0 / 3.0];

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke;

    const int totalDashes = 14;

    for (final fraction in dividerFractions) {
      final lineTopX = topLeft + (topRoadW * fraction);
      final lineBotX = bottomLeft + (botRoadW * fraction);

      for (int i = 0; i < totalDashes; i++) {
        // Perspective distribution from horizon to bottom
        final pStart = ((i + scrollOffset) % totalDashes) / totalDashes;
        final pEnd = pStart + (0.45 / totalDashes);
        if (pEnd > 1.0) continue;

        // Quadratic curve for perspective depth acceleration
        final t0 = pStart * pStart;
        final t1 = pEnd * pEnd;

        final y0 = topY + (bottomY - topY) * t0;
        final y1 = topY + (bottomY - topY) * t1;

        final x0 = lineTopX + (lineBotX - lineTopX) * t0;
        final x1 = lineTopX + (lineBotX - lineTopX) * t1;

        // Thickness increases as it gets closer
        dashPaint.strokeWidth = 1.0 + (3.5 * t1);

        canvas.drawLine(Offset(x0, y0), Offset(x1, y1), dashPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ArcadeRoadPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.playerSpeedMph != playerSpeedMph;
  }
}
