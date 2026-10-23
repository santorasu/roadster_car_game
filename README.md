# Tesla Roadster 3D Simulator (Android Only)

[![Flutter](https://img.shields.io/badge/Flutter-3.47.7-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20Only%20(API%2024--35)-green.svg)](https://developer.android.com)
[![Unity](https://img.shields.io/badge/Unity-2022.3%20LTS-black.svg)](https://unity.com)
[![Protocol](https://img.shields.io/badge/Bridge%20Protocol-v1.0.0-red.svg)](docs/ARCHITECTURE.md)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](docs/ASSET_LICENSES.md)

An electric hypercar 3D driving game foundation inspired by the Tesla Roadster concept, built using a hybrid **Flutter** and **Unity 3D** architecture targeting **Android only**.

---

## Key Features in Feature 01

- **Clean Feature-First Architecture**: Structured into modular `core/` and `features/` (`home`, `game_viewport`) modules.
- **Minimal Home Screen**: Tesla Roadster cyber aesthetic with quick performance specs, real-time Android integration diagnostics, Play button, error simulation, and retry flow.
- **Versioned Communication Bridge (`v1.0.0`)**: Standardized JSON protocol supporting bidirectional handshake negotiation, heartbeat ping/pong, 10 Hz real-time telemetry streaming, steering/throttle/brake inputs, camera view cycling, and vehicle finish customization.
- **Unity 3D Project Structure**: Standalone Unity 2022.3 LTS project at `unity/TeslaRoadsterGame/` with `BootstrapScene.unity`, placeholder vehicle prefab, C# bridge scripts, and automated Android Gradle library export.
- **Android Runtime Integration**: Configured `minSdk = 24` (Android 7.0+ Nougat), `targetSdk = 35` (Android 15), ARM64 architecture, ProGuard/R8 rules, and Android activity lifecycle & memory observers.
- **Dual-Mode Bridge Adapter**: High-fidelity reactive bridge adapter enables interactive 3D simulation, HUD verification, error testing, and CI automated testing without requiring local multi-gigabyte Unity Editor binary compilation.

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

# Automated widget and bridge unit tests (5 passed)
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
