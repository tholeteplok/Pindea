import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_dimensions.dart';
import '../../../core/theme/tokens/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../pairing/pairing_payload.dart';

/// QR Pairing Modal Dialog for Desktop Hub / Pairing initiator
/// Shows QR Code with 120-second countdown per PRD 13.3 specification.
class QrPairingDialog extends StatefulWidget {
  final PairingPayload payload;

  const QrPairingDialog({
    super.key,
    required this.payload,
  });

  static Future<void> show(BuildContext context, PairingPayload payload) {
    return showDialog(
      context: context,
      builder: (_) => QrPairingDialog(payload: payload),
    );
  }

  @override
  State<QrPairingDialog> createState() => _QrPairingDialogState();
}

class _QrPairingDialogState extends State<QrPairingDialog> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _remainingSeconds = widget.payload.expiresAt - nowSeconds;
    if (_remainingSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          timer.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpired = _remainingSeconds <= 0;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: BorderSide(
          color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
          width: AppDimensions.borderWidthThin,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              'Pairing Perangkat Baru',
              style: AppTypography.headingSmall(isDark: isDark),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 20),
            splashRadius: 18,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pindai QR ini dari aplikasi Pindea di HP Anda yang berada dalam jaringan Wi-Fi yang sama.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(isDark: isDark),
            ),
            const SizedBox(height: AppDimensions.space16),

            // QR Code Container
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.lightOutline),
              ),
              child: isExpired
                  ? const SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: Text(
                          'QR Kedaluwarsa\nSilakan buat QR baru',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : QrImageView(
                      data: widget.payload.toJsonString(),
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
            ),

            const SizedBox(height: AppDimensions.space12),

            // Expiry countdown badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space12,
                vertical: AppDimensions.space4,
              ),
              decoration: BoxDecoration(
                color: isExpired
                    ? AppColors.lightDestructive.withAlpha(30)
                    : (isDark ? AppColors.darkActiveChip : AppColors.lightActiveChip),
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: Text(
                isExpired ? 'Kedaluwarsa' : 'Berlaku: $_remainingSeconds detik',
                style: AppTypography.monoLabel(isDark: isDark).copyWith(
                  color: isExpired ? AppColors.lightDestructive : null,
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.space8),
            Text(
              'Hub: ${widget.payload.name} (${widget.payload.addresses.first}:${widget.payload.port})',
              style: AppTypography.bodySmall(isDark: isDark).copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: AppButton(
            label: 'Selesai',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
