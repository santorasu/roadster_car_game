enum ArcadeGameStatus {
  ready,
  playing,
  paused,
  gameOver,
}

class ArcadeGameState {
  ArcadeGameStatus status;
  int score;
  int highScore;
  double distanceMeters;
  double topSpeedMph;
  double comboMultiplier;
  int collisionsCount;
  double screenShakeIntensity;
  String currentSectorName;
  double currentCurvature;
  double currentElevation;
  double sectorNotificationTimer;
  int sectorIndex;

  ArcadeGameState({
    this.status = ArcadeGameStatus.ready,
    this.score = 0,
    this.highScore = 0,
    this.distanceMeters = 0.0,
    this.topSpeedMph = 0.0,
    this.comboMultiplier = 1.0,
    this.collisionsCount = 0,
    this.screenShakeIntensity = 0.0,
    this.currentSectorName = 'NEON HIGHWAY',
    this.currentCurvature = 0.0,
    this.currentElevation = 0.0,
    this.sectorNotificationTimer = 0.0,
    this.sectorIndex = 1,
  });

  void reset() {
    status = ArcadeGameStatus.ready;
    score = 0;
    distanceMeters = 0.0;
    topSpeedMph = 0.0;
    comboMultiplier = 1.0;
    collisionsCount = 0;
    screenShakeIntensity = 0.0;
    currentSectorName = 'NEON HIGHWAY';
    currentCurvature = 0.0;
    currentElevation = 0.0;
    sectorNotificationTimer = 0.0;
    sectorIndex = 1;
  }
}
