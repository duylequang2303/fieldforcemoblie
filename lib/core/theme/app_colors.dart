import 'package:flutter/material.dart';

/// SortScape-inspired design system for Fieldforce Mobile.
/// Light neutral paper, clear sans type, green accent on actions.
abstract final class AppColors {
  // Brand / accent — vivid lawn green aligned with SortScape primary actions
  static const Color accent = Color(0xFF4CAF50);
  static const Color accentLight = Color(0xFF81C784);
  static const Color accentDark = Color(0xFF2E7D32);
  static const Color accentMuted = Color(0xFFE8F5E9);

  // Neutral paper scale
  static const Color background = Color(0xFFF7F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0F0EC);
  static const Color surfaceRaised = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFFE6E6E0);
  static const Color divider = Color(0xFFECECEC);
  static const Color onSurface = Color(0xFF1B1B1B);
  static const Color onSurfaceMuted = Color(0xFF6B6B6B);
  static const Color onSurfaceWeak = Color(0xFF9E9E9E);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFB28726);
  static const Color warningContainer = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFC62828);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1565C0);
  static const Color infoContainer = Color(0xFFE3F2FD);

  // Backward-compatible aliases used across the app
  static const Color primary = accent;
  static const Color primaryLight = accentLight;
  static const Color primaryDark = accentDark;
  static const Color secondary = accent;
  static const Color secondaryLight = accentLight;
  static const Color surfaceVariant = surfaceAlt;
  static const Color offlineBanner = accentDark;

  static const Color stageNew = Color(0xFF546E7A);
  static const Color stageInProgress = accent;
  static const Color stageDone = success;
  static const Color stageCancelled = error;

  // Schedule screen
  static const Color schedulePrimary = accentDark; // header bar / CTAs
  static const Color schedulePrimaryContainer = accentMuted; // chip active bg
  static const Color scheduleSurface = surfaceAlt; // list bg
  static const Color scheduleCardAccent = accent; // card accent bar
  static const Color scheduleText = onSurface;
  static const Color scheduleSecondaryText = onSurfaceMuted;
  static const Color scheduleDivider = divider;
  static const Color scheduleChipBackground = surfaceAlt;
  static const Color scheduleChipBorder = outline;
}
