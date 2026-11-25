import 'package:flutter/material.dart';

class AppColors {
  AppColors._();


  static const Color primaryTeal = Color(0xFF006D77);
  static const Color primaryTealDark = Color(0xFF004D54);
  static const Color primaryTealLight = Color(0xFF83C5BE);
  static const Color primaryTealSoft = Color(0xFFE8F4F5);
  static const Color primaryTealSurface = Color(0xFFF2F9F9);


  static const Color medicalBlue = Color(0xFF0284C7);
  static const Color medicalBlueDark = Color(0xFF0369A1);
  static const Color medicalBlueLight = Color(0xFF38BDF8);
  static const Color medicalBlueSoft = Color(0xFFE0F2FE);


  static const Color emergencyRed = Color(0xFFEF4444);
  static const Color emergencyRedDark = Color(0xFFDC2626);
  static const Color emergencyRedSoft = Color(0xFFFEE2E2);


  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenSoft = Color(0xFFD1FAE5);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color warningOrangeSoft = Color(0xFFFEF3C7);
  static const Color infoPurple = Color(0xFF8B5CF6);
  static const Color infoPurpleSoft = Color(0xFFEDE9FE);


  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color cardBorderSubtle = Color(0xFFF1F5F9);


  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFCBD5E1);


  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF006D77), Color(0xFF009688)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueTealGradient = LinearGradient(
    colors: [Color(0xFF006D77), Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
