import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/tokens/app_colors.dart';
import '../../core/theme/tokens/app_dimensions.dart';
import '../../core/theme/tokens/app_typography.dart';
import '../../features/notes/presentation/trash/trash_screen.dart';
import '../../features/sync/presentation/sync_status_sheet.dart';

/// Centralized drawer navigation for Pindea
class AppDrawer extends ConsumerWidget {
  final VoidCallback? onExportTap;

  const AppDrawer({
    super.key,
    this.onExportTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: AppColors.surface(isDark: isDark),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.space8),
                        decoration: BoxDecoration(
                          color: AppColors.accent(isDark: isDark).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                        ),
                        child: Icon(
                          PhosphorIcons.bookBookmark(PhosphorIconsStyle.fill),
                          color: AppColors.accent(isDark: isDark),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pindea',
                            style: AppTypography.headingMedium(isDark: isDark),
                          ),
                          Text(
                            'Local-First Notes',
                            style: AppTypography.code(isDark: isDark).copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: AppColors.border(isDark: isDark),
            ),
            const SizedBox(height: AppDimensions.space8),

            // Navigation Items
            _DrawerItem(
              icon: PhosphorIcons.notebook(),
              title: 'Semua Catatan',
              isDark: isDark,
              onTap: () => Navigator.of(context).pop(),
            ),
            _DrawerItem(
              icon: PhosphorIcons.trash(),
              title: 'Kotak Sampah',
              isDark: isDark,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TrashScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: PhosphorIcons.arrowsClockwise(),
              title: 'Status Sinkronisasi',
              isDark: isDark,
              onTap: () {
                Navigator.of(context).pop();
                SyncStatusSheet.show(context);
              },
            ),
            if (onExportTap != null)
              _DrawerItem(
                icon: PhosphorIcons.export(),
                title: 'Ekspor & Cadangan',
                isDark: isDark,
                onTap: () {
                  Navigator.of(context).pop();
                  onExportTap!();
                },
              ),

            const Spacer(),
            Divider(
              height: 1,
              color: AppColors.border(isDark: isDark),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Text(
                'Pindea v1.0 • Offline Ready',
                style: AppTypography.code(isDark: isDark).copyWith(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textPrimary(isDark: isDark),
        size: 22,
      ),
      title: Text(
        title,
        style: AppTypography.body(isDark: isDark).copyWith(fontWeight: FontWeight.w500),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space24,
        vertical: AppDimensions.space4,
      ),
      onTap: onTap,
    );
  }
}
