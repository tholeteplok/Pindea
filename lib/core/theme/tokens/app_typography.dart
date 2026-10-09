import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized Typography System for Pindea
/// Scale based on Inter (body & UI), Space Mono (chips & technical meta), and Caveat (handwriting option).
class AppTypography {
  AppTypography._();

  // Heading Styles (Inter)
  static TextStyle headingLarge({required bool isDark}) => GoogleFonts.inter(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle headingMedium({required bool isDark}) => GoogleFonts.inter(
        fontSize: 18.0,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle headingSmall({required bool isDark}) => GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  // Body Styles (Inter)
  static TextStyle bodyLarge({required bool isDark}) => GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle bodyMedium({required bool isDark}) => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      );

  static TextStyle bodySmall({required bool isDark}) => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
      );

  static TextStyle body({required bool isDark}) => bodyMedium(isDark: isDark);

  // Monospace Technical Labels & Chips (Space Mono)
  static TextStyle monoLabel({required bool isDark, FontWeight weight = FontWeight.w600}) =>
      GoogleFonts.spaceMono(
        fontSize: 11.0,
        fontWeight: weight,
        letterSpacing: 0.4,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  static TextStyle code({required bool isDark}) => monoLabel(isDark: isDark);


  // Handwriting Title Option (Caveat)
  static TextStyle handwritingTitle({required bool isDark}) => GoogleFonts.caveat(
        fontSize: 22.0,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      );

  // Button Label (Inter SemiBold)
  static TextStyle buttonLabel({required Color color}) => GoogleFonts.inter(
        fontSize: 13.0,
        fontWeight: FontWeight.w700,
        color: color,
      );
}
