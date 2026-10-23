import 'package:flutter/material.dart';

/// Design tokens and palette for Tesla Roadster-inspired UI.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF090B10);
  static const Color surface = Color(0xFF12151E);
  static const Color surfaceElevated = Color(0xFF191D2B);
  static const Color surfaceBorder = Color(0xFF262C3D);

  // Brand Accents
  static const Color roadsterRed = Color(0xFFE82127);
  static const Color roadsterRedDark = Color(0xFFA61217);
  static const Color cyberCyan = Color(0xFF00E5FF);
  static const Color thrusterOrange = Color(0xFFFF6D00);
  static const Color electricLime = Color(0xFF00E676);

  // Status
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF334B);

  // Text
  static const Color textPrimary = Color(0xFFF5F6FA);
  static const Color textSecondary = Color(0xFF9E9EB2);
  static const Color textMuted = Color(0xFF5D6175);

  // Gradients
  static const LinearGradient redGlowGradient = LinearGradient(
    colors: [Color(0xFFFF2A36), Color(0xFFBA0C12)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGlowGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF00838F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF151824), Color(0xFF0D0F17)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
