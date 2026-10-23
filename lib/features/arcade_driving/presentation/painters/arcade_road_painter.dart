import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders an enhanced pseudo-3D cyber highway environment with multi-layered parallax
/// skylines, scrolling roadside cyber streetlamps/gantries, alternating kerb rumble strips,
/// 3D guardrail posts with neon crash barriers, textured asphalt with tire wear sheen,
/// dashed lane dividers with reflective cat's-eye studs, and high-speed warp effects.
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

    // 1. Deep Cyber Sky & Multi-Tier Distant Skyline
    _drawSkyAndSkyline(canvas, w, h, horizonY);

    // 2. Off-Road Perspective Neon Terrain Grid
    _drawOffRoadTerrain(canvas, w, h, horizonY);

    // Road Geometry: Width at horizon: 32% of screen; at bottom: 78% of screen
    final roadTopWidth = w * 0.32;
    final roadBottomWidth = w * 0.78;

    final roadTopLeft = (w - roadTopWidth) / 2;
    final roadTopRight = roadTopLeft + roadTopWidth;
    final roadBottomLeft = (w - roadBottomWidth) / 2;
    final roadBottomRight = roadBottomLeft + roadBottomWidth;

    // 3. Road Shoulder Gravel Run-Off Strips
    _drawRoadShoulders(canvas, w, h, horizonY, roadTopLeft, roadTopRight, roadBottomLeft, roadBottomRight);

    // 4. Main Asphalt Highway Surface & Wet Sheen
    _drawAsphaltSurface(canvas, w, h, horizonY, roadTopLeft, roadTopRight, roadBottomLeft, roadBottomRight);

    // 5. Dynamic Scrolling Kerb Rumble Strips (Red/White & Cyan)
    _drawRumbleStrips(canvas, horizonY, h, roadTopLeft, roadTopRight, roadBottomLeft, roadBottomRight);

    // 6. 3D Elevated Guardrails, Support Posts & Glowing Neon Barriers
    _drawGuardrailsAndBarriers(canvas, horizonY, h, roadTopLeft, roadTopRight, roadBottomLeft, roadBottomRight);

    // 7. Scrolling Dashed Lane Dividers with Reflective Cat's-Eye Studs
    _drawLaneDividersAndStuds(canvas, horizonY, h, roadTopLeft, roadTopRight, roadBottomLeft, roadBottomRight);

    // 8. Roadside Cyber Streetlamps / Light Gantries with Roadside Scenery
    _drawRoadsideGantriesAndScenery(canvas, w, h, horizonY, roadTopLeft, roadTopRight, roadBottomLeft, roadBottomRight);

    // 9. High-Speed Warp Streaks (active at > 85 MPH)
    if (playerSpeedMph > 85.0) {
      _drawWarpSpeedLines(canvas, w, h, horizonY);
    }

    // 10. Hyper-Speed Tunnel Vision Vignette (active at > 160 MPH)
    if (playerSpeedMph > 160.0) {
      _drawHyperSpeedVignette(canvas, w, h);
    }
  }

  void _drawSkyAndSkyline(Canvas canvas, double w, double h, double horizonY) {
    // 1. Deep Space Atmospheric Gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF020408),
          Color(0xFF070B16),
          Color(0xFF0F172B),
        ],
        stops: [0.0, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, horizonY));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, horizonY), skyPaint);

    // 2. Distant Starfield & Data Grid Points
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.45);
    final rng = math.Random(1337);
    for (int i = 0; i < 35; i++) {
      final sx = rng.nextDouble() * w;
      final sy = rng.nextDouble() * (horizonY * 0.75);
      final r = 0.5 + rng.nextDouble() * 1.0;
      canvas.drawCircle(Offset(sx, sy), r, starPaint);
    }

    // 3. Multi-Layer Cyberpunk City Skyline
    // Layer A: Distant Dark Mega-Pyramids and Monoliths
    final megaPaint = Paint()..color = const Color(0xFF090E1A);
    double mx = 0;
    while (mx < w) {
      final mw = 40.0 + rng.nextDouble() * 70.0;
      final mh = 25.0 + rng.nextDouble() * 55.0;
      canvas.drawRect(Rect.fromLTWH(mx, horizonY - mh, mw, mh), megaPaint);
      mx += mw + 8.0;
    }

    // Layer B: Mid-Ground Skyscrapers with Illuminated Windows & Antenna Beacons
    final midBuildingPaint = Paint()..color = const Color(0xFF11182B);
    final windowCyan = const Color(0xFF00F0FF).withValues(alpha: 0.65);
    final windowAmber = const Color(0xFFFFB300).withValues(alpha: 0.65);
    final beaconRed = const Color(0xFFFF1744);

    double bx = 0;
    int bIndex = 0;
    while (bx < w) {
      final bw = 16.0 + rng.nextDouble() * 32.0;
      final bh = 18.0 + rng.nextDouble() * 42.0;
      final bRect = Rect.fromLTWH(bx, horizonY - bh, bw, bh);
      canvas.drawRect(bRect, midBuildingPaint);

      // Window rows on select buildings
      if (bIndex % 2 == 0) {
        final winPaint = Paint()..color = (bIndex % 4 == 0) ? windowCyan : windowAmber;
        for (double wy = horizonY - bh + 6.0; wy < horizonY - 4.0; wy += 8.0) {
          for (double wx = bx + 3.0; wx < bx + bw - 3.0; wx += 5.0) {
            canvas.drawRect(Rect.fromLTWH(wx, wy, 2.5, 3.5), winPaint);
          }
        }
      }

      // Rooftop antenna mast with blinking beacon
      if (bIndex % 3 == 0) {
        final antennaX = bx + bw / 2;
        canvas.drawLine(
          Offset(antennaX, horizonY - bh),
          Offset(antennaX, horizonY - bh - 8.0),
          Paint()..color = const Color(0xFF2A3650)..strokeWidth = 1.0,
        );
        canvas.drawCircle(Offset(antennaX, horizonY - bh - 8.0), 1.5, Paint()..color = beaconRed);
      }

      bx += bw + 3.0;
      bIndex++;
    }

    // 4. Horizon Atmospheric Neon Glow
    final speedNorm = (playerSpeedMph / 250.0).clamp(0.0, 1.0);
    final glowAlpha = 0.28 + 0.20 * speedNorm;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, 1.0),
        radius: 1.1,
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: glowAlpha),
          const Color(0xFF9900FF).withValues(alpha: glowAlpha * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, horizonY * 1.6));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, horizonY), glowPaint);
  }

  void _drawOffRoadTerrain(Canvas canvas, double w, double h, double horizonY) {
    // Terrain base gradient
    final terrainPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF060912),
          Color(0xFF090E1A),
          Color(0xFF04060C),
        ],
      ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY));
    canvas.drawRect(Rect.fromLTWH(0, horizonY, w, h - horizonY), terrainPaint);

    // Neon perspective terrain grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.07)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final centerX = w / 2;
    for (int i = -8; i <= 8; i++) {
      if (i.abs() <= 2) continue; // Skip road
      final bottomX = centerX + (i * (w / 7));
      canvas.drawLine(Offset(centerX, horizonY), Offset(bottomX, h), gridPaint);
    }
  }

  void _drawRoadShoulders(
    Canvas canvas,
    double w,
    double h,
    double horizonY,
    double roadTopLeft,
    double roadTopRight,
    double roadBottomLeft,
    double roadBottomRight,
  ) {
    // Darker asphalt shoulder run-off zone expanding 8% beyond road edges
    final shoulderTopW = (roadTopRight - roadTopLeft) * 0.12;
    final shoulderBotW = (roadBottomRight - roadBottomLeft) * 0.14;

    final leftShoulder = Path()
      ..moveTo(roadTopLeft - shoulderTopW, horizonY)
      ..lineTo(roadTopLeft, horizonY)
      ..lineTo(roadBottomLeft, h)
      ..lineTo(roadBottomLeft - shoulderBotW, h)
      ..close();

    final rightShoulder = Path()
      ..moveTo(roadTopRight, horizonY)
      ..lineTo(roadTopRight + shoulderTopW, horizonY)
      ..lineTo(roadBottomRight + shoulderBotW, h)
      ..lineTo(roadBottomRight, h)
      ..close();

    final shoulderPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0C101A), Color(0xFF141924), Color(0xFF0E121B)],
      ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY));

    canvas.drawPath(leftShoulder, shoulderPaint);
    canvas.drawPath(rightShoulder, shoulderPaint);
  }

  void _drawAsphaltSurface(
    Canvas canvas,
    double w,
    double h,
    double horizonY,
    double roadTopLeft,
    double roadTopRight,
    double roadBottomLeft,
    double roadBottomRight,
  ) {
    final roadPath = Path()
      ..moveTo(roadTopLeft, horizonY)
      ..lineTo(roadTopRight, horizonY)
      ..lineTo(roadBottomRight, h)
      ..lineTo(roadBottomLeft, h)
      ..close();

    // High-tech asphalt gradient with deep contrast
    final asphaltPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0F141F),
          Color(0xFF151B27),
          Color(0xFF1A2130),
          Color(0xFF121722),
        ],
        stops: [0.0, 0.4, 0.85, 1.0],
      ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY));
    canvas.drawPath(roadPath, asphaltPaint);

    // Center Wet-Asphalt Reflective Light Sheen
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0xFF00F0FF).withValues(alpha: 0.05),
          const Color(0xFF00F0FF).withValues(alpha: 0.09),
          const Color(0xFF00F0FF).withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(roadBottomLeft, horizonY, roadBottomRight - roadBottomLeft, h - horizonY));
    canvas.drawPath(roadPath, sheenPaint);

    // Subtle Road Surface Motion Grit Lines
    final gritPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.038)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const int totalGritSteps = 28;
    for (int i = 0; i < totalGritSteps; i++) {
      final progress = ((i + scrollOffset * 1.6) % totalGritSteps) / totalGritSteps;
      final t = progress * progress; // quadratic perspective curve
      final y = horizonY + (h - horizonY) * t;

      final xLeft = roadTopLeft + (roadBottomLeft - roadTopLeft) * t;
      final xRight = roadTopRight + (roadBottomRight - roadTopRight) * t;

      canvas.drawLine(Offset(xLeft, y), Offset(xRight, y), gritPaint);
    }
  }

  void _drawRumbleStrips(
    Canvas canvas,
    double topY,
    double bottomY,
    double topLeft,
    double topRight,
    double bottomLeft,
    double bottomRight,
  ) {
    const int totalCurbs = 26;
    final redCurbPaint = Paint()..color = const Color(0xFFFF2A4D);
    final whiteCurbPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    final cyanCurbPaint = Paint()..color = const Color(0xFF00F0FF);

    for (int i = 0; i < totalCurbs; i++) {
      final p0 = ((i + scrollOffset * 1.5) % totalCurbs) / totalCurbs;
      final p1 = p0 + (0.50 / totalCurbs);
      if (p1 > 1.0) continue;

      final t0 = p0 * p0;
      final t1 = p1 * p1;

      final y0 = topY + (bottomY - topY) * t0;
      final y1 = topY + (bottomY - topY) * t1;

      final curbWidth0 = 3.0 + (14.0 * t0);
      final curbWidth1 = 3.0 + (14.0 * t1);

      // Alternating curb colors
      final isEven = (i % 2 == 0);
      final leftPaint = isEven ? redCurbPaint : whiteCurbPaint;
      final rightPaint = isEven ? cyanCurbPaint : whiteCurbPaint;

      // Left Verge Rumble Kerb
      final lx0 = topLeft + (bottomLeft - topLeft) * t0;
      final lx1 = topLeft + (bottomLeft - topLeft) * t1;
      final leftCurbPath = Path()
        ..moveTo(lx0 - curbWidth0, y0)
        ..lineTo(lx0, y0)
        ..lineTo(lx1, y1)
        ..lineTo(lx1 - curbWidth1, y1)
        ..close();
      canvas.drawPath(leftCurbPath, leftPaint);

      // Right Verge Rumble Kerb
      final rx0 = topRight + (bottomRight - topRight) * t0;
      final rx1 = topRight + (bottomRight - topRight) * t1;
      final rightCurbPath = Path()
        ..moveTo(rx0, y0)
        ..lineTo(rx0 + curbWidth0, y0)
        ..lineTo(rx1 + curbWidth1, y1)
        ..lineTo(rx1, y1)
        ..close();
      canvas.drawPath(rightCurbPath, rightPaint);
    }
  }

  void _drawGuardrailsAndBarriers(
    Canvas canvas,
    double topY,
    double bottomY,
    double topLeft,
    double topRight,
    double bottomLeft,
    double bottomRight,
  ) {
    // 1. 3D Guardrail Vertical Support Posts spaced along track
    final postPaint = Paint()
      ..color = const Color(0xFF384358)
      ..strokeWidth = 2.0;

    const int totalPosts = 16;
    for (int i = 0; i < totalPosts; i++) {
      final p = ((i + scrollOffset * 0.8) % totalPosts) / totalPosts;
      final t = p * p;
      final y = topY + (bottomY - topY) * t;
      final postHeight = 6.0 + (26.0 * t);

      // Left post
      final lx = topLeft + (bottomLeft - topLeft) * t;
      canvas.drawLine(Offset(lx - 2, y), Offset(lx - 2, y - postHeight), postPaint);

      // Right post
      final rx = topRight + (bottomRight - topRight) * t;
      canvas.drawLine(Offset(rx + 2, y), Offset(rx + 2, y - postHeight), postPaint);
    }

    // 2. Continuous Left Neon Barrier (Cyber Cyan)
    final leftGlow = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.5)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final leftSolid = Paint()
      ..color = const Color(0xFF00F0FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(topLeft, topY), Offset(bottomLeft, bottomY), leftGlow);
    canvas.drawLine(Offset(topLeft, topY), Offset(bottomLeft, bottomY), leftSolid);

    // 3. Continuous Right Neon Barrier (Electric Red)
    final rightGlow = Paint()
      ..color = const Color(0xFFFF1E44).withValues(alpha: 0.5)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final rightSolid = Paint()
      ..color = const Color(0xFFFF1E44)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(topRight, topY), Offset(bottomRight, bottomY), rightGlow);
    canvas.drawLine(Offset(topRight, topY), Offset(bottomRight, bottomY), rightSolid);
  }

  void _drawLaneDividersAndStuds(
    Canvas canvas,
    double topY,
    double bottomY,
    double topLeft,
    double topRight,
    double bottomLeft,
    double bottomRight,
  ) {
    final topRoadW = topRight - topLeft;
    final botRoadW = bottomRight - bottomLeft;

    // 3 equal lanes -> 2 divider lines
    final dividerFractions = [1.0 / 3.0, 2.0 / 3.0];

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke;

    final studPaint = Paint()..color = const Color(0xFFFFB300);
    final studGlow = Paint()
      ..color = const Color(0xFFFFB300).withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    const int totalDashes = 15;

    for (final fraction in dividerFractions) {
      final lineTopX = topLeft + (topRoadW * fraction);
      final lineBotX = bottomLeft + (botRoadW * fraction);

      for (int i = 0; i < totalDashes; i++) {
        final pStart = ((i + scrollOffset) % totalDashes) / totalDashes;
        final pEnd = pStart + (0.45 / totalDashes);
        if (pEnd > 1.0) continue;

        final t0 = pStart * pStart;
        final t1 = pEnd * pEnd;

        final y0 = topY + (bottomY - topY) * t0;
        final y1 = topY + (bottomY - topY) * t1;

        final x0 = lineTopX + (lineBotX - lineTopX) * t0;
        final x1 = lineTopX + (lineBotX - lineTopX) * t1;

        // Line thickness grows with perspective
        dashPaint.strokeWidth = 1.0 + (3.8 * t1);
        canvas.drawLine(Offset(x0, y0), Offset(x1, y1), dashPaint);

        // Retroreflective cat's-eye road stud between dashes
        final studT = (t0 + t1) / 2.0;
        if (studT > 0.08) {
          final sx = lineTopX + (lineBotX - lineTopX) * studT;
          final sy = topY + (bottomY - topY) * studT;
          final studRadius = 1.0 + (2.2 * studT);

          canvas.drawCircle(Offset(sx, sy), studRadius * 1.5, studGlow);
          canvas.drawCircle(Offset(sx, sy), studRadius, studPaint);
        }
      }
    }
  }

  void _drawRoadsideGantriesAndScenery(
    Canvas canvas,
    double w,
    double h,
    double horizonY,
    double roadTopLeft,
    double roadTopRight,
    double roadBottomLeft,
    double roadBottomRight,
  ) {
    // Spaced overhead cyber gantries / streetlamp arches scrolling with progress
    const int totalGantries = 4;
    final gantryFramePaint = Paint()
      ..color = const Color(0xFF202A3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final lampLightPaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    for (int i = 0; i < totalGantries; i++) {
      final p = ((i + scrollOffset * 0.25) % totalGantries) / totalGantries;
      final t = p * p;
      if (t < 0.04 || t > 0.98) continue;

      final y = horizonY + (h - horizonY) * t;
      final archH = 22.0 + (90.0 * t);

      final lx = roadTopLeft + (roadBottomLeft - roadTopLeft) * t - (18.0 * t);
      final rx = roadTopRight + (roadBottomRight - roadTopRight) * t + (18.0 * t);

      // Overhead arch gantry spanning the road
      final archPath = Path()
        ..moveTo(lx, y)
        ..lineTo(lx, y - archH)
        ..lineTo(rx, y - archH)
        ..lineTo(rx, y);
      canvas.drawPath(archPath, gantryFramePaint);

      // Downward road illumination pool from overhead lamps
      final poolRect = Rect.fromCenter(center: Offset((lx + rx) / 2, y), width: (rx - lx) * 0.8, height: 18.0 * t + 8.0);
      canvas.drawOval(poolRect, lampLightPaint);

      // Gantry status beacon lights
      final beaconX1 = lx + (rx - lx) * 0.35;
      final beaconX2 = lx + (rx - lx) * 0.65;
      canvas.drawCircle(Offset(beaconX1, y - archH), 1.5 + (2.0 * t), Paint()..color = const Color(0xFF00F0FF));
      canvas.drawCircle(Offset(beaconX2, y - archH), 1.5 + (2.0 * t), Paint()..color = const Color(0xFFFF1744));
    }
  }

  void _drawWarpSpeedLines(Canvas canvas, double w, double h, double horizonY) {
    final warpFactor = ((playerSpeedMph - 85.0) / 165.0).clamp(0.0, 1.0);
    final streakAlpha = (0.2 + 0.5 * warpFactor).clamp(0.0, 0.7);

    final streakPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: streakAlpha)
      ..strokeWidth = 1.5 + (2.0 * warpFactor)
      ..style = PaintingStyle.stroke;

    final rng = math.Random(77);
    final streakCount = (8 + (16 * warpFactor)).toInt();

    for (int i = 0; i < streakCount; i++) {
      final side = rng.nextBool() ? 1 : -1;
      final startProgress = rng.nextDouble() * 0.7;
      final length = 0.12 + 0.25 * warpFactor;
      final endProgress = (startProgress + length).clamp(0.0, 1.0);

      final t0 = startProgress * startProgress;
      final t1 = endProgress * endProgress;

      final y0 = horizonY + (h - horizonY) * t0;
      final y1 = horizonY + (h - horizonY) * t1;

      final spread0 = (w * 0.22) + (rng.nextDouble() * w * 0.25);
      final spread1 = spread0 * (1.0 + 1.2 * t1);

      final x0 = (w / 2) + (side * spread0);
      final x1 = (w / 2) + (side * spread1);

      canvas.drawLine(Offset(x0, y0), Offset(x1, y1), streakPaint);
    }
  }

  void _drawHyperSpeedVignette(Canvas canvas, double w, double h) {
    final hyperFactor = ((playerSpeedMph - 160.0) / 90.0).clamp(0.0, 1.0);
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.black.withValues(alpha: 0.35 * hyperFactor),
          const Color(0xFF00F0FF).withValues(alpha: 0.18 * hyperFactor),
        ],
        stops: const [0.0, 0.65, 0.88, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), vignettePaint);
  }

  @override
  bool shouldRepaint(covariant ArcadeRoadPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.playerSpeedMph != playerSpeedMph;
  }
}
