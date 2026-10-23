# Architecture Specification: Tesla Roadster 3D Simulation Platform

## 1. System Overview

This application is an Android-only 3D driving experience inspired by the Tesla Roadster electric hypercar concept. The platform utilizes a hybrid architecture combining:
1. **Flutter Host Layer**: Provides UI, menus, vehicle telemetry HUD, settings, navigation, and state management.
2. **Unity 3D Engine Subsystem**: Hosts the 3D rendering pipeline, procedural ground track, shaders, camera management, and vehicle dynamics.
3. **Versioned Communication Bridge (`v1.0.0`)**: Transmits bidirectional commands and real-time 10 Hz telemetry between Flutter and Unity over standard JSON schemas.

```
+-------------------------------------------------------------------------+
|                              FLUTTER HOST                               |
|                                                                         |
|   +-----------------------+                 +-----------------------+   |
|   |      HomeScreen       |                 |  GameViewportScreen   |   |
|   | (Hero, Specs, Status) |                 | (HUD, Pedals, Steering)|  |
|   +-----------+-----------+                 +-----------+-----------+   |
|               |                                         |               |
|               v                                         v               |
|   +-----------------------------------------------------------------+   |
|   |                     UnityBridgeService                          |   |
|   |         - State Machine (Disconnected, Connecting, Ready, Error)|   |
|   |         - Version Negotiation (v1.0.0)                          |   |
|   |         - Telemetry Aggregator (10 Hz)                          |   |
|   +-----------------------------------------------------------------+   |
|               ^                                                         |
|               | Android Lifecycle Observer (Paused, Resumed, Low Memory)|
+---------------|---------------------------------------------------------+
                |
                | Versioned JSON Bridge Protocol (v1.0.0)
                | (PlatformChannel / UnitySendMessage / Mock Bridge)
                v
+-------------------------------------------------------------------------+
|                         UNITY 3D ENGINE (Android)                       |
|                                                                         |
|   +-----------------------------------------------------------------+   |
|   |                           UnityBridge                           |   |
|   |    - OnFlutterMessage(json)                                     |   |
|   |    - UnityMessageManager.SendMessageToFlutter(json)             |   |
|   |    - Handshake, Ping/Pong, Lifecycle Hooks                      |   |
|   +-------------------+-----------------------------+---------------+   |
|                       |                             |                   |
|                       v                             v                   |
|   +-----------------------------+     +-----------------------------+   |
|   | PlaceholderVehicleController|     |    ChaseCameraController    |   |
|   | - Dynamics & Steering       |     | - Modes: Chase, Orbit,      |   |
|   | - Telemetry (Speed, Batt, G)|     |   Cockpit                   |   |
|   +-----------------------------+     +-----------------------------+   |
+-------------------------------------------------------------------------+
```

---

## 2. Directory & Package Structure

The repository follows a clean, feature-first modular architecture:

