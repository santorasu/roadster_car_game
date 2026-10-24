import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/arcade_game_state.dart';
import '../models/game_mode.dart';
import '../models/game_particle.dart';
import '../models/obstacle_vehicle.dart';
import '../models/player_car.dart';
import '../models/road_section.dart';

/// Pure Dart game engine handling arcade physics, obstacle spawning,
/// collision detection, scoring, and particle life cycles.
class ArcadeGameEngine {
  final PlayerCar player = PlayerCar();
  final ArcadeGameState state = ArcadeGameState();
  final List<ObstacleVehicle> obstacles = [];
  final List<GameParticle> particles = [];
  final TrackProgressionManager trackManager = TrackProgressionManager();

  final math.Random _random = math.Random();

  // Road animation accumulator
  double roadScrollOffset = 0.0;

  // Obstacle spawn timer
  double _spawnTimer = 0.0;
  final double _spawnInterval = 1.8; // seconds between obstacles

  // Physics & Handling Constants
  static const double defaultTopSpeed = 250.0;
  static const double minSpeed = 20.0;
  static const double defaultBaseSteeringSpeed = 2.4; // Base lateral lanes per second
  static const double naturalCenteringRate = 0.55; // Controlled auto-return to neutral
  static const double boundaryVergeThreshold = 0.88; // Road verge starts here
  static const double maxPlayableBoundary = 1.0; // Strict playable boundary limit

  /// Active top speed governed by selected vehicle chassis
  double get topSpeed => player.vehicle.topSpeedMph;

  /// Active lateral steering responsiveness governed by selected vehicle chassis
  double get baseSteeringSpeed => defaultBaseSteeringSpeed * player.vehicle.baseSteeringMultiplier;

  // Lanes
  static const List<double> lanes = [-0.65, 0.0, 0.65];

  ArcadeGameEngine();

  /// Computes progressive motor acceleration accounting for instant electric torque,
  /// vehicle chassis acceleration multiplier, and high-speed aerodynamic drag
  double computeAccelerationRate(double speed) {
    final speedRatio = (speed / topSpeed).clamp(0.0, 1.0);
    // Instant torque at lower speeds scaled by vehicle-specific powertrain tuning
    final motorTorque = (95.0 - (38.0 * math.pow(speedRatio, 0.65))) * player.vehicle.accelerationMultiplier;
    // Aerodynamic drag increases with velocity squared
    final aeroDrag = 42.0 * math.pow(speedRatio, 2.0);
    return math.max(6.0, motorTorque - aeroDrag);
  }

  /// Computes progressive braking rate with responsive bite and speed-proportional stopping
  double computeBrakingRate(double speed) {
    final speedRatio = (speed / topSpeed).clamp(0.0, 1.0);
    return 75.0 + (75.0 * speedRatio);
  }

  /// Computes speed-sensitive steering sensitivity multiplier
  double computeSpeedSteerRatio(double speed) {
    final speedRatio = (speed / topSpeed).clamp(0.0, 1.0);
    // 1.15 at low speeds for agile maneuvering, scaling down to 0.45 at 250 MPH for stability
    return 1.15 - (0.70 * speedRatio);
  }

