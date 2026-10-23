import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/arcade_game_state.dart';
import '../models/game_particle.dart';
import '../models/obstacle_vehicle.dart';
import '../models/player_car.dart';

/// Pure Dart game engine handling arcade physics, obstacle spawning,
/// collision detection, scoring, and particle life cycles.
class ArcadeGameEngine {
  final PlayerCar player = PlayerCar();
  final ArcadeGameState state = ArcadeGameState();
  final List<ObstacleVehicle> obstacles = [];
  final List<GameParticle> particles = [];

  final math.Random _random = math.Random();

  // Road animation accumulator
  double roadScrollOffset = 0.0;

  // Obstacle spawn timer
  double _spawnTimer = 0.0;
  final double _spawnInterval = 1.8; // seconds between obstacles

  // Constants
  static const double topSpeed = 250.0;
  static const double minSpeed = 20.0;
  static const double accelerationRate = 85.0; // MPH per second
  static const double brakingRate = 130.0; // MPH per second
  static const double coastingDrag = 18.0; // MPH per second
  static const double steeringSpeed = 2.4; // Lanes per second

  // Lanes
  static const List<double> lanes = [-0.65, 0.0, 0.65];

  ArcadeGameEngine();

  /// Starts or resumes the game
  void start() {
    if (state.status == ArcadeGameStatus.ready ||
        state.status == ArcadeGameStatus.gameOver) {
      reset();
    }
    state.status = ArcadeGameStatus.playing;
  }

  /// Pauses the game loop
  void pause() {
    if (state.status == ArcadeGameStatus.playing) {
      state.status = ArcadeGameStatus.paused;
    }
  }

  /// Resumes from pause
  void resume() {
    if (state.status == ArcadeGameStatus.paused) {
      state.status = ArcadeGameStatus.playing;
    }
  }

  /// Resets and starts a fresh game session
  void restart() {
    reset();
    start();
  }

  /// Resets all entities to initial state
  void reset() {
    final prevHighScore = state.highScore;
    player.reset();
    player.speedMph = 35.0; // Initial rolling start
    state.reset();
    state.highScore = prevHighScore;
    obstacles.clear();
    particles.clear();
    roadScrollOffset = 0.0;
    _spawnTimer = 0.5;
  }

  /// Main physics and game logic tick
  void tick(double dt, double screenWidth, double screenHeight) {
    if (state.status != ArcadeGameStatus.playing) return;

    // 1. Update Player Speed & Physics
    if (player.isAccelerating) {
      player.speedMph = (player.speedMph + accelerationRate * dt).clamp(0.0, topSpeed);
    } else if (player.isBraking) {
      player.speedMph = (player.speedMph - brakingRate * dt).clamp(0.0, topSpeed);
    } else {
      // Coasting
      if (player.speedMph > minSpeed) {
        player.speedMph = (player.speedMph - coastingDrag * dt).clamp(minSpeed, topSpeed);
      } else {
        player.speedMph = (player.speedMph + 10.0 * dt).clamp(0.0, minSpeed);
      }
    }

    if (player.speedMph > state.topSpeedMph) {
      state.topSpeedMph = player.speedMph;
      player.topSpeedMph = player.speedMph;
    }

    // 2. Update Steering & Roll Angle
    if (player.steerInput != 0.0) {
      // Speed factor makes steering sharper at mid speeds and stable at high speeds
      final speedFactor = (player.speedMph / 100.0).clamp(0.4, 1.2);
      player.lanePosition += player.steerInput * steeringSpeed * speedFactor * dt;
      player.lanePosition = player.lanePosition.clamp(-1.0, 1.0);

      // Visual car tilt
      final targetRoll = player.steerInput * 0.12;
      player.rollAngle += (targetRoll - player.rollAngle) * (dt * 10.0);
    } else {
      // Return roll to neutral
      player.rollAngle += (0.0 - player.rollAngle) * (dt * 10.0);
    }

    // 3. Update Road Scrolling & Distance Traveled
    final speedRatio = player.speedMph / 100.0;
    roadScrollOffset = (roadScrollOffset + speedRatio * dt * 8.0) % 1.0;

    // Convert speed (MPH) to meters/sec (1 MPH ≈ 0.44704 m/s)
    final distanceDelta = (player.speedMph * 0.44704) * dt;
    player.distanceTraveledMeters += distanceDelta;
    state.distanceMeters = player.distanceTraveledMeters;

    // 4. Update Score & Multipliers
    if (player.speedMph > 200.0) {
      state.comboMultiplier = 3.0;
    } else if (player.speedMph > 140.0) {
      state.comboMultiplier = 2.0;
    } else if (player.speedMph > 80.0) {
      state.comboMultiplier = 1.5;
    } else {
      state.comboMultiplier = 1.0;
    }

    state.score += (distanceDelta * state.comboMultiplier * 2.0).round();
    if (state.score > state.highScore) {
      state.highScore = state.score;
    }

    // 5. Spawn Obstacles
    _spawnTimer += dt;
    // Spawn faster as score increases
    final dynamicInterval = (_spawnInterval - (state.distanceMeters / 5000.0) * 0.5).clamp(0.9, 2.2);
    if (_spawnTimer >= dynamicInterval) {
      _spawnTimer = 0.0;
      _spawnObstacle();
    }

    // 6. Update Obstacles & Check Collisions
    final playerRect = player.getBoundingRect(screenWidth, screenHeight);

    for (int i = obstacles.length - 1; i >= 0; i--) {
      final obstacle = obstacles[i];

      // Relative downward speed on screen:
      // Player moving faster makes obstacle approach player (yProgress increases)
      final relativeSpeed = math.max(20.0, player.speedMph - obstacle.speedMph + 30.0);
      obstacle.yProgress += (relativeSpeed / 100.0) * dt * 0.45;

      // Check collision if obstacle is near player's vertical zone
      if (!obstacle.hasCollided && obstacle.yProgress > 0.60 && obstacle.yProgress < 0.90) {
        final obstacleRect = obstacle.getBoundingRect(screenWidth, screenHeight);
        if (playerRect.overlaps(obstacleRect)) {
          _handleCollision(obstacle, playerRect, obstacleRect);
        }
      }

      // Check near-miss overtaking bonus
      if (!obstacle.hasCollided && obstacle.yProgress >= 0.90 && obstacle.yProgress < 0.95) {
        // Successfully passed
        state.score += 250;
      }

      // Remove obstacles that have scrolled past bottom
      if (obstacle.yProgress > 1.25) {
        obstacles.removeAt(i);
      }
    }

    // 7. Update Particles
    _updateParticles(dt, screenWidth, screenHeight);

    // 8. Decay Screen Shake
    if (state.screenShakeIntensity > 0.0) {
      state.screenShakeIntensity = math.max(0.0, state.screenShakeIntensity - dt * 3.5);
    }
  }