```
tesla_roadster_game/
├── android/                            # Android native Gradle project
│   ├── app/
│   │   ├── build.gradle.kts            # MinSdk 24, TargetSdk 35, ARM64 ABI, ProGuard
│   │   ├── proguard-rules.pro          # Flutter & Unity R8 keep rules
│   │   └── src/main/AndroidManifest.xml
│   ├── settings.gradle.kts             # Conditional unityLibrary Gradle inclusion
│   └── unityLibrary/                   # Target export folder for Unity Android Library
├── docs/                               # Project documentation
│   ├── ARCHITECTURE.md                 # System architecture (this document)
│   ├── FEATURE_PROGRESS.md             # Feature tracking & milestones
│   └── ASSET_LICENSES.md               # Legal disclaimers & asset licensing
├── lib/
│   ├── app/
│   │   ├── app.dart                    # MaterialApp & AndroidLifecycleObserver root
│   │   └── app_routes.dart             # Application navigation
│   ├── core/
│   │   ├── bridge/
│   │   │   ├── bridge_message.dart     # Immutable JSON-serializable message payload
│   │   │   ├── bridge_protocol.dart    # Protocol v1.0.0 action constants & timeouts
│   │   │   ├── unity_bridge_interface.dart # Abstract bridge contract
│   │   │   ├── mock_unity_bridge.dart  # Deterministic mock bridge for dev/emulator/CI
│   │   │   └── unity_bridge_service.dart # Central singleton service & telemetry buffer
│   │   ├── lifecycle/
│   │   │   └── android_lifecycle_observer.dart # OS pause/resume & low-memory handling
│   │   ├── theme/
│   │   │   ├── app_colors.dart         # Obsidian/Red/Cyan design tokens
│   │   │   ├── app_typography.dart     # Modern font styles & mono telemetry typography
│   │   │   └── app_theme.dart          # Dark theme configuration
│   │   └── widgets/
│   │       ├── cyber_button.dart       # High-fidelity glowing interactive button
│   │       ├── glass_card.dart         # Glassmorphic elevated container
│   │       └── status_badge.dart       # Status chip with pulsing LED glow
│   ├── features/
│   │   ├── home/
│   │   │   └── presentation/
│   │   │       ├── screens/home_screen.dart # Home menu, specs, play & test buttons
│   │   │       └── widgets/
│   │   │           ├── roadster_hero_banner.dart # Silhouette & brand banner
│   │   │           ├── quick_specs_row.dart      # Performance metric cards
│   │   │           └── system_status_card.dart   # Real-time Android runtime stats
│   │   └── game_viewport/
│   │       ├── domain/models/
│   │       │   ├── game_session_state.dart       # Phase, scenes, steps state
│   │       │   └── telemetry_data.dart           # Real-time vehicle physics model
│   │       └── presentation/
│   │           ├── controllers/game_viewport_controller.dart # Screen state manager
│   │           ├── screens/game_viewport_screen.dart         # Viewport coordinator
│   │           └── widgets/
│   │               ├── interactive_3d_viewport.dart # 3D perspective Canvas surface
│   │               ├── unity_loading_overlay.dart   # 4-stage initialization loader
│   │               ├── unity_error_overlay.dart     # Error view with Retry button
│   │               ├── unity_hud_overlay.dart       # Cockpit gauges & touch controls
│   │               └── bridge_debug_panel.dart      # Live JSON protocol inspector
│   └── main.dart                       # Entry point, orientation constraints
├── test/
│   └── widget_test.dart                # Automated UI and bridge unit/widget test suite
└── unity/
    └── TeslaRoadsterGame/              # Standalone Unity 2022.3 LTS Project
        ├── Assets/
        │   ├── Scenes/BootstrapScene.unity # Bootstrap scene with Camera, Track, Car
        │   ├── Scripts/
        │   │   ├── Bridge/             # BridgeProtocol, BridgeMessage, UnityBridge
        │   │   ├── Vehicle/            # PlaceholderVehicleController, CameraController
        │   │   └── Editor/BuildScript.cs # Automated Android Gradle library export
        │   └── Prefabs/                # PlaceholderRoadster.prefab
        ├── Packages/manifest.json      # Unity package dependencies
        └── ProjectSettings/            # Android bundle ID, minSdk 24, ARM64 target
```

---

## 3. Communication Bridge Protocol Specification (`v1.0.0`)

All communication between Flutter and Unity occurs through serialized JSON payloads conforming to `BridgeMessage`.

### 3.1 Message Schema
```json
{
  "version": "1.0.0",
  "action": "ACTION_NAME",
  "payload": { ... },
  "payloadJson": "{ ... }",
  "timestamp": 1729668000000
}
```

### 3.2 Protocol Sequence Flow

#### A. Handshake & Initialization
1. Flutter initiates handshake on surface bind:
   `{"action": "HANDSHAKE_SYN", "payload": {"platform": "android", "minSdk": 24}}`
2. Unity replies with capability acknowledgement:
   `{"action": "HANDSHAKE_ACK", "payload": {"unityVersion": "2022.3.20f1", "scene": "BootstrapScene", "renderApi": "Vulkan", "status": "READY"}}`
3. Unity confirms scene readiness:
   `{"action": "SCENE_LOADED", "payload": {"sceneName": "BootstrapScene", "status": "INITIALIZED"}}`
4. Unity confirms placeholder vehicle instantiation:
   `{"action": "VEHICLE_SPAWNED", "payload": {"vehicleId": "roadster_proto_01", "model": "Roadster"}}`

