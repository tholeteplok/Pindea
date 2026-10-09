import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/database/device_database.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_dimensions.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../providers/sync_providers.dart';
import 'qr_pairing_dialog.dart';
import 'qr_scanner_sheet.dart';

/// Centralized Bottom Sheet for Sync Status and Device Pairing
class SyncStatusSheet extends ConsumerStatefulWidget {
  const SyncStatusSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      title: 'Sinkronisasi LAN & Perangkat',
      child: const SyncStatusSheet(),
    );
  }

  @override
  ConsumerState<SyncStatusSheet> createState() => _SyncStatusSheetState();
}

class _SyncStatusSheetState extends ConsumerState<SyncStatusSheet> {
  bool _isSyncing = false;
  String? _syncMessage;

  Future<void> _triggerManualSync() async {
    setState(() {
      _isSyncing = true;
      _syncMessage = null;
    });

    final hubServer = ref.read(syncHubServerProvider);
    if (!hubServer.isRunning) {
      await hubServer.start();
    }

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _syncMessage = 'Sinkronisasi selesai (LAN Hub aktif port ${hubServer.port})';
      });
    }
  }

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  void _openPairing() {
    if (_isMobile) {
      Navigator.of(context).pop(); // Close sheet
      QrScannerSheet.show(context);
    } else {
      final hubServer = ref.read(syncHubServerProvider);
      final userAsync = ref.read(deviceDatabaseProvider);

      userAsync.select(userAsync.localUsers).get().then((users) {
        final userId = users.isNotEmpty ? users.first.userId : 'local-user';
        final payload = hubServer.createPairingSession(userId: userId);
        if (mounted) {
          Navigator.of(context).pop(); // Close sheet
          QrPairingDialog.show(context, payload);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hubServer = ref.watch(syncHubServerProvider);
    final deviceDb = ref.watch(deviceDatabaseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. HUB STATUS CARD (WAJIB PAKAI KARTU)
        AppCard(
          backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hubServer.isRunning ? AppColors.syncConnected : AppColors.syncWarning,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hubServer.isRunning ? 'LAN Hub Aktif' : 'LAN Hub Menunggu Koneksi',
                      style: AppTypography.headingSmall(isDark: isDark),
                    ),
                    const SizedBox(height: AppDimensions.space2),
                    Text(
                      hubServer.isRunning
                          ? 'Mendengarkan di port ${hubServer.port} (Jaringan Lokal)'
                          : 'Hub akan otomatis menyala saat pairing/sync dimulai',
                      style: AppTypography.bodySmall(isDark: isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.space16),

        // 2. PAIRED DEVICES LIST
        Row(
          children: [
            Text(
              'Perangkat Terpasang',
              style: AppTypography.headingSmall(isDark: isDark),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _openPairing,
              icon: PhosphorIcon(
                _isMobile ? PhosphorIconsRegular.camera : PhosphorIconsRegular.qrCode,
                size: 16,
              ),
              label: Text(_isMobile ? 'Pindai QR' : 'Tambah (QR)'),
            ),
          ],
        ),

        StreamBuilder<List<PairedDevice>>(
          stream: deviceDb.select(deviceDb.pairedDevices).watch(),
          builder: (context, snapshot) {
            final devices = snapshot.data ?? [];
            if (devices.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.space12),
                child: Text(
                  _isMobile
                      ? 'Belum ada perangkat yang dipasangkan. Klik "Pindai QR" untuk menyorot QR di layar PC.'
                      : 'Belum ada perangkat yang dipasangkan. Klik "Tambah (QR)" untuk menampilkan QR bagi HP Anda.',
                  style: AppTypography.bodySmall(isDark: isDark),
                ),
              );
            }

            return Column(
              children: devices.map((d) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppDimensions.space12),
                    child: Row(
                      children: [
                        PhosphorIcon(
                          d.platform == 'android' ? PhosphorIconsRegular.deviceMobile : PhosphorIconsRegular.desktop,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.name, style: AppTypography.bodyMedium(isDark: isDark)),
                              Text(
                                'Terakhir sinkron: ${d.lastSyncAt != null ? "${d.lastSyncAt!.hour}:${d.lastSyncAt!.minute}" : "Baru dipasangkan"}',
                                style: AppTypography.bodySmall(isDark: isDark),
                              ),
                            ],
                          ),
                        ),
                        const PhosphorIcon(PhosphorIconsFill.checkCircle, size: 16, color: AppColors.syncConnected),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),

        if (_syncMessage != null) ...[
          const SizedBox(height: AppDimensions.space8),
          Text(
            _syncMessage!,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall(isDark: isDark).copyWith(
              color: AppColors.syncConnected,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],

        const SizedBox(height: AppDimensions.space16),

        // 3. ACTION BUTTON: SINKRONKAN SEKARANG
        AppButton(
          label: _isSyncing ? 'Sedang Menyinkronkan...' : 'Sinkronkan Sekarang',
          icon: _isSyncing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const PhosphorIcon(PhosphorIconsRegular.arrowsClockwise, size: 18),
          onPressed: _isSyncing ? null : _triggerManualSync,
        ),
      ],
    );
  }
}
