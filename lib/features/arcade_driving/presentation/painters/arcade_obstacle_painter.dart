import 'package:flutter/material.dart';
import '../../domain/models/obstacle_vehicle.dart';

/// Renders traffic vehicles and hazards with high-fidelity cyberpunk styling,
/// realistic perspective scaling, soft contact shadows, visible wheels,
/// tinted glass canopies, and vibrant emissive lighting assemblies.
class ArcadeObstaclePainter extends CustomPainter {
  final List<ObstacleVehicle> obstacles;
  final double curveOffset;
  final double elevationOffset;

  ArcadeObstaclePainter({
    required this.obstacles,
    this.curveOffset = 0.0,
    this.elevationOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (final obstacle in obstacles) {
      final rect = obstacle.getBoundingRect(w, h, curveOffset, elevationOffset);
      final cw = rect.width;
      final ch = rect.height;

      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);

      // Subtle perspective pitch scaling for obstacles
      if (elevationOffset != 0.0) {
        final pitchScaleY = (1.0 - elevationOffset * 0.05).clamp(0.92, 1.08);
        canvas.scale(1.0, pitchScaleY);
      }

      // Align vehicle heading with curved road trajectory
      if (curveOffset != 0.0) {
        final horizonY = h * 0.18;
        final t = ((rect.center.dy - horizonY) / (h - horizonY)).clamp(0.0, 1.0);
        final curveYaw = -curveOffset * (1.0 - t) * 0.08;
        canvas.rotate(curveYaw);
      }

      // 1. Perspective-Correct Soft Contact Ground Shadow
      _drawContactShadow(canvas, cw, ch);

      // 2. Specialized Vehicle / Hazard Rendering
      switch (obstacle.type) {
        case ObstacleType.cyberSedan:
          _drawCyberSedan(canvas, cw, ch, obstacle.color);
          break;
        case ObstacleType.cyberTruck:
          _drawCyberTruck(canvas, cw, ch, obstacle.color);
          break;
        case ObstacleType.heavyHauler:
          _drawHeavyHauler(canvas, cw, ch, obstacle.color);
          break;
        case ObstacleType.energyBarrier:
          _drawEnergyBarrier(canvas, cw, ch, obstacle.color);
          break;
      }

      canvas.restore();
    }
  }

