import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders a dynamic pseudo-3D cyber highway environment with support for smooth
/// curved road geometry, multi-layered parallax skylines, scrolling roadside gantries,
/// alternating kerb rumble strips, 3D guardrails with glowing neon crash barriers,
/// asphalt wet sheen, dashed lane dividers with cat's-eye studs, and speed effects.
class ArcadeRoadPainter extends CustomPainter {
  final double scrollOffset;
  final double playerSpeedMph;
  final double curveOffset;

  ArcadeRoadPainter({
    required this.scrollOffset,
    required this.playerSpeedMph,
    this.curveOffset = 0.0,
  });

  /// Center X offset of the road at vertical depth t (0.0 = horizon, 1.0 = bottom)
  double getCurveShift(double t, double w) {
    final maxHorizonShift = w * 0.28;
    return curveOffset * maxHorizonShift * math.pow(1.0 - t, 2.0);
  }

  /// Center X coordinate of the road at depth t
  double getRoadCenterX(double t, double w) {
    return (w / 2) + getCurveShift(t, w);
  }

  /// Road width at depth t
  double getRoadWidth(double t, double w) {
    final topW = w * 0.32;
    final botW = w * 0.78;
    return topW + (botW - topW) * t;
  }

  /// Left edge X coordinate of road at depth t
  double getRoadLeftX(double t, double w) {
    return getRoadCenterX(t, w) - (getRoadWidth(t, w) / 2);
  }

  /// Right edge X coordinate of road at depth t
  double getRoadRightX(double t, double w) {
    return getRoadCenterX(t, w) + (getRoadWidth(t, w) / 2);
  }

  /// Vertical Y coordinate at depth t
  double getRoadY(double t, double h, double horizonY) {
    return horizonY + (h - horizonY) * t;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Horizon line (vanishing point at ~18% screen height)
    final horizonY = h * 0.18;

    // 1. Deep Cyber Sky & Multi-Tier Distant Skyline with Parallax Yaw
    _drawSkyAndSkyline(canvas, w, h, horizonY);

    // 2. Off-Road Perspective Neon Terrain Grid
    _drawOffRoadTerrain(canvas, w, h, horizonY);

    // 3. Road Shoulder Gravel Run-Off Strips (Curved)
    _drawRoadShoulders(canvas, w, h, horizonY);

    // 4. Main Asphalt Highway Surface & Wet Sheen (Curved)
    _drawAsphaltSurface(canvas, w, h, horizonY);

    // 5. Dynamic Scrolling Kerb Rumble Strips (Red/White & Cyan along curve)
    _drawRumbleStrips(canvas, w, h, horizonY);

    // 6. 3D Elevated Guardrails, Support Posts & Continuous Glowing Neon Barriers
    _drawGuardrailsAndBarriers(canvas, w, h, horizonY);

    // 7. Scrolling Dashed Lane Dividers with Reflective Cat's-Eye Studs (Curved)
    _drawLaneDividersAndStuds(canvas, w, h, horizonY);

    // 8. Roadside Cyber Streetlamps / Light Gantries with Roadside Scenery (Curved)
    _drawRoadsideGantriesAndScenery(canvas, w, h, horizonY);

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

    // Parallax horizon counter-shift during turns
    final parallaxShift = -curveOffset * 32.0;

    canvas.save();
    canvas.translate(parallaxShift, 0.0);

    // 2. Distant Starfield & Data Grid Points
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.45);
    final rng = math.Random(1337);
    for (int i = 0; i < 35; i++) {
      final sx = rng.nextDouble() * (w + 80.0) - 40.0;
      final sy = rng.nextDouble() * (horizonY * 0.75);
      final r = 0.5 + rng.nextDouble() * 1.0;
      canvas.drawCircle(Offset(sx, sy), r, starPaint);
    }

