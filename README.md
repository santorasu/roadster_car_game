# Tesla Roadster 3D Simulator (Android Only)

[![Flutter](https://img.shields.io/badge/Flutter-3.47.7-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20Only%20(API%2024--35)-green.svg)](https://developer.android.com)
[![Unity](https://img.shields.io/badge/Unity-2022.3%20LTS-black.svg)](https://unity.com)
[![Protocol](https://img.shields.io/badge/Bridge%20Protocol-v1.0.0-red.svg)](docs/ARCHITECTURE.md)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](docs/ASSET_LICENSES.md)

An electric hypercar 3D driving game foundation inspired by the Tesla Roadster concept, built using a hybrid **Flutter** and **Unity 3D** architecture targeting **Android only**.

---

## Key Features

### 🔊 Feature 04: Game UI, Audio & Visual Effects Polish (Flutter Only)
- **Cyber Sports Car UI Design**: Glassmorphic dark styling, neon borders, custom telemetry badges, and consistent typography across Garage, HUD, Pause, Game Over, and Audio dialogs.
- **Dynamic Driving Visual Feedback**: Dynamic speedometer color transitions (Cyan < 115 MPH, Amber 115-180 MPH, Hyper Red > 180 MPH), instantaneous power output kW bar gauge, road surface motion grit, and warp speed streaks (> 85 MPH).
- **Critical Hull Alarm & Pulsing Shield**: Emergency red warning box and flashing bar when hull < 25%; concentric glowing shield rings during collision recovery.
- **Embedded Audio Engine**: Procedural 16-bit PCM WAV assets for BGM, electric motor acceleration/deceleration with dynamic pitch scaling (0.8x-1.9x), collision crunch, verge sparks, and UI button blips.
- **Comprehensive Audio Controls**: Interactive Audio modal with Master, Music, and SFX volume sliders, individual mute switches, and defaults restore accessible anywhere in the app.
- **Performance & Accessibility**: Isolated `RepaintBoundary` rendering layers, debounced audio triggers, throttled engine updates, and 48x48dp minimum touch target compliance.

### ⚡ Feature 03: Advanced Driving Controls & Handling (Flutter Only)
- **Smooth, Frame-Rate-Independent Steering**: Exponential lateral velocity smoothing (`1 - exp(-12 * dt)`) with realistic lateral inertia and natural auto-centering.
- **Electric Hypercar Torque Curve**: Progressive acceleration delivering ~95 MPH/s at low speeds, naturally tapering off against aerodynamic drag at 250 MPH.
- **Speed-Sensitive Steering Ratio**: Dynamic steering responsiveness scaling from 1.15 at low speeds to 0.45 at top speed, preventing twitchy oversteer at 250 MPH.
- **Road Boundary Containment**: Elastic counter-force, boundary friction dampening, verge contact sparks, and strict $[-1.0, 1.0]$ boundary clamping preventing player escape.
- **Collision Recovery Grace Window**: 0.85-second recovery window after obstacle impact with lateral velocity stabilization (`*= 0.25`) and visual cyan shield aura.
- **Multi-Touch Precision Controls**: Simultaneous steering, acceleration, and braking with independent pointer tracking via `flutter_screenutil`.

### 🏎️ Feature 02: Playable Arcade Driving Game (Flutter Only)
- **100% Pure Flutter Arcade Physics**: Zero Unity runtime dependency for instant, smooth 60 FPS gameplay on Android.
- **Pseudo-3D Perspective Road**: Custom canvas rendering with horizon vanishing depth, neon glowing road barriers, and scrolling lane stripes.
- **Original Cyber Roadster Supercar**: Procedural vector sports car art with dynamic headlights, brake light halos, high-speed blue thruster plumes, and roll angle tilt during steering.
- **Traffic Obstacles & Dynamic Collision**: Procedural obstacle spawning (Cyber Sedans, Cyber Trucks, Heavy Haulers, Energy Barriers) with bounding box collision detection and spark FX.
- **Responsive Android Touch Controls**: Multi-touch steering pads, regenerative braking pedal, and drive/boost accelerator scaled with `flutter_screenutil`.
- **Complete Arcade Game Loop**: Real-time telemetry HUD (speedometer, distance in KM, score & combo multiplier, hull integrity bar), interactive pause menu, game over screen with score tracking, and instant restart.

### 🔌 Feature 01: Hybrid Project Foundation & 3D Bridge (Preserved)
- **Clean Feature-First Architecture**: Structured into modular `core/` and `features/` (`home`, `arcade_driving`, `game_viewport`).
- **Versioned Communication Bridge (`v1.0.0`)**: Standardized JSON protocol supporting bidirectional handshake negotiation, heartbeat ping/pong, and 10 Hz telemetry.
- **Unity 3D Project Structure**: Standalone Unity 2022.3 LTS project at `unity/TeslaRoadsterGame/` with `BootstrapScene.unity`, placeholder vehicle prefab, and C# bridge scripts.
- **Android Runtime Integration**: Configured `minSdk = 24`, `targetSdk = 35`, ARM64 ABI, ProGuard/R8 rules, and Android lifecycle observers.

---

## Documentation Quick Links

- 📐 [Architecture Specification](docs/ARCHITECTURE.md) — Detailed system design, bridge protocol schemas, and Gradle configuration.
- 📋 [Feature Progress & Verification](docs/FEATURE_PROGRESS.md) — Acceptance criteria checklist, test reports, and build artifacts.
- ⚖️ [Asset Licenses & Legal Disclaimers](docs/ASSET_LICENSES.md) — Trademark attribution and MIT software licensing.

---

## Getting Started

### Prerequisites
- **Flutter SDK**: 3.24+ (Tested on 3.47.7 / Dart 3.13.5)
- **Android SDK**: API 35 (Android 15) with platform-tools and emulator
- **Java Development Kit**: OpenJDK 17
- **Target Device**: Android emulator or physical device with Android 7.0+ (API 24+)

### Run Analysis & Automated Tests
```bash
# Static analysis (0 errors, 0 warnings, 0 deprecations)
flutter analyze

# Automated widget, audio, handling, and bridge unit tests (32 passed)
flutter test
```

### Launch on Android Emulator or Device
```bash
# Verify connected Android target
flutter devices

# Run in debug mode
flutter run -d emulator-5554
```

---

## Build Commands

### Debug APK
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Production Release APK (with R8 ProGuard Optimization)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk (46.2 MB)
```

### Production Google Play App Bundle (AAB)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab (46.1 MB)
```

---

## Unity Project & Android Export Workflow

The Unity 3D project is located at:
```
unity/TeslaRoadsterGame/
```

### Exporting Unity as Android Library:
1. Open the project in **Unity 2022.3 LTS** (or Unity 6).
2. Ensure the Android Build Support module (with OpenJDK & Android NDK) is installed in Unity Hub.
3. In Unity Editor, click the top menu bar item:
   `Flutter` > `Export Android (Library)`
   *(Or run headless via command line)*:
   ```bash
   /Applications/Unity/Hub/Editor/2022.3.20f1/Unity.app/Contents/MacOS/Unity \
     -batchmode \
     -projectPath unity/TeslaRoadsterGame \
     -executeMethod TeslaRoadster.Editor.BuildScript.ExportAndroidLibrary \
     -quit
   ```
4. The script exports the Android library to `android/unityLibrary`.
5. `android/settings.gradle.kts` and `android/app/build.gradle.kts` automatically detect and link `:unityLibrary`.

---

## Verified Target

- **Device**: Android 15 (API 35) ARM64 Emulator (`emulator-5554`)
- **Display**: 1080 x 2400 (420 dpi)
- **Toolchain**: OpenJDK 17 + Android SDK 37.0.0 + Flutter 3.47.7

---

## Legal Disclaimer

*This project is an independent tribute simulation developed for technical demonstration and educational research. "Tesla", "Roadster", and related trademarks belong to Tesla, Inc.*
