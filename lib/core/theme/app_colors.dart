import 'package:flutter/material.dart';

/// Global color constants used throughout the app
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  static const Color primary = primaryGreen;
  static const Color primaryLight = Color(0xFF81C784);

  // Accent Colors
  static const Color skyBlue = Color(0xFF42A5F5);
  static const Color sunYellow = Color(0xFFFFC107);
  static const Color earthBrown = Color(0xFF8D6E63);
  static const Color warmOrange = Color(0xFFFF7043);

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textHint = Color(0xFF9E9E9E);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Background Colors
  static const Color background = Color(0xFFF5F7F6);
  static const Color backgroundPrimary = Color(0xFFF5F7F6);
  static const Color backgroundSecondary = Color(0xFFEEEEEE);
  static const Color surface = Colors.white;
  static const Color white = Colors.white;
  static const Color lightGray = Color(0xFFF5F5F5);

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);

  // Shadow
  static const Color shadowLight = Colors.black12;
  static Color shadowMedium = Colors.black.withOpacity(0.1);

  // Overlay variants - using method to return color with opacity
  static Color get primaryGreenOverlay10 => primaryGreen.withOpacity(0.1);
  static Color get whiteOverlay20 => Colors.white.withOpacity(0.2);
  static Color get whiteOverlay90 => Colors.white.withOpacity(0.9);
}
