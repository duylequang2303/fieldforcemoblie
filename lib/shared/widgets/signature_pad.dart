import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../core/theme/app_colors.dart';

/// Widget thu chữ ký khách hàng trực tiếp trên màn hình.
/// Gọi [SignaturePad.show(context)] để hiển thị dialog và nhận PNG bytes.
class SignaturePad extends StatefulWidget {
  const SignaturePad({
    super.key,
    this.onSigned,
    this.onChanged,
    this.onClear,
  });

  final void Function(Uint8List pngBytes)? onSigned;
  final void Function(bool hasDrawing)? onChanged;
  final VoidCallback? onClear;

  /// Hiển thị dialog ký tên, trả về PNG bytes hoặc null nếu huỷ.
  static Future<Uint8List?> show(BuildContext context) async {
    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SignatureDialog(),
    );
  }

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      widget.onChanged?.call(_controller.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.surfaceVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Signature(controller: _controller, height: 200),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () {
                _controller.clear();
                widget.onClear?.call();
                widget.onChanged?.call(false);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Xoá'),
            ),
            if (widget.onSigned != null) ...[  
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_controller.isEmpty) return;
                  final bytes = await _controller.toPngBytes();
                  if (bytes != null) widget.onSigned!(bytes);
                },
                icon: const Icon(Icons.check),
                label: const Text('Xác nhận'),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SignatureDialog extends StatefulWidget {
  @override
  State<_SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<_SignatureDialog> {
  final _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chữ ký khách hàng'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Signature(controller: _controller, height: 200, width: 300),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _controller.clear,
            child: const Text('Ký lại'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_controller.isEmpty) return;
            final bytes = await _controller.toPngBytes();
            if (context.mounted) Navigator.of(context).pop(bytes);
          },
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}
