import 'dart:ui';
import 'package:flutter/material.dart';

enum ParticleType {
  collisionSpark,
  speedLine,
  thrusterPlume,
  tireSmoke,
}

class GameParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life; // 1.0 -> 0.0
  double maxLife;
  double size;
  Color color;
  ParticleType type;

  GameParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.maxLife,
    required this.size,
    required this.color,
    required this.type,
  });

  bool update(double dt) {
    x += vx * dt;
    y += vy * dt;
    life -= dt / maxLife;
    return life > 0;
  }
}