  /// Starts or resumes the game
  void start({GameMode? mode}) {
    if (mode != null) {
      state.gameMode = mode;
    }
    if (state.status == ArcadeGameStatus.ready ||
        state.status == ArcadeGameStatus.gameOver) {
      reset(mode: mode);
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
  void restart({GameMode? mode}) {
    reset(mode: mode);
    start(mode: mode);
  }

  /// Resets all entities to initial state
  void reset({GameMode? mode}) {
    final prevHighScore = state.highScore;
    player.reset();
    player.speedMph = 35.0; // Initial rolling start
    state.reset(mode: mode);
    state.highScore = prevHighScore;
    state.currentSectorName = trackManager.sections.isNotEmpty
        ? trackManager.sections.first.name
        : 'NEON HIGHWAY';
    state.currentCurvature = 0.0;
    state.currentElevation = 0.0;
    state.sectorNotificationTimer = 0.0;
    state.sectorIndex = 1;
    obstacles.clear();
    particles.clear();
    roadScrollOffset = 0.0;
    _spawnTimer = 0.5;
  }

  /// Main physics and game logic tick
  void tick(double dt, double screenWidth, double screenHeight) {
    if (state.status != ArcadeGameStatus.playing) return;

    // Track survival time
    state.timeElapsedSeconds += dt;

    // Time Trial mode countdown
    if (state.gameMode == GameMode.timeTrial) {
      state.timeRemainingSeconds -= dt;
      if (state.timeRemainingSeconds <= 0.0) {
        state.timeRemainingSeconds = 0.0;
        state.status = ArcadeGameStatus.gameOver;
        state.gameOverReason = 'TIME EXPIRED';
        if (state.score > state.highScore) {
          state.highScore = state.score;
        }
        return;
      }
    }

    // Health depletion game over check
    if (player.health <= 0.0) {
      state.status = ArcadeGameStatus.gameOver;
      state.gameOverReason ??= 'VEHICLE CRITICAL DAMAGE';
      if (state.score > state.highScore) {
        state.highScore = state.score;
      }
      return;
    }

    if (state.bonusTimeFlashTimer > 0.0) {
      state.bonusTimeFlashTimer = math.max(0.0, state.bonusTimeFlashTimer - dt);
    }

    if (state.nearMissNotificationTimer > 0.0) {
      state.nearMissNotificationTimer = math.max(0.0, state.nearMissNotificationTimer - dt);
    }

    // 0. Update Collision Recovery Window
    if (player.collisionRecoveryTimer > 0.0) {
      player.collisionRecoveryTimer = math.max(0.0, player.collisionRecoveryTimer - dt);
    }

    // Dynamic Road Curvature, Elevation & Track Progression
    final currentCurvature = trackManager.computeCurvatureAt(player.distanceTraveledMeters);
    final currentElevation = trackManager.computeElevationAt(player.distanceTraveledMeters);
    state.currentCurvature = currentCurvature;
    state.currentElevation = currentElevation;

    final activeSection = trackManager.getSectionForDistance(player.distanceTraveledMeters);
    final sectorIndex = trackManager.getSectorIndex(player.distanceTraveledMeters);

    if (sectorIndex != state.sectorIndex) {
      state.sectorIndex = sectorIndex;
      state.currentSectorName = activeSection.name;
      state.sectorNotificationTimer = 2.5;
      state.score += activeSection.bonusPoints;
    }

    if (state.sectorNotificationTimer > 0.0) {
      state.sectorNotificationTimer = math.max(0.0, state.sectorNotificationTimer - dt);
    }

    // 1. Progressive Acceleration & Braking Curves
    if (player.isAccelerating) {
      final accelRate = computeAccelerationRate(player.speedMph);
      player.speedMph = (player.speedMph + accelRate * dt).clamp(0.0, topSpeed);
    } else if (player.isBraking) {
      final brakeRate = computeBrakingRate(player.speedMph);
      player.speedMph = (player.speedMph - brakeRate * dt).clamp(0.0, topSpeed);
    } else {
      // Natural progressive coasting drag
      final coastDrag = 12.0 + (10.0 * (player.speedMph / topSpeed));
      if (player.speedMph > minSpeed) {
        player.speedMph = (player.speedMph - coastDrag * dt).clamp(minSpeed, topSpeed);
      } else {
        player.speedMph = (player.speedMph + 10.0 * dt).clamp(0.0, minSpeed);
      }
    }

    // Subtle elevation-based gravity speed feedback
    // Uphill (>0) adds gentle climb resistance, downhill (<0) adds speed momentum
    if (currentElevation.abs() > 0.01 && player.speedMph > 1.0) {
      final gravityFactor = currentElevation > 0.0 ? 14.0 : 16.0;
      final gravityAccel = -currentElevation * gravityFactor;
      player.speedMph = (player.speedMph + gravityAccel * dt).clamp(0.0, topSpeed);
    }

    if (player.speedMph > state.topSpeedMph) {
      state.topSpeedMph = player.speedMph;
      player.topSpeedMph = player.speedMph;
    }

    // 2. Speed-Sensitive Steering & Smooth Lateral Inertia
    final speedSteerRatio = computeSpeedSteerRatio(player.speedMph);
    final targetLateralVelocity = player.steerInput * baseSteeringSpeed * speedSteerRatio;

    // Frame-rate independent exponential smoothing for lateral inertia
    const steerInertiaRate = 12.0;
    final blend = 1.0 - math.exp(-steerInertiaRate * dt);
    player.lateralVelocity += (targetLateralVelocity - player.lateralVelocity) * blend;

    // Road Curvature Centrifugal Force
    // Curvature > 0 (right bend) pulls car outward to the left (-lateralVelocity)
    // Curvature < 0 (left bend) pulls car outward to the right (+lateralVelocity)
    if (currentCurvature.abs() > 0.01 && player.speedMph > 5.0) {
      final speedRatio = (player.speedMph / topSpeed).clamp(0.0, 1.0);
      final centrifugalForce = -currentCurvature * speedRatio * 1.60;
      player.lateralVelocity += centrifugalForce * dt;
    }

    // Controlled return toward neutral center when steering input is released
    if (player.steerInput == 0.0) {
      player.lateralVelocity -= player.lanePosition * naturalCenteringRate * dt;
    }

    // 3. Road-Boundary Handling & Soft Resistance
    player.lanePosition += player.lateralVelocity * dt;

    if (player.lanePosition.abs() >= boundaryVergeThreshold) {
      player.isAtRoadBoundary = true;
      final sign = player.lanePosition.sign;
      final excess = player.lanePosition.abs() - boundaryVergeThreshold;

      // Soft elastic boundary counter-force
      player.lateralVelocity -= sign * (excess * 24.0 * dt);

      // Boundary friction dampening
      final vergeFriction = 35.0 * excess;
      player.speedMph = math.max(minSpeed, player.speedMph - vergeFriction * dt);

      // Spawn boundary contact sparks if moving at speed
      if (player.speedMph > 40.0 && _random.nextDouble() < 0.45) {
        _spawnBoundarySparks(sign, screenWidth, screenHeight);
      }
    } else {
      player.isAtRoadBoundary = false;
    }

    // Strict boundary clamping so the vehicle never renders outside the playable road
    player.lanePosition = player.lanePosition.clamp(-maxPlayableBoundary, maxPlayableBoundary);
    if (player.lanePosition.abs() >= maxPlayableBoundary) {
      // Cancel outward lateral momentum at the hard boundary
      if (player.lanePosition * player.lateralVelocity > 0) {
        player.lateralVelocity = 0.0;
      }
    }

    // Dynamic vehicle roll tilt angle (combining steering roll and road banking)
    final curveRoll = -currentCurvature * 0.06;
    final targetRoll = (player.steerInput != 0.0)
        ? (player.steerInput * 0.12 + curveRoll)
        : ((player.lateralVelocity / baseSteeringSpeed) * 0.08 + curveRoll);
    final rollBlend = 1.0 - math.exp(-10.0 * dt);
    player.rollAngle += (targetRoll - player.rollAngle) * rollBlend;

    // 4. Update Road Scrolling & Distance Traveled
    final speedRatio = player.speedMph / 100.0;
    roadScrollOffset = (roadScrollOffset + speedRatio * dt * 8.0) % 1.0;

    // Convert speed (MPH) to meters/sec (1 MPH ≈ 0.44704 m/s)
    final distanceDelta = (player.speedMph * 0.44704) * dt;
    player.distanceTraveledMeters += distanceDelta;
    state.distanceMeters = player.distanceTraveledMeters;

    // 5. Update Score & Multipliers
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

    // 6. Spawn Obstacles with Section-based Difficulty Progression
    _spawnTimer += dt;
    final dynamicInterval = (_spawnInterval / activeSection.trafficDensityMultiplier - (state.distanceMeters / 6000.0) * 0.35).clamp(0.85, 2.2);
    if (_spawnTimer >= dynamicInterval) {
      _spawnTimer = 0.0;
      _spawnObstacle();
    }

    // 6. Update Obstacles & Check Collisions (Passing road curvature and elevation to bounding rects)
    final playerRect = player.getBoundingRect(screenWidth, screenHeight, currentCurvature, currentElevation);

    for (int i = obstacles.length - 1; i >= 0; i--) {
      final obstacle = obstacles[i];

      // Feature 10: Autonomous AI updates (safe-gap checks, braking, and lane transitions)
      obstacle.updateAI(dt, obstacles, lanes, player.lanePosition, player.speedMph);

      // Relative downward speed on screen:
      // Player moving faster makes obstacle approach player (yProgress increases)
      final relativeSpeed = math.max(20.0, player.speedMph - obstacle.speedMph + 30.0);
      obstacle.yProgress += (relativeSpeed / 100.0) * dt * 0.45;

      // Check collision if obstacle is near player's vertical zone
      if (!obstacle.hasCollided && obstacle.yProgress > 0.60 && obstacle.yProgress < 0.90) {
        final obstacleRect = obstacle.getBoundingRect(screenWidth, screenHeight, currentCurvature, currentElevation);
        if (playerRect.overlaps(obstacleRect)) {
          _handleCollision(obstacle, playerRect, obstacleRect);
        }
      }

      // Check near-miss overtaking bonus (Feature 10)
      if (!obstacle.hasCollided &&
          !obstacle.hasAwardedNearMiss &&
          obstacle.yProgress >= 0.88 &&
          obstacle.yProgress <= 0.96) {
        final lateralDist = (obstacle.lanePosition - player.lanePosition).abs();
        if (lateralDist >= 0.15 && lateralDist <= 0.52) {
          obstacle.hasAwardedNearMiss = true;
          state.nearMissCount++;
          final bonusScore = (250 * state.comboMultiplier).round();
          state.score += bonusScore;
          state.lastNearMissBonusScore = bonusScore;
          state.nearMissNotificationTimer = 1.2;

          // In Time Trial mode, award bonus time!
          if (state.gameMode == GameMode.timeTrial) {
            final bonus = GameModeInfo.timeTrial.nearMissBonusSeconds;
            state.timeRemainingSeconds += bonus;
            state.bonusTimeFlashTimer = 1.0;
          }

          _spawnNearMissSparks(playerRect.center, obstacle.lanePosition > player.lanePosition);
        }
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
    double baseSpeed;
    TrafficBehavior behavior;

    // Feature 10: Progression scaling based on track sector and distance
    final sectorDifficulty = (state.sectorIndex / 7.0).clamp(0.15, 1.0);
    final speedBoost = sectorDifficulty * 16.0;

    if (typeRoll < 0.38) {
      type = ObstacleType.cyberSedan;
      color = const Color(0xFF00E5FF); // Electric Cyan
      baseSpeed = 65.0 + _random.nextDouble() * 20.0 + speedBoost;
      if (_random.nextDouble() < (0.45 + sectorDifficulty * 0.40)) {
        behavior = _random.nextDouble() < sectorDifficulty * 0.5
            ? TrafficBehavior.aggressive
            : TrafficBehavior.laneChanger;
      } else {
        behavior = TrafficBehavior.cruiser;
      }
    } else if (typeRoll < 0.72) {
      type = ObstacleType.cyberTruck;
      color = const Color(0xFFFFB300); // Warning Amber
      baseSpeed = 50.0 + _random.nextDouble() * 15.0 + speedBoost * 0.8;
      behavior = _random.nextDouble() < 0.65 ? TrafficBehavior.speedAdjuster : TrafficBehavior.laneChanger;
    } else if (typeRoll < 0.88) {
      type = ObstacleType.heavyHauler;
      color = const Color(0xFF78909C); // Industrial Slate
      baseSpeed = 35.0 + _random.nextDouble() * 12.0 + speedBoost * 0.5;
      behavior = TrafficBehavior.cruiser;
    } else {
      type = ObstacleType.energyBarrier;
      color = const Color(0xFFFF1744); // Hazard Red
      baseSpeed = 0.0; // Stationary road hazard
      behavior = TrafficBehavior.hazard;
    }

    obstacles.add(ObstacleVehicle(
      id: 'obs_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
      type: type,
      color: color,
      lanePosition: chosenLane,
      yProgress: 0.05, // Spawn at horizon
      speedMph: baseSpeed,
      desiredSpeedMph: baseSpeed,
      behavior: behavior,
    ));
  }

  void _spawnNearMissSparks(Offset playerCenter, bool obstacleIsOnRight) {
    final lateralSign = obstacleIsOnRight ? 1.0 : -1.0;
    for (int i = 0; i < 8; i++) {
      final angle = (obstacleIsOnRight ? 0.0 : math.pi) + (_random.nextDouble() - 0.5) * 0.8;
      final speed = 60.0 + _random.nextDouble() * 120.0;
      particles.add(GameParticle(
        x: playerCenter.dx + lateralSign * 25.0,
        y: playerCenter.dy + (_random.nextDouble() - 0.5) * 30.0,
        vx: math.cos(angle) * speed,
        vy: -50.0 - _random.nextDouble() * 100.0,
        life: 1.0,
        maxLife: 0.28 + _random.nextDouble() * 0.18,
        size: 2.2 + _random.nextDouble() * 1.8,
        color: _random.nextBool() ? const Color(0xFF00E5FF) : const Color(0xFFFFB300),
        type: ParticleType.collisionSpark,
      ));
    }
  }

  void _handleCollision(ObstacleVehicle obstacle, Rect playerRect, Rect obstacleRect) {
    // If vehicle is in post-collision recovery, ignore subsequent damage frames
    if (player.collisionRecoveryTimer > 0.0) {
      return;
    }

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

    final effectiveDamage = damage * player.vehicle.damageMultiplier;
    player.health = math.max(0.0, player.health - effectiveDamage);
    // Progressive speed reduction with vehicle handling stabilization
    player.speedMph = math.max(minSpeed, player.speedMph * 0.65);
    // Dampen lateral velocity to stabilize vehicle after impact
    player.lateralVelocity *= 0.25;
    // Activate collision recovery window (0.85s)
    player.collisionRecoveryTimer = 0.85;

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
      state.gameOverReason = 'VEHICLE CRITICAL DAMAGE';
      if (state.score > state.highScore) {
        state.highScore = state.score;
      }
    }
  }

  void _spawnBoundarySparks(double sign, double screenWidth, double screenHeight) {
    final roadWidth = screenWidth * 0.72;
    final contactX = (screenWidth / 2) + (sign * (roadWidth / 2));
    final contactY = screenHeight * 0.75;

    for (int i = 0; i < 3; i++) {
      particles.add(GameParticle(
        x: contactX,
        y: contactY,
        vx: -sign * (40.0 + _random.nextDouble() * 90.0),
        vy: -30.0 - (_random.nextDouble() * 60.0),
        life: 1.0,
        maxLife: 0.22,
        size: 2.2,
        color: const Color(0xFFFF9100),
        type: ParticleType.collisionSpark,
      ));
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
