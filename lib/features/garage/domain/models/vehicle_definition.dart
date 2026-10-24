import 'package:flutter/material.dart';

/// Body style archetypes for fictional electric hypercars
enum VehicleBodyStyle {
  roadster,    // Sculpted aerodynamic roadster with teardrop glass canopy
  valkyrieAero,// Low-slung race prototype with shark fin and massive splitters
  titanStealth // Faceted angular armored stealth interceptor with wide shoulders
}

/// Wheel rim design styles
enum WheelRimType {
  turbine,      // Aerodynamic multi-blade turbine rims
  cyberDisc,    // Solid aerodynamic futuristic disc wheels
  starfireSplit,// Aggressive 5-spoke split racing alloy rims
  carbonLattice // Ultra-lightweight carbon fiber multi-spoke lattice
}

/// Paint color definition with rich metallic gradients
class PaintColorOption {
  final String id;
  final String name;
  final Color primaryColor;
  final List<Color> gradientColors;
  final String? requiredMilestoneId;

  const PaintColorOption({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.gradientColors,
    this.requiredMilestoneId,
  });

  Color get accentColor => primaryColor;

  bool isUnlocked(Set<String> unlockedMilestones) {
    if (requiredMilestoneId == null) return true;
    return unlockedMilestones.contains(requiredMilestoneId);
  }

  String get unlockRequirementDescription {
    switch (requiredMilestoneId) {
      case 'century':
        return 'Reach 100 MPH (CENTURY CLUB)';
      case 'warp_speed':
        return 'Reach 150 MPH (WARP VELOCITY)';
      case 'endurance':
        return 'Drive 1,000 meters (ENDURANCE)';
      case 'high_roller':
        return 'Score 25,000 points (HIGH ROLLER)';
      case 'cyber_legend':
        return 'Score 50,000 points (CYBER LEGEND)';
      default:
        return 'Unlocked';
    }
  }

  static const List<PaintColorOption> allColors = [
    PaintColorOption(
      id: 'cyber_crimson',
      name: 'CYBER CRIMSON',
      primaryColor: Color(0xFFE51D33),
      gradientColors: [
        Color(0xFFFF3E55),
        Color(0xFFE51D33),
        Color(0xFFBD0F22),
        Color(0xFF880816),
        Color(0xFF5A000C),
      ],
      requiredMilestoneId: null, // Unlocked by default
    ),
    PaintColorOption(
      id: 'electric_cyan',
      name: 'ELECTRIC CYAN',
      primaryColor: Color(0xFF00E5FF),
      gradientColors: [
        Color(0xFF80F5FF),
        Color(0xFF00E5FF),
        Color(0xFF00B4D8),
        Color(0xFF0077B6),
        Color(0xFF023E8A),
      ],
      requiredMilestoneId: null, // Unlocked by default
    ),
    PaintColorOption(
      id: 'stealth_obsidian',
      name: 'STEALTH OBSIDIAN',
      primaryColor: Color(0xFF212529),
      gradientColors: [
        Color(0xFF495057),
        Color(0xFF343A40),
        Color(0xFF212529),
        Color(0xFF16181B),
        Color(0xFF0D0E10),
      ],
      requiredMilestoneId: null, // Unlocked by default
    ),
    PaintColorOption(
      id: 'acid_lime',
      name: 'ACID PULSE',
      primaryColor: Color(0xFF76FF03),
      gradientColors: [
        Color(0xFFB2FF59),
        Color(0xFF76FF03),
        Color(0xFF64DD17),
        Color(0xFF43A047),
        Color(0xFF1B5E20),
      ],
      requiredMilestoneId: 'century', // Requires 100+ MPH
    ),
    PaintColorOption(
      id: 'solar_flare',
      name: 'SOLAR FLARE',
      primaryColor: Color(0xFFFF9100),
      gradientColors: [
        Color(0xFFFFD180),
        Color(0xFFFF9100),
        Color(0xFFFF6D00),
        Color(0xFFE65100),
        Color(0xFFBF360C),
      ],
      requiredMilestoneId: 'warp_speed', // Requires 150+ MPH
    ),
    PaintColorOption(
      id: 'hyper_violet',
      name: 'NEON VIOLET',
      primaryColor: Color(0xFFD500F9),
      gradientColors: [
        Color(0xFFEA80FC),
        Color(0xFFD500F9),
        Color(0xFFAA00FF),
        Color(0xFF7B1FA2),
        Color(0xFF4A148C),
      ],
      requiredMilestoneId: 'high_roller', // Requires 25,000 pts
    ),
  ];
}

