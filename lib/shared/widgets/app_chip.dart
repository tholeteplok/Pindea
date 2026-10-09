import 'package:flutter/material.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_dimensions.dart';
import '../../core/theme/tokens/app_typography.dart';

/// Centralized Filter & Sort Chip for Pindea
/// Uses Space Mono monospace font and 999dp pill radius per UI Spec.
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? trailing;

  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isSelected
        ? (isDark ? AppColors.darkActiveChip : AppColors.lightActiveChip)
        : (isDark ? AppColors.darkSurface : AppColors.lightSurface);

    final border = isSelected
        ? (isDark ? AppColors.darkActiveChip : AppColors.lightActiveChip)
        : (isDark ? AppColors.darkOutline : AppColors.lightOutline);

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        side: BorderSide(
          color: border,
          width: AppDimensions.borderWidthThin,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space12,
            vertical: AppDimensions.space6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.monoLabel(
                  isDark: isDark,
                  weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppDimensions.space4),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
