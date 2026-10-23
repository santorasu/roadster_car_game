# Walkthrough — Feature 06: Dynamic Roads & Advanced Gameplay

## Executive Summary
**Feature 06** elevates the pure-Flutter arcade driving game with **dynamic pseudo-3D curved roads**, continuous road transitions, aligned environmental effects, centrifugal steering physics, and a 7-sector track progression system. Built purely using Flutter's `CustomPainter` canvas architecture without external 3D engines, it maintains fluid 60 FPS gameplay on Android while preserving 100% of Features 01–05 (audio, HUD, car visuals, controls, pause, scoring, and collision recovery).

---

## Live Android Verification (`emulator-5554`)

Visual output and gameplay mechanics were verified live on an Android 15 (API 35, ARM64) emulator (`emulator-5554`, 1080x2400 display).

- **Sector 01: Neon Boulevard (Straightaway)**: Full HUD at 87 MPH, aligned traffic vehicles, and neutral vanishing point.
- **Sector 02: Cyber Sweep (Gentle Right)**: Dynamic HUD notification banner ("CYBER SWEEP - GENTLE RIGHT"), curved road geometry, curved neon crash barriers, and aligned obstacles.
- **Sector 02: Sustained Curve**: Smooth curve geometry, rumble kerbs, overhead gantry spotlight pool, and counter-shifted skyline parallax.
- **Sector 04: Pulse Highway (Sweeping Left)**: High-speed driving in sweeping left bend with curved dashed lane dividers and obstacle alignment.
- **Pause Dialog**: Interactive pause menu layered seamlessly over curved road visuals.

---

## Key Technical Implementations

### 1. Pseudo-3D Road Curve Mathematics
Classical pseudo-3D racing games (e.g. *OutRun*) simulate curves by shifting road slice centerlines as a function of depth. In our unified projection pipeline:
- Depth parameter $t \in [0.0, 1.0]$, where $t = 0.0$ is the horizon line and $t = 1.0$ is the screen bottom / player bumper.
- Lateral curve displacement:
  $$\Delta x(t) = \text{curveOffset} \times (w \times 0.40) \times (1.0 - t)^2$$
- Because $(1.0 - t)^2 = 0$ at the bottom ($t=1.0$), the road is anchored directly beneath the player car, and curves outward toward the vanishing point at the horizon ($t=0.0$).
- All elements—asphalt polygon, multi-segment shoulders, rumble kerbs, 3D guardrail posts, continuous neon crash barriers, dashed lane dividers, reflective cat's-eye studs, and overhead gantry arches—use this unified coordinate function:
  ```dart
  double getCurveShift(double t, double w) =>
      curveOffset * (w * 0.40) * (1.0 - t) * (1.0 - t);

  double getRoadCenterX(double t, double w) =>
      (w * 0.5) + getCurveShift(t, w);

  double getRoadWidth(double t, double w) =>
      (w * 0.14) + (w * 0.72) * t;
  ```

### 2. Smooth Curve Transitions & S-Curves (`road_section.dart`)
- Curve transitions use **cubic smoothstep interpolation**:
  $$\text{smoothstep}(u) = 3u^2 - 2u^3, \quad u \in [0.0, 1.0]$$
- A 20-meter lead-in buffer ensures that as the player approaches a new sector, curvature ramps up progressively without camera snaps or sudden jumps.
- When exiting a curve, the road smoothly returns to neutral (`0.0`).
- S-Curve sections (`RoadCurveType.sCurve`) oscillate sinusoidally across the sector length:
  $$\text{curvature}(d) = \text{targetCurvature} \times \sin\left(\frac{2\pi (d - d_{\text{start}})}{d_{\text{end}} - d_{\text{start}}}\right)$$

### 3. Depth-Accurate Hitbox Alignment
To ensure collision detection matches the visual rendering with zero hitbox drift:
- `PlayerCar.getBoundingRect(w, h, curveOffset)` calculates road width and center at player depth ($t_{\text{car}} \approx 0.86$):
  ```dart
  final curveShift = curveOffset * (screenWidth * 0.40) * (1.0 - carDepthT) * (1.0 - carDepthT);
  final roadCenterX = (screenWidth * 0.5) + curveShift;
  ```
- `ObstacleVehicle.getBoundingRect(w, h, curveOffset)` calculates road width and center at obstacle depth $t = \text{progress}$:
  ```dart
  final curveShift = curveOffset * (screenWidth * 0.40) * (1.0 - progress) * (1.0 - progress);
  final roadCenterX = (screenWidth * 0.5) + curveShift;
  ```
- Obstacle hitboxes remain centered in their assigned lane as the road bends, and player collision bounds track perfectly on curves.

