import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/safe_image_file.dart';

/// Widget chụp/chọn ảnh hoá đơn từ camera hoặc gallery.
class ReceiptImagePicker extends StatelessWidget {
  const ReceiptImagePicker({
    super.key,
    this.imagePath,
    required this.onImageSelected,
    this.onRemove,
  });

  final String? imagePath;
  final ValueChanged<String> onImageSelected;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPickerDialog(context),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: imagePath != null
                ? AppColors.primary
                : AppColors.onSurfaceMuted.withValues(alpha: 0.3),
            width: imagePath != null ? 2 : 1,
            style: BorderStyle.solid,
          ),
        ),
        child: imagePath != null
            ? Stack(
                children: [
                  SafeImageFile(
                    file: File(imagePath!),
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  if (onRemove != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 36, color: AppColors.onSurfaceMuted),
                  SizedBox(height: 8),
                  Text(
                    'Chụp/Chọn ảnh hoá đơn',
                    style: TextStyle(
                        color: AppColors.onSurfaceMuted, fontSize: 13),
                  ),
                ],
              ),
      ),
    );
  }

  void _showPickerDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (picked != null) {
      onImageSelected(picked.path);
    }
  }
}
