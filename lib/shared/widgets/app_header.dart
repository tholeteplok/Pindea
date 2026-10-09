import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_dimensions.dart';
import '../../core/theme/tokens/app_typography.dart';

/// Centralized Seamless App Header for Pindea
/// Header and Action Icons are seamless (no card containers).
class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onWorkspaceTap;
  final VoidCallback? onSyncTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onSettingsTap;
  final bool isSyncing;

  const AppHeader({
    super.key,
    this.title = 'Pindea',
    this.subtitle = 'Personal',
    this.leading,
    this.actions,
    this.onWorkspaceTap,
    this.onSyncTap,
    this.onSearchTap,
    this.onSettingsTap,
    this.isSyncing = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenMargin,
        vertical: AppDimensions.space8,
      ),
      child: SizedBox(
        height: AppDimensions.headerHeight,
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppDimensions.space8),
            ],
            // App Title (Seamless, no card wrapper)
            Text(
              title,
              style: AppTypography.headingLarge(isDark: isDark),
            ),

            const SizedBox(width: AppDimensions.space8),

            // Workspace Switcher Badge (Flat/Clean)
            if (subtitle != null)
              GestureDetector(
                onTap: onWorkspaceTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space4,
                    vertical: AppDimensions.space8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '▾ $subtitle',
                        style: AppTypography.bodySmall(isDark: isDark).copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Action Icons: Clean/Naked without surrounding box containers
            if (actions != null)
              ...actions!
            else ...[
              // 1. Sync Icon
              IconButton(
                onPressed: onSyncTap,
                icon: isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.syncSyncing,
                        ),
                      )
                    : PhosphorIcon(
                        PhosphorIcons.arrowsClockwise(),
                        size: 20,
                        color: AppColors.syncConnected,
                      ),
                tooltip: 'Sync Status',
                splashRadius: 22,
              ),

              // 2. Search Icon (only shown if explicit callback provided)
              if (onSearchTap != null)
                IconButton(
                  onPressed: onSearchTap,
                  icon: PhosphorIcon(
                    PhosphorIcons.magnifyingGlass(),
                    size: 20,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  tooltip: 'Search Notes',
                  splashRadius: 22,
                ),

              // 3. Settings Icon (only shown if explicit callback provided)
              if (onSettingsTap != null)
                IconButton(
                  onPressed: onSettingsTap,
                  icon: PhosphorIcon(
                    PhosphorIcons.gear(),
                    size: 20,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  tooltip: 'Settings',
                  splashRadius: 22,
                ),
            ],
          ],

        ),
      ),
    );
  }
}
