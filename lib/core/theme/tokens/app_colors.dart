import 'package:flutter/material.dart';

/// Centralized Color Tokens for Pindea
/// Enforcing zero hardcoding across the entire application.
class AppColors {
  AppColors._();

  // App Background & Surface
  static const Color lightBackground = Color(0xFFF5F5F3);
  static const Color darkBackground = Color(0xFF121212);

  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1E1E1E);

  static const Color lightSurfaceVariant = Color(0xFFF0F0EE);
  static const Color darkSurfaceVariant = Color(0xFF282828);

  // Border & Outlines
  static const Color lightOutline = Color(0xFFE3E3E0);
  static const Color darkOutline = Color(0xFF2E2E2E);

  static const Color lightDivider = Color(0xFFEEEEEC);
  static const Color darkDivider = Color(0xFF242424);

  // Typography Colors
  static const Color lightTextPrimary = Color(0xFF1F1F1F);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);

  static const Color lightTextSecondary = Color(0xFF5F5F5F);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  static const Color lightTextMuted = Color(0xFF9E9E9E);
  static const Color darkTextMuted = Color(0xFF757575);

  // Semantic & Action Colors
  static const Color lightDestructive = Color(0xFFC62828);
  static const Color darkDestructive = Color(0xFFEF9A9A);

  static const Color lightActiveChip = Color(0xFFE0E0E0);
  static const Color darkActiveChip = Color(0xFF3A3A3A);

  // Semantic Dynamic Accessors
  static Color background({required bool isDark}) => isDark ? darkBackground : lightBackground;
  static Color surface({required bool isDark}) => isDark ? darkSurface : lightSurface;
  static Color border({required bool isDark}) => isDark ? darkOutline : lightOutline;
  static Color textPrimary({required bool isDark}) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary({required bool isDark}) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color textMuted({required bool isDark}) => isDark ? darkTextMuted : lightTextMuted;
  static Color destructive({required bool isDark}) => isDark ? darkDestructive : lightDestructive;
  static Color accent({required bool isDark}) => isDark ? qnYellowDark : const Color(0xFFD4A373);

  // Sync Status Colors
  static const Color syncConnected = Color(0xFF2E7D32);

  static const Color syncSyncing = Color(0xFF1976D2);
  static const Color syncWarning = Color(0xFFF57F17);
  static const Color syncError = Color(0xFFC62828);
  static const Color syncOffline = Color(0xFF9E9E9E);

  // Quick Note Pastel Colors (8 Fixed Swatches, UI Spec 3.1)
  // Light Mode Colors
  static const Color qnYellowLight = Color(0xFFFFF176);
  static const Color qnGreenLight = Color(0xFFC5E1A5);
  static const Color qnBlueLight = Color(0xFFB3E5FC);
  static const Color qnPinkLight = Color(0xFFF8BBD0);
  static const Color qnOrangeLight = Color(0xFFFFCC80);
  static const Color qnPurpleLight = Color(0xFFD1C4E9);
  static const Color qnTealLight = Color(0xFFB2DFDB);
  static const Color qnGrayLight = Color(0xFFE0E0E0);

  // Dark Mode Colors
  static const Color qnYellowDark = Color(0xFF5C5320);
  static const Color qnGreenDark = Color(0xFF3E5A2E);
  static const Color qnBlueDark = Color(0xFF2B4C5C);
  static const Color qnPinkDark = Color(0xFF5E3345);
  static const Color qnOrangeDark = Color(0xFF5F4220);
  static const Color qnPurpleDark = Color(0xFF43385E);
  static const Color qnTealDark = Color(0xFF2B5450);
  static const Color qnGrayDark = Color(0xFF3A3A3A);
}

/// 8 Preset Quick Note Color Options
enum QuickNoteColor {
  yellow,
  green,
  blue,
  pink,
  orange,
  purple,
  teal,
  gray;

  Color getColor({required bool isDark}) {
    if (isDark) {
      switch (this) {
        case QuickNoteColor.yellow:
          return AppColors.qnYellowDark;
        case QuickNoteColor.green:
          return AppColors.qnGreenDark;
        case QuickNoteColor.blue:
          return AppColors.qnBlueDark;
        case QuickNoteColor.pink:
          return AppColors.qnPinkDark;
        case QuickNoteColor.orange:
          return AppColors.qnOrangeDark;
        case QuickNoteColor.purple:
          return AppColors.qnPurpleDark;
        case QuickNoteColor.teal:
          return AppColors.qnTealDark;
        case QuickNoteColor.gray:
          return AppColors.qnGrayDark;
      }
    } else {
      switch (this) {
        case QuickNoteColor.yellow:
          return AppColors.qnYellowLight;
        case QuickNoteColor.green:
          return AppColors.qnGreenLight;
        case QuickNoteColor.blue:
          return AppColors.qnBlueLight;
        case QuickNoteColor.pink:
          return AppColors.qnPinkLight;
        case QuickNoteColor.orange:
          return AppColors.qnOrangeLight;
        case QuickNoteColor.purple:
          return AppColors.qnPurpleLight;
        case QuickNoteColor.teal:
          return AppColors.qnTealLight;
        case QuickNoteColor.gray:
          return AppColors.qnGrayLight;
      }
    }
  }

  Color get textColor => const Color(0xFF1F1F1F);
}
