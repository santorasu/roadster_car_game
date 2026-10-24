import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/player_car.dart';
import '../../../garage/domain/models/vehicle_definition.dart';

/// Renders the enhanced Cyber Roadster electric hypercar with realistic proportions,
/// multi-layered body panels, aerodynamic aero kit, visible wheels and tires,
/// panoramic glass canopy with interior cockpit silhouette, quad-LED projector headlights,
/// razor-thin taillight blade, dynamic underglow, and active aerodynamic thrusters.
class ArcadeCarPainter extends CustomPainter {
  final PlayerCar player;
  final double curveOffset;
  final double elevationOffset;

  ArcadeCarPainter({
    required this.player,
    this.curveOffset = 0.0,
    this.elevationOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Use curved and elevated bounding rectangle for exact physics alignment
    final rect = player.getBoundingRect(w, h, curveOffset, elevationOffset);
    final carWidth = rect.width / 0.85;
    final carHeight = rect.height / 0.85;

    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);

    // Subtle perspective pitch scaling (compress slightly uphill, expand slightly downhill)
    final pitchScaleY = (1.0 - elevationOffset * 0.05).clamp(0.92, 1.08);
    canvas.scale(1.0, pitchScaleY);

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

    // 2. High-Tech Neon Underglow Ground Effect (Customizable)
    final underglowOpt = player.customization.underglowOption;
    if (underglowOpt.color != Colors.transparent) {
      final speedRatio = (player.speedMph / player.vehicle.topSpeedMph).clamp(0.0, 1.0);
      final underglowColor = player.isBraking
          ? const Color(0xFFFF1744)
          : underglowOpt.color;
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

    final wheelCustom = player.customization.wheelStyle;
    final rimPaint = Paint()..color = wheelCustom.rimColor;
    final rimHighlightPaint = Paint()
      ..color = wheelCustom.highlightColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final caliperPaint = Paint()..color = wheelCustom.caliperColor;

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

      // Alloy Rim Disc & Spoke Design based on WheelRimType
      final rimRect = Rect.fromCenter(center: Offset.zero, width: wheelW * 0.7, height: wheelH * 0.75);
      canvas.drawRRect(RRect.fromRectAndRadius(rimRect, const Radius.circular(2)), rimPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rimRect, const Radius.circular(2)), rimHighlightPaint);

      switch (wheelCustom.type) {
        case WheelRimType.turbine:
          final bladePaint = Paint()
            ..color = wheelCustom.highlightColor.withValues(alpha: 0.6)
            ..strokeWidth = 1.0;
          canvas.drawLine(Offset(-wheelW * 0.25, -wheelH * 0.25), Offset(wheelW * 0.25, wheelH * 0.25), bladePaint);
          canvas.drawLine(Offset(wheelW * 0.25, -wheelH * 0.25), Offset(-wheelW * 0.25, wheelH * 0.25), bladePaint);
          break;
        case WheelRimType.cyberDisc:
          final discGlow = Paint()
            ..color = wheelCustom.highlightColor.withValues(alpha: 0.7)
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke;
          canvas.drawCircle(Offset.zero, wheelW * 0.22, discGlow);
          break;
        case WheelRimType.starfireSplit:
          final spokePaint = Paint()
            ..color = wheelCustom.highlightColor.withValues(alpha: 0.8)
            ..strokeWidth = 1.2;
          for (int s = 0; s < 5; s++) {
            final a = s * (math.pi * 2 / 5);
            canvas.drawLine(Offset.zero, Offset(math.cos(a) * wheelW * 0.3, math.sin(a) * wheelH * 0.3), spokePaint);
          }
          break;
        case WheelRimType.carbonLattice:
          final latticePaint = Paint()
            ..color = wheelCustom.highlightColor.withValues(alpha: 0.5)
            ..strokeWidth = 0.8;
          canvas.drawLine(Offset(-wheelW * 0.25, 0), Offset(wheelW * 0.25, 0), latticePaint);
          canvas.drawLine(Offset(0, -wheelH * 0.25), Offset(0, wheelH * 0.25), latticePaint);
          canvas.drawCircle(Offset.zero, wheelW * 0.15, rimHighlightPaint);
          break;
      }

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
    final bodyStyle = player.customization.vehicle.bodyStyle;

    final bodyPath = Path();
    if (bodyStyle == VehicleBodyStyle.valkyrieAero) {
      // Aerodynamic Le Mans Circuit Prototype Silhouette
      bodyPath
        ..moveTo(0, -halfH * 1.04) // Low tapered aerodynamic nose
        ..lineTo(halfW * 0.35, -halfH * 0.98)
        ..cubicTo(halfW * 0.55, -halfH * 0.95, halfW * 0.85, -halfH * 0.75, halfW * 0.92, -halfH * 0.42)
        ..lineTo(halfW * 0.88, -halfH * 0.12)
        ..cubicTo(halfW * 0.65, 0.0, halfW * 0.65, halfH * 0.18, halfW * 0.90, halfH * 0.35)
        ..cubicTo(halfW * 0.98, halfH * 0.50, halfW * 0.92, halfH * 0.85, halfW * 0.82, halfH * 0.96)
        ..lineTo(-halfW * 0.82, halfH * 0.96)
        ..cubicTo(-halfW * 0.92, halfH * 0.85, -halfW * 0.98, halfH * 0.50, -halfW * 0.90, halfH * 0.35)
        ..cubicTo(-halfW * 0.65, halfH * 0.18, -halfW * 0.65, 0.0, -halfW * 0.88, -halfH * 0.12)
        ..lineTo(-halfW * 0.92, -halfH * 0.42)
        ..cubicTo(-halfW * 0.85, -halfH * 0.75, -halfW * 0.55, -halfH * 0.95, -halfW * 0.35, -halfH * 0.98)
        ..close();
    } else if (bodyStyle == VehicleBodyStyle.titanStealth) {
      // Angular Chiseled Armored Stealth Interceptor Silhouette
      bodyPath
        ..moveTo(0, -halfH * 1.02)
        ..lineTo(halfW * 0.42, -halfH * 0.94)
        ..lineTo(halfW * 0.84, -halfH * 0.72)
        ..lineTo(halfW * 0.94, -halfH * 0.38)
        ..lineTo(halfW * 0.86, -halfH * 0.08)
        ..lineTo(halfW * 0.84, halfH * 0.22)
        ..lineTo(halfW * 0.96, halfH * 0.44)
        ..lineTo(halfW * 0.90, halfH * 0.88)
        ..lineTo(halfW * 0.68, halfH * 0.96)
        ..lineTo(-halfW * 0.68, halfH * 0.96)
        ..lineTo(-halfW * 0.90, halfH * 0.88)
        ..lineTo(-halfW * 0.96, halfH * 0.44)
        ..lineTo(-halfW * 0.84, halfH * 0.22)
        ..lineTo(-halfW * 0.86, -halfH * 0.08)
        ..lineTo(-halfW * 0.94, -halfH * 0.38)
        ..lineTo(-halfW * 0.84, -halfH * 0.72)
        ..lineTo(-halfW * 0.42, -halfH * 0.94)
        ..close();
    } else {
      // Iconic Sculpted Roadster with flared fenders and coke-bottle waist
      bodyPath
        ..moveTo(0, -halfH * 0.98)
        ..cubicTo(halfW * 0.45, -halfH * 0.98, halfW * 0.82, -halfH * 0.78, halfW * 0.88, -halfH * 0.45)
        ..cubicTo(halfW * 0.92, -halfH * 0.35, halfW * 0.94, -halfH * 0.22, halfW * 0.86, -halfH * 0.12)
        ..cubicTo(halfW * 0.74, 0.0, halfW * 0.74, halfH * 0.15, halfW * 0.88, halfH * 0.28)
        ..cubicTo(halfW * 0.98, halfH * 0.45, halfW * 0.94, halfH * 0.78, halfW * 0.76, halfH * 0.94)
        ..lineTo(-halfW * 0.76, halfH * 0.94)
        ..cubicTo(-halfW * 0.94, halfH * 0.78, -halfW * 0.98, halfH * 0.45, -halfW * 0.88, halfH * 0.28)
        ..cubicTo(-halfW * 0.74, halfH * 0.15, -halfW * 0.74, 0.0, -halfW * 0.86, -halfH * 0.12)
        ..cubicTo(-halfW * 0.94, -halfH * 0.22, -halfW * 0.92, -halfH * 0.35, -halfW * 0.88, -halfH * 0.45)
        ..cubicTo(-halfW * 0.82, -halfH * 0.78, -halfW * 0.45, -halfH * 0.98, 0, -halfH * 0.98)
        ..close();
    }

    // Dynamic Multi-Tone Metallic Paint Shader from active customization
    final bodyColors = player.customization.paintColor.gradientColors;
    final bodyShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: bodyColors,
      stops: const [0.0, 0.22, 0.52, 0.82, 1.0],
    ).createShader(Rect.fromCenter(center: Offset.zero, width: cw, height: ch));

