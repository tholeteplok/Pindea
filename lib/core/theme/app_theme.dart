import 'package:flutter/material.dart';
import 'tokens/app_colors.dart';
import 'tokens/app_dimensions.dart';
import 'tokens/app_typography.dart';

/// Centralized ThemeData Factory for Pindea
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        outline: AppColors.lightOutline,
        error: AppColors.lightDestructive,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: AppDimensions.borderWidthThin,
        space: 1.0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: const BorderSide(
            color: AppColors.lightOutline,
            width: AppDimensions.borderWidthThin,
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.headingLarge(isDark: false),
        headlineMedium: AppTypography.headingMedium(isDark: false),
        titleMedium: AppTypography.headingSmall(isDark: false),
        bodyLarge: AppTypography.bodyLarge(isDark: false),
        bodyMedium: AppTypography.bodyMedium(isDark: false),
        bodySmall: AppTypography.bodySmall(isDark: false),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.darkOutline,
        error: AppColors.darkDestructive,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: AppDimensions.borderWidthThin,
        space: 1.0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: const BorderSide(
            color: AppColors.darkOutline,
            width: AppDimensions.borderWidthThin,
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.headingLarge(isDark: true),
        headlineMedium: AppTypography.headingMedium(isDark: true),
        titleMedium: AppTypography.headingSmall(isDark: true),
        bodyLarge: AppTypography.bodyLarge(isDark: true),
        bodyMedium: AppTypography.bodyMedium(isDark: true),
        bodySmall: AppTypography.bodySmall(isDark: true),
      ),
    );
  }
}
