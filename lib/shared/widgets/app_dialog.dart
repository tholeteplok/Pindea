import 'package:flutter/material.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_dimensions.dart';
import '../../core/theme/tokens/app_typography.dart';
import 'app_button.dart';

/// Centralized Confirmation & Alert Dialog for Pindea
class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Batal',
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Batal',
    bool isDestructive = false,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
    );
  }

  static Future<void> showCustom({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: AppColors.surface(isDark: isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            side: BorderSide(
              color: AppColors.border(isDark: isDark),
              width: AppDimensions.borderWidthThin,
            ),
          ),
          title: Text(title, style: AppTypography.headingSmall(isDark: isDark)),
          content: child,
        );
      },
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Batal',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: BorderSide(
          color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
          width: AppDimensions.borderWidthThin,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.headingSmall(isDark: isDark),
      ),
      content: Text(
        message,
        style: AppTypography.bodyMedium(isDark: isDark),
      ),
      actionsPadding: const EdgeInsets.all(AppDimensions.space16),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(
              label: cancelLabel,
              isSecondary: true,
              onPressed: onCancel ?? () => Navigator.of(context).pop(false),
            ),
            const SizedBox(width: AppDimensions.space8),
            AppButton(
              label: confirmLabel,
              isDestructive: isDestructive,
              onPressed: onConfirm,
            ),
          ],
        ),
      ],
    );
  }
}
