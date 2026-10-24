import 'dart:math' as math;

/// Type of curve geometry for a road section
enum RoadCurveType {
  straight,
  gentleRight,
  sharpRight,
  gentleLeft,
  sharpLeft,
  sCurve,
}

/// Type of vertical elevation profile for a road section
enum RoadElevationType {
  flat,
  gentleUphill,
  steepUphill,
  gentleDownhill,
  steepDownhill,
  undulating, // Rollercoaster / terrain crests and dips
}

/// Represents a distinct section of the arcade driving highway
class RoadSection {
  final String id;
  final String name;
  final double startDistanceMeters;
  final double endDistanceMeters;
  final RoadCurveType curveType;

  /// Target peak curvature (-1.0 to 1.0)
  /// Negative = Left curve, Positive = Right curve, 0.0 = Straight
  final double targetCurvature;

  /// Elevation profile type
  final RoadElevationType elevationType;

  /// Target peak elevation (-1.0 to 1.0)
  /// Positive = Uphill climb, Negative = Downhill descent, 0.0 = Flat
  final double targetElevation;

  /// Multiplier applied to obstacle spawning frequency
  final double trafficDensityMultiplier;

  /// Bonus points awarded for completing the sector
  final int bonusPoints;

  const RoadSection({
    required this.id,
    required this.name,
    required this.startDistanceMeters,
    required this.endDistanceMeters,
    required this.curveType,
    required this.targetCurvature,
    this.elevationType = RoadElevationType.flat,
    this.targetElevation = 0.0,
    this.trafficDensityMultiplier = 1.0,
    this.bonusPoints = 500,
  });

  double get lengthMeters => endDistanceMeters - startDistanceMeters;
}

/// Manages track layout, sector progression, and smooth curvature/elevation interpolation
class TrackProgressionManager {
  final List<RoadSection> sections;

  TrackProgressionManager({List<RoadSection>? customSections})
      : sections = customSections ?? defaultSections;

  /// Default structured arcade highway progression with accessible distance pacing
  /// combining dynamic horizontal curvature and vertical elevation profiles
  static const List<RoadSection> defaultSections = [
    RoadSection(
      id: 'sec_01',
      name: 'NEON HIGHWAY',
      startDistanceMeters: 0.0,
      endDistanceMeters: 100.0,
      curveType: RoadCurveType.straight,
      targetCurvature: 0.0,
      elevationType: RoadElevationType.flat,
      targetElevation: 0.0,
      trafficDensityMultiplier: 1.0,
      bonusPoints: 300,
    ),
    RoadSection(
      id: 'sec_02',
      name: 'CYBER SWEEP',
      startDistanceMeters: 100.0,
      endDistanceMeters: 400.0,
      curveType: RoadCurveType.gentleRight,
      targetCurvature: 0.48,
      elevationType: RoadElevationType.gentleUphill,
      targetElevation: 0.35,
      trafficDensityMultiplier: 1.15,
      bonusPoints: 600,
    ),
    RoadSection(
      id: 'sec_03',
      name: 'GRID CONNECTOR',
      startDistanceMeters: 400.0,
      endDistanceMeters: 600.0,
      curveType: RoadCurveType.straight,
      targetCurvature: 0.0,
      elevationType: RoadElevationType.gentleDownhill,
      targetElevation: -0.30,
      trafficDensityMultiplier: 1.20,
      bonusPoints: 400,
    ),
    RoadSection(
      id: 'sec_04',
      name: 'NIGHT CANYON',
      startDistanceMeters: 600.0,
      endDistanceMeters: 1000.0,
      curveType: RoadCurveType.gentleLeft,
      targetCurvature: -0.55,
      elevationType: RoadElevationType.steepUphill,
      targetElevation: 0.55,
      trafficDensityMultiplier: 1.30,
      bonusPoints: 750,
    ),
    RoadSection(
      id: 'sec_05',
      name: 'DATA CHICANE',
      startDistanceMeters: 1000.0,
      endDistanceMeters: 1500.0,
      curveType: RoadCurveType.sCurve,
      targetCurvature: 0.50, // Peak amplitude for alternating sine curve
      elevationType: RoadElevationType.undulating,
      targetElevation: 0.45, // Oscillates with undulating terrain
      trafficDensityMultiplier: 1.45,
      bonusPoints: 1000,
    ),
    RoadSection(
      id: 'sec_06',
      name: 'CIRCUIT OVERPASS',
      startDistanceMeters: 1500.0,
      endDistanceMeters: 2100.0,
      curveType: RoadCurveType.sharpRight,
      targetCurvature: 0.70,
      elevationType: RoadElevationType.steepUphill,
      targetElevation: 0.70, // Steep ramp ascending the elevated skybridge
      trafficDensityMultiplier: 1.55,
      bonusPoints: 1200,
    ),
    RoadSection(
      id: 'sec_07',
      name: 'HYPERDRIVE MATRIX',
      startDistanceMeters: 2100.0,
      endDistanceMeters: 3000.0,
      curveType: RoadCurveType.sharpLeft,
      targetCurvature: -0.75,
      elevationType: RoadElevationType.steepDownhill,
      targetElevation: -0.65, // Thrilling downhill descent to complete the circuit loop
      trafficDensityMultiplier: 1.70,
      bonusPoints: 1500,
    ),
  ];

