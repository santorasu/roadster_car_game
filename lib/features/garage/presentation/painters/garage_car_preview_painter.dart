import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/vehicle_definition.dart';

/// CustomPainter for rendering high-fidelity vehicle showroom previews in the Garage.
/// Features interactive turntable rotation, ambient floor grid, underglow emission,
/// and distinctive body shells for each fictional electric hypercar.
class GarageCarPreviewPainter extends CustomPainter {
  final VehicleDefinition vehicle;
  final PaintColorOption paintColor;
  final WheelStyleOption wheelStyle;
  final UnderglowOption underglow;
  final double turntableAngle; // Radians for subtle 3D turntable oscillation

  const GarageCarPreviewPainter({
    required this.vehicle,
    required this.paintColor,
    required this.wheelStyle,
    required this.underglow,
    this.turntableAngle = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Draw Showroom Turntable Floor & Lighting
    _drawShowroomFloor(canvas, size, cx, cy);

    // 2. Apply Turntable Perspective Transformation
    canvas.save();
    canvas.translate(cx, cy);

    // Subtle 3D perspective pitch and yaw from turntable
    final yawCos = math.cos(turntableAngle);
    final yawSin = math.sin(turntableAngle);

    // Slight scale and shear to give pseudo-3D turntable presence
    final scaleFactor = (size.height * 0.72) / 280.0;
    canvas.scale(scaleFactor * (0.95 + 0.05 * yawCos.abs()), scaleFactor);
    canvas.rotate(yawSin * 0.08);

    const carWidth = 120.0;
    const carHeight = 250.0;

    // 3. Ground Shadow & Neon Underglow
    _drawUnderglowAndShadow(canvas, carWidth, carHeight);

    // 4. Wheels & Brake Assemblies
    _drawWheelsAndRims(canvas, carWidth, carHeight);

    // 5. Vehicle Body Shell & Aero Surfaces
    _drawBodyShell(canvas, carWidth, carHeight);

    // 6. Cockpit Glass Canopy & Interior
    _drawCockpit(canvas, carWidth, carHeight);

    // 7. Lighting Assemblies & Aero Wing
    _drawLightingAndAero(canvas, carWidth, carHeight);

    canvas.restore();
  }

  void _drawShowroomFloor(Canvas canvas, Size size, double cx, double cy) {
    final w = size.width;
    final h = size.height;

    // Ambient radial showroom spotlight
    final spotShader = RadialGradient(
      center: Alignment.center,
      radius: 0.85,
      colors: [
        paintColor.accentColor.withValues(alpha: 0.14),
        const Color(0xFF0D111A),
        const Color(0xFF080A0F),
      ],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..shader = spotShader,
    );

    // Turntable circular rings
    final turntableBase = Paint()
      ..color = const Color(0xFF141A24)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 20), width: w * 0.90, height: h * 0.70),
      turntableBase,
    );

    // Concentric glowing rings
    final ringPaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 20), width: w * 0.88, height: h * 0.68),
      ringPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 20), width: w * 0.72, height: h * 0.54),
      ringPaint..strokeWidth = 0.8,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 20), width: w * 0.52, height: h * 0.38),
      ringPaint..color = paintColor.accentColor.withValues(alpha: 0.28),
    );

    // Turntable Radial Grid Spokes
    final spokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1.0;
    for (int i = 0; i < 12; i++) {
      final rad = (i * math.pi / 6) + (turntableAngle * 0.5);
      final rx = (w * 0.44) * math.cos(rad);
      final ry = (h * 0.34) * math.sin(rad);
      canvas.drawLine(Offset(cx, cy + 20), Offset(cx + rx, cy + 20 + ry), spokePaint);
    }
  }

  void _drawUnderglowAndShadow(Canvas canvas, double cw, double ch) {
    final halfW = cw / 2;

    // Contact Ground Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.75)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 4), width: cw * 1.15, height: ch * 1.04),
      shadowPaint,
    );

    // Neon Underglow Ground Emission
    if (underglow.color != Colors.transparent) {
      final glowOuter = Paint()
        ..color = underglow.color.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
      final glowInner = Paint()
        ..color = underglow.color.withValues(alpha: 0.80)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      final glowRect = Rect.fromCenter(
        center: const Offset(0, 0),
        width: cw * 1.05,
        height: ch * 0.90,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(glowRect, Radius.circular(halfW * 0.4)), glowOuter);
      canvas.drawRRect(RRect.fromRectAndRadius(glowRect, Radius.circular(halfW * 0.4)), glowInner);
    }
  }

  void _drawWheelsAndRims(Canvas canvas, double cw, double ch) {
    final halfW = cw / 2;
    final halfH = ch / 2;
    final tireW = cw * 0.24;
    final tireH = ch * 0.23;

    final wheelCenters = [
      Offset(-halfW * 0.90, -halfH * 0.58), // Front Left
      Offset(halfW * 0.90, -halfH * 0.58),  // Front Right
      Offset(-halfW * 0.92, halfH * 0.58),  // Rear Left
      Offset(halfW * 0.92, halfH * 0.58),   // Rear Right
    ];

    for (final center in wheelCenters) {
      // 1. Tire Rubber
      final tireRect = Rect.fromCenter(center: center, width: tireW, height: tireH);
      final tirePaint = Paint()..color = const Color(0xFF101217);
      canvas.drawRRect(RRect.fromRectAndRadius(tireRect, const Radius.circular(6)), tirePaint);

      // Tread edge
      final treadPaint = Paint()
        ..color = const Color(0xFF222630)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRRect(RRect.fromRectAndRadius(tireRect, const Radius.circular(6)), treadPaint);

      // 2. Carbon-Ceramic Brake Rotor
      final rotorPaint = Paint()..color = const Color(0xFF4B5563);
      final rimRadius = (tireW / 2) * 0.82;
      canvas.drawCircle(center, rimRadius, rotorPaint);

      // 3. Performance Brake Caliper
      final caliperPaint = Paint()..color = wheelStyle.caliperColor;
      final caliperRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy - rimRadius * 0.4),
        width: rimRadius * 0.70,
        height: rimRadius * 0.35,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(caliperRect, const Radius.circular(2)), caliperPaint);

      // 4. Rim Pattern according to WheelRimType
      _drawRimPattern(canvas, center, rimRadius);
    }
  }

  void _drawRimPattern(Canvas canvas, Offset center, double radius) {
    final rimBasePaint = Paint()..color = wheelStyle.rimBaseColor;
    final rimAccentPaint = Paint()
      ..color = wheelStyle.rimHighlightColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    switch (wheelStyle.rimType) {
      case WheelRimType.turbine:
        // 5 Swept directional turbine blades
        for (int i = 0; i < 5; i++) {
          final angle = (i * 2 * math.pi / 5) + (turntableAngle * 0.2);
          final p1 = Offset(center.dx + radius * 0.2 * math.cos(angle), center.dy + radius * 0.2 * math.sin(angle));
          final p2 = Offset(center.dx + radius * 0.88 * math.cos(angle + 0.4), center.dy + radius * 0.88 * math.sin(angle + 0.4));
          canvas.drawLine(p1, p2, rimAccentPaint);
        }
        break;

      case WheelRimType.cyberDisc:
        // Closed solid aero disc with circular venting ring
        canvas.drawCircle(center, radius * 0.82, rimBasePaint);
        canvas.drawCircle(center, radius * 0.82, rimAccentPaint);
        canvas.drawCircle(center, radius * 0.45, rimAccentPaint..strokeWidth = 0.8);
        for (int i = 0; i < 6; i++) {
          final angle = (i * 2 * math.pi / 6) + (turntableAngle * 0.2);
          final slotX = center.dx + radius * 0.65 * math.cos(angle);
          final slotY = center.dy + radius * 0.65 * math.sin(angle);
          canvas.drawCircle(Offset(slotX, slotY), 1.6, rimAccentPaint);
        }
        break;

      case WheelRimType.starfireSplit:
        // 5 Split dual-spoke sports rim
        for (int i = 0; i < 5; i++) {
          final baseAngle = (i * 2 * math.pi / 5) + (turntableAngle * 0.2);
          final a1 = baseAngle - 0.15;
          final a2 = baseAngle + 0.15;
          final p1 = Offset(center.dx + radius * 0.86 * math.cos(a1), center.dy + radius * 0.86 * math.sin(a1));
          final p2 = Offset(center.dx + radius * 0.86 * math.cos(a2), center.dy + radius * 0.86 * math.sin(a2));
          canvas.drawLine(center, p1, rimAccentPaint);
          canvas.drawLine(center, p2, rimAccentPaint);
        }
        break;

      case WheelRimType.carbonLattice:
        // Intricate lightweight hexagonal cross-mesh
        for (int i = 0; i < 8; i++) {
          final a1 = (i * 2 * math.pi / 8) + (turntableAngle * 0.2);
          final a2 = a1 + (math.pi / 4);
          final p1 = Offset(center.dx + radius * 0.85 * math.cos(a1), center.dy + radius * 0.85 * math.sin(a1));
          final p2 = Offset(center.dx + radius * 0.50 * math.cos(a2), center.dy + radius * 0.50 * math.sin(a2));
          canvas.drawLine(p1, p2, rimAccentPaint..strokeWidth = 0.9);
        }
        break;
    }

    // Central hub nut
    canvas.drawCircle(center, radius * 0.25, Paint()..color = const Color(0xFF0F1218));
    canvas.drawCircle(center, radius * 0.12, Paint()..color = wheelStyle.rimHighlightColor);
  }

  void _drawBodyShell(Canvas canvas, double cw, double ch) {
    final halfW = cw / 2;
    final halfH = ch / 2;
    final bodyPath = Path();

    // Distinct body shell silhouettes based on VehicleBodyStyle
    if (vehicle.bodyStyle == VehicleBodyStyle.valkyrieAero) {
      // APEX GT-E: Extreme circuit Le Mans aerodynamic archetype
      bodyPath.moveTo(0, -halfH * 0.98); // Sharp nose cone
      bodyPath.cubicTo(-halfW * 0.38, -halfH * 0.96, -halfW * 0.78, -halfH * 0.82, -halfW * 0.88, -halfH * 0.65); // Front splitter
      bodyPath.lineTo(-halfW * 0.86, -halfH * 0.35); // Front wheel arch
      bodyPath.cubicTo(-halfW * 0.65, -halfH * 0.20, -halfW * 0.62, halfH * 0.15, -halfW * 0.88, halfH * 0.35); // Deep venturi waist
      bodyPath.lineTo(-halfW * 0.92, halfH * 0.66); // Rear flared pontoon
      bodyPath.cubicTo(-halfW * 0.84, halfH * 0.85, -halfW * 0.68, halfH * 0.92, -halfW * 0.45, halfH * 0.96); // Rear diffuser
      bodyPath.lineTo(0, halfH * 0.97);
      bodyPath.lineTo(halfW * 0.45, halfH * 0.96);
      bodyPath.cubicTo(halfW * 0.68, halfH * 0.92, halfW * 0.84, halfH * 0.85, halfW * 0.92, halfH * 0.66);
      bodyPath.lineTo(halfW * 0.88, halfH * 0.35);
      bodyPath.cubicTo(halfW * 0.62, halfH * 0.15, halfW * 0.65, -halfH * 0.20, halfW * 0.86, -halfH * 0.35);
      bodyPath.lineTo(halfW * 0.88, -halfH * 0.65);
      bodyPath.cubicTo(halfW * 0.78, -halfH * 0.82, halfW * 0.38, -halfH * 0.96, 0, -halfH * 0.98);
      bodyPath.close();
    } else if (vehicle.bodyStyle == VehicleBodyStyle.titanStealth) {
      // HYPERION PHANTOM: Faceted cyber-stealth wedge archetype
      bodyPath.moveTo(0, -halfH * 0.96);
      bodyPath.lineTo(-halfW * 0.48, -halfH * 0.92); // Faceted stealth nose
      bodyPath.lineTo(-halfW * 0.92, -halfH * 0.62); // Chiseled front fender
      bodyPath.lineTo(-halfW * 0.84, -halfH * 0.15); // Side angular cut
      bodyPath.lineTo(-halfW * 0.96, halfH * 0.25);  // Wide rear quarter panel
      bodyPath.lineTo(-halfW * 0.94, halfH * 0.72);  // Armored rear bumper
      bodyPath.lineTo(-halfW * 0.50, halfH * 0.94);  // Heavy rear valence
      bodyPath.lineTo(0, halfH * 0.92);
      bodyPath.lineTo(halfW * 0.50, halfH * 0.94);
      bodyPath.lineTo(halfW * 0.94, halfH * 0.72);
      bodyPath.lineTo(halfW * 0.96, halfH * 0.25);
      bodyPath.lineTo(halfW * 0.84, -halfH * 0.15);
      bodyPath.lineTo(halfW * 0.92, -halfH * 0.62);
      bodyPath.lineTo(halfW * 0.48, -halfH * 0.92);
      bodyPath.close();
    } else {
      // CYBER ROADSTER: Streamlined aerodynamic hypercar archetype
      bodyPath.moveTo(0, -halfH * 0.97);
      bodyPath.cubicTo(-halfW * 0.45, -halfH * 0.96, -halfW * 0.82, -halfH * 0.80, -halfW * 0.86, -halfH * 0.52);
      bodyPath.cubicTo(-halfW * 0.72, -halfH * 0.10, -halfW * 0.72, halfH * 0.15, -halfW * 0.88, halfH * 0.52);
      bodyPath.cubicTo(-halfW * 0.86, halfH * 0.78, -halfW * 0.64, halfH * 0.92, -halfW * 0.42, halfH * 0.95);
      bodyPath.lineTo(0, halfH * 0.96);
      bodyPath.lineTo(halfW * 0.42, halfH * 0.95);
      bodyPath.cubicTo(halfW * 0.64, halfH * 0.92, halfW * 0.86, halfH * 0.78, halfW * 0.88, halfH * 0.52);
      bodyPath.cubicTo(halfW * 0.72, halfH * 0.15, halfW * 0.72, -halfH * 0.10, halfW * 0.86, -halfH * 0.52);
      bodyPath.cubicTo(halfW * 0.82, -halfH * 0.80, halfW * 0.45, -halfH * 0.96, 0, -halfH * 0.97);
      bodyPath.close();
    }

    // Metallic Finish Paint Shader
    final paintShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: paintColor.gradientColors,
      stops: paintColor.gradientColors.length == 3 ? const [0.0, 0.45, 1.0] : null,
    ).createShader(Rect.fromCenter(center: Offset.zero, width: cw, height: ch));

    final bodyPaint = Paint()
      ..shader = paintShader
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bodyPaint);

    // Specular Highlight Sweep along vehicle centerline
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.35, 0.50, 0.65],
      ).createShader(Rect.fromCenter(center: Offset.zero, width: cw, height: ch))
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, highlightPaint);

    // Subtle edge outline
    final outlinePaint = Paint()
      ..color = paintColor.accentColor.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(bodyPath, outlinePaint);

    // Distinct aero cuts
    _drawAeroFeatures(canvas, cw, ch);
  }

  void _drawAeroFeatures(Canvas canvas, double cw, double ch) {
    final halfH = ch / 2;
    final ductPaint = Paint()
      ..color = const Color(0xFF0D0F14)
      ..style = PaintingStyle.fill;
    final ductAccent = Paint()
      ..color = paintColor.accentColor.withValues(alpha: 0.60)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    if (vehicle.bodyStyle == VehicleBodyStyle.valkyrieAero) {
      // Keel Aerodynamic Flow Ducts on Hood
      final leftKeel = Path()
        ..moveTo(-cw * 0.10, -halfH * 0.42)
        ..lineTo(-cw * 0.22, -halfH * 0.68)
        ..lineTo(-cw * 0.14, -halfH * 0.70)
        ..lineTo(-cw * 0.06, -halfH * 0.44)
        ..close();
      canvas.drawPath(leftKeel, ductPaint);
      canvas.drawPath(leftKeel, ductAccent);

      final rightKeel = Path()
        ..moveTo(cw * 0.10, -halfH * 0.42)
        ..lineTo(cw * 0.22, -halfH * 0.68)
        ..lineTo(cw * 0.14, -halfH * 0.70)
        ..lineTo(cw * 0.06, -halfH * 0.44)
        ..close();
      canvas.drawPath(rightKeel, ductPaint);
      canvas.drawPath(rightKeel, ductAccent);

      // Central Shark Fin Backbone
      final finPaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.85)
        ..strokeWidth = 2.0;
      canvas.drawLine(Offset(0, -halfH * 0.05), Offset(0, halfH * 0.75), finPaint);
    } else if (vehicle.bodyStyle == VehicleBodyStyle.titanStealth) {
      // Armored Cooling Louvers on Rear Deck
      final louverPaint = Paint()
        ..color = const Color(0xFF0C0E13)
        ..strokeWidth = 2.0;
      for (int i = 0; i < 4; i++) {
        final ly = halfH * 0.45 + (i * 7.0);
        canvas.drawLine(Offset(-cw * 0.26, ly), Offset(cw * 0.26, ly), louverPaint);
      }
    } else {
      // Sleek hood extractor vents
      final ventPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(-cw * 0.20, -halfH * 0.55), Offset(-cw * 0.08, -halfH * 0.42), ventPaint);
      canvas.drawLine(Offset(cw * 0.20, -halfH * 0.55), Offset(cw * 0.08, -halfH * 0.42), ventPaint);
    }
  }

  void _drawCockpit(Canvas canvas, double cw, double ch) {
    final halfW = cw / 2;
    final halfH = ch / 2;

    // Teardrop Glass Canopy
    final glassPath = Path()
      ..moveTo(0, -halfH * 0.36)
      ..cubicTo(halfW * 0.58, -halfH * 0.34, halfW * 0.62, 0.0, halfW * 0.54, halfH * 0.40)
      ..lineTo(-halfW * 0.54, halfH * 0.40)
      ..cubicTo(-halfW * 0.62, 0.0, -halfW * 0.58, -halfH * 0.34, 0, -halfH * 0.36)
      ..close();

    final glassPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1E2838),
          Color(0xFF0F1622),
          Color(0xFF080C14),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCenter(center: Offset.zero, width: cw * 0.7, height: ch * 0.5));
    canvas.drawPath(glassPath, glassPaint);

    // Glowing Cyan Digital Dashboard Cluster
    final dashGlow = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.75)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(0, -halfH * 0.10), width: cw * 0.20, height: ch * 0.04),
      dashGlow,
    );

    // Cyber Yoke Steering Wheel
    final yokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.60)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final yokePath = Path()
      ..moveTo(-cw * 0.11, -halfH * 0.16)
      ..lineTo(cw * 0.11, -halfH * 0.16)
      ..moveTo(-cw * 0.11, -halfH * 0.18)
      ..lineTo(-cw * 0.11, -halfH * 0.13)
      ..moveTo(cw * 0.11, -halfH * 0.18)
      ..lineTo(cw * 0.11, -halfH * 0.13);
    canvas.drawPath(yokePath, yokePaint);

    // Sport Bucket Seats
    final seatPaint = Paint()..color = const Color(0xFF121620);
    final seatStitch = Paint()
      ..color = paintColor.accentColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final leftSeat = Rect.fromCenter(center: Offset(-cw * 0.20, halfH * 0.12), width: cw * 0.18, height: ch * 0.12);
    final rightSeat = Rect.fromCenter(center: Offset(cw * 0.20, halfH * 0.12), width: cw * 0.18, height: ch * 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(leftSeat, const Radius.circular(3)), seatPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(leftSeat, const Radius.circular(3)), seatStitch);
    canvas.drawRRect(RRect.fromRectAndRadius(rightSeat, const Radius.circular(3)), seatPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightSeat, const Radius.circular(3)), seatStitch);

    // Specular Windshield Glare Line
    final glarePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(glassPath, glarePaint);
  }

  void _drawLightingAndAero(Canvas canvas, double cw, double ch) {
    final halfW = cw / 2;
    final halfH = ch / 2;

    // 1. LED Laser Headlight Clusters & Light Beams
    final drlPaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final leftDrl = Path()
      ..moveTo(-halfW * 0.35, -halfH * 0.88)
      ..lineTo(-halfW * 0.75, -halfH * 0.70)
      ..lineTo(-halfW * 0.80, -halfH * 0.56);
    canvas.drawPath(leftDrl, drlPaint);

    final rightDrl = Path()
      ..moveTo(halfW * 0.35, -halfH * 0.88)
      ..lineTo(halfW * 0.75, -halfH * 0.70)
      ..lineTo(halfW * 0.80, -halfH * 0.56);
    canvas.drawPath(rightDrl, drlPaint);

    // Quad optical projector dots
    final projectorGlow = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(-halfW * 0.52, -halfH * 0.80), 2.2, projectorGlow);
    canvas.drawCircle(Offset(-halfW * 0.66, -halfH * 0.74), 2.2, projectorGlow);
    canvas.drawCircle(Offset(halfW * 0.52, -halfH * 0.80), 2.2, projectorGlow);
    canvas.drawCircle(Offset(halfW * 0.66, -halfH * 0.74), 2.2, projectorGlow);

    // 2. Full-Width Edge-to-Edge Neon Taillight Blade
    final tailHalo = Paint()
      ..color = const Color(0xFFFF2644).withValues(alpha: 0.85)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final tailCore = Paint()
      ..color = const Color(0xFFFFBAC2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final tailPath = Path()
      ..moveTo(-halfW * 0.78, halfH * 0.86)
      ..lineTo(halfW * 0.78, halfH * 0.86);
    canvas.drawPath(tailPath, tailHalo);
    canvas.drawPath(tailPath, tailCore);

    // 3. Rear Aero Wing according to body style
    if (vehicle.bodyStyle == VehicleBodyStyle.valkyrieAero) {
      // Massive GT3 Swan-Neck Wing with Endplates
      final wingPaint = Paint()..color = const Color(0xFF10141C);
      final wingEdge = Paint()
        ..color = paintColor.accentColor
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;

      final wingRect = Rect.fromCenter(
        center: Offset(0, halfH * 0.85),
        width: cw * 0.98,
        height: ch * 0.05,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(wingRect, const Radius.circular(2)), wingPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(wingRect, const Radius.circular(2)), wingEdge);

      // Swan-neck stanchions
      final carbonStanchion = Paint()..color = const Color(0xFF090B0F);
      canvas.drawRect(Rect.fromLTWH(-halfW * 0.40, halfH * 0.75, 4, ch * 0.12), carbonStanchion);
      canvas.drawRect(Rect.fromLTWH(halfW * 0.40 - 4, halfH * 0.75, 4, ch * 0.12), carbonStanchion);

      // Endplates
      canvas.drawRect(Rect.fromLTWH(-cw * 0.50, halfH * 0.80, 4, ch * 0.10), carbonStanchion);
      canvas.drawRect(Rect.fromLTWH(cw * 0.50 - 4, halfH * 0.80, 4, ch * 0.10), carbonStanchion);
    } else if (vehicle.bodyStyle == VehicleBodyStyle.titanStealth) {
      // Angular Armored Airbrake Wing
      final wingPaint = Paint()..color = const Color(0xFF181C24);
      final wingEdge = Paint()
        ..color = const Color(0xFFFF9E00).withValues(alpha: 0.8)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      final wingPath = Path()
        ..moveTo(-cw * 0.40, halfH * 0.78)
        ..lineTo(cw * 0.40, halfH * 0.78)
        ..lineTo(cw * 0.34, halfH * 0.86)
        ..lineTo(-cw * 0.34, halfH * 0.86)
        ..close();
      canvas.drawPath(wingPath, wingPaint);
      canvas.drawPath(wingPath, wingEdge);
    } else {
      // Roadster low-drag active rear spoiler
      final spoilerPaint = Paint()..color = const Color(0xFF141720);
      final spoilerEdge = Paint()
        ..color = const Color(0xFF00F0FF).withValues(alpha: 0.7)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      final spoilerRect = Rect.fromCenter(
        center: Offset(0, halfH * 0.82),
        width: cw * 0.82,
        height: ch * 0.045,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(spoilerRect, const Radius.circular(2)), spoilerPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(spoilerRect, const Radius.circular(2)), spoilerEdge);
    }
  }

  @override
  bool shouldRepaint(covariant GarageCarPreviewPainter oldDelegate) {
    return oldDelegate.vehicle.id != vehicle.id ||
        oldDelegate.paintColor.id != paintColor.id ||
        oldDelegate.wheelStyle.id != wheelStyle.id ||
        oldDelegate.underglow.id != underglow.id ||
        oldDelegate.turntableAngle != turntableAngle;
  }
}
