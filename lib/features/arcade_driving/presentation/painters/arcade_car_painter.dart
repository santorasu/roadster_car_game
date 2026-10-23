import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/player_car.dart';

/// Renders the enhanced Cyber Roadster electric hypercar with realistic proportions,
/// multi-layered body panels, aerodynamic aero kit, visible wheels and tires,
/// panoramic glass canopy with interior cockpit silhouette, quad-LED projector headlights,
/// razor-thin taillight blade, dynamic underglow, and active aerodynamic thrusters.
class ArcadeCarPainter extends CustomPainter {
  final PlayerCar player;
  final double curveOffset;

  ArcadeCarPainter({
    required this.player,
    this.curveOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Use curved bounding rectangle for exact physics alignment
    final rect = player.getBoundingRect(w, h, curveOffset);
    final carWidth = rect.width / 0.85;
    final carHeight = rect.height / 0.85;

    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);

    // Dynamic car tilt / roll during steering and banking into road curve
    final curveBank = -curveOffset * 0.04;
    canvas.rotate(player.rollAngle + curveBank);

    // 1. Perspective Headlight Light Cones onto Asphalt
    _drawHeadlightBeams(canvas, carWidth, carHeight);

    // 2. High-Speed Thruster Plume & Plasma Exhaust (Accelerating > 95 MPH)
    if (player.isAccelerating && player.speedMph > 95.0) {
      _drawThrusterPlume(canvas, carWidth, carHeight);
    }

    // 3. Ground Underglow & Soft Contact Shadow
    _drawGroundShadowAndUnderglow(canvas, carWidth, carHeight);

    // 4. Visible Performance Tires and Alloy Rims
    _drawWheelsAndTires(canvas, carWidth, carHeight);

    // 5. Carbon Fiber Aero Splitter, Side Skirts, and Rear Diffuser
    _drawAeroGroundEffects(canvas, carWidth, carHeight);

    // 6. Sculpted Muscular Hypercar Body Shell & Panels
    _drawHypercarBody(canvas, carWidth, carHeight);

    // 7. Panoramic Tinted Canopy & Cockpit Interior Silhouette
    _drawCockpitAndInterior(canvas, carWidth, carHeight);

    // 8. Quad Projector Laser Headlights & Full-Width Taillight Blade
    _drawLightingAssemblies(canvas, carWidth, carHeight);

    // 9. Active Rear Spoiler Winglets (Deployed at > 120 MPH or when Braking)
    _drawActiveAeroSpoiler(canvas, carWidth, carHeight);

    // 10. Post-Collision Recovery Energy Shield Aura
    if (player.collisionRecoveryTimer > 0.0) {
      _drawRecoveryShieldAura(canvas, carWidth, carHeight);
    }

    canvas.restore();
  }

