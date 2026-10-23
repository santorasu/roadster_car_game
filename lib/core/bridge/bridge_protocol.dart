/// Constants and specifications for the versioned Flutter-Unity bridge protocol.
class BridgeProtocol {
  BridgeProtocol._();

  static const String version = '1.0.0';

  // Handshake & Ping
  static const String actionHandshakeSyn = 'HANDSHAKE_SYN';
  static const String actionHandshakeAck = 'HANDSHAKE_ACK';
  static const String actionPing = 'PING';
  static const String actionPong = 'PONG';

  // Scene & Vehicle Lifecycle
  static const String actionLoadScene = 'LOAD_SCENE';
  static const String actionSceneLoaded = 'SCENE_LOADED';
  static const String actionSpawnVehicle = 'SPAWN_VEHICLE';
  static const String actionVehicleSpawned = 'VEHICLE_SPAWNED';

  // Controls & Configuration
  static const String actionSetCameraMode = 'SET_CAMERA_MODE';
  static const String actionSetVehicleColor = 'SET_VEHICLE_COLOR';
  static const String actionDriveInput = 'DRIVE_INPUT';
  static const String actionTelemetryUpdate = 'TELEMETRY_UPDATE';

  // Lifecycle & Diagnostics
  static const String actionPause = 'PAUSE';
  static const String actionResume = 'RESUME';
  static const String actionMemoryWarning = 'MEMORY_WARNING';
  static const String actionError = 'ERROR';

  // Timing thresholds
  static const Duration handshakeTimeout = Duration(seconds: 8);
  static const Duration pingInterval = Duration(seconds: 2);
}
