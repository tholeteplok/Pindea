import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_dimensions.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../pairing/pairing_payload.dart';
import '../providers/sync_providers.dart';

/// Smart QR Pairing Sheet for Mobile Devices
/// Defaults to Camera Scanner for scanning PC screen, with fallback tabs to Show QR or Input Code.
class QrScannerSheet extends ConsumerStatefulWidget {
  const QrScannerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QrScannerSheet(),
    );
  }

  @override
  ConsumerState<QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends ConsumerState<QrScannerSheet> {
  int _activeTabIndex = 0; // 0: Scan Camera, 1: Show QR, 2: Manual Code
  MobileScannerController? _scannerController;
  bool _isProcessingScan = false;
  String? _errorMessage;

  // Show QR Host State
  PairingPayload? _hostPayload;
  int _hostRemainingSeconds = 120;
  Timer? _hostTimer;

  // Manual Input State
  final TextEditingController _manualInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _initHostPayload();
  }

  void _initHostPayload() {
    final hubServer = ref.read(syncHubServerProvider);
    final deviceDb = ref.read(deviceDatabaseProvider);

    deviceDb.select(deviceDb.localUsers).get().then((users) {
      if (!mounted) return;
      final userId = users.isNotEmpty ? users.first.userId : 'local-user';
      final payload = hubServer.createPairingSession(userId: userId);
      setState(() {
        _hostPayload = payload;
        final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        _hostRemainingSeconds = payload.expiresAt - nowSeconds;
      });

      _hostTimer?.cancel();
      _hostTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (_hostRemainingSeconds > 0) {
          setState(() => _hostRemainingSeconds--);
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _hostTimer?.cancel();
    _scannerController?.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  Future<void> _handleScannedString(String rawData) async {
    if (_isProcessingScan) return;

    setState(() {
      _isProcessingScan = true;
      _errorMessage = null;
    });

    try {
      final Map<String, dynamic> jsonMap;
      if (rawData.startsWith('{')) {
        jsonMap = jsonDecode(rawData) as Map<String, dynamic>;
      } else {
        // Try Base64 decoding if encoded
        final decoded = utf8.decode(base64Decode(rawData));
        jsonMap = jsonDecode(decoded) as Map<String, dynamic>;
      }

      final payload = PairingPayload.fromJson(jsonMap);
      await _executePairing(payload);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingScan = false;
          _errorMessage = 'Format QR tidak dikenali sebagai kode pairing Pindea.';
        });
      }
    }
  }

  Future<void> _executePairing(PairingPayload payload) async {
    final syncClient = ref.read(syncClientEngineProvider);
    final deviceDb = ref.read(deviceDatabaseProvider);

    final localUsers = await deviceDb.select(deviceDb.localUsers).get();
    final localDeviceId = localUsers.isNotEmpty ? 'client-${localUsers.first.userId}' : 'mobile-device';
    final localDeviceName = localUsers.isNotEmpty ? localUsers.first.displayName : 'Android Phone';

    try {
      final success = await syncClient.pairWithHub(
        payload,
        deviceId: localDeviceId,
        deviceName: localDeviceName,
        platform: 'android',
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil terpasang dengan ${payload.name}!'),
              backgroundColor: AppColors.syncConnected,
            ),
          );
        } else {
          setState(() {
            _isProcessingScan = false;
            _errorMessage = 'Gagal terhubung ke IP Hub. Pastikan kedua perangkat di Wi-Fi yang sama.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingScan = false;
          _errorMessage = 'Error koneksi pairing: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusSheet),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppDimensions.space8, bottom: AppDimensions.space4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16, vertical: AppDimensions.space8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Hubungkan ke Komputer / PC',
                    style: AppTypography.headingSmall(isDark: isDark),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Mode Selection Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
            child: Row(
              children: [
                _buildTabButton(0, 'Pindai QR PC', PhosphorIconsRegular.camera, isDark),
                const SizedBox(width: AppDimensions.space8),
                _buildTabButton(1, 'Tampilkan QR', PhosphorIconsRegular.qrCode, isDark),
                const SizedBox(width: AppDimensions.space8),
                _buildTabButton(2, 'Input Manual', PhosphorIconsRegular.keyboard, isDark),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.space12),

          // Tab Content
          Expanded(
            child: switch (_activeTabIndex) {
              0 => _buildCameraScannerTab(isDark),
              1 => _buildShowQrTab(isDark),
              2 => _buildManualInputTab(isDark),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, PhosphorIconData icon, bool isDark) {
    final isSelected = _activeTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTabIndex = index;
            _errorMessage = null;
          });
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightActiveChip)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.darkTextPrimary : const Color(0xFF1F1F1F))
                  : (isDark ? AppColors.darkOutline : AppColors.lightOutline),
              width: AppDimensions.borderWidthThin,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(
                icon,
                size: 15,
                color: isSelected
                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                    : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              ),
              const SizedBox(width: AppDimensions.space4),
              Text(
                label,
                style: AppTypography.bodySmall(isDark: isDark).copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                      : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraScannerTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16, vertical: AppDimensions.space4),
          child: Text(
            'Arahkan kamera ke QR Code yang ditampilkan pada layar PC Pindea Anda.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall(isDark: isDark),
          ),
        ),
        const SizedBox(height: AppDimensions.space8),

        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.border(isDark: isDark)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_scannerController != null)
                  MobileScanner(
                    controller: _scannerController!,
                    onDetect: (capture) {
                      final barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        final val = barcode.rawValue;
                        if (val != null && val.isNotEmpty) {
                          _handleScannedString(val);
                          break;
                        }
                      }
                    },
                  ),

                // Viewfinder Target Frame
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 2.5,
                    ),
                  ),
                ),

                // Controls (Torch Toggle)
                Positioned(
                  bottom: AppDimensions.space16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _scannerController?.toggleTorch(),
                        icon: const PhosphorIcon(PhosphorIconsRegular.flashlight, color: Colors.white, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: const EdgeInsets.all(AppDimensions.space12),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space16),
                      IconButton(
                        onPressed: () => _scannerController?.switchCamera(),
                        icon: const PhosphorIcon(PhosphorIconsRegular.cameraRotate, color: Colors.white, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: const EdgeInsets.all(AppDimensions.space12),
                        ),
                      ),
                    ],
                  ),
                ),

                // Processing Indicator
                if (_isProcessingScan)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: AppDimensions.space12),
                          Text(
                            'Menghubungkan ke Hub PC...',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(AppDimensions.space12),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(isDark: isDark).copyWith(
                color: AppColors.destructive(isDark: isDark),
              ),
            ),
          ),
        const SizedBox(height: AppDimensions.space16),
      ],
    );
  }

  Widget _buildShowQrTab(bool isDark) {
    if (_hostPayload == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isExpired = _hostRemainingSeconds <= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        children: [
          Text(
            'Tampilkan kode ini jika perangkat lain yang ingin memindai HP ini.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall(isDark: isDark),
          ),
          const SizedBox(height: AppDimensions.space16),

          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.border(isDark: isDark)),
            ),
            child: isExpired
                ? SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(
                      child: Text(
                        'QR Kedaluwarsa',
                        style: AppTypography.headingSmall(isDark: false).copyWith(color: Colors.red),
                      ),
                    ),
                  )
                : QrImageView(
                    data: _hostPayload!.toJsonString(),
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
          ),

          const SizedBox(height: AppDimensions.space12),
          Text(
            isExpired ? 'Waktu habis. Silakan buat sesi baru.' : 'Berlaku dalam $_hostRemainingSeconds detik',
            style: AppTypography.monoLabel(isDark: isDark).copyWith(
              color: isExpired ? AppColors.destructive(isDark: isDark) : AppColors.textSecondary(isDark: isDark),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          if (isExpired)
            AppButton.secondary(
              label: 'Perbarui Kode QR',
              icon: PhosphorIcons.arrowClockwise(),
              onPressed: _initHostPayload,
            ),
        ],
      ),
    );
  }

  Widget _buildManualInputTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Jika kamera bermasalah, tempelkan teks payload atau token pairing yang dibuat oleh PC di sini:',
            style: AppTypography.bodySmall(isDark: isDark),
          ),
          const SizedBox(height: AppDimensions.space12),

          TextField(
            controller: _manualInputController,
            maxLines: 4,
            style: AppTypography.body(isDark: isDark),
            decoration: InputDecoration(
              hintText: 'Tempel JSON pairing atau Base64 payload di sini...',
              hintStyle: AppTypography.bodySmall(isDark: isDark),
              filled: true,
              fillColor: AppColors.surface(isDark: isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                borderSide: BorderSide(color: AppColors.border(isDark: isDark)),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.space16),

          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: AppTypography.bodySmall(isDark: isDark).copyWith(
                color: AppColors.destructive(isDark: isDark),
              ),
            ),
            const SizedBox(height: AppDimensions.space12),
          ],

          AppButton.primary(
            label: _isProcessingScan ? 'Menghubungkan...' : 'Hubungkan Manual',
            onPressed: _isProcessingScan
                ? null
                : () {
                    final text = _manualInputController.text.trim();
                    if (text.isNotEmpty) {
                      _handleScannedString(text);
                    }
                  },
          ),
        ],
      ),
    );
  }
}
