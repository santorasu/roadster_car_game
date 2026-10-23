import 'package:flutter/foundation.dart';

@immutable
class TelemetryData {
  final double speedMph;
  final int rpm;
  final double batteryPercent;
  final String gear;
  final double gForce;
  final double motorTempC;
  final double steering;
  final double throttle;
  final String cameraMode;
  final String color;

  const TelemetryData({
    this.speedMph = 0.0,
    this.rpm = 800,
    this.batteryPercent = 100.0,
    this.gear = 'P',
    this.gForce = 0.0,
    this.motorTempC = 38.0,
    this.steering = 0.0,
    this.throttle = 0.0,
    this.cameraMode = 'CHASE',
    this.color = '#E82127',
  });

  factory TelemetryData.fromMap(Map<String, dynamic> map) {
    return TelemetryData(
      speedMph: (map['speedMph'] as num?)?.toDouble() ?? 0.0,
      rpm: (map['rpm'] as num?)?.toInt() ?? 800,
      batteryPercent: (map['batteryPercent'] as num?)?.toDouble() ?? 100.0,
      gear: (map['gear'] as String?) ?? 'P',
      gForce: (map['gForce'] as num?)?.toDouble() ?? 0.0,
      motorTempC: (map['motorTempC'] as num?)?.toDouble() ?? 38.0,
      steering: (map['steering'] as num?)?.toDouble() ?? 0.0,
      throttle: (map['throttle'] as num?)?.toDouble() ?? 0.0,
      cameraMode: (map['cameraMode'] as String?) ?? 'CHASE',
      color: (map['color'] as String?) ?? '#E82127',
    );
  }

  TelemetryData copyWith({
    double? speedMph,
    int? rpm,
    double? batteryPercent,
    String? gear,
    double? gForce,
    double? motorTempC,
    double? steering,
    double? throttle,
    String? cameraMode,
    String? color,
  }) {
    return TelemetryData(
      speedMph: speedMph ?? this.speedMph,
      rpm: rpm ?? this.rpm,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      gear: gear ?? this.gear,
      gForce: gForce ?? this.gForce,
      motorTempC: motorTempC ?? this.motorTempC,
      steering: steering ?? this.steering,
      throttle: throttle ?? this.throttle,
      cameraMode: cameraMode ?? this.cameraMode,
      color: color ?? this.color,
    );
  }
}