    final bodyPaint = Paint()..shader = bodyShader;
    canvas.drawPath(bodyPath, bodyPaint);

    // Specular body outline
    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(bodyPath, outlinePaint);

    // Body styling accents based on archetype
    if (bodyStyle == VehicleBodyStyle.valkyrieAero) {
      // 1. Central Carbon Shark-Fin Dorsal Spine
      final finBasePaint = Paint()
        ..color = const Color(0xFF0F1722)
        ..strokeWidth = 3.5;
      final finHighlight = Paint()
        ..color = player.customization.paintColor.primaryColor.withValues(alpha: 0.85)
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(0, -halfH * 0.18), Offset(0, halfH * 0.78), finBasePaint);
      canvas.drawLine(Offset(0, -halfH * 0.18), Offset(0, halfH * 0.78), finHighlight);

      // 2. High-Downforce Front Aero Keel Ducts
      final keelPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      final leftKeel = Path()
        ..moveTo(-cw * 0.28, -halfH * 0.72)
        ..lineTo(-cw * 0.12, -halfH * 0.45)
        ..lineTo(-cw * 0.20, -halfH * 0.42)
        ..close();
      final rightKeel = Path()
        ..moveTo(cw * 0.28, -halfH * 0.72)
        ..lineTo(cw * 0.12, -halfH * 0.45)
        ..lineTo(cw * 0.20, -halfH * 0.42)
        ..close();
      canvas.drawPath(leftKeel, keelPaint);
      canvas.drawPath(rightKeel, keelPaint);
    } else if (bodyStyle == VehicleBodyStyle.titanStealth) {
      // Heavy Armored Rear Deck Louvers
      final louverPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.65)
        ..strokeWidth = 2.2;
      final louverHighlight = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..strokeWidth = 0.8;
      for (int i = 0; i < 4; i++) {
        final y = halfH * 0.58 + (i * 6.0);
        final louverW = cw * (0.28 - i * 0.03);
        canvas.drawLine(Offset(-louverW, y), Offset(louverW, y), louverPaint);
        canvas.drawLine(Offset(-louverW, y + 1), Offset(louverW, y + 1), louverHighlight);
      }
    } else {
      // Classic Roadster Aerodynamic Cooling Ducts
      final ductDarkPaint = Paint()
        ..color = const Color(0xFF2B0307)
        ..style = PaintingStyle.fill;
      final ductAccentPaint = Paint()
        ..color = player.customization.paintColor.primaryColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final leftDuct = Path()
        ..moveTo(-cw * 0.22, -halfH * 0.68)
        ..lineTo(-cw * 0.08, -halfH * 0.38)
        ..lineTo(-cw * 0.16, -halfH * 0.36)
        ..lineTo(-cw * 0.26, -halfH * 0.65)
        ..close();
      canvas.drawPath(leftDuct, ductDarkPaint);
      canvas.drawPath(leftDuct, ductAccentPaint);

      final rightDuct = Path()
        ..moveTo(cw * 0.22, -halfH * 0.68)
        ..lineTo(cw * 0.08, -halfH * 0.38)
        ..lineTo(cw * 0.16, -halfH * 0.36)
        ..lineTo(cw * 0.26, -halfH * 0.65)
        ..close();
      canvas.drawPath(rightDuct, ductDarkPaint);
      canvas.drawPath(rightDuct, ductAccentPaint);
    }

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
    final bodyStyle = player.vehicle.bodyStyle;

    if (bodyStyle == VehicleBodyStyle.valkyrieAero) {
      // Wide GT3 swan-neck carbon wing with aerodynamic endplates
      final wingPaint = Paint()..color = const Color(0xFF10141A);
      final wingAccent = Paint()
        ..color = player.customization.paintColor.accentColor
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      final wingRect = Rect.fromCenter(
        center: Offset(0, halfH * 0.84),
        width: cw * 0.96,
        height: ch * 0.05,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(wingRect, const Radius.circular(2)), wingPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(wingRect, const Radius.circular(2)), wingAccent);

      // Swan-neck stanchions & endplates
      final carbonPaint = Paint()..color = const Color(0xFF090B0E);
      canvas.drawRect(Rect.fromLTWH(-cw * 0.49, halfH * 0.78, 4, ch * 0.11), carbonPaint);
      canvas.drawRect(Rect.fromLTWH(cw * 0.49 - 4, halfH * 0.78, 4, ch * 0.11), carbonPaint);
      canvas.drawRect(Rect.fromLTWH(-halfW * 0.35, halfH * 0.76, 3, ch * 0.12), carbonPaint);
      canvas.drawRect(Rect.fromLTWH(halfW * 0.35 - 3, halfH * 0.76, 3, ch * 0.12), carbonPaint);
    } else if (bodyStyle == VehicleBodyStyle.titanStealth) {
      // Heavy armored airbrake flap with aggressive faceted angles
      final flapPaint = Paint()..color = const Color(0xFF1E2129);
      final flapEdge = Paint()
        ..color = const Color(0xFFFF9E00).withValues(alpha: 0.8)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;

      final flapPath = Path()
        ..moveTo(-cw * 0.38, halfH * 0.78)
        ..lineTo(cw * 0.38, halfH * 0.78)
        ..lineTo(cw * 0.32, halfH * 0.86)
        ..lineTo(-cw * 0.32, halfH * 0.86)
        ..close();
      canvas.drawPath(flapPath, flapPaint);
      canvas.drawPath(flapPath, flapEdge);

      // Hydraulic ram cylinders
      final ramPaint = Paint()..color = const Color(0xFF6B7280);
      canvas.drawRect(Rect.fromLTWH(-cw * 0.22, halfH * 0.84, 4, ch * 0.05), ramPaint);
      canvas.drawRect(Rect.fromLTWH(cw * 0.22 - 4, halfH * 0.84, 4, ch * 0.05), ramPaint);
    } else {
      // Roadster sleek low-profile active spoiler
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
        oldDelegate.player.isAtRoadBoundary != player.isAtRoadBoundary ||
        oldDelegate.player.customization != player.customization;
  }
}
