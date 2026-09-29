import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF6B1E2E); // Deep maroon / burgundy
  static const Color primaryDark = Color(0xFF4A121F);
  static const Color primaryLight = Color(0xFF8C2C41);
  static const Color primaryContainer = Color(0xFFF6E8E9);

  // Secondary / Background
  static const Color background = Color(0xFFFFFBF5); // Warm ivory / cream
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // Accent
  static const Color accentGold = Color(0xFFD9A441); // Subtle gold
  static const Color accentGoldLight = Color(0xFFFFF7E6);
  static const Color accentGoldDark = Color(0xFFB38022);

  // Text Colors
  static const Color textPrimary = Color(0xFF2A1518); // Dark charcoal / maroon
  static const Color textSecondary = Color(0xFF6E5D62);
  static const Color textLight = Color(0xFF9E8E93);
  static const Color textOnPrimary = Colors.white;

  // Status & Utility
  static const Color border = Color(0xFFE8D9D0);
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFED6C02);
  static const Color favorite = Color(0xFFE53935);
  static const Color locked = Color(0xFFC62828);
  static const Color chipBackground = Color(0xFFF3ECE7);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6B1E2E), Color(0xFF8C2C41)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD9A441), Color(0xFFF3C868)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
