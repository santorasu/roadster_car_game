import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/telemetry_data.dart';

class Interactive3DViewport extends StatefulWidget {
  final TelemetryData telemetry;

  const Interactive3DViewport({
    super.key,
    required this.telemetry,
  });

  @override
  State<Interactive3DViewport> createState() => _Interactive3DViewportState();
}

class _Interactive3DViewportState extends State<Interactive3DViewport>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  double _userOrbitYaw = 0.0;
  double _userOrbitPitch = 0.25;
  double _groundScroll = 0.0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _animCtrl.addListener(() {
      setState(() {
        final speedFactor = widget.telemetry.speedMph * 0.02;
        _groundScroll = (_groundScroll + speedFactor + 0.02) % 1.0;
      });
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color vehicleColor;
    try {
      final hex = widget.telemetry.color.replaceFirst('#', '');
      vehicleColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      vehicleColor = const Color(0xFFE82127);
    }

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _userOrbitYaw += details.delta.dx * 0.01;
          _userOrbitPitch = (_userOrbitPitch - details.delta.dy * 0.01)
              .clamp(0.05, 0.85);
        });
      },
      child: Container(
        color: const Color(0xFF07090E),
        child: CustomPaint(
          size: Size.infinite,
          painter: _Roadster3DPainter(
            yaw: _userOrbitYaw,
            pitch: _userOrbitPitch,
            groundScroll: _groundScroll,
            speedMph: widget.telemetry.speedMph,
            steering: widget.telemetry.steering,
            throttle: widget.telemetry.throttle,
            vehicleColor: vehicleColor,
            cameraMode: widget.telemetry.cameraMode,
          ),
        ),
      ),
    );
  }
}