  /// Returns the active road section for the given distance
  RoadSection getSectionForDistance(double distanceMeters) {
    if (sections.isEmpty) {
      return defaultSections.first;
    }

    final totalTrackLength = sections.last.endDistanceMeters;
    // Loop track infinitely if driving past defined sections
    final loopedDistance = (distanceMeters >= totalTrackLength)
        ? (distanceMeters % totalTrackLength)
        : distanceMeters;

    for (final section in sections) {
      if (loopedDistance >= section.startDistanceMeters &&
          loopedDistance < section.endDistanceMeters) {
        return section;
      }
    }

    return sections.last;
  }

  /// Calculates smooth, continuous curvature at any given distance
  /// Handles smooth entry transition, sustained turn, and smooth exit
  double computeCurvatureAt(double distanceMeters) {
    final section = getSectionForDistance(distanceMeters);
    final totalTrackLength = sections.last.endDistanceMeters;
    final loopedDistance = (distanceMeters >= totalTrackLength)
        ? (distanceMeters % totalTrackLength)
        : distanceMeters;

    final progressInSection = (loopedDistance - section.startDistanceMeters) / section.lengthMeters;
    final clampedProgress = progressInSection.clamp(0.0, 1.0);

    // Special handling for S-Curve / Chicane (alternates through sine wave)
    if (section.curveType == RoadCurveType.sCurve) {
      // 2 complete cycles with smooth entry/exit envelope
      final envelope = math.sin(clampedProgress * math.pi);
      final oscillation = math.sin(clampedProgress * math.pi * 3.0);
      return section.targetCurvature * oscillation * envelope;
    }

    if (section.targetCurvature == 0.0) {
      return 0.0;
    }

    // Standard Curve: Smooth Entry (first 18%), Sustained Apex (18%-82%), Smooth Exit (last 18%)
    const transitionRatio = 0.18;
    if (clampedProgress < transitionRatio) {
      // Smooth cubic entry: 3t^2 - 2t^3
      final t = clampedProgress / transitionRatio;
      final smoothT = t * t * (3.0 - 2.0 * t);
      return section.targetCurvature * smoothT;
    } else if (clampedProgress > (1.0 - transitionRatio)) {
      // Smooth cubic exit back to neutral: 3t^2 - 2t^3
      final t = (1.0 - clampedProgress) / transitionRatio;
      final smoothT = t * t * (3.0 - 2.0 * t);
      return section.targetCurvature * smoothT;
    } else {
      // Sustained apex turn
      return section.targetCurvature;
    }
  }

  /// Calculates smooth, continuous vertical elevation (-1.0 to 1.0) at any given distance.
  /// Handles smooth entry transition, sustained slope, smooth return to flat,
  /// and sinusoidal oscillation for undulating rollercoaster sections.
  double computeElevationAt(double distanceMeters) {
    final section = getSectionForDistance(distanceMeters);
    final totalTrackLength = sections.last.endDistanceMeters;
    final loopedDistance = (distanceMeters >= totalTrackLength)
        ? (distanceMeters % totalTrackLength)
        : distanceMeters;

    final progressInSection = (loopedDistance - section.startDistanceMeters) / section.lengthMeters;
    final clampedProgress = progressInSection.clamp(0.0, 1.0);

    // Special handling for undulating / rollercoaster terrain (sine wave crests and dips)
    if (section.elevationType == RoadElevationType.undulating) {
      final envelope = math.sin(clampedProgress * math.pi);
      final oscillation = math.sin(clampedProgress * math.pi * 3.0);
      return section.targetElevation * oscillation * envelope;
    }

    if (section.targetElevation == 0.0) {
      return 0.0;
    }

    // Standard Slope: Smooth Entry (first 18%), Sustained Grade (18%-82%), Smooth Exit (last 18%)
    const transitionRatio = 0.18;
    if (clampedProgress < transitionRatio) {
      // Smooth cubic entry: 3t^2 - 2t^3
      final t = clampedProgress / transitionRatio;
      final smoothT = t * t * (3.0 - 2.0 * t);
      return section.targetElevation * smoothT;
    } else if (clampedProgress > (1.0 - transitionRatio)) {
      // Smooth cubic exit: 3t^2 - 2t^3
      final t = (1.0 - clampedProgress) / transitionRatio;
      final smoothT = t * t * (3.0 - 2.0 * t);
      return section.targetElevation * smoothT;
    } else {
      // Sustained slope
      return section.targetElevation;
    }
  }

  /// Returns 1-based sector index for display
  int getSectorIndex(double distanceMeters) {
    final section = getSectionForDistance(distanceMeters);
    final idx = sections.indexOf(section);
    return idx >= 0 ? idx + 1 : 1;
  }
}
