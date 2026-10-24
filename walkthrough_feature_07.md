# Walkthrough — Feature 07: Road Elevation & Career Progression

## Executive Summary
**Feature 07** brings vertical road elevation, dynamic gravity driving physics, persistent driver career progression, and comprehensive session summaries to the pure-Flutter Android arcade driving game. Built using the existing pseudo-3D `CustomPainter` canvas architecture without external 3D engines, it introduces smooth uphill and downhill road sections, guaranteed monotonic depth projection, zero hitbox drift, lightweight local storage via `shared_preferences`, 9 career milestone badges, and live reactive garage telemetry. All features from Features 01–06 (audio, controls, HUD, curved roads, scoring, pause, and collision recovery) are completely preserved.

---

## Live Android Verification (`emulator-5554`)

Visual output, elevation transitions, gravity acceleration, and storage persistence were verified live on an Android 15 (API 35, ARM64) emulator (`emulator-5554`, 1080x2400 display).

### Verification Artifacts & Screenshots

1. **Garage Dashboard Telemetry Card (Initial State)**:
   - File: `docs/screenshots/feature07_01_home_career.png`
   - Highlights: Initial state showing `DRIVER CAREER TELEMETRY`, `0/9 BADGES`, `HIGH SCORE 0`, `BEST DIST 0.0 KM`, `RECORD SPEED 0 MPH`.
2. **Uphill Driving in Sector 02 ("CYBER SWEEP")**:
   - File: `docs/screenshots/feature07_02_uphill_gameplay.png`
   - Highlights: Driving at 151 MPH with elevated horizon vanishing point, curved neon crash barriers, warp speed streaks, and perspective-scaled traffic roadster.
3. **Downhill Descent in Sector 03 ("GRID CONNECTOR")**:
   - File: `docs/screenshots/feature07_03_downhill_gameplay.png`
   - Highlights: High-speed downhill descent with gravity acceleration reaching 152 MPH and unlocking high-speed milestones.
4. **Game Over Session Summary & Milestone Badges**:
   - File: `docs/screenshots/feature07_04_game_over_summary.png`
   - Highlights: Complete post-run summary showing Final Score (28,933), Best Score (28,933), Distance (0.19 KM), Top Speed (95 MPH), Sector Reached (SEC 02: CYBER SWEEP), and newly unlocked badges (`TEST PILOT`, `HIGH ROLLER`).
5. **Garage Dashboard Reactive Update (Session 1)**:
   - File: `docs/screenshots/feature07_05_home_updated_records.png`
   - Highlights: Garage telemetry card reactively updated via `ValueNotifier` showing `2/9 BADGES`, `HIGH SCORE 28933`, `BEST DIST 0.2 KM`, `RECORD SPEED 95 MPH`.
6. **Cumulative Progression Update (Session 2)**:
   - File: `docs/screenshots/feature07_06_home_records_progressed.png`
   - Highlights: Cumulative career progression showing `4/9 BADGES`, `BEST DIST 0.5 KM`, and `RECORD SPEED 152 MPH` after the downhill run.

---

## Key Technical Implementations

### 1. Pseudo-3D Vertical Elevation Mathematics & Monotonicity
Classical pseudo-3D racing engines project road geometry through depth slices $t \in [0.0, 1.0]$, where $t=0.0$ is the horizon line and $t=1.0$ is the screen bottom directly beneath the vehicle bumper.

Vertical elevation displacement is applied using a quadratic decay function $(1 - t)^2$:
$$\Delta y(t) = -\text{elevationOffset} \times (h \times 0.12) \times (1 - t)^2$$

The absolute vertical position on screen $Y(t)$ is:
$$Y(t) = \text{horizonY} + (h - \text{horizonY}) \cdot t - \text{elevationOffset} \times (h \times 0.12) \times (1 - t)^2$$

#### Mathematical Proof of Monotonicity (Zero Slice Inversion)
To prevent road slices from overlapping or inverting when driving on steep hills:
$$\frac{dY}{dt} = (h - \text{horizonY}) + 2 \times \text{elevationOffset} \times (h \times 0.12) \times (1 - t)$$

Given $\text{horizonY} \approx 0.18h$ (so $h - \text{horizonY} \approx 0.82h$) and maximum elevation $|\text{elevationOffset}| \le 1.0$:
$$\min_{t \in [0, 1]} \frac{dY}{dt} \ge 0.82h - 2(1.0)(0.12h) = 0.82h - 0.24h = 0.58h > 0$$

Because $\frac{dY}{dt} > 0$ strictly holds for all $t \in [0, 1]$, road slices are strictly ordered from top to bottom with zero visual singularities or artifacts.

### 2. 7-Sector Track Elevation Profiles & Smooth Transitions
Each sector in the 3,000-meter loop has a dedicated elevation and curvature profile:

| Sector | Name | Distance | Curvature | Elevation Type | Target Elevation |
| :---: | :--- | :---: | :---: | :---: | :---: |
| **01** | Neon Boulevard | 0m – 100m | Straight (0.0) | Flat | 0.00 |
| **02** | Cyber Sweep | 100m – 400m | Gentle Right (+0.35) | Gentle Uphill | +0.25 |
| **03** | Grid Connector | 400m – 700m | Straight (0.0) | Gentle Downhill | -0.35 |
| **04** | Pulse Highway | 700m – 1100m | Sweeping Left (-0.50) | Steep Uphill | +0.55 |
| **05** | Data Chicane | 1100m – 1500m | S-Curve ($\pm 0.45$) | Undulating | $\pm 0.40$ (Sinusoid) |
| **06** | Circuit Overpass | 1500m – 2000m | Sweeping Right (+0.60) | Steep Overpass | +0.65 |
| **07** | Hyperdrive Matrix | 2000m – 3000m | Straight / Gentle Left | Steep Downhill | -0.75 |

