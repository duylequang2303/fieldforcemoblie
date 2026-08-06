import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/safe_image_file.dart';

/// Widget chụp và hiển thị nhiều ảnh hiện trường.
class PhotoCaptureWidget extends StatelessWidget {
  const PhotoCaptureWidget({
    super.key,
    required this.photoPaths,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> photoPaths;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ảnh hiện trường',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add button
              _AddPhotoButton(onTap: () => _pickPhoto(context)),

              // Photo thumbnails
              ...photoPaths.asMap().entries.map(
                    (entry) => _PhotoThumbnail(
                      path: entry.value,
                      onRemove: () => onRemove(entry.key),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickPhoto(BuildContext context) async {
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
              onTap: () async {
                Navigator.pop(context);
                await _captureFromSource(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Chọn từ thư viện'),
              onTap: () async {
                Navigator.pop(context);
                await _captureFromSource(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final images = source == ImageSource.gallery
        ? await picker.pickMultiImage(imageQuality: 70, maxWidth: 1280)
        : [
            await picker.pickImage(
                source: source, imageQuality: 70, maxWidth: 1280)
          ].whereType<XFile>().toList();

    for (final img in images) {
      onAdd(img.path);
    }
  }
}

class _AddPhotoButton extends StatelessWidget {
  const _AddPhotoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        height: 88,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1.5,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primary.withValues(alpha: 0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined,
                color: AppColors.primary, size: 28),
            const SizedBox(height: 4),
            const Text(
              'Thêm ảnh',
              style: TextStyle(fontSize: 10, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SafeImageFile(
            path: path,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(12),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