  void _drawContactShadow(Canvas canvas, double cw, double ch) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.62)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: const Offset(0, 4),
          width: cw * 1.08,
          height: ch * 1.04,
        ),
        const Radius.circular(8),
      ),
      shadowPaint,
    );
  }

  void _drawCyberSedan(Canvas canvas, double cw, double ch, Color color) {
    final halfW = cw / 2;
    final halfH = ch / 2;

    // 1. Wheels & Tires
    final wheelW = cw * 0.15;
    final wheelH = ch * 0.20;
    final tirePaint = Paint()..color = const Color(0xFF16181E);
    final rimPaint = Paint()..color = const Color(0xFF6B7586);

    final wheelOffsets = [
      Offset(-halfW * 0.95, -halfH * 0.45),
      Offset(halfW * 0.95, -halfH * 0.45),
      Offset(-halfW * 0.95, halfH * 0.45),
      Offset(halfW * 0.95, halfH * 0.45),
    ];
    for (final pt in wheelOffsets) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pt, width: wheelW, height: wheelH), const Radius.circular(2)),
        tirePaint,
      );
      canvas.drawRect(Rect.fromCenter(center: pt, width: wheelW * 0.55, height: wheelH * 0.65), rimPaint);
    }

    // 2. Aerodynamic Sedan Body Shell
    final bodyPath = Path()
      ..moveTo(0, -halfH)
      ..cubicTo(halfW * 0.6, -halfH, halfW * 0.88, -halfH * 0.65, halfW * 0.88, -halfH * 0.2)
      ..lineTo(halfW * 0.85, halfH * 0.65)
      ..cubicTo(halfW * 0.85, halfH * 0.90, halfW * 0.5, halfH, 0, halfH)
      ..cubicTo(-halfW * 0.5, halfH, -halfW * 0.85, halfH * 0.90, -halfW * 0.85, halfH * 0.65)
      ..lineTo(-halfW * 0.88, -halfH * 0.2)
      ..cubicTo(-halfW * 0.88, -halfH * 0.65, -halfW * 0.6, -halfH, 0, -halfH)
      ..close();

    final bodyShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color,
        color.withValues(alpha: 0.85),
        const Color(0xFF151C28),
        const Color(0xFF0C1018),
      ],
      stops: const [0.0, 0.35, 0.75, 1.0],
    ).createShader(Rect.fromCenter(center: Offset.zero, width: cw, height: ch));

    canvas.drawPath(bodyPath, Paint()..shader = bodyShader);

    // Specular body outline
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // 3. Panoramic Tinted Glass Canopy
    final glassPath = Path()
      ..moveTo(0, -halfH * 0.25)
      ..cubicTo(halfW * 0.6, -halfH * 0.25, halfW * 0.62, 0.0, halfW * 0.55, halfH * 0.35)
      ..lineTo(-halfW * 0.55, halfH * 0.35)
      ..cubicTo(-halfW * 0.62, 0.0, -halfW * 0.6, -halfH * 0.25, 0, -halfH * 0.25)
      ..close();
    canvas.drawPath(glassPath, Paint()..color = const Color(0xFF0A0F18));
    canvas.drawPath(
      glassPath,
      Paint()
        ..color = const Color(0xFF00F0FF).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // 4. Emissive Rear Red Taillights with Halo
    final tailPaint = Paint()
      ..color = const Color(0xFFFF2233)
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(Offset(-halfW * 0.75, halfH * 0.92), Offset(halfW * 0.75, halfH * 0.92), tailPaint);
    canvas.drawLine(
      Offset(-halfW * 0.75, halfH * 0.92),
      Offset(halfW * 0.75, halfH * 0.92),
      Paint()..color = Colors.white..strokeWidth = 1.2,
    );
  }

  void _drawCyberTruck(Canvas canvas, double cw, double ch, Color color) {
    final halfW = cw / 2;
    final halfH = ch / 2;

    // 1. Heavy All-Terrain Tires
    final wheelW = cw * 0.17;
    final wheelH = ch * 0.22;
    final tirePaint = Paint()..color = const Color(0xFF14161B);
    final boltPaint = Paint()..color = const Color(0xFF8B94A0);

    final wheelPositions = [
      Offset(-halfW * 0.96, -halfH * 0.40),
      Offset(halfW * 0.96, -halfH * 0.40),
      Offset(-halfW * 0.96, halfH * 0.48),
      Offset(halfW * 0.96, halfH * 0.48),
    ];
    for (final pt in wheelPositions) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pt, width: wheelW, height: wheelH), const Radius.circular(3)),
        tirePaint,
      );
      canvas.drawCircle(pt, 1.5, boltPaint);
    }

    // 2. Stainless Steel Angular Wedge Exoskeleton
    final truckPath = Path()
      ..moveTo(0, -halfH)
      ..lineTo(halfW * 0.88, -halfH * 0.52)
      ..lineTo(halfW * 0.88, halfH * 0.95)
      ..lineTo(-halfW * 0.88, halfH * 0.95)
      ..lineTo(-halfW * 0.88, -halfH * 0.52)
      ..close();

    final bodyShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFA6B4C4),
        Color(0xFF758394),
        Color(0xFF4C5868),
        Color(0xFF333C48),
      ],
      stops: [0.0, 0.35, 0.75, 1.0],
    ).createShader(Rect.fromCenter(center: Offset.zero, width: cw, height: ch));

    canvas.drawPath(truckPath, Paint()..shader = bodyShader);

    // Sharp crease lines on stainless steel
    final creasePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(truckPath, creasePaint);

    // 3. Angular Vault Cabin & Recessed Truck Bed
    final bedRect = Rect.fromCenter(center: Offset(0, halfH * 0.55), width: cw * 0.68, height: ch * 0.32);
    canvas.drawRect(bedRect, Paint()..color = const Color(0xFF1E242D));

    // Bed ribs
    final ribPaint = Paint()
      ..color = const Color(0xFF14181F)
      ..strokeWidth = 1.2;
    for (int i = -2; i <= 2; i++) {
      final y = (halfH * 0.55) + (i * 6.0);
      canvas.drawLine(Offset(-cw * 0.30, y), Offset(cw * 0.30, y), ribPaint);
    }

    // Triangular Cabin Roof
    final roofPath = Path()
      ..moveTo(0, -halfH * 0.48)
      ..lineTo(halfW * 0.65, 0)
      ..lineTo(-halfW * 0.65, 0)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = const Color(0xFF181F28));

    // 4. Amber Warning Beacon Lightbar on Roof
    final beaconPaint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(Offset(-halfW * 0.55, -halfH * 0.20), Offset(halfW * 0.55, -halfH * 0.20), beaconPaint);
    canvas.drawLine(
      Offset(-halfW * 0.55, -halfH * 0.20),
      Offset(halfW * 0.55, -halfH * 0.20),
      Paint()..color = Colors.white..strokeWidth = 1.5,
    );

    // 5. Rear Full-Width Taillight Bar
    final tailPaint = Paint()
      ..color = const Color(0xFFFF1E38)
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawLine(Offset(-halfW * 0.80, halfH * 0.92), Offset(halfW * 0.80, halfH * 0.92), tailPaint);
  }

  void _drawHeavyHauler(Canvas canvas, double cw, double ch, Color color) {
    final halfW = cw / 2;
    final halfH = ch / 2;

    // 1. Articulated Tractor Cab (Front)
    final cabRect = Rect.fromCenter(center: Offset(0, -halfH * 0.68), width: cw * 0.88, height: ch * 0.26);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cabRect, const Radius.circular(5)),
      Paint()..color = const Color(0xFF37474F),
    );

    // Cab windshield
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -halfH * 0.72), width: cw * 0.72, height: ch * 0.12),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF0F1820),
    );

    // Dual Roof Warning Strobe Beacons
    final strobePaint = Paint()
      ..color = const Color(0xFFFF9100)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(-halfW * 0.65, -halfH * 0.82), 3.0, strobePaint);
    canvas.drawCircle(Offset(halfW * 0.65, -halfH * 0.82), 3.0, strobePaint);
    canvas.drawCircle(Offset(-halfW * 0.65, -halfH * 0.82), 1.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(halfW * 0.65, -halfH * 0.82), 1.5, Paint()..color = Colors.white);

    // 2. Heavy Cargo Container Trailer (Rear)
    final trailerRect = Rect.fromCenter(center: Offset(0, halfH * 0.18), width: cw * 0.95, height: ch * 0.74);
    canvas.drawRRect(
      RRect.fromRectAndRadius(trailerRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF212B35),
    );

    // Corrugated Cargo Container Paneling Lines
    final corrugatePaint = Paint()
      ..color = const Color(0xFF171E25)
      ..strokeWidth = 1.2;
    for (double y = -halfH * 0.12; y <= halfH * 0.48; y += 10.0) {
      canvas.drawLine(Offset(-cw * 0.42, y), Offset(cw * 0.42, y), corrugatePaint);
    }

    // Industrial Safety Chevron Stripes on Trailer Rear
    final chevronPaint = Paint()
      ..color = const Color(0xFFFFC107).withValues(alpha: 0.85)
      ..strokeWidth = 2.0;
    for (int i = -3; i <= 3; i++) {
      canvas.drawLine(
        Offset(-cw * 0.38, (halfH * 0.55) + (i * 8.0)),
        Offset(cw * 0.38, (halfH * 0.55) + (i * 8.0) + 6.0),
        chevronPaint,
      );
    }

    // Glowing Telemetry Status Bar (Green / Cyan)
    final statusPaint = Paint()
      ..color = const Color(0xFF00E676)
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawLine(Offset(-cw * 0.35, -halfH * 0.15), Offset(cw * 0.35, -halfH * 0.15), statusPaint);

    // Rear Quad Taillights
    final tailPaint = Paint()..color = const Color(0xFFFF1744);
    canvas.drawCircle(Offset(-halfW * 0.75, halfH * 0.52), 3.0, tailPaint);
    canvas.drawCircle(Offset(-halfW * 0.55, halfH * 0.52), 3.0, tailPaint);
    canvas.drawCircle(Offset(halfW * 0.55, halfH * 0.52), 3.0, tailPaint);
    canvas.drawCircle(Offset(halfW * 0.75, halfH * 0.52), 3.0, tailPaint);
  }

  void _drawEnergyBarrier(Canvas canvas, double cw, double ch, Color color) {
    final halfW = cw / 2;

    // 1. Dual Heavy Reinforced Industrial Hazard Pylons
    final pylonPaint = Paint()..color = const Color(0xFF263238);
    final pylonWarningPaint = Paint()..color = const Color(0xFFFF9100);

    final leftPylon = Rect.fromCenter(center: Offset(-halfW + 6, 0), width: 12, height: ch);
    final rightPylon = Rect.fromCenter(center: Offset(halfW - 6, 0), width: 12, height: ch);

    canvas.drawRect(leftPylon, pylonPaint);
    canvas.drawRect(rightPylon, pylonPaint);

    // Hazard Stripes on Pylons
    canvas.drawRect(Rect.fromCenter(center: Offset(-halfW + 6, -ch * 0.25), width: 12, height: 4), pylonWarningPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(-halfW + 6, ch * 0.25), width: 12, height: 4), pylonWarningPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(halfW - 6, -ch * 0.25), width: 12, height: 4), pylonWarningPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(halfW - 6, ch * 0.25), width: 12, height: 4), pylonWarningPaint);

    // 2. High-Voltage Electric Plasma Forcefield Arcs
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    final corePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5;

    // Horizontal main forcefield beam
    canvas.drawLine(Offset(-halfW + 6, 0), Offset(halfW - 6, 0), glowPaint);
    canvas.drawLine(Offset(-halfW + 6, 0), Offset(halfW - 6, 0), corePaint);

    // Animated lightning zig-zags between pylons
    final arcPath = Path()..moveTo(-halfW + 6, 0);
    const int segments = 8;
    final segW = (cw - 12) / segments;
    for (int i = 1; i < segments; i++) {
      final sign = (i % 2 == 1) ? 1 : -1;
      final yArc = sign * (ch * 0.28);
      arcPath.lineTo(-halfW + 6 + (i * segW), yArc);
    }
    arcPath.lineTo(halfW - 6, 0);

    final arcPaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(arcPath, arcPaint);
  }

  @override
  bool shouldRepaint(covariant ArcadeObstaclePainter oldDelegate) => true;
}
