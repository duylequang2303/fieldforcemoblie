import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/widgets/error_view.dart';
import '../models/product.dart';
import '../providers/stock_provider.dart';

/// Trang quét mã barcode/QR vật tư.
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _torchOn = false;
  bool _processingBarcode = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text(
              'Quét Vật Tư',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _torchOn ? Icons.flash_on : Icons.flash_off,
                  color: _torchOn ? AppColors.warning : Colors.white,
                ),
                onPressed: () {
                  _controller.toggleTorch();
                  setState(() => _torchOn = !_torchOn);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Camera preview
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: (capture) {
                        if (_processingBarcode) return;
                        final barcode = capture.barcodes.firstOrNull?.rawValue;
                        if (barcode != null) {
                          _onBarcodeDetected(barcode, provider);
                        }
                      },
                    ),
                    // Viewfinder overlay
                    _ScannerOverlay(),
                    // Loading indicator khi đang xử lý
                    if (provider.isLoading)
                      Container(
                        color: Colors.black45,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Result panel
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.white,
                  child: provider.errorMessage != null
                      ? ErrorView(
                          message: provider.errorMessage!,
                          onRetry: () {
                            provider.clearError();
                            setState(() => _processingBarcode = false);
                          },
                        )
                      : provider.scannedProduct != null
                          ? _ProductFoundPanel(
                              product: provider.scannedProduct!,
                              onRecord: (qty) async {
                                // Lấy orderId từ route params nếu có
                                await provider.recordOut(
                                  orderOdooId: 0, // sẽ truyền từ route
                                  qty: qty,
                                );
                                if (context.mounted) {
                                  setState(() => _processingBarcode = false);
                                }
                              },
                              onCancel: () {
                                provider.clearScanned();
                                setState(() => _processingBarcode = false);
                              },
                            )
                          : _WaitingPanel(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onBarcodeDetected(String barcode, StockProvider provider) {
    setState(() => _processingBarcode = true);
    logger.i('ScannerPage: barcode detected = $barcode');
    provider.onBarcodeScanned(barcode);
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondary, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Corner markers
            Positioned(top: 0, left: 0, child: _Corner()),
            Positioned(top: 0, right: 0, child: Transform.scale(scaleX: -1, child: _Corner())),
            Positioned(bottom: 0, left: 0, child: Transform.scale(scaleY: -1, child: _Corner())),
            Positioned(bottom: 0, right: 0, child: Transform.scale(scaleX: -1, scaleY: -1, child: _Corner())),
          ],
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _CornerPainter()),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WaitingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_scanner, size: 48, color: AppColors.onSurfaceMuted),
          SizedBox(height: 12),
          Text(
            'Hướng camera vào mã barcode / QR',
            style: TextStyle(color: AppColors.onSurfaceMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ProductFoundPanel extends StatefulWidget {
  const _ProductFoundPanel({
    required this.product,
    required this.onRecord,
    required this.onCancel,
  });

  final Product product;
  final Future<void> Function(double qty) onRecord;
  final VoidCallback onCancel;

  @override
  State<_ProductFoundPanel> createState() => _ProductFoundPanelState();
}

class _ProductFoundPanelState extends State<_ProductFoundPanel> {
  final _qtyController = TextEditingController(text: '1');

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          if (widget.product.defaultCode != null)
            Text(
              'Mã: ${widget.product.defaultCode}',
              style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 13),
            ),
          const Spacer(),
          // Số lượng
          Row(
            children: [
              const Text('Số lượng:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _qtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
              if (widget.product.uomName != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(widget.product.uomName!),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Huỷ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    final qty = double.tryParse(_qtyController.text) ?? 1.0;
                    widget.onRecord(qty);
                  },
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label: const Text('Xuất kho'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
