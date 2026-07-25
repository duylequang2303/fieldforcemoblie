import 'package:flutter/material.dart';

/// Theme Configuration for Field Force Mobile (Sortscape-inspired)
class AppTheme {
  // Tokens
  static const Color primary = Color(0xFF5B9E1C);
  static const Color secondary = Color(0xFF4A8A1A);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
        onPrimary: surface,
        onSecondary: surface,
        onBackground: textPrimary,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: background,
      
      // AppBar Theme: background primary green, title trắng, elevation 2
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: surface,
        elevation: 2,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: surface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.normal, // Hallmark: Typography purity (no italics)
        ),
      ),

      // Bottom Navigation Theme: Elevation 8, fixed type, active/inactive colors
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      ),

      // Card Theme: Border radius 8px, nhẹ elevation 2
      cardTheme: CardTheme(
        color: surface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Text Theme
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        labelLarge: TextStyle(color: textSecondary),
      ),
    );
  }
}