Elevation transitions use cubic smoothstep interpolation:
$$\text{smoothstep}(u) = 3u^2 - 2u^3, \quad u \in [0, 1]$$
And undulating rollercoaster sections use sinusoidal oscillation:
$$\text{elevation}(d) = \text{targetElevation} \times \sin(3\pi u)$$

### 3. Depth-Accurate Hitbox & Perspective Alignment (Zero Drift)
To ensure collision hitboxes exactly match the rendered road and vehicles:
- `PlayerCar.getBoundingRect(w, h, curveOffset, elevationOffset)` computes:
  $$\Delta y = -\text{elevationOffset} \times (h \times 0.12) \times (1 - t_{\text{car}})^2$$
- `ObstacleVehicle.getBoundingRect(w, h, curveOffset, elevationOffset)` computes:
  $$\Delta y = -\text{elevationOffset} \times (h \times 0.12) \times (1 - t_{\text{obs}})^2$$
- `ArcadeRoadPainter`, `ArcadeCarPainter`, and `ArcadeObstaclePainter` project geometry using the identical formula, guaranteeing zero hitbox drift regardless of elevation or curvature.

### 4. Driving Physics: Elevation-Based Gravity & Pitch
- **Gravity Acceleration / Resistance**:
  $$a_{\text{gravity}} = -\text{elevation} \times (16.0\text{ on downhill or }14.0\text{ on uphill}) \text{ MPH/s}$$
  When descending downhills, gravity accelerates the car naturally (reaching 150+ MPH), while uphill grades apply realistic mechanical resistance.
- **Visual Pitch Scaling**:
  The vehicle sprite dynamically compresses or elongates vertically based on road pitch:
  $$\text{scaleY} = 1.0 - \text{elevationOffset} \times 0.05$$

### 5. Persistent Career Records & Lightweight Storage
- Built using `shared_preferences: ^2.5.6` with a decoupled `PlayerDataStorage` interface:
  - `SharedPreferencesPlayerDataStorage`: Production implementation for Android runtime.
  - `InMemoryPlayerDataStorage`: Hermetic in-memory storage for deterministic unit and widget testing.
- Tracks:
  - High Score (integer)
  - Best Distance (meters / KM)
  - Top Speed (MPH)
  - Total Races (count)
  - Sectors Cleared (count)
  - 9 Unlocked Career Milestone Badges
  - Audio Settings (Master, Music, SFX volumes and mute switches)
- **9 Career Milestones**:
  1. `initiation`: TEST PILOT (Completed first simulation run)
  2. `century`: CENTURY CLUB (Exceeded 100 MPH driving speed)
  3. `warp_speed`: WARP VELOCITY (Pushed hypercar beyond 150 MPH)
  4. `hyperdrive`: HYPERDRIVE (Achieved 200+ MPH top speed)
  5. `endurance`: ENDURANCE TIER I (Traveled over 1,000m in one run)
  6. `circuit_master`: CIRCUIT MASTER (Completed full 3,000m loop)
  7. `high_roller`: HIGH ROLLER (Scored over 25,000 points)
  8. `cyber_legend`: CYBER LEGEND (Scored over 50,000 points)
  9. `overpass_climber`: OVERPASS CLIMBER (Traveled over 1,500m across elevated bridges)
- **Reactive UI Synchronization**:
  `PlayerDataService` exposes `changeNotifier` (`ValueNotifier<int>`). Whenever a run finishes or records are saved, `PlayerDataService.notifyDataChanged()` triggers immediate re-renders of the garage telemetry card without requiring app restarts or manual reloads.

---

## Verification Summary

### 1. Static Analysis
```bash
flutter analyze
# Analyzing tesla_roadster_game...
# No issues found! (ran in 2.2s)
```

### 2. Automated Test Suite (66 Tests Passing across 7 Files)
```bash
flutter test
# 00:03 +66: All tests passed!
```
- `test/elevation_and_career_test.dart` (18 new tests):
  - Elevation transitions and cubic smoothstep easing
  - Road depth monotonicity proof ($\frac{dY}{dt} > 0$ for all $t$)
  - S-Curve undulating sinusoidal oscillation
  - Player and obstacle hitbox alignment with zero elevation drift
  - Gravity acceleration on downhills and gravity resistance on uphills
  - Vehicle visual pitch scaling
  - Storage serialization and deserialization
  - `InMemoryPlayerDataStorage` session recording and milestone unlocking
  - Audio settings persistence
  - Session summary dialog UI with badges and metrics
  - Reactive `CareerRecordsCard` updates via `ValueNotifier`
- `test/dynamic_roads_test.dart` (11 tests passed)
- `test/handling_physics_test.dart` (8 tests passed)
- `test/audio_and_polish_test.dart` (10 tests passed)
- `test/visuals_enhanced_test.dart` (5 tests passed)
- `test/arcade_driving_test.dart` (9 tests passed)
- `test/widget_test.dart` (5 tests passed)

### 3. Android Build Status
```bash
flutter build apk --debug
# Running Gradle task 'assembleDebug'... 7.3s
# ✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

---

## Known Limitations & Constraints
- **Platform Scope**: Android-only (`minSdk = 24`, `targetSdk = 35`, ARM64).
- **Rendering Architecture**: Pure Flutter `CustomPainter` canvas rendering. Honestly described as pseudo-3D rasterization rather than a true polygonal 3D pipeline.
- **Preservation**: All Features 01–06 (Unity 3D bridge foundation, arcade driving engine, audio effects, cyber car visuals, curved roads, HUD) remain fully intact and operational.
- **Feature Boundary**: Feature 08 has not been started.