  void _drawHeadlightBeams(Canvas canvas, double cw, double ch) {
    final beamLength = ch * 2.4;
    final speedFactor = (player.speedMph / 250.0).clamp(0.0, 1.0);
    final beamSpread = cw * (0.9 + 0.3 * speedFactor);

    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF00F0FF).withValues(alpha: 0.38),
          const Color(0xFF00B4D8).withValues(alpha: 0.16),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(-beamSpread, -beamLength, beamSpread * 2, beamLength))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // Left beam
    final leftPath = Path()
      ..moveTo(-cw * 0.34, -ch * 0.44)
      ..lineTo(-beamSpread, -beamLength)
      ..lineTo(-cw * 0.08, -beamLength)
      ..close();
    canvas.drawPath(leftPath, beamPaint);

    // Right beam
    final rightPath = Path()
      ..moveTo(cw * 0.34, -ch * 0.44)
      ..lineTo(cw * 0.08, -beamLength)
      ..lineTo(beamSpread, -beamLength)
      ..close();
    canvas.drawPath(rightPath, beamPaint);

    // Focal hot spots in front of the car
    final hotSpotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-cw * 0.34, -ch * 0.8), width: cw * 0.35, height: ch * 0.4),
      hotSpotPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cw * 0.34, -ch * 0.8), width: cw * 0.35, height: ch * 0.4),
      hotSpotPaint,
    );
  }

  void _drawThrusterPlume(Canvas canvas, double cw, double ch) {
    final speedNorm = (player.speedMph / 250.0).clamp(0.0, 1.0);
    final plumeLength = (ch * 0.65) * speedNorm;

    // Twin plasma exhaust jets flanking center diffuser
    final plumeOffsets = [-cw * 0.24, cw * 0.24];

    for (final xOffset in plumeOffsets) {
      final plumePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            const Color(0xFF00E5FF),
            const Color(0xFF0051FF).withValues(alpha: 0.75),
            Colors.transparent,
          ],
          stops: const [0.0, 0.25, 0.7, 1.0],
        ).createShader(Rect.fromLTWH(xOffset - cw * 0.12, ch * 0.48, cw * 0.24, plumeLength))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final plumePath = Path()
        ..moveTo(xOffset - cw * 0.09, ch * 0.48)
        ..lineTo(xOffset, ch * 0.48 + plumeLength)
        ..lineTo(xOffset + cw * 0.09, ch * 0.48)
        ..close();
      canvas.drawPath(plumePath, plumePaint);

      // Core white-hot shock diamond
      final diamondPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      final diamondPath = Path()
        ..moveTo(xOffset, ch * 0.49)
        ..lineTo(xOffset + cw * 0.04, ch * 0.49 + plumeLength * 0.25)
        ..lineTo(xOffset, ch * 0.49 + plumeLength * 0.5)
        ..lineTo(xOffset - cw * 0.04, ch * 0.49 + plumeLength * 0.25)
        ..close();
      canvas.drawPath(diamondPath, diamondPaint);
    }
  }

  void _drawGroundShadowAndUnderglow(Canvas canvas, double cw, double ch) {
    // 1. Soft Ambient Contact Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.68)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: const Offset(0, 6),
          width: cw * 1.12,
          height: ch * 1.04,
        ),
        const Radius.circular(12),
      ),
      shadowPaint,
    );

    // 2. High-Tech Cyan / Red Underglow Ground Effect
    final speedRatio = (player.speedMph / 250.0).clamp(0.0, 1.0);
    final underglowColor = player.isBraking
        ? const Color(0xFFFF1744)
        : (player.isAccelerating ? const Color(0xFF00F0FF) : const Color(0xFF0099FF));
    final underglowAlpha = 0.25 + 0.35 * speedRatio;

    final underglowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.75,
        colors: [
          underglowColor.withValues(alpha: underglowAlpha),
          underglowColor.withValues(alpha: underglowAlpha * 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(center: Offset(0, ch * 0.05), width: cw * 1.4, height: ch * 1.2))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, ch * 0.05), width: cw * 1.25, height: ch * 1.1),
      underglowPaint,
    );
  }

  void _drawWheelsAndTires(Canvas canvas, double cw, double ch) {
    final halfW = cw / 2;
    final halfH = ch / 2;

    final wheelW = cw * 0.16;
    final wheelH = ch * 0.21;

    // 4 wheel positions (Front-Left, Front-Right, Rear-Left, Rear-Right)
    final wheelPositions = [
      Offset(-halfW * 0.94, -halfH * 0.42), // Front-Left
      Offset(halfW * 0.94, -halfH * 0.42),  // Front-Right
      Offset(-halfW * 0.94, halfH * 0.48),  // Rear-Left
      Offset(halfW * 0.94, halfH * 0.48),   // Rear-Right
    ];

    final tirePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF141416), Color(0xFF28282E), Color(0xFF121214)],
      ).createShader(Rect.fromLTWH(-wheelW, -wheelH, wheelW * 2, wheelH * 2));

    final rimPaint = Paint()..color = const Color(0xFF555D6A);
    final rimHighlightPaint = Paint()
      ..color = const Color(0xFF8E99A8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final caliperPaint = Paint()..color = const Color(0xFFFF1E38);

    for (int i = 0; i < wheelPositions.length; i++) {
      final pos = wheelPositions[i];
      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      // Subtle front wheel turning angle responsive to steering input
      if (i < 2) {
        canvas.rotate(player.steerInput * 0.18);
      }

      // Tire body
      final tireRect = Rect.fromCenter(center: Offset.zero, width: wheelW, height: wheelH);
      canvas.drawRRect(RRect.fromRectAndRadius(tireRect, const Radius.circular(3)), tirePaint);

      // Tire tread lines
      final treadPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(-wheelW * 0.35, -wheelH * 0.3), Offset(wheelW * 0.35, -wheelH * 0.3), treadPaint);
      canvas.drawLine(Offset(-wheelW * 0.35, 0), Offset(wheelW * 0.35, 0), treadPaint);
      canvas.drawLine(Offset(-wheelW * 0.35, wheelH * 0.3), Offset(wheelW * 0.35, wheelH * 0.3), treadPaint);

      // Brake Caliper visible through spokes
      final isLeftSide = pos.dx < 0;
      final caliperRect = Rect.fromCenter(
        center: Offset(isLeftSide ? wheelW * 0.15 : -wheelW * 0.15, -wheelH * 0.1),
        width: wheelW * 0.35,
        height: wheelH * 0.32,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(caliperRect, const Radius.circular(1.5)), caliperPaint);

      // Alloy Turbine Rim Disc
      final rimRect = Rect.fromCenter(center: Offset.zero, width: wheelW * 0.7, height: wheelH * 0.75);
      canvas.drawRRect(RRect.fromRectAndRadius(rimRect, const Radius.circular(2)), rimPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rimRect, const Radius.circular(2)), rimHighlightPaint);

      canvas.restore();
    }
  }

  void _drawAeroGroundEffects(Canvas canvas, double cw, double ch) {
    final halfW = cw / 2;
    final halfH = ch / 2;

    final aeroCarbonPaint = Paint()
      ..color = const Color(0xFF16181D)
      ..style = PaintingStyle.fill;

    final aeroEdgePaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.45)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 1. Front Aero Splitter Lip
    final splitterPath = Path()
      ..moveTo(-halfW * 0.82, -halfH * 0.88)
      ..lineTo(0, -halfH * 1.03)
      ..lineTo(halfW * 0.82, -halfH * 0.88)
      ..lineTo(halfW * 0.74, -halfH * 0.82)
      ..lineTo(0, -halfH * 0.96)
      ..lineTo(-halfW * 0.74, -halfH * 0.82)
      ..close();
    canvas.drawPath(splitterPath, aeroCarbonPaint);
    canvas.drawPath(splitterPath, aeroEdgePaint);

    // 2. Side Skirts
    final leftSkirt = Rect.fromLTWH(-halfW * 0.94, -halfH * 0.25, halfW * 0.18, halfH * 0.65);
    final rightSkirt = Rect.fromLTWH(halfW * 0.76, -halfH * 0.25, halfW * 0.18, halfH * 0.65);
    canvas.drawRect(leftSkirt, aeroCarbonPaint);
    canvas.drawRect(rightSkirt, aeroCarbonPaint);

    // 3. Rear Quad-Fin Diffuser
    final diffuserPath = Path()
      ..moveTo(-halfW * 0.76, halfH * 0.92)
      ..lineTo(halfW * 0.76, halfH * 0.92)
      ..lineTo(halfW * 0.70, halfH * 1.02)
      ..lineTo(-halfW * 0.70, halfH * 1.02)
      ..close();
    canvas.drawPath(diffuserPath, aeroCarbonPaint);

    // Diffuser vertical aero fins
    final finPaint = Paint()
      ..color = const Color(0xFF2A2E38)
      ..strokeWidth = 1.5;
    for (int i = -3; i <= 3; i += 2) {
      final finX = halfW * (i / 4.0);
      canvas.drawLine(Offset(finX, halfH * 0.92), Offset(finX, halfH * 1.02), finPaint);
    }
  }

  void _drawHypercarBody(Canvas canvas, double cw, double ch) {
    final halfW = cw / 2;
    final halfH = ch / 2;

    // Muscular Roadster Body Silhouette with flared fenders and coke-bottle waist
    final bodyPath = Path()
      // Nose cone apex
      ..moveTo(0, -halfH * 0.98)
      // Front right nose curve into right fender
      ..cubicTo(halfW * 0.45, -halfH * 0.98, halfW * 0.82, -halfH * 0.78, halfW * 0.88, -halfH * 0.45)
      // Front wheel arch flare
      ..cubicTo(halfW * 0.92, -halfH * 0.35, halfW * 0.94, -halfH * 0.22, halfW * 0.86, -halfH * 0.12)
      // Waist tuck (sculpted door air intake)
      ..cubicTo(halfW * 0.74, 0.0, halfW * 0.74, halfH * 0.15, halfW * 0.88, halfH * 0.28)
      // Wide rear muscular haunch
      ..cubicTo(halfW * 0.98, halfH * 0.45, halfW * 0.94, halfH * 0.78, halfW * 0.76, halfH * 0.94)
      // Rear bumper & tail deck
      ..lineTo(-halfW * 0.76, halfH * 0.94)
      // Left rear muscular haunch
      ..cubicTo(-halfW * 0.94, halfH * 0.78, -halfW * 0.98, halfH * 0.45, -halfW * 0.88, halfH * 0.28)
      // Left waist tuck
      ..cubicTo(-halfW * 0.74, halfH * 0.15, -halfW * 0.74, 0.0, -halfW * 0.86, -halfH * 0.12)
      // Left front wheel arch flare
      ..cubicTo(-halfW * 0.94, -halfH * 0.22, -halfW * 0.92, -halfH * 0.35, -halfW * 0.88, -halfH * 0.45)
      // Back to nose cone
      ..cubicTo(-halfW * 0.82, -halfH * 0.78, -halfW * 0.45, -halfH * 0.98, 0, -halfH * 0.98)
      ..close();

    // Multi-Tone Metallic Crimson Paint Shader
    final bodyShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFF3E55), // Front hood specular peak
        Color(0xFFE51D33), // Rich cyber crimson
        Color(0xFFBD0F22), // Mid-body saturated red
        Color(0xFF880816), // Deep door tuck shadow
        Color(0xFF5A000C), // Rear deck undertone
      ],
      stops: [0.0, 0.22, 0.52, 0.82, 1.0],
    ).createShader(Rect.fromCenter(center: Offset.zero, width: cw, height: ch));

    final bodyPaint = Paint()..shader = bodyShader;
    canvas.drawPath(bodyPath, bodyPaint);

    // Specular body outline
    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(bodyPath, outlinePaint);

    // Hood Aerodynamic Cooling Ducts & Feature Lines
    final ductDarkPaint = Paint()
      ..color = const Color(0xFF2B0307)
      ..style = PaintingStyle.fill;
    final ductAccentPaint = Paint()
      ..color = const Color(0xFFFF6677).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Left hood duct
    final leftDuct = Path()
      ..moveTo(-cw * 0.22, -halfH * 0.68)
      ..lineTo(-cw * 0.08, -halfH * 0.38)
      ..lineTo(-cw * 0.16, -halfH * 0.36)
      ..lineTo(-cw * 0.26, -halfH * 0.65)
      ..close();
    canvas.drawPath(leftDuct, ductDarkPaint);
    canvas.drawPath(leftDuct, ductAccentPaint);

    // Right hood duct
    final rightDuct = Path()
      ..moveTo(cw * 0.22, -halfH * 0.68)
      ..lineTo(cw * 0.08, -halfH * 0.38)
      ..lineTo(cw * 0.16, -halfH * 0.36)
      ..lineTo(cw * 0.26, -halfH * 0.65)
      ..close();
    canvas.drawPath(rightDuct, ductDarkPaint);
    canvas.drawPath(rightDuct, ductAccentPaint);

    // Side Door Shutlines & Air Intake Ducts
    final seamPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-halfW * 0.84, -halfH * 0.15), Offset(-halfW * 0.72, halfH * 0.25), seamPaint);
    canvas.drawLine(Offset(halfW * 0.84, -halfH * 0.15), Offset(halfW * 0.72, halfH * 0.25), seamPaint);

    // Rear motor deck heat extractors
    final ventPaint = Paint()
      ..color = const Color(0xFF1E0205)
      ..strokeWidth = 1.2;
    for (int i = 0; i < 3; i++) {
      final y = halfH * 0.70 + (i * 4.5);
      canvas.drawLine(Offset(-cw * 0.25, y), Offset(cw * 0.25, y), ventPaint);
    }
  }

  void _drawCockpitAndInterior(Canvas canvas, double cw, double ch) {
    final halfW = cw / 2;
    final halfH = ch / 2;

    // Panoramic Teardrop Canopy Path
    final canopyPath = Path()
      ..moveTo(0, -halfH * 0.34)
      ..cubicTo(halfW * 0.55, -halfH * 0.34, halfW * 0.62, 0.0, halfW * 0.54, halfH * 0.42)
      ..lineTo(-halfW * 0.54, halfH * 0.42)
      ..cubicTo(-halfW * 0.62, 0.0, -halfW * 0.55, -halfH * 0.34, 0, -halfH * 0.34)
      ..close();

    // Dark Solar-Tint Glass Shader
    final glassPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1E2A3A),
          Color(0xFF0F1722),
          Color(0xFF070B12),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCenter(center: Offset.zero, width: cw * 0.7, height: ch * 0.5));
    canvas.drawPath(canopyPath, glassPaint);

    // Cockpit Interior Elements (Visible through tinted glass)
    // 1. Digital Instrument Cluster / Center Console Glow
    final clusterPaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(0, -halfH * 0.08), width: cw * 0.16, height: ch * 0.035),
      clusterPaint,
    );

    // 2. Minimalist Cyber Yoke Steering Wheel Silhouette
    final yokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final yokePath = Path()
      ..moveTo(-cw * 0.09, -halfH * 0.14)
      ..lineTo(cw * 0.09, -halfH * 0.14)
      ..moveTo(-cw * 0.09, -halfH * 0.16)
      ..lineTo(-cw * 0.09, -halfH * 0.11)
      ..moveTo(cw * 0.09, -halfH * 0.16)
      ..lineTo(cw * 0.09, -halfH * 0.11);
    canvas.drawPath(yokePath, yokePaint);

    // 3. Driver & Passenger Headrest Silhouettes
    final seatPaint = Paint()..color = const Color(0xFF10141D);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(-cw * 0.18, halfH * 0.14), width: cw * 0.16, height: ch * 0.10),
        const Radius.circular(3),
      ),
      seatPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cw * 0.18, halfH * 0.14), width: cw * 0.16, height: ch * 0.10),
        const Radius.circular(3),
      ),
      seatPaint,
    );

    // Glass Canopy Glare & Specular Reflection Lines
    final glarePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(canopyPath, glarePaint);

    // Angled Sky Glare Reflection Sweep
    final reflectionSweep = Path()
      ..moveTo(-halfW * 0.38, -halfH * 0.26)
      ..lineTo(-halfW * 0.05, halfH * 0.25);
    final sweepPaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    canvas.drawPath(reflectionSweep, sweepPaint);
  }

  void _drawLightingAssemblies(Canvas canvas, double cw, double ch) {
    final halfW = cw / 2;
    final halfH = ch / 2;

    // 1. Quad-Projector LED Laser Headlights + Cyan DRL Ribbons
    final drlPaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    final drlCorePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Left DRL ribbon
    final leftDrl = Path()
      ..moveTo(-halfW * 0.35, -halfH * 0.90)
      ..lineTo(-halfW * 0.76, -halfH * 0.72)
      ..lineTo(-halfW * 0.82, -halfH * 0.58);
    canvas.drawPath(leftDrl, drlPaint);
    canvas.drawPath(leftDrl, drlCorePaint);

    // Right DRL ribbon
    final rightDrl = Path()
      ..moveTo(halfW * 0.35, -halfH * 0.90)
      ..lineTo(halfW * 0.76, -halfH * 0.72)
      ..lineTo(halfW * 0.82, -halfH * 0.58);
    canvas.drawPath(rightDrl, drlPaint);
    canvas.drawPath(rightDrl, drlCorePaint);

    // Quad optical projector dots
    final projectorPaint = Paint()..color = Colors.white;
    final projectorGlow = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.75)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final projectorCoords = [
      Offset(-halfW * 0.50, -halfH * 0.82),
      Offset(-halfW * 0.64, -halfH * 0.76),
      Offset(halfW * 0.50, -halfH * 0.82),
      Offset(halfW * 0.64, -halfH * 0.76),
    ];
    for (final pt in projectorCoords) {
      canvas.drawCircle(pt, 2.5, projectorGlow);
      canvas.drawCircle(pt, 1.2, projectorPaint);
    }

    // 2. Full-Width Edge-To-Edge Neon Taillight Blade
    final isBraking = player.isBraking;
    final tailColor = isBraking ? const Color(0xFFFF0033) : const Color(0xFFFF2644);
    final tailHaloAlpha = isBraking ? 0.95 : 0.65;
    final tailGlowRadius = isBraking ? 9.0 : 4.0;

    final tailHaloPaint = Paint()
      ..color = tailColor.withValues(alpha: tailHaloAlpha)
      ..strokeWidth = isBraking ? 7.0 : 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, tailGlowRadius);

    final tailPath = Path()
      ..moveTo(-halfW * 0.74, halfH * 0.88)
      ..lineTo(halfW * 0.74, halfH * 0.88);
    canvas.drawPath(tailPath, tailHaloPaint);

    // Sharp white-hot tail light core
    final tailCorePaint = Paint()
      ..color = isBraking ? Colors.white : const Color(0xFFFFB3BC)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(tailPath, tailCorePaint);

    // Center High-Mount Stop Light (CHMSL) above rear deck
    final chmslPaint = Paint()
      ..color = isBraking ? Colors.white : const Color(0xFFFF2644).withValues(alpha: 0.7)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-cw * 0.14, halfH * 0.44), Offset(cw * 0.14, halfH * 0.44), chmslPaint);
  }

  void _drawActiveAeroSpoiler(Canvas canvas, double cw, double ch) {
    // Active aero spoiler deploys at high speed (> 120 MPH) or as airbrake when braking
    final isDeployed = (player.speedMph > 120.0) || player.isBraking;
    if (!isDeployed) return;

    final halfW = cw / 2;
    final halfH = ch / 2;

    final spoilerPaint = Paint()
      ..color = const Color(0xFF14161C)
      ..style = PaintingStyle.fill;
    final spoilerEdge = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final spoilerRect = Rect.fromCenter(
      center: Offset(0, halfH * 0.82),
      width: cw * 0.82,
      height: ch * 0.045,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(spoilerRect, const Radius.circular(2)), spoilerPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(spoilerRect, const Radius.circular(2)), spoilerEdge);

    // Dual carbon stanchions
    final stanchionPaint = Paint()..color = const Color(0xFF0B0D12);
    canvas.drawRect(Rect.fromLTWH(-halfW * 0.45, halfH * 0.82, 3, ch * 0.06), stanchionPaint);
    canvas.drawRect(Rect.fromLTWH(halfW * 0.45 - 3, halfH * 0.82, 3, ch * 0.06), stanchionPaint);
  }

  void _drawRecoveryShieldAura(Canvas canvas, double cw, double ch) {
    final timer = player.collisionRecoveryTimer;
    final pulse = (math.sin(timer * 18.0) + 1.0) / 2.0;
    final outerAlpha = (0.30 + 0.40 * pulse).clamp(0.0, 1.0);
    final innerAlpha = (0.50 + 0.35 * (1.0 - pulse)).clamp(0.0, 1.0);

    // Concentric glowing barrier rings
    final outerPaint = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: outerAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: innerAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final radiusX = cw * (0.85 + 0.08 * pulse);
    final radiusY = ch * (0.64 + 0.05 * pulse);

    final shieldRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: radiusX * 2, height: radiusY * 2),
      Radius.circular(radiusX * 0.45),
    );

    canvas.drawRRect(shieldRRect, outerPaint);
    canvas.drawRRect(shieldRRect, innerPaint);

    // Energy node ticks along shield boundary
    final nodePaint = Paint()..color = const Color(0xFF00F0FF);
    final tickAngles = [0.0, math.pi / 2, math.pi, 3 * math.pi / 2];
    for (final angle in tickAngles) {
      final nodeX = radiusX * math.cos(angle + timer * 4.0);
      final nodeY = radiusY * math.sin(angle + timer * 4.0);
      canvas.drawCircle(Offset(nodeX, nodeY), 3.0, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ArcadeCarPainter oldDelegate) {
    return oldDelegate.curveOffset != curveOffset ||
        oldDelegate.player.lanePosition != player.lanePosition ||
        oldDelegate.player.speedMph != player.speedMph ||
        oldDelegate.player.rollAngle != player.rollAngle ||
        oldDelegate.player.isAccelerating != player.isAccelerating ||
        oldDelegate.player.isBraking != player.isBraking ||
        oldDelegate.player.collisionRecoveryTimer != player.collisionRecoveryTimer ||
        oldDelegate.player.isAtRoadBoundary != player.isAtRoadBoundary;
  }
}
