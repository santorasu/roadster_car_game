import 'package:flutter/material.dart';
import '../../domain/models/game_particle.dart';

/// Renders dynamic visual FX such as collision sparks and high-speed streaks.
class ArcadeParticlePainter extends CustomPainter {
  final List<GameParticle> particles;

  ArcadeParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final alpha = p.life.clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: alpha);

      switch (p.type) {
        case ParticleType.collisionSpark:
          paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
          canvas.drawCircle(Offset(p.x, p.y), p.size * alpha, paint);
          break;

        case ParticleType.speedLine:
          paint.strokeWidth = p.size;
          canvas.drawLine(
            Offset(p.x, p.y),
            Offset(p.x, p.y + (p.vy * 0.05)),
            paint,
          );
          break;

        case ParticleType.thrusterPlume:
        case ParticleType.tireSmoke:
          paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
          canvas.drawCircle(Offset(p.x, p.y), p.size * (2.0 - alpha), paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant ArcadeParticlePainter oldDelegate) => true;
}
