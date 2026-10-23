import 'package:flutter/material.dart';
import '../../domain/models/obstacle_vehicle.dart';

/// Renders obstacles and traffic vehicles with distinct cyberpunk silhouettes and lighting.
class ArcadeObstaclePainter extends CustomPainter {
  final List<ObstacleVehicle> obstacles;

  ArcadeObstaclePainter({required this.obstacles});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (final obstacle in obstacles) {
      final rect = obstacle.getBoundingRect(w, h);

      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);

      switch (obstacle.type) {
        case ObstacleType.cyberSedan:
          _drawCyberSedan(canvas, rect.width, rect.height, obstacle.color);
          break;
        case ObstacleType.cyberTruck:
          _drawCyberTruck(canvas, rect.width, rect.height, obstacle.color);
          break;
        case ObstacleType.heavyHauler:
          _drawHeavyHauler(canvas, rect.width, rect.height, obstacle.color);
          break;
        case ObstacleType.energyBarrier:
          _drawEnergyBarrier(canvas, rect.width, rect.height, obstacle.color);
          break;
      }

      canvas.restore();
    }
  }

  void _drawCyberSedan(Canvas canvas, double cw, double ch, Color color) {
    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 3), width: cw * 1.05, height: ch * 1.02),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Body
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.95),
          const Color(0xFF1E2838),
          const Color(0xFF0F1522),
        ],
      ).createShader(Rect.fromCenter(center: Offset.zero, width: cw, height: ch));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: cw, height: ch),
        const Radius.circular(6),
      ),
      bodyPaint,
    );

    // Windshield
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -ch * 0.1), width: cw * 0.7, height: ch * 0.35),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF080C14),
    );

    // Headlights (front facing down screen in top-down traffic or away if ahead)
    final redTailPaint = Paint()..color = const Color(0xFFFF2A2A);
    canvas.drawOval(Rect.fromCenter(center: Offset(-cw * 0.35, ch * 0.45), width: cw * 0.2, height: ch * 0.08), redTailPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cw * 0.35, ch * 0.45), width: cw * 0.2, height: ch * 0.08), redTailPaint);
  }

  void _drawCyberTruck(Canvas canvas, double cw, double ch, Color color) {
    // Shadow
    canvas.drawRect(
      Rect.fromCenter(center: const Offset(0, 4), width: cw * 1.05, height: ch * 1.02),
      Paint()..color = Colors.black.withValues(alpha: 0.55)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Angular wedge body
    final truckPath = Path()
      ..moveTo(0, -ch / 2)
      ..lineTo(cw / 2, -ch * 0.35)
      ..lineTo(cw / 2, ch / 2)
      ..lineTo(-cw / 2, ch / 2)
      ..lineTo(-cw / 2, -ch * 0.35)
      ..close();

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF8C9BAE),
          Color(0xFF5A6677),
          Color(0xFF38404D),
        ],
      ).createShader(Rect.fromCenter(center: Offset.zero, width: cw, height: ch));

    canvas.drawPath(truckPath, bodyPaint);

    // Angular roof vault
    final roofPaint = Paint()..color = const Color(0xFF1B222C);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(0, -ch * 0.05), width: cw * 0.72, height: ch * 0.45),
      roofPaint,
    );

    // Glowing Amber Warning Beacon Bar
    final beaconPaint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(Offset(-cw * 0.4, -ch * 0.25), Offset(cw * 0.4, -ch * 0.25), beaconPaint);
  }

  void _drawHeavyHauler(Canvas canvas, double cw, double ch, Color color) {
    // Long trailer body
    final trailerRect = Rect.fromCenter(center: Offset(0, ch * 0.08), width: cw * 0.95, height: ch * 0.75);
    final cabRect = Rect.fromCenter(center: Offset(0, -ch * 0.38), width: cw * 0.90, height: ch * 0.24);

    // Trailer
    canvas.drawRRect(
      RRect.fromRectAndRadius(trailerRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF263238),
    );

    // Industrial hazard stripes on trailer roof
    final stripePaint = Paint()
      ..color = const Color(0xFFFFB300).withValues(alpha: 0.7)
      ..strokeWidth = 2.0;
    for (int i = -3; i <= 3; i++) {
      canvas.drawLine(
        Offset(-cw * 0.35, (ch * 0.08) + (i * 12.0)),
        Offset(cw * 0.35, (ch * 0.08) + (i * 12.0) + 8.0),
        stripePaint,
      );
    }

    // Cab
    canvas.drawRRect(
      RRect.fromRectAndRadius(cabRect, const Radius.circular(5)),
      Paint()..color = const Color(0xFF37474F),
    );

    // Rear double red markers
    final markerPaint = Paint()..color = const Color(0xFFFF1744);
    canvas.drawCircle(Offset(-cw * 0.38, ch * 0.44), 3.0, markerPaint);
    canvas.drawCircle(Offset(cw * 0.38, ch * 0.44), 3.0, markerPaint);
  }

  void _drawEnergyBarrier(Canvas canvas, double cw, double ch, Color color) {
    // Energy Hazard Barrier
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final corePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0;

    canvas.drawLine(Offset(-cw / 2, 0), Offset(cw / 2, 0), glowPaint);
    canvas.drawLine(Offset(-cw / 2, 0), Offset(cw / 2, 0), corePaint);

    // Hazard pylons at edges
    final pylonPaint = Paint()..color = const Color(0xFFFF9100);
    canvas.drawRect(Rect.fromCenter(center: Offset(-cw / 2, 0), width: 8, height: ch), pylonPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cw / 2, 0), width: 8, height: ch), pylonPaint);
  }

  @override
  bool shouldRepaint(covariant ArcadeObstaclePainter oldDelegate) => true;
}
