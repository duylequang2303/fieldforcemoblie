/// Design tokens for SortScape/Fieldforce app.
/// All colors, spacing, and radii should be defined here.
/// Widgets must use these tokens instead of hardcoding values.
import 'package:flutter/material.dart';

abstract final class SfTokens {
  SfTokens._();

  // === COLORS ===
  /// Primary brand color (vivid green for active states / CTAs)
  static const Color primary = Color(0xFF5B9E1C);
  static const Color primaryLight = Color(0xFF8BC34A);
  static const Color primaryDark = Color(0xFF3E6B13);
  static const Color primaryMuted = Color(0xFFEAF3DF);

  // Neutral paper scale
  static const Color background = Color(0xFFF7F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0F0EC);
  static const Color outline = Color(0xFFE6E6E0);
  static const Color divider = Color(0xFFECECEC);
  static const Color onSurface = Color(0xFF1B1B1B);
  static const Color onSurfaceMuted = Color(0xFF6B6B6B);
  static const Color onSurfaceWeak = Color(0xFF9E9E9E);

  // Status colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFB28726);
  static const Color warningContainer = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFC62828);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1565C0);
  static const Color infoContainer = Color(0xFFE3F2FD);

  // === SPACING ===
  static const double spacingXxs = 4.0;
  static const double spacingXs = 8.0;
  static const double spacingSm = 12.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // === BORDER RADIUS ===
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  // === ICON SIZES ===
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
}
