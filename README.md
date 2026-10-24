# Tesla Roadster 3D Simulator (Android Only)

[![Flutter](https://img.shields.io/badge/Flutter-3.47.7-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20Only%20(API%2024--35)-green.svg)](https://developer.android.com)
[![Unity](https://img.shields.io/badge/Unity-2022.3%20LTS-black.svg)](https://unity.com)
[![Protocol](https://img.shields.io/badge/Bridge%20Protocol-v1.0.0-red.svg)](docs/ARCHITECTURE.md)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](docs/ASSET_LICENSES.md)

An electric hypercar 3D driving game foundation inspired by the Tesla Roadster concept, built using a hybrid **Flutter** and **Unity 3D** architecture targeting **Android only**.

---

## Key Features

### ⏱️ Feature 09: Game Modes, Missions & Challenges (Flutter Only)
- **Two Distinct Playable Game Modes**:
  - **Endless Drive**: Classic survival mode where the driver navigates dynamic road curves, rolling elevations, and highway traffic to survive as long as possible while accumulating maximum combo multipliers, score, and distance until hull integrity depletion.
  - **Time Trial (60s)**: High-intensity sprint against a 60-second countdown clock to maximize distance traveled. Near-miss overtaking maneuvers dynamically award **+1.5s time extensions** with an on-screen bonus flash, challenging drivers to balance aggressive weaving against crash risk.
- **Career Missions & Directives System**:
  - **8 Distinct Objectives** across 6 challenge archetypes:
    - `FIRST LAUNCH`: Travel 500 meters in a single run (+1,000 PTS)
    - `VELOCITY BREAKER`: Exceed 170 MPH (+1,500 PTS)
    - `GHOST DRIFT`: Clean driving 400 meters with zero vehicle collisions (+2,000 PTS)
    - `ENDURANCE TEST`: Survive on the highway for at least 40 continuous seconds (+1,500 PTS)
    - `HAZARD SLICER`: Execute 4 close near-miss overtakes through traffic (+2,500 PTS)
    - `CHRONO SPRINTER`: Cover at least 800 meters in Time Trial mode before time expires (+3,000 PTS)
    - `CIRCUIT OVERLOAD`: Travel 1,800 meters through highway curves and elevations (+3,500 PTS)
    - `FLAWLESS VECTOR`: Immaculate driving for 800 meters with zero collisions (+5,000 PTS)
- **Real-Time Evaluation & In-Run Feedback**: Real-time evaluation during active gameplay; immediate HUD toast banner notification upon objective completion (`MISSION COMPLETED: <TITLE> (+<PTS> PTS)`); duplicate reward prevention guaranteed at storage level.
- **Mode-Specific Results & Summary**: Enhanced Game Over recap displaying mode badges (`ENDLESS DRIVE` vs `TIME TRIAL`), termination reason (`TIME EXPIRED` or `VEHICLE CRITICAL DAMAGE`), distance covered, survival time, near-miss overtakes count, final score, top speed, and newly completed mission cards with reward point accumulation.
- **Career Missions Sheet & Home Mode Selector**:
  - `GameModeSelector` on Home Screen with interactive mode cards, mode rules, personal records, and quick access to missions.
  - `MissionsSheet` modal bottom sheet displaying overall progress (`COMPLETED X / 8`, `REWARD POINTS Y PTS`), mission cards, requirements, and `CLAIMED` status badges.
- **Full Architecture Persistence**: Seamless integration with local `PlayerDataStorage` preserving game mode preference, Time Trial best distance, completed mission IDs, and earned reward points without backend dependencies or cloud accounts.

### 🚗 Feature 08: Garage, Car Selection & Customization (Flutter Only)
- **3 Distinct Fictional Electric Sports Cars**:
  - **Cyber Roadster (Prototype 01)**: Balanced all-rounder with sculpted teardrop canopy, dual-motor instant torque, and active aerodynamic stabilization (Top Speed: 250 MPH, Accel: 1.00x, Handling: 1.00x, Durability: Standard 1.00x). Unlocked by default.
  - **Apex GT-E (Valkyrie Aero)**: Extreme Le Mans-style circuit prototype engineered with front splitter downforce, dual keel vents, central shark fin, and GT3 swan-neck rear wing (Top Speed: 242 MPH, Accel: +15% Torque surge, Handling: +18% Lateral agility, Durability: -25% Lightweight frame). Unlocked via `century` milestone (100+ MPH).
  - **Hyperion Phantom (Titan Edition)**: Armored high-velocity interceptor featuring faceted stealth wedge armor, wide rear fenders, cooling louvers, and heavy airbrake flap (Top Speed: 268 MPH, Accel: -12% Torque off the line, Handling: -12% Heavier turning, Durability: +32% Kinetic armor absorption). Unlocked via `warp_speed` milestone (150+ MPH).
- **Interactive Showroom Turntable Preview**: High-detail procedural `CustomPainter` rendering each car variant on an animated 3D turntable with ambient spotlight, concentric glowing floor rings, ground shadows, and underglow emission.
- **Three-Tier Customization System**:
  - **Body Paint**: 6 metallic multi-stop gradient palettes (Cyber Crimson, Electric Cyan, Stealth Obsidian, Acid Pulse, Solar Flare, Neon Violet) with milestone unlocks.
  - **Wheel Rims**: 4 procedural wheel designs (Aero Turbine blades, Cyber Disc flat aero wheels, Starfire Split 5-spoke alloys, Carbon Lattice hexagonal mesh) with custom brake calipers.
  - **Neon Underglow**: 6 ground lighting effects (Cyber Cyan, Laser Red, Acid Green, Pulse Violet, Solar Amber, Stealth Off) with soft floor emission shaders.
- **Direct Gameplay Stat Integration**: Selected vehicle chassis dynamically scales `topSpeed`, progressive acceleration torque in `computeAccelerationRate`, lateral lane transitions in `baseSteeringSpeed`, and collision damage scaling in `_handleCollision`.
- **Persistent Player Selections**: All equipped vehicles and accessories persist across sessions via lightweight local `PlayerDataStorage` (`shared_preferences`), automatically loading into arcade runs.

### 🏔️ Feature 07: Road Elevation & Career Progression (Flutter Only)
- **Pseudo-3D Vertical Road Elevation**: Smooth uphill and downhill gradients integrated with custom canvas rendering. Utilizes cubic smoothstep transitions ($3t^2 - 2t^3$) and undulating sinusoidal elevation curves, shifting road slices and vanishing points while strictly maintaining monotonic depth ($\frac{dY}{dt} > 0$).
- **Perspective Hitbox & Scenery Alignment**: Road markings, barriers, scenery, traffic vehicles, and player vehicle calculate vertical position via an identical quadratic formula ($\Delta y = -\text{elevationOffset} \times (h \times 0.12) \times (1 - t)^2$). Bounding hitboxes track visual geometry across all elevation changes with zero drift.
- **Elevation-Based Driving Feel & Physics**: Subtle vehicle pitch scaling ($1.0 - \text{elevationOffset} \times 0.05$) and elevation-responsive gravity acceleration ($a_{\text{gravity}} = -\text{elevation} \times (14.0\text{ or }16.0)$ MPH/s). Downhills naturally accelerate the hypercar beyond 150+ MPH, while uphills create authentic resistance without breaking steering or collision recovery.
- **7-Sector Elevation Track System**: Every sector on the 3,000-meter course features dedicated elevation profiles (Flat Boulevard, Gentle Uphill sweep, Downhill connector, Steep Uphill canyon, Undulating rollercoaster chicane, Steep Overpass ascent, Steep Downhill hyperspace plunge) with dynamic HUD trend indicators.
- **Persistent Career Records & Lightweight Storage**: Persistent driver profile powered by `shared_preferences` tracking High Score, Best Distance (KM), Top Speed (MPH), Total Races, Sectors Cleared, 9 Career Milestone Badges, and audio volume/mute preferences.
- **Session Summary & Live Garage Telemetry**: Comprehensive game-over recap displaying score, best score, distance, top speed, sector achievements, and newly unlocked milestone badges. Live garage telemetry card updates reactively via `ValueNotifier`.

### 🛣️ Feature 06: Dynamic Roads & Advanced Gameplay (Flutter Only)
- **Pseudo-3D Curved Roads**: Smooth left and right dynamic road curvature based on quadratic depth perspective $(1 - t)^2$. The road curves naturally from the player's bumper towards the distant horizon.
- **Continuous Road Transitions**: Gradual curve entry, sustained turns, and smooth return to straight roads using cubic smoothstep interpolation ($3t^2 - 2t^3$) with zero visual snapping or camera jerking.
- **Aligned Environmental Effects**: Sliced road asphalt polygon, multi-segment road shoulders, red/white/cyan rumble kerb strips, continuous glowing neon barriers, dashed lane dividers, reflective cat's-eye studs, and overhead gantry arches curve seamlessly with road geometry. Sky parallax counter-shifts inversely for enhanced depth.
- **Dynamic Driving Physics & Centrifugal Drift**: Lateral physics apply realistic centrifugal force ($a_{\text{centrifugal}} = -\text{curvature} \times \frac{v}{v_{\text{max}}} \times 1.60$) requiring driver counter-steering on high-speed curves. Vehicle roll tilt combines steering input with road banking.
- **Arcade Sector Progression System**: 7 distinct track sectors over a 3,000-meter course (Neon Boulevard, Cyber Sweep, Hyperflux Connector, Pulse Highway, Data Chicane S-curve, Circuit Overpass, Hyperdrive Matrix) with distance-based difficulty scaling, traffic density multipliers, and sector completion score bonuses.
- **Dynamic HUD Sector Notification**: Sleek glowing cyan HUD announcement banner with directional turn indicators appearing during sector transitions.
- **Depth-Accurate Hitbox Alignment**: Player and obstacle AABB hitboxes are computed using the identical depth-shifted perspective curve formulas, guaranteeing 100% collision precision without visual desynchronization.

### 🎨 Feature 05: Enhanced Car & Road Visuals (Flutter Only)
- **Detailed Roadster Artwork**: Supercar proportions with flared wheel arches, coke-bottle waistline, carbon aero splitter/skirts/diffuser, 4 visible performance tires with brake calipers, tinted glass canopy with cockpit yoke silhouette, laser projector headlights with cyan DRL ribbons, full-width taillight blade, active spoiler, and underglow ground illumination.
- **Richer Road Environment**: Multi-segment road shoulders, alternating high-contrast red/white and cyan rumble kerbs, 3D guardrail posts with continuous neon crash barriers, scrolling overhead streetlamp gantries casting downward illumination pools, and dashed lane dividers with drop-shadows and reflective amber cat's-eye road studs.
- **Procedural Cyberpunk Scenery**: Multi-tier parallax skyline featuring distant pyramids/monoliths, midground illuminated skyscrapers with blinking antenna beacons, horizon atmospheric neon haze, starfield, and perspective off-road terrain grid with zero external bitmap assets.
- **Upgraded Traffic Vehicles**: 4 distinct obstacle archetypes with soft contact ground shadows and visible wheels: aerodynamic **Cyber Sedan**, faceted stainless-steel **Cyber Truck**, 8-wheel articulated **Heavy Hauler** with hazard chevrons, and dual-pylon **Energy Barrier** with animated plasma lightning arcs.
- **Speed-Responsive FX**: Dynamic horizon haze, high-speed warp streaks (> 85 MPH), and peripheral tunnel-vision vignette (> 160 MPH) that smoothly scale with car speed.

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

# Automated widget, audio, handling, visual, dynamic road, and elevation/career unit tests (66 passed across 7 suites)
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