class _Roadster3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final double groundScroll;
  final double speedMph;
  final double steering;
  final double throttle;
  final Color vehicleColor;
  final String cameraMode;

  _Roadster3DPainter({
    required this.yaw,
    required this.pitch,
    required this.groundScroll,
    required this.speedMph,
    required this.steering,
    required this.throttle,
    required this.vehicleColor,
    required this.cameraMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.52;

    _drawSkyGradient(canvas, size);
    _drawPerspectiveGroundGrid(canvas, size, cx, cy);
    _draw3DRoadster(canvas, size, cx, cy);
  }

  void _drawSkyGradient(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF05070B),
          Color(0xFF0F1420),
          Color(0xFF161E30),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawPerspectiveGroundGrid(Canvas canvas, Size size, double cx, double cy) {
    final horizonY = cy - 20;

    // Neon horizon glow
    final horizonPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.2)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, horizonY), Offset(size.width, horizonY), horizonPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF26324D).withValues(alpha: 0.5)
      ..strokeWidth = 1.2;

    // Perspective converging longitudinal lines
    for (int i = -8; i <= 8; i++) {
      final xBottom = cx + (i * 75);
      final xTop = cx + (i * 8);
      canvas.drawLine(Offset(xTop, horizonY), Offset(xBottom, size.height), linePaint);
    }

    // Moving horizontal grid lines
    for (int j = 0; j < 12; j++) {
      final t = ((j / 12.0) + groundScroll) % 1.0;
      final y = horizonY + (size.height - horizonY) * math.pow(t, 2.2);
      final alpha = (t * 0.6).clamp(0.0, 0.6);
      final hPaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: alpha)
        ..strokeWidth = 1.0 + (t * 1.5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hPaint);
    }
  }

  void _draw3DRoadster(Canvas canvas, Size size, double cx, double cy) {
    // Camera angles based on mode
    double effectiveYaw = yaw;
    double effectivePitch = pitch;

    if (cameraMode == 'ORBIT') {
      effectiveYaw += 0.8;
    } else if (cameraMode == 'COCKPIT') {
      effectivePitch = 0.1;
    }

    // 3D Point projection helper
    Offset project(double x, double y, double z) {
      // Rotation around Y (yaw)
      final cosY = math.cos(effectiveYaw);
      final sinY = math.sin(effectiveYaw);
      final rx = x * cosY - z * sinY;
      final rz1 = x * sinY + z * cosY;

      // Rotation around X (pitch)
      final cosP = math.cos(effectivePitch);
      final sinP = math.sin(effectivePitch);
      final ry = y * cosP - rz1 * sinP;
      final rz = y * sinP + rz1 * cosP + 450; // Distance

      final fov = 380;
      final scale = fov / rz;
      return Offset(cx + rx * scale, cy - ry * scale);
    }

    // Car shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    final shadowPath = Path()
      ..moveTo(project(-65, -15, -110).dx, project(-65, -15, -110).dy)
      ..lineTo(project(65, -15, -110).dx, project(65, -15, -110).dy)
      ..lineTo(project(60, -15, 110).dx, project(60, -15, 110).dy)
      ..lineTo(project(-60, -15, 110).dx, project(-60, -15, 110).dy)
      ..close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Body Panels
    final bodyPaint = Paint()
      ..color = vehicleColor
      ..style = PaintingStyle.fill;

    final bodyDarkPaint = Paint()
      ..color = Color.lerp(vehicleColor, Colors.black, 0.4)!
      ..style = PaintingStyle.fill;

    final glassPaint = Paint()
      ..color = const Color(0xFF10192A).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final wirePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Lower Chassis
    final lowerChassis = Path()
      ..moveTo(project(-55, -8, -100).dx, project(-55, -8, -100).dy)
      ..lineTo(project(55, -8, -100).dx, project(55, -8, -100).dy)
      ..lineTo(project(52, -8, 100).dx, project(52, -8, 100).dy)
      ..lineTo(project(-52, -8, 100).dx, project(-52, -8, 100).dy)
      ..close();
    canvas.drawPath(lowerChassis, bodyDarkPaint);
    canvas.drawPath(lowerChassis, wirePaint);

    // Main Hood & Body
    final mainHood = Path()
      ..moveTo(project(-52, 12, -90).dx, project(-52, 12, -90).dy)
      ..lineTo(project(52, 12, -90).dx, project(52, 12, -90).dy)
      ..lineTo(project(48, 15, 10).dx, project(48, 15, 10).dy)
      ..lineTo(project(-48, 15, 10).dx, project(-48, 15, 10).dy)
      ..close();
    canvas.drawPath(mainHood, bodyPaint);
    canvas.drawPath(mainHood, wirePaint);

    // Canopy & Glass Roof
    final canopy = Path()
      ..moveTo(project(-38, 15, 10).dx, project(-38, 15, 10).dy)
      ..lineTo(project(38, 15, 10).dx, project(38, 15, 10).dy)
      ..lineTo(project(32, 38, 55).dx, project(32, 38, 55).dy)
      ..lineTo(project(-32, 38, 55).dx, project(-32, 38, 55).dy)
      ..close();
    canvas.drawPath(canopy, glassPaint);
    canvas.drawPath(canopy, wirePaint);

    // Rear Decklid & Aero Diffuser
    final rearDeck = Path()
      ..moveTo(project(-48, 16, 55).dx, project(-48, 16, 55).dy)
      ..lineTo(project(48, 16, 55).dx, project(48, 16, 55).dy)
      ..lineTo(project(52, 22, 105).dx, project(52, 22, 105).dy)
      ..lineTo(project(-52, 22, 105).dx, project(-52, 22, 105).dy)
      ..close();
    canvas.drawPath(rearDeck, bodyPaint);
    canvas.drawPath(rearDeck, wirePaint);

    // Quad Cyber Headlights
    final headlightPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      project(-46, 8, -98),
      project(-20, 10, -96),
      headlightPaint,
    );
    canvas.drawLine(
      project(20, 10, -96),
      project(46, 8, -98),
      headlightPaint,
    );

    // Continuous Rear Cyber Taillight
    final taillightPaint = Paint()
      ..color = const Color(0xFFFF1744)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      project(-48, 20, 105),
      project(48, 20, 105),
      taillightPaint,
    );

    // 4 Wheels
    final wheelPaint = Paint()
      ..color = const Color(0xFF1E222D)
      ..style = PaintingStyle.fill;
    final rimPaint = Paint()
      ..color = const Color(0xFF8E9297)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    void drawWheel(double wx, double wy, double wz, double steerAngle) {
      final center = project(wx, wy, wz);
      canvas.drawCircle(center, 14, wheelPaint);
      canvas.drawCircle(center, 14, rimPaint);
      canvas.drawCircle(center, 4, Paint()..color = vehicleColor);
    }

    drawWheel(-56, -4, -65, steering);
    drawWheel(56, -4, -65, steering);
    drawWheel(-56, -4, 75, 0.0);
    drawWheel(56, -4, 75, 0.0);
  }

  @override
  bool shouldRepaint(covariant _Roadster3DPainter oldDelegate) {
    return oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.groundScroll != groundScroll ||
        oldDelegate.speedMph != speedMph ||
        oldDelegate.steering != steering ||
        oldDelegate.throttle != throttle ||
        oldDelegate.vehicleColor != vehicleColor ||
        oldDelegate.cameraMode != cameraMode;
  }
}