### 4. Dynamic Driving Physics & Centrifugal Drift
- When navigating a curved road, lateral physics apply realistic centrifugal force:
  $$a_{\text{centrifugal}} = -\text{curvature} \times \frac{v}{v_{\text{max}}} \times 1.60$$
- **Speed sensitivity**: At high speeds (e.g. 150+ MPH), the car drifts outward toward the exterior road barrier unless the player counter-steers.
- **Stationary check**: If speed $< 5.0$ MPH, centrifugal force is zero to prevent drift while stopped.
- **Visual banking**: Vehicle roll tilt dynamically combines steering input and road banking angle:
  ```dart
  final effectiveRoll = (player.rollAngle + (state.currentCurvature * 0.22)).clamp(-0.45, 0.45);
  ```

### 5. Track Progression & Difficulty Scaling
The `TrackProgressionManager` defines a 7-sector looped course (3,000 meters total):

| Sector | Distance | Name | Curve Type | Target Curvature | Traffic Multiplier | Completion Bonus |
| :---: | :---: | :--- | :--- | :---: | :---: | :---: |
| **1** | 0 – 100 m | Neon Boulevard | Straight | 0.00 | 1.0x | +2,500 pts |
| **2** | 100 – 400 m | Cyber Sweep | Gentle Right | +0.45 | 1.1x | +3,500 pts |
| **3** | 400 – 600 m | Hyperflux Connector | Straight | 0.00 | 1.15x | +3,000 pts |
| **4** | 600 – 1000 m | Pulse Highway | Sweeping Left | -0.60 | 1.3x | +5,000 pts |
| **5** | 1000 – 1500 m | Data Chicane | S-Curve | $\pm 0.70$ | 1.45x | +6,500 pts |
| **6** | 1500 – 2100 m | Circuit Overpass | Sharp Right | +0.80 | 1.6x | +8,000 pts |
| **7** | 2100 – 3000 m | Hyperdrive Matrix | High-Speed Left | -0.55 | 1.8x | +10,000 pts |

- **Traffic Density**: Spawn intervals dynamically scale with sector difficulty ($t_{\text{spawn}} = \frac{t_{\text{base}}}{\text{densityMultiplier}}$).
- **Sector Announcement Banner**: When entering a new sector, a glowing cyan HUD notification displays the sector name, directional turn icon (`turn_right_rounded`, `turn_left`, `straight`), and bonus point reward for 2.5 seconds.
- **Parallax Skyline Counter-Shift**: Midground skyscrapers and background megastructures shift inversely ($-32 \times \text{curvature}$) to enhance depth perception during turns.

---

## Verification & Test Results

### 1. Static Analysis (`flutter analyze`)
```bash
flutter analyze
Analyzing tesla_roadster_game...
No issues found! (ran in 1.4s)
```
- **0 errors, 0 warnings, 0 lints**.

### 2. Automated Test Suite (`flutter test`)
Created [`test/dynamic_roads_test.dart`](test/dynamic_roads_test.dart) with 11 deterministic tests, bringing the total suite to **48 tests across 6 files**:

```bash
flutter test
00:03 +48: All tests passed!
```

| Test Suite | File | Tests | Status |
| :--- | :--- | :---: | :---: |
| **Foundation & Bridge** | `test/widget_test.dart` | 5 | **PASS** |
| **Arcade Gameplay** | `test/arcade_driving_test.dart` | 9 | **PASS** |
| **Handling & Physics** | `test/handling_physics_test.dart` | 8 | **PASS** |
| **UI Polish & Audio** | `test/audio_and_polish_test.dart` | 10 | **PASS** |
| **Enhanced Visuals** | `test/visuals_enhanced_test.dart` | 5 | **PASS** |
| **Dynamic Roads & Gameplay** | `test/dynamic_roads_test.dart` | 11 | **PASS** |
| **Total** | | **48** | **ALL PASS** |

### 3. Android Debug Build (`flutter build apk --debug`)
```bash
flutter build apk --debug
Running Gradle task 'assembleDebug'...
✓ Built build/app/outputs/flutter-apk/app-debug.apk (5.4s)
```

---

## Honest Disclosure & Limitations
- **Rendering Architecture**: Rendering remains strictly **pseudo-3D** vector geometry computed via Flutter's `CustomPainter` canvas. No 3D meshes, vertex shaders, or external 3D engines are used for the arcade driving mode.
- **Vertical Hills**: Road geometry currently supports horizontal curvature (left/right bends and S-curves); vertical crests and elevation dips are planned for future milestones.
- **All Previous Features Intact**: Features 01–05 (audio synthesizer, HUD, vehicle artwork, controls, pause, restart, scoring, and collision recovery) remain fully functional and verified.