#### B. Heartbeat & Diagnostics
- Flutter emits periodic `PING` at 2-second intervals:
  `{"action": "PING", "payload": {"clientTs": 1729668000100}}`
- Unity responds with `PONG` containing engine metrics:
  `{"action": "PONG", "payload": {"fps": 60, "memoryMB": 145, "clientTs": 1729668000100, "serverTs": 1729668000116}}`

#### C. Real-Time Telemetry Stream (10 Hz)
Unity streams vehicle dynamics every 100ms:
```json
{
  "action": "TELEMETRY_UPDATE",
  "payload": {
    "speedMph": 118.5,
    "rpm": 9100,
    "batteryPercent": 96.8,
    "gear": "D",
    "gForce": 1.25,
    "motorTempC": 44.2,
    "steering": 0.15,
    "throttle": 0.80,
    "cameraMode": "CHASE",
    "color": "#E82127"
  }
}
```

#### D. Control Inputs
- **Drive Input**: `{"action": "DRIVE_INPUT", "payload": {"throttle": 1.0, "steering": -0.2, "brake": 0.0}}`
- **Camera View**: `{"action": "SET_CAMERA_MODE", "payload": {"mode": "ORBIT" | "CHASE" | "COCKPIT"}}`
- **Vehicle Finish**: `{"action": "SET_VEHICLE_COLOR", "payload": {"hexColor": "#00E5FF"}}`
- **Engine Pause/Resume**: `{"action": "PAUSE"}` / `{"action": "RESUME"}`

---

## 4. Android Platform & Gradle Configuration

### 4.1 SDK & Toolchain Requirements
- **Target OS**: Android Only (iOS builds explicitly disabled per constraints).
- **Minimum Android SDK**: API 24 (Android 7.0 Nougat). Required for Unity Vulkan / OpenGLES3 support.
- **Target / Compile SDK**: API 35 (Android 15).
- **Target Architectures**: `arm64-v8a` (Primary 64-bit production target), `armeabi-v7a` (32-bit fallback), `x86_64` (emulator development).
- **Java / JDK Version**: OpenJDK 17.
- **Android Gradle Plugin (AGP)**: 9.1.0 with Kotlin DSL (`build.gradle.kts`).

### 4.2 Unity Library Integration Mechanism
In `android/settings.gradle.kts`, the Unity exported Android library is conditionally included:
```kotlin
val unityLibraryDir = file("unityLibrary")
if (unityLibraryDir.exists()) {
    include(":unityLibrary")
    project(":unityLibrary").projectDir = unityLibraryDir
}
```
And in `android/app/build.gradle.kts`:
```kotlin
dependencies {
    if (findProject(":unityLibrary") != null) {
        implementation(project(":unityLibrary"))
    }
}
```
This decoupling ensures that developers and CI environments can compile, test, and run Flutter builds without failing if Unity has not yet been exported locally.

### 4.3 ProGuard / R8 Obfuscation & Keep Rules
Configured in `android/app/proguard-rules.pro`:
- Preserves Flutter embedding and plugin registrant classes.
- Preserves `com.unity3d.player.**` classes and interfaces.
- Suppresses warnings for optional Google Play Core SplitCompat classes.

---

## 5. Lifecycle Management & Memory Guarding

1. **Android Activity Pause/Resume**:
   - `AndroidLifecycleObserver` hooks into Flutter's `WidgetsBindingObserver`.
   - When the user backgrounds the application (`AppLifecycleState.paused`), `PAUSE` is transmitted across the bridge, freezing Unity time scale (`Time.timeScale = 0`) and stopping telemetry loops to prevent CPU/battery drain.
   - When foregrounded (`AppLifecycleState.resumed`), `RESUME` is transmitted, restoring frame rendering.
2. **Low Memory Handling**:
   - Flutter listens to `didHaveMemoryPressure()`.
   - Unity listens to `Application.lowMemory += OnLowMemory`.
   - On low memory, Unity invokes `Resources.UnloadUnusedAssets()` and garbage collection, emitting `MEMORY_WARNING` across the bridge.
3. **Session Teardown**:
   - Navigating away from `GameViewportScreen` disposes tickers, cancels telemetry timers, and calls `_bridgeService.disconnect()`.
