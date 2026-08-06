import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/signature_pad.dart';
import '../../../shared/widgets/safe_image_file.dart';

/// Widget thu thập chữ ký khách hàng kèm tên xác nhận.
class CustomerSignatureWidget extends StatefulWidget {
  const CustomerSignatureWidget({
    super.key,
    required this.onSigned,
    this.existingSignaturePath,
    this.existingCustomerName,
  });

  final Future<void> Function({
    required String signaturePath,
    required String customerName,
  }) onSigned;

  final String? existingSignaturePath;
  final String? existingCustomerName;

  @override
  State<CustomerSignatureWidget> createState() =>
      _CustomerSignatureWidgetState();
}

class _CustomerSignatureWidgetState extends State<CustomerSignatureWidget> {
  final _nameController = TextEditingController();
  final _repaintKey = GlobalKey();
  bool _hasSigned = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingCustomerName != null) {
      _nameController.text = widget.existingCustomerName!;
    }
    _hasSigned = widget.existingSignaturePath != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Row(
          children: [
            Icon(Icons.draw_outlined, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'Chữ ký xác nhận khách hàng',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Nếu đã ký — hiển thị ảnh chữ ký
        if (_hasSigned && widget.existingSignaturePath != null) ...[
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.success, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: SafeImageFile(
              path: widget.existingSignaturePath!,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.success, size: 18),
              const SizedBox(width: 6),
              Text(
                'Đã ký: ${widget.existingCustomerName ?? 'Khách hàng'}',
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _hasSigned = false),
                child: const Text('Ký lại'),
              ),
            ],
          ),
        ] else ...[
          // Tên khách hàng
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tên khách hàng ký',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),

          // SignaturePad
          RepaintBoundary(
            key: _repaintKey,
            child: SignaturePad(
              key: const Key('signature_pad'),
              onChanged: (bool hasDrawing) {
                if (hasDrawing && !_hasSigned) {
                  setState(() => _hasSigned = true);
                }
              },
              onClear: () => setState(() => _hasSigned = false),
            ),
          ),

          const SizedBox(height: 12),

          // Confirm button
          FilledButton.icon(
            onPressed: (_hasSigned && !_isSaving) ? _confirmSignature : null,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.check, size: 18),
            label: Text(_isSaving ? 'Đang lưu...' : 'Xác nhận chữ ký'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmSignature() async {
    final customerName = _nameController.text.trim();
    if (customerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên khách hàng')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Capture signature as image
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // Save to app documents
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      await widget.onSigned(
        signaturePath: file.path,
        customerName: customerName,
      );
      if (mounted) setState(() => _hasSigned = true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