/// Wheel style definition
class WheelStyleOption {
  final String id;
  final String name;
  final WheelRimType type;
  final Color rimColor;
  final Color highlightColor;
  final Color caliperColor;
  final String? requiredMilestoneId;

  const WheelStyleOption({
    required this.id,
    required this.name,
    required this.type,
    required this.rimColor,
    required this.highlightColor,
    required this.caliperColor,
    this.requiredMilestoneId,
  });

  Color get rimBaseColor => rimColor;
  Color get rimHighlightColor => highlightColor;
  WheelRimType get rimType => type;

  bool isUnlocked(Set<String> unlockedMilestones) {
    if (requiredMilestoneId == null) return true;
    return unlockedMilestones.contains(requiredMilestoneId);
  }

  String get unlockRequirementDescription {
    switch (requiredMilestoneId) {
      case 'century':
        return 'Reach 100 MPH (CENTURY CLUB)';
      case 'warp_speed':
        return 'Reach 150 MPH (WARP VELOCITY)';
      case 'endurance':
        return 'Drive 1,000 meters (ENDURANCE)';
      case 'high_roller':
        return 'Score 25,000 points (HIGH ROLLER)';
      default:
        return 'Unlocked';
    }
  }

  static const List<WheelStyleOption> allWheels = [
    WheelStyleOption(
      id: 'turbine_aero',
      name: 'TURBINE AERO',
      type: WheelRimType.turbine,
      rimColor: Color(0xFF555D6A),
      highlightColor: Color(0xFF8E99A8),
      caliperColor: Color(0xFFFF1E38),
      requiredMilestoneId: null,
    ),
    WheelStyleOption(
      id: 'cyber_disc',
      name: 'CYBER DISC',
      type: WheelRimType.cyberDisc,
      rimColor: Color(0xFF2A2D34),
      highlightColor: Color(0xFF00E5FF),
      caliperColor: Color(0xFF00E5FF),
      requiredMilestoneId: null,
    ),
    WheelStyleOption(
      id: 'starfire_split',
      name: 'STARFIRE SPLIT',
      type: WheelRimType.starfireSplit,
      rimColor: Color(0xFFD0D5DD),
      highlightColor: Color(0xFFFFFFFF),
      caliperColor: Color(0xFFFF9100),
      requiredMilestoneId: 'century',
    ),
    WheelStyleOption(
      id: 'carbon_lattice',
      name: 'CARBON LATTICE',
      type: WheelRimType.carbonLattice,
      rimColor: Color(0xFF181A1F),
      highlightColor: Color(0xFF76FF03),
      caliperColor: Color(0xFF76FF03),
      requiredMilestoneId: 'warp_speed',
    ),
  ];
}

/// Neon underglow ground illumination option
class UnderglowOption {
  final String id;
  final String name;
  final Color color;
  final String? requiredMilestoneId;

  const UnderglowOption({
    required this.id,
    required this.name,
    required this.color,
    this.requiredMilestoneId,
  });

  bool isUnlocked(Set<String> unlockedMilestones) {
    if (requiredMilestoneId == null) return true;
    return unlockedMilestones.contains(requiredMilestoneId);
  }

  String get unlockRequirementDescription {
    switch (requiredMilestoneId) {
      case 'century':
        return 'Reach 100 MPH (CENTURY CLUB)';
      case 'warp_speed':
        return 'Reach 150 MPH (WARP VELOCITY)';
      case 'endurance':
        return 'Drive 1,000 meters (ENDURANCE)';
      case 'cyber_legend':
        return 'Score 50,000 points (CYBER LEGEND)';
      default:
        return 'Unlocked';
    }
  }

