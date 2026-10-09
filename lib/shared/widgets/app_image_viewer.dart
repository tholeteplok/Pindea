import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/tokens/app_dimensions.dart';
import '../../core/theme/tokens/app_typography.dart';

/// Centralized Fullscreen Interactive Image Viewer
/// Provides pinch-to-zoom, panning, and seamless dismissal.
class AppImageViewer extends StatelessWidget {
  final String imagePath;
  final String? title;

  const AppImageViewer({
    super.key,
    required this.imagePath,
    this.title,
  });

  /// Open fullscreen image viewer modal
  static Future<void> open(
    BuildContext context, {
    required String imagePath,
    String? title,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.92),
        pageBuilder: (context, animation, secondaryAnimation) => AppImageViewer(
          imagePath: imagePath,
          title: title,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
    final fileName = title ?? (file.existsSync() ? p.basename(imagePath) : 'Pratinjau Gambar');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Interactive Zoom & Pan Area
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.5,
                clipBehavior: Clip.none,
                child: file.existsSync()
                    ? Image.file(
                        file,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => _buildErrorContent(),
                      )
                    : _buildErrorContent(),
              ),
            ),

            // Top Action Bar (Title & Close Button)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                  vertical: AppDimensions.space12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const PhosphorIcon(PhosphorIconsRegular.x, color: Colors.white, size: 24),
                      tooltip: 'Tutup',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    Expanded(
                      child: Text(
                        fileName,
                        style: AppTypography.headingSmall(isDark: true).copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Floating Hint
            Positioned(
              bottom: AppDimensions.space20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space12,
                    vertical: AppDimensions.space6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                  ),
                  child: Text(
                    'Cubit untuk memperbesar · Geser untuk memindahkan',
                    style: AppTypography.bodySmall(isDark: true).copyWith(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PhosphorIcon(PhosphorIconsRegular.imageBroken, size: 48, color: Colors.white54),
        const SizedBox(height: AppDimensions.space12),
        Text(
          'Berkas gambar tidak ditemukan atau rusak',
          style: AppTypography.bodyMedium(isDark: true).copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}
