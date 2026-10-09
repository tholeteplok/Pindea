import 'package:flutter/material.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_dimensions.dart';
import '../../core/theme/tokens/app_typography.dart';

/// Centralized Button System for Pindea
/// Ensures guaranteed minimum 48x48dp touch target.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;
  final bool isSecondary;
  final bool isDestructive;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    Widget? icon,
    this.isSecondary = false,
    this.isDestructive = false,
    this.width,
  }) : leadingIcon = icon;

  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    Widget? icon,
    this.width,
  })  : leadingIcon = icon,
        isSecondary = false,
        isDestructive = false;

  AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    dynamic icon,
    this.width,
  })  : leadingIcon = icon is IconData ? Icon(icon, size: 18) : (icon as Widget?),
        isSecondary = true,
        isDestructive = false;

  AppButton.destructive({
    super.key,
    required this.label,
    this.onPressed,
    dynamic icon,
    this.width,
  })  : leadingIcon = icon is IconData ? Icon(icon, size: 18) : (icon as Widget?),
        isSecondary = false,
        isDestructive = true;

  static Widget icon({
    required IconData icon,
    VoidCallback? onPressed,
    String? tooltip,
    Color? color,
    double size = 20.0,
  }) {
    return IconButton(
      icon: Icon(icon, size: size, color: color),
      tooltip: tooltip,
      onPressed: onPressed,
      splashRadius: 22,
    );
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    Color border;

    if (isDestructive) {
      bg = isDark ? AppColors.darkDestructive : AppColors.lightDestructive;
      fg = Colors.white;
      border = Colors.transparent;
    } else if (isSecondary) {
      bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
      fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
      border = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    } else {
      bg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
      fg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
      border = Colors.transparent;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppDimensions.minTouchTarget,
        minWidth: AppDimensions.minTouchTarget,
      ),
      child: SizedBox(
        width: width,
        height: AppDimensions.buttonHeight,
        child: Material(
          color: onPressed != null ? bg : bg.withAlpha(128),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            side: BorderSide(color: border, width: AppDimensions.borderWidthThin),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    leadingIcon!,
                    const SizedBox(width: AppDimensions.space8),
                  ],
                  Text(
                    label,
                    style: AppTypography.buttonLabel(color: fg),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