  static const List<UnderglowOption> allOptions = [
    UnderglowOption(
      id: 'neon_cyan',
      name: 'CYBER CYAN',
      color: Color(0xFF00E5FF),
      requiredMilestoneId: null,
    ),
    UnderglowOption(
      id: 'laser_red',
      name: 'LASER RED',
      color: Color(0xFFFF1744),
      requiredMilestoneId: null,
    ),
    UnderglowOption(
      id: 'acid_green',
      name: 'ACID GREEN',
      color: Color(0xFF76FF03),
      requiredMilestoneId: null,
    ),
    UnderglowOption(
      id: 'pulse_violet',
      name: 'PULSE VIOLET',
      color: Color(0xFFD500F9),
      requiredMilestoneId: 'century',
    ),
    UnderglowOption(
      id: 'solar_amber',
      name: 'SOLAR AMBER',
      color: Color(0xFFFF9100),
      requiredMilestoneId: 'warp_speed',
    ),
    UnderglowOption(
      id: 'stealth_off',
      name: 'STEALTH (OFF)',
      color: Colors.transparent,
      requiredMilestoneId: null,
    ),
  ];
}

/// Complete vehicle definition including performance stats and gameplay multipliers
class VehicleDefinition {
  final String id;
  final String name;
  final String codeName;
  final String subtitle;
  final String description;
  final VehicleBodyStyle bodyStyle;

  // Stat ratings displayed in UI (0.0 to 1.0)
  final double accelerationRating;
  final double topSpeedRating;
  final double handlingRating;
  final double durabilityRating;

  // Concrete gameplay mechanics multipliers
  final double topSpeedMph;
  final double accelerationMultiplier; // Scales motor torque
  final double baseSteeringMultiplier; // Scales lateral steering velocity
  final double damageMultiplier;       // Multiplies collision damage received (< 1.0 is more durable)

  // Default customization
  final String defaultPaintColorId;
  final String defaultWheelStyleId;
  final String defaultUnderglowColorId;

  // Milestone unlock condition
  final String? requiredMilestoneId;
  final String? unlockRequirementText;

  const VehicleDefinition({
    required this.id,
    required this.name,
    required this.codeName,
    required this.subtitle,
    required this.description,
    required this.bodyStyle,
    required this.accelerationRating,
    required this.topSpeedRating,
    required this.handlingRating,
    required this.durabilityRating,
    required this.topSpeedMph,
    required this.accelerationMultiplier,
    required this.baseSteeringMultiplier,
    required this.damageMultiplier,
    required this.defaultPaintColorId,
    required this.defaultWheelStyleId,
    required this.defaultUnderglowColorId,
    this.requiredMilestoneId,
    this.unlockRequirementText,
  });

  bool isUnlocked(Set<String> unlockedMilestones) {
    if (requiredMilestoneId == null) return true;
    return unlockedMilestones.contains(requiredMilestoneId);
  }

  String get unlockRequirementDescription => unlockRequirementText ?? 'Unlocked';

