import 'package:flutter/material.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_dimensions.dart';
import '../../core/theme/tokens/app_typography.dart';

/// Centralized Bottom Sheet Wrapper for Pindea
class AppBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusSheet),
        ),
      ),
      builder: (ctx) => AppBottomSheet(
        title: title,
        trailing: trailing,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(
                  top: AppDimensions.space8,
                  bottom: AppDimensions.space12,
                ),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
              ),
            ),

            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenMargin,
                vertical: AppDimensions.space4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.headingSmall(isDark: isDark),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
            const Divider(),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppDimensions.screenMargin),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
