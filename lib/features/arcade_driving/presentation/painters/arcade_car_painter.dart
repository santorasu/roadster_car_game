import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/player_car.dart';

/// Renders the original Cyber Roadster supercar using custom vector canvas paths,
/// dynamic lighting, brake halos, and high-speed thruster plumes.
class ArcadeCarPainter extends CustomPainter {
  final PlayerCar player;

  ArcadeCarPainter({required this.player});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Road boundaries
    final roadWidth = w * 0.72;
    final carWidth = roadWidth * 0.17;
    final carHeight = carWidth * 1.95;

    final centerX = (w / 2) + (player.lanePosition * (roadWidth / 2 - carWidth * 0.6));
    final centerY = h * 0.75;

    canvas.save();
    canvas.translate(centerX, centerY);

    // Dynamic car tilt / roll
    canvas.rotate(player.rollAngle);

    // 1. Headlight Light Cones onto Road
    _drawHeadlightBeams(canvas, carWidth, carHeight);

    // 2. High-Speed Thruster Plume (if accelerating > 100 MPH)
    if (player.isAccelerating && player.speedMph > 100.0) {
      _drawThrusterPlume(canvas, carWidth, carHeight);
    }

    // 3. Ground Ambient Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: const Offset(0, 4),
          width: carWidth * 1.05,
          height: carHeight * 1.02,
        ),
        const Radius.circular(10),
      ),
      shadowPaint,
    );

    // 4. Aerodynamic Body Shell
    _drawSupercarBody(canvas, carWidth, carHeight);

    // 5. Cockpit Panoramic Canopy (Tinted Glass)
    _drawCockpit(canvas, carWidth, carHeight);

    // 6. LED Headlights & Full-Width Neon Taillight
    _drawLights(canvas, carWidth, carHeight);

    // 7. Post-Collision Recovery Aura (if recovering)
    if (player.collisionRecoveryTimer > 0.0) {
      _drawRecoveryAura(canvas, carWidth, carHeight);
    }

    canvas.restore();
  }

  void _drawHeadlightBeams(Canvas canvas, double cw, double ch) {
    final beamLength = ch * 2.2;
    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.cyanAccent.withValues(alpha: 0.35),
          Colors.cyanAccent.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(-cw, -beamLength, cw * 2, beamLength))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Left beam
    final leftPath = Path()
      ..moveTo(-cw * 0.32, -ch * 0.45)
      ..lineTo(-cw * 0.85, -beamLength)
      ..lineTo(-cw * 0.1, -beamLength)
      ..close();
    canvas.drawPath(leftPath, beamPaint);

    // Right beam
    final rightPath = Path()
      ..moveTo(cw * 0.32, -ch * 0.45)
      ..lineTo(cw * 0.1, -beamLength)
      ..lineTo(cw * 0.85, -beamLength)
      ..close();
    canvas.drawPath(rightPath, beamPaint);
  }

  void _drawThrusterPlume(Canvas canvas, double cw, double ch) {
    final plumeHeight = (ch * 0.55) * (player.speedMph / 250.0);
    final plumePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          const Color(0xFF00E5FF),
          const Color(0xFF0051FF).withValues(alpha: 0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(-cw * 0.3, ch * 0.45, cw * 0.6, plumeHeight))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final plumePath = Path()
      ..moveTo(-cw * 0.22, ch * 0.45)
      ..lineTo(0, ch * 0.45 + plumeHeight)
      ..lineTo(cw * 0.22, ch * 0.45)
      ..close();
    canvas.drawPath(plumePath, plumePaint);
  }

  void _drawSupercarBody(Canvas canvas, double cw, double ch) {
    final halfW = cw / 2;
    final halfH = ch / 2;

    // Roadster muscular contour path
    final bodyPath = Path()
      // Nose cone
      ..moveTo(0, -halfH)
      ..cubicTo(halfW * 0.5, -halfH, halfW * 0.82, -halfH * 0.7, halfW * 0.86, -halfH * 0.3)
      // Front wheel arch to waist tuck
      ..cubicTo(halfW * 0.95, -halfH * 0.1, halfW * 0.78, halfH * 0.05, halfW * 0.82, halfH * 0.3)
      // Wide rear haunches
      ..cubicTo(halfW * 1.0, halfH * 0.55, halfW * 0.92, halfH * 0.85, halfW * 0.75, halfH)
      // Rear diffuser & bumper
      ..lineTo(-halfW * 0.75, halfH)
      ..cubicTo(-halfW * 0.92, halfH * 0.85, -halfW * 1.0, halfH * 0.55, -halfW * 0.82, halfH * 0.3)
      // Waist tuck to front wheel arch
      ..cubicTo(-halfW * 0.78, halfH * 0.05, -halfW * 0.95, -halfH * 0.1, -halfW * 0.86, -halfH * 0.3)
      // Back to nose cone
      ..cubicTo(-halfW * 0.82, -halfH * 0.7, -halfW * 0.5, -halfH, 0, -halfH)
      ..close();

    // Metallic crimson body paint shader
    final bodyShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFF334B), // Highlight hood
        Color(0xFFE01E2E), // Main rich red
        Color(0xFF9E0B19), // Deep shadow
        Color(0xFF6B000B), // Rear bumper
      ],
      stops: [0.0, 0.35, 0.75, 1.0],
    ).createShader(Rect.fromCenter(center: Offset.zero, width: cw, height: ch));

    final bodyPaint = Paint()..shader = bodyShader;
    canvas.drawPath(bodyPath, bodyPaint);

    // Specular body edge highlights
    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(bodyPath, edgePaint);

    // Hood aerodynamic intake lines
    final intakePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(-cw * 0.2, -halfH * 0.65), Offset(-cw * 0.08, -halfH * 0.2), intakePaint);
    canvas.drawLine(Offset(cw * 0.2, -halfH * 0.65), Offset(cw * 0.08, -halfH * 0.2), intakePaint);
  }

  void _drawCockpit(Canvas canvas, double cw, double ch) {
    final canopyPath = Path()
      ..moveTo(0, -ch * 0.18)
      ..cubicTo(cw * 0.32, -ch * 0.18, cw * 0.38, 0, cw * 0.32, ch * 0.22)
      ..lineTo(-cw * 0.32, ch * 0.22)
      ..cubicTo(-cw * 0.38, 0, -cw * 0.32, -ch * 0.18, 0, -ch * 0.18)
      ..close();

    final glassPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1E2838),
          Color(0xFF0F1520),
          Color(0xFF05080E),
        ],
      ).createShader(Rect.fromCenter(center: Offset.zero, width: cw * 0.7, height: ch * 0.5));
    canvas.drawPath(canopyPath, glassPaint);

    // Glass glare line
    final glarePaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(canopyPath, glarePaint);
  }

  void _drawLights(Canvas canvas, double cw, double ch) {
    final halfW = cw / 2;
    final halfH = ch / 2;

    // 1. Dual Angled Headlights
    final headlightPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(-halfW * 0.55, -halfH * 0.82), width: cw * 0.15, height: ch * 0.05),
      headlightPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(halfW * 0.55, -halfH * 0.82), width: cw * 0.15, height: ch * 0.05),
      headlightPaint,
    );

    // 2. Full-Width Cyber Taillight Blade
    final isBraking = player.isBraking;
    final tailColor = isBraking ? const Color(0xFFFF0033) : const Color(0xFFFF2222);
    final tailGlowRadius = isBraking ? 8.0 : 3.0;

    // Glowing halo
    final tailGlowPaint = Paint()
      ..color = tailColor.withValues(alpha: isBraking ? 0.95 : 0.6)
      ..strokeWidth = isBraking ? 6.0 : 3.5
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, tailGlowRadius);

    final tailPath = Path()
      ..moveTo(-halfW * 0.68, halfH * 0.94)
      ..lineTo(halfW * 0.68, halfH * 0.94);

    canvas.drawPath(tailPath, tailGlowPaint);

    // Sharp core lightbar
    final tailCorePaint = Paint()
      ..color = isBraking ? Colors.white : const Color(0xFFFF8888)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(tailPath, tailCorePaint);
  }

  void _drawRecoveryAura(Canvas canvas, double cw, double ch) {
    final pulse = (math.sin(player.collisionRecoveryTimer * 16.0) + 1.0) / 2.0;
    final outerAlpha = (0.25 + 0.35 * pulse).clamp(0.0, 1.0);
    final innerAlpha = (0.40 + 0.30 * (1.0 - pulse)).clamp(0.0, 1.0);

    // Outer pulsing barrier halo
    final outerPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: outerAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 + (1.5 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: cw * (1.22 + 0.12 * pulse),
          height: ch * (1.12 + 0.08 * pulse),
        ),
        const Radius.circular(18),
      ),
      outerPaint,
    );

    // Inner sharp stabilization shield
    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: innerAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: cw * 1.15, height: ch * 1.08),
        const Radius.circular(14),
      ),
      innerPaint,
    );
  }


  @override
  bool shouldRepaint(covariant ArcadeCarPainter oldDelegate) {
    return oldDelegate.player.lanePosition != player.lanePosition ||
        oldDelegate.player.speedMph != player.speedMph ||
        oldDelegate.player.rollAngle != player.rollAngle ||
        oldDelegate.player.isBraking != player.isBraking ||
        oldDelegate.player.isAccelerating != player.isAccelerating ||
        oldDelegate.player.collisionRecoveryTimer != player.collisionRecoveryTimer ||
        oldDelegate.player.isAtRoadBoundary != player.isAtRoadBoundary;
  }
}