  /// All 3 distinct fictional electric sports cars
  static const List<VehicleDefinition> allVehicles = [
    // 1. Prototype 01 — Cyber Roadster (Balanced All-Rounder)
    VehicleDefinition(
      id: 'cyber_roadster',
      name: 'CYBER ROADSTER',
      codeName: 'PROTOTYPE 01',
      subtitle: 'All-Wheel Drive Electric Hypercar',
      description: 'The iconic cybernetic roadster featuring balanced dual-motor instant torque, sculpted teardrop canopy, and active aerodynamic stabilization.',
      bodyStyle: VehicleBodyStyle.roadster,
      accelerationRating: 0.82,
      topSpeedRating: 0.80,
      handlingRating: 0.78,
      durabilityRating: 0.75,
      topSpeedMph: 250.0,
      accelerationMultiplier: 1.00,
      baseSteeringMultiplier: 1.00,
      damageMultiplier: 1.00,
      defaultPaintColorId: 'cyber_crimson',
      defaultWheelStyleId: 'turbine_aero',
      defaultUnderglowColorId: 'neon_cyan',
      requiredMilestoneId: null, // Always available
    ),

    // 2. Apex GT-E — Valkyrie Aero (Lightweight Circuit Specialist)
    VehicleDefinition(
      id: 'apex_gte',
      name: 'APEX GT-E',
      codeName: 'VALKYRIE AERO',
      subtitle: 'Lightweight Circuit Prototype',
      description: 'Ultra-low aerodynamic silhouette engineered with extreme downforce splitters and ultra-responsive lateral agility for technical highway curves.',
      bodyStyle: VehicleBodyStyle.valkyrieAero,
      accelerationRating: 0.94,
      topSpeedRating: 0.76,
      handlingRating: 0.95,
      durabilityRating: 0.60,
      topSpeedMph: 242.0,
      accelerationMultiplier: 1.15, // 15% faster torque surge
      baseSteeringMultiplier: 1.18, // 18% sharper lane transition speed
      damageMultiplier: 1.25,       // Lightweight chassis takes 25% more damage
      defaultPaintColorId: 'electric_cyan',
      defaultWheelStyleId: 'starfire_split',
      defaultUnderglowColorId: 'laser_red',
      requiredMilestoneId: 'century',
      unlockRequirementText: 'Exceed 100 MPH in any run (CENTURY CLUB)',
    ),

    // 3. Hyperion Phantom — Titan Edition (Heavyweight Armored Interceptor)
    VehicleDefinition(
      id: 'hyperion_phantom',
      name: 'HYPERION PHANTOM',
      codeName: 'TITAN INTERCEPTOR',
      subtitle: 'Armored High-Velocity Interceptor',
      description: 'Massive quad-motor armored wedge chassis boasting unmatched straightaway top speed and heavy kinetic impact absorption.',
      bodyStyle: VehicleBodyStyle.titanStealth,
      accelerationRating: 0.74,
      topSpeedRating: 0.96,
      handlingRating: 0.65,
      durabilityRating: 0.98,
      topSpeedMph: 268.0,
      accelerationMultiplier: 0.88, // Slower off the line due to reinforced mass
      baseSteeringMultiplier: 0.88, // Heavier turning response
      damageMultiplier: 0.68,       // Heavy armor absorbs 32% of collision impact
      defaultPaintColorId: 'stealth_obsidian',
      defaultWheelStyleId: 'cyber_disc',
      defaultUnderglowColorId: 'pulse_violet',
      requiredMilestoneId: 'warp_speed',
      unlockRequirementText: 'Exceed 150 MPH in any run (WARP VELOCITY)',
    ),
  ];

  static VehicleDefinition getById(String id) {
    return allVehicles.firstWhere(
      (v) => v.id == id,
      orElse: () => allVehicles.first,
    );
  }
}

/// Represents active vehicle customization state
class VehicleCustomization {
  final String vehicleId;
  final String paintColorId;
  final String wheelStyleId;
  final String underglowColorId;

  const VehicleCustomization({
    this.vehicleId = 'cyber_roadster',
    this.paintColorId = 'cyber_crimson',
    this.wheelStyleId = 'turbine_aero',
    this.underglowColorId = 'neon_cyan',
  });

  VehicleDefinition get vehicle => VehicleDefinition.getById(vehicleId);

  PaintColorOption get paintColor => PaintColorOption.allColors.firstWhere(
    (c) => c.id == paintColorId,
    orElse: () => PaintColorOption.allColors.first,
  );

  WheelStyleOption get wheelStyle => WheelStyleOption.allWheels.firstWhere(
    (w) => w.id == wheelStyleId,
    orElse: () => WheelStyleOption.allWheels.first,
  );

  UnderglowOption get underglowOption => UnderglowOption.allOptions.firstWhere(
    (u) => u.id == underglowColorId,
    orElse: () => UnderglowOption.allOptions.first,
  );

  VehicleCustomization copyWith({
    String? vehicleId,
    String? paintColorId,
    String? wheelStyleId,
    String? underglowColorId,
  }) {
    return VehicleCustomization(
      vehicleId: vehicleId ?? this.vehicleId,
      paintColorId: paintColorId ?? this.paintColorId,
      wheelStyleId: wheelStyleId ?? this.wheelStyleId,
      underglowColorId: underglowColorId ?? this.underglowColorId,
    );
  }
}

/// Centralized catalog accessor for vehicles and customization accessories
class VehicleCatalog {
  static List<VehicleDefinition> get vehicles => VehicleDefinition.allVehicles;
  static List<PaintColorOption> get paints => PaintColorOption.allColors;
  static List<WheelStyleOption> get wheels => WheelStyleOption.allWheels;
  static List<UnderglowOption> get underglows => UnderglowOption.allOptions;
}