    // 3. Multi-Layer Cyberpunk City Skyline
    // Layer A: Distant Dark Mega-Pyramids and Monoliths
    final megaPaint = Paint()..color = const Color(0xFF090E1A);
    double mx = -60.0;
    while (mx < w + 60.0) {
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

    double bx = -40.0;
    int bIndex = 0;
    while (bx < w + 40.0) {
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

    canvas.restore();

    // 4. Horizon Atmospheric Neon Glow
    final speedNorm = (playerSpeedMph / 250.0).clamp(0.0, 1.0);
    final glowAlpha = 0.28 + 0.20 * speedNorm;
    final horizonCenter = Offset(getRoadCenterX(0.0, w), horizonY);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (horizonCenter.dx / w) * 2.0 - 1.0,
          1.0,
        ),
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

    // Neon perspective terrain grid lines extending from road horizon center
    final gridPaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.07)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final horizonX = getRoadCenterX(0.0, w);
    final bottomCenterX = getRoadCenterX(1.0, w);

    for (int i = -8; i <= 8; i++) {
      if (i.abs() <= 2) continue; // Skip active road area
      final bottomX = bottomCenterX + (i * (w / 7));
      canvas.drawLine(Offset(horizonX, horizonY), Offset(bottomX, h), gridPaint);
    }
  }

  void _drawRoadShoulders(Canvas canvas, double w, double h, double horizonY) {
    const int segments = 22;
    final leftShoulderPath = Path();
    final rightShoulderPath = Path();

    // 1. Build Left Shoulder
    final topLX = getRoadLeftX(0.0, w);
    final topSW = getRoadWidth(0.0, w) * 0.12;
    leftShoulderPath.moveTo(topLX - topSW, horizonY);

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final y = getRoadY(t, h, horizonY);
      final lx = getRoadLeftX(t, w);
      final sw = getRoadWidth(t, w) * 0.13;
      leftShoulderPath.lineTo(lx - sw, y);
    }
    for (int i = segments; i >= 0; i--) {
      final t = i / segments;
      final y = getRoadY(t, h, horizonY);
      final lx = getRoadLeftX(t, w);
      leftShoulderPath.lineTo(lx, y);
    }
    leftShoulderPath.close();

    // 2. Build Right Shoulder
    final topRX = getRoadRightX(0.0, w);
    rightShoulderPath.moveTo(topRX, horizonY);

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final y = getRoadY(t, h, horizonY);
      final rx = getRoadRightX(t, w);
      rightShoulderPath.lineTo(rx, y);
    }
    for (int i = segments; i >= 0; i--) {
      final t = i / segments;
      final y = getRoadY(t, h, horizonY);
      final rx = getRoadRightX(t, w);
      final sw = getRoadWidth(t, w) * 0.13;
      rightShoulderPath.lineTo(rx + sw, y);
    }
    rightShoulderPath.close();

    final shoulderPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0C101A), Color(0xFF141924), Color(0xFF0E121B)],
      ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY));

    canvas.drawPath(leftShoulderPath, shoulderPaint);
    canvas.drawPath(rightShoulderPath, shoulderPaint);
  }

  void _drawAsphaltSurface(Canvas canvas, double w, double h, double horizonY) {
    const int segments = 24;
    final roadPath = Path();

    // Trace along left curve from top to bottom
    roadPath.moveTo(getRoadLeftX(0.0, w), horizonY);
    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      roadPath.lineTo(getRoadLeftX(t, w), getRoadY(t, h, horizonY));
    }

    // Bottom edge
    roadPath.lineTo(getRoadRightX(1.0, w), h);

    // Trace along right curve from bottom to top
    for (int i = segments - 1; i >= 0; i--) {
      final t = i / segments;
      roadPath.lineTo(getRoadRightX(t, w), getRoadY(t, h, horizonY));
    }
    roadPath.close();

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

    // Center Wet-Asphalt Reflective Light Sheen following road curve
    final sheenPath = Path();
    sheenPath.moveTo(getRoadCenterX(0.0, w) - getRoadWidth(0.0, w) * 0.22, horizonY);
    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      final cx = getRoadCenterX(t, w);
      final rw = getRoadWidth(t, w);
      sheenPath.lineTo(cx - rw * 0.22, getRoadY(t, h, horizonY));
    }
    for (int i = segments; i >= 0; i--) {
      final t = i / segments;
      final cx = getRoadCenterX(t, w);
      final rw = getRoadWidth(t, w);
      sheenPath.lineTo(cx + rw * 0.22, getRoadY(t, h, horizonY));
    }
    sheenPath.close();

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
      ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY));
    canvas.drawPath(sheenPath, sheenPaint);

    // Subtle Road Surface Motion Grit Lines across curved slices
    final gritPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.038)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const int totalGritSteps = 28;
    for (int i = 0; i < totalGritSteps; i++) {
      final progress = ((i + scrollOffset * 1.6) % totalGritSteps) / totalGritSteps;
      final t = progress * progress; // quadratic perspective curve
      final y = getRoadY(t, h, horizonY);

      final lx = getRoadLeftX(t, w);
      final rx = getRoadRightX(t, w);

      canvas.drawLine(Offset(lx, y), Offset(rx, y), gritPaint);
    }
  }

  void _drawRumbleStrips(Canvas canvas, double w, double h, double horizonY) {
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

      final y0 = getRoadY(t0, h, horizonY);
      final y1 = getRoadY(t1, h, horizonY);

      final curbWidth0 = 3.0 + (14.0 * t0);
      final curbWidth1 = 3.0 + (14.0 * t1);

      // Alternating curb colors
      final isEven = (i % 2 == 0);
      final leftPaint = isEven ? redCurbPaint : whiteCurbPaint;
      final rightPaint = isEven ? cyanCurbPaint : whiteCurbPaint;

      // Left Verge Rumble Kerb
      final lx0 = getRoadLeftX(t0, w);
      final lx1 = getRoadLeftX(t1, w);
      final leftCurbPath = Path()
        ..moveTo(lx0 - curbWidth0, y0)
        ..lineTo(lx0, y0)
        ..lineTo(lx1, y1)
        ..lineTo(lx1 - curbWidth1, y1)
        ..close();
      canvas.drawPath(leftCurbPath, leftPaint);

      // Right Verge Rumble Kerb
      final rx0 = getRoadRightX(t0, w);
      final rx1 = getRoadRightX(t1, w);
      final rightCurbPath = Path()
        ..moveTo(rx0, y0)
        ..lineTo(rx0 + curbWidth0, y0)
        ..lineTo(rx1 + curbWidth1, y1)
        ..lineTo(rx1, y1)
        ..close();
      canvas.drawPath(rightCurbPath, rightPaint);
    }
  }

  void _drawGuardrailsAndBarriers(Canvas canvas, double w, double h, double horizonY) {
    // 1. 3D Guardrail Vertical Support Posts along curved boundary
    final postPaint = Paint()
      ..color = const Color(0xFF384358)
      ..strokeWidth = 2.0;

    const int totalPosts = 16;
    for (int i = 0; i < totalPosts; i++) {
      final p = ((i + scrollOffset * 0.8) % totalPosts) / totalPosts;
      final t = p * p;
      final y = getRoadY(t, h, horizonY);
      final postHeight = 6.0 + (26.0 * t);

      // Left post
      final lx = getRoadLeftX(t, w);
      canvas.drawLine(Offset(lx - 2, y), Offset(lx - 2, y - postHeight), postPaint);

      // Right post
      final rx = getRoadRightX(t, w);
      canvas.drawLine(Offset(rx + 2, y), Offset(rx + 2, y - postHeight), postPaint);
    }

    // 2. Continuous Left Neon Barrier (Cyber Cyan) following road curve
    const int curveSteps = 24;
    final leftPath = Path()..moveTo(getRoadLeftX(0.0, w), horizonY);
    for (int i = 1; i <= curveSteps; i++) {
      final t = i / curveSteps;
      leftPath.lineTo(getRoadLeftX(t, w), getRoadY(t, h, horizonY));
    }

    final leftGlow = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.5)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final leftSolid = Paint()
      ..color = const Color(0xFF00F0FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(leftPath, leftGlow);
    canvas.drawPath(leftPath, leftSolid);

    // 3. Continuous Right Neon Barrier (Electric Red) following road curve
    final rightPath = Path()..moveTo(getRoadRightX(0.0, w), horizonY);
    for (int i = 1; i <= curveSteps; i++) {
      final t = i / curveSteps;
      rightPath.lineTo(getRoadRightX(t, w), getRoadY(t, h, horizonY));
    }

    final rightGlow = Paint()
      ..color = const Color(0xFFFF1E44).withValues(alpha: 0.5)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final rightSolid = Paint()
      ..color = const Color(0xFFFF1E44)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(rightPath, rightGlow);
    canvas.drawPath(rightPath, rightSolid);
  }

  void _drawLaneDividersAndStuds(Canvas canvas, double w, double h, double horizonY) {
    // 3 equal lanes -> 2 divider lines at fractions 1/3 and 2/3
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
      for (int i = 0; i < totalDashes; i++) {
        final pStart = ((i + scrollOffset) % totalDashes) / totalDashes;
        final pEnd = pStart + (0.45 / totalDashes);
        if (pEnd > 1.0) continue;

        final t0 = pStart * pStart;
        final t1 = pEnd * pEnd;

        final y0 = getRoadY(t0, h, horizonY);
        final y1 = getRoadY(t1, h, horizonY);

        final x0 = getRoadLeftX(t0, w) + (getRoadWidth(t0, w) * fraction);
        final x1 = getRoadLeftX(t1, w) + (getRoadWidth(t1, w) * fraction);

        // Line thickness grows with perspective
        dashPaint.strokeWidth = 1.0 + (3.8 * t1);
        canvas.drawLine(Offset(x0, y0), Offset(x1, y1), dashPaint);

        // Retroreflective cat's-eye road stud between dashes
        final studT = (t0 + t1) / 2.0;
        if (studT > 0.08) {
          final sx = getRoadLeftX(studT, w) + (getRoadWidth(studT, w) * fraction);
          final sy = getRoadY(studT, h, horizonY);
          final studRadius = 1.0 + (2.2 * studT);

          canvas.drawCircle(Offset(sx, sy), studRadius * 1.5, studGlow);
          canvas.drawCircle(Offset(sx, sy), studRadius, studPaint);
        }
      }
    }
  }

  void _drawRoadsideGantriesAndScenery(Canvas canvas, double w, double h, double horizonY) {
    // Spaced overhead cyber gantries / streetlamp arches scrolling with progress along curve
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

      final y = getRoadY(t, h, horizonY);
      final archH = 22.0 + (90.0 * t);

      final lx = getRoadLeftX(t, w) - (18.0 * t);
      final rx = getRoadRightX(t, w) + (18.0 * t);

      // Overhead arch gantry spanning the curved road
      final archPath = Path()
        ..moveTo(lx, y)
        ..lineTo(lx, y - archH)
        ..lineTo(rx, y - archH)
        ..lineTo(rx, y);
      canvas.drawPath(archPath, gantryFramePaint);

      // Downward road illumination pool from overhead lamps centered on road
      final poolCenterX = (lx + rx) / 2;
      final poolRect = Rect.fromCenter(
        center: Offset(poolCenterX, y),
        width: (rx - lx) * 0.8,
        height: 18.0 * t + 8.0,
      );
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

      final y0 = getRoadY(t0, h, horizonY);
      final y1 = getRoadY(t1, h, horizonY);

      final spread0 = (w * 0.22) + (rng.nextDouble() * w * 0.25);
      final spread1 = spread0 * (1.0 + 1.2 * t1);

      final x0 = getRoadCenterX(t0, w) + (side * spread0);
      final x1 = getRoadCenterX(t1, w) + (side * spread1);

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
        oldDelegate.playerSpeedMph != playerSpeedMph ||
        oldDelegate.curveOffset != curveOffset;
  }
}
