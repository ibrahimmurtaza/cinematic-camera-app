import 'package:flutter/material.dart';

class AppTheme {
  static const Color scaffoldBackground = Color(0xFF070B10);
  static const Color panelBackground = Color(0xFF121A24);
  static const Color accentColor = Color(0xFF7DD3FC);
  static const Color accentSecondary = Color(0xFF8B5CF6);
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFFB7C3D1);
  static const Color borderColor = Color(0xFF2C3A4A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: accentSecondary,
        surface: panelBackground,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.04,
        ),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: textPrimary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: panelBackground,
        side: const BorderSide(color: borderColor),
        labelStyle: const TextStyle(color: textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
