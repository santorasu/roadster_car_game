import 'dart:ui';

/// Player car physics and state for the arcade driving prototype.
class PlayerCar {
  /// Normalized horizontal position on the road (-1.0 = left edge, 1.0 = right edge)
  double lanePosition;

  /// Current speed in miles per hour (MPH)
  double speedMph;

  /// Steering velocity (-1.0 steer left, 1.0 steer right)
  double steerInput;

  /// Player vehicle hull integrity (1.0 = 100%, 0.0 = destroyed)
  double health;

  /// Battery level (percentage 0.0 to 1.0)
  double batteryLevel;

  /// Throttle and brake active states
  bool isAccelerating;
  bool isBraking;

  /// Visual tilt/roll angle during steering (radians)
  double rollAngle;

  /// Dynamic lateral drift velocity (-1.0 to 1.0/s) for smooth inertia
  double lateralVelocity;

  /// Post-collision recovery/invulnerability timer (seconds)
  double collisionRecoveryTimer;

  /// Whether the vehicle is currently brushing against the road boundary
  bool isAtRoadBoundary;

  /// Distance traveled in meters
  double distanceTraveledMeters;

  /// Top speed achieved during this run
  double topSpeedMph;

  PlayerCar({
    this.lanePosition = 0.0,
    this.speedMph = 0.0,
    this.steerInput = 0.0,
    this.health = 1.0,
    this.batteryLevel = 1.0,
    this.isAccelerating = false,
    this.isBraking = false,
    this.rollAngle = 0.0,
    this.lateralVelocity = 0.0,
    this.collisionRecoveryTimer = 0.0,
    this.isAtRoadBoundary = false,
    this.distanceTraveledMeters = 0.0,
    this.topSpeedMph = 0.0,
  });

  /// Reset vehicle state for a new run
  void reset() {
    lanePosition = 0.0;
    speedMph = 0.0;
    steerInput = 0.0;
    health = 1.0;
    batteryLevel = 1.0;
    isAccelerating = false;
    isBraking = false;
    rollAngle = 0.0;
    lateralVelocity = 0.0;
    collisionRecoveryTimer = 0.0;
    isAtRoadBoundary = false;
    distanceTraveledMeters = 0.0;
    topSpeedMph = 0.0;
  }

  /// Calculates the 2D bounding rectangle in screen coordinates
  Rect getBoundingRect(double screenWidth, double screenHeight) {
    // Road center is middle of screen width
    final roadWidth = screenWidth * 0.72;
    final carWidth = roadWidth * 0.17;
    final carHeight = carWidth * 1.95;

    final centerX = (screenWidth / 2) + (lanePosition * (roadWidth / 2 - carWidth * 0.6));
    final centerY = screenHeight * 0.75;

    return Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: carWidth * 0.85, // Slightly forgiving hitbox for arcade fun
      height: carHeight * 0.85,
    );
  }
}
