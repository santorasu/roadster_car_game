import 'package:flutter/foundation.dart';

enum GamePhase {
  uninitialized,
  initializing,
  ready,
  driving,
  paused,
  error,
}

@immutable
class GameSessionState {
  final GamePhase phase;
  final String? errorMessage;
  final String currentScene;
  final String activeVehicle;
  final int initializationStep;
  final String stepDescription;

  const GameSessionState({
    this.phase = GamePhase.uninitialized,
    this.errorMessage,
    this.currentScene = 'None',
    this.activeVehicle = 'None',
    this.initializationStep = 0,
    this.stepDescription = 'Idle',
  });

  GameSessionState copyWith({
    GamePhase? phase,
    String? errorMessage,
    String? currentScene,
    String? activeVehicle,
    int? initializationStep,
    String? stepDescription,
  }) {
    return GameSessionState(
      phase: phase ?? this.phase,
      errorMessage: errorMessage ?? this.errorMessage,
      currentScene: currentScene ?? this.currentScene,
      activeVehicle: activeVehicle ?? this.activeVehicle,
      initializationStep: initializationStep ?? this.initializationStep,
      stepDescription: stepDescription ?? this.stepDescription,
    );
  }
}
