import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFE55A2B);
  static const Color primaryLight = Color(0xFFFF8B5C);

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF4ECDC4);
  static const Color secondaryDark = Color(0xFF2BBBAD);
  static const Color secondaryLight = Color(0xFF7EE0DA);

  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textDisabled = Color(0xFFADB5BD);

  // Semantic Colors
  static const Color successColor = Color(0xFF28A745);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFDC3545);
  static const Color infoColor = Color(0xFF17A2B8);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8B5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF7EE0DA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static const Color shadowColor = Color(0x1A000000);
  static const Color cardShadow = Color(0x0D000000);

  // Border Colors
  static const Color borderColor = Color(0xFFE9ECEF);
  static const Color dividerColor = Color(0xFFDEE2E6);
}