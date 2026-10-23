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

  ArcadeGameState({
    this.status = ArcadeGameStatus.ready,
    this.score = 0,
    this.highScore = 0,
    this.distanceMeters = 0.0,
    this.topSpeedMph = 0.0,
    this.comboMultiplier = 1.0,
    this.collisionsCount = 0,
    this.screenShakeIntensity = 0.0,
  });

  void reset() {
    status = ArcadeGameStatus.ready;
    score = 0;
    distanceMeters = 0.0;
    topSpeedMph = 0.0;
    comboMultiplier = 1.0;
    collisionsCount = 0;
    screenShakeIntensity = 0.0;
  }
}