  void _spawnObstacle() {
    // Pick lane not recently populated
    final availableLanes = List<double>.from(lanes);
    availableLanes.shuffle(_random);
    final chosenLane = availableLanes.first;

    final typeRoll = _random.nextDouble();
    ObstacleType type;
    Color color;
    double speed;

    if (typeRoll < 0.35) {
      type = ObstacleType.cyberSedan;
      color = const Color(0xFF00E5FF); // Electric Cyan
      speed = 65.0 + _random.nextDouble() * 20.0;
    } else if (typeRoll < 0.70) {
      type = ObstacleType.cyberTruck;
      color = const Color(0xFFFFB300); // Warning Amber
      speed = 50.0 + _random.nextDouble() * 15.0;
    } else if (typeRoll < 0.90) {
      type = ObstacleType.heavyHauler;
      color = const Color(0xFF78909C); // Industrial Slate
      speed = 35.0 + _random.nextDouble() * 10.0;
    } else {
      type = ObstacleType.energyBarrier;
      color = const Color(0xFFFF1744); // Hazard Red
      speed = 0.0; // Stationary road hazard
    }

    obstacles.add(ObstacleVehicle(
      id: 'obs_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
      type: type,
      color: color,
      lanePosition: chosenLane,
      yProgress: 0.05, // Spawn at horizon
      speedMph: speed,
    ));
  }

  void _handleCollision(ObstacleVehicle obstacle, Rect playerRect, Rect obstacleRect) {
    obstacle.hasCollided = true;
    state.collisionsCount++;

    // Damage based on obstacle mass
    double damage;
    switch (obstacle.type) {
      case ObstacleType.heavyHauler:
        damage = 0.40;
        break;
      case ObstacleType.energyBarrier:
        damage = 0.35;
        break;
      case ObstacleType.cyberTruck:
        damage = 0.25;
        break;
      case ObstacleType.cyberSedan:
        damage = 0.20;
        break;
    }

    player.health = math.max(0.0, player.health - damage);
    player.speedMph = math.max(minSpeed, player.speedMph * 0.55);
    state.comboMultiplier = 1.0;
    state.screenShakeIntensity = 1.0;

    // Spawn collision sparks at intersection center
    final intersectionCenter = Offset(
      (playerRect.center.dx + obstacleRect.center.dx) / 2,
      (playerRect.center.dy + obstacleRect.center.dy) / 2,
    );

    for (int i = 0; i < 22; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final velocity = 80.0 + _random.nextDouble() * 220.0;
      particles.add(GameParticle(
        x: intersectionCenter.dx,
        y: intersectionCenter.dy,
        vx: math.cos(angle) * velocity,
        vy: math.sin(angle) * velocity,
        life: 1.0,
        maxLife: 0.35 + _random.nextDouble() * 0.25,
        size: 3.0 + _random.nextDouble() * 3.5,
        color: _random.nextBool() ? const Color(0xFFFF9100) : const Color(0xFFFFD600),
        type: ParticleType.collisionSpark,
      ));
    }

    // Check Game Over
    if (player.health <= 0.0) {
      state.status = ArcadeGameStatus.gameOver;
      if (state.score > state.highScore) {
        state.highScore = state.score;
      }
    }
  }

  void _updateParticles(double dt, double screenWidth, double screenHeight) {
    // Generate speed lines when driving fast
    if (player.speedMph > 110.0 && _random.nextDouble() < 0.6) {
      particles.add(GameParticle(
        x: _random.nextDouble() * screenWidth,
        y: 0.0,
        vx: 0.0,
        vy: 400.0 + (player.speedMph * 3.0),
        life: 1.0,
        maxLife: 0.4,
        size: 2.0,
        color: Colors.cyanAccent.withValues(alpha: 0.6),
        type: ParticleType.speedLine,
      ));
    }

    // Update existing particles
    for (int i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      if (!p.update(dt)) {
        particles.removeAt(i);
      }
    }
  }
}
