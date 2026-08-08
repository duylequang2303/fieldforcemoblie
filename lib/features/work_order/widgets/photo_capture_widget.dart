import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/widgets/safe_image_file.dart';

/// Widget chụp và hiển thị nhiều ảnh hiện trường.
class PhotoCaptureWidget extends StatelessWidget {
  static const int _maxPhotos = 10;
  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

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
              // Photo thumbnails
              ...photoPaths.asMap().entries.map(
                    (entry) => _PhotoThumbnail(
                      path: entry.value,
                      onRemove: () => onRemove(entry.key),
                    ),
                  ),
              // Add button
              _AddPhotoButton(onTap: () => _pickPhoto(context)),
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
                await _captureFromSource(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Chọn từ thư viện'),
              onTap: () async {
                Navigator.pop(context);
                await _captureFromSource(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureFromSource(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final images = source == ImageSource.gallery
        ? await picker.pickMultiImage(imageQuality: 70, maxWidth: 1280)
        : [
            await picker.pickImage(
                source: source, imageQuality: 70, maxWidth: 1280)
          ].whereType<XFile>().toList();

    final currentCount = photoPaths.length;
    final maxAllowed = _maxPhotos - currentCount;

    final validImages = <XFile>[];
    for (final img in images) {
      try {
        final size = await img.length();
        if (size > _maxFileSizeBytes) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ảnh ${img.path.split('/').last} vượt quá 10MB, bỏ qua.'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          continue;
        }
        validImages.add(img);
      } on Exception catch (e, stackTrace) {
        logger.w('PhotoCaptureWidget: cannot read ${img.path}',
            error: e, stackTrace: stackTrace);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể đọc ảnh ${img.path.split('/').last}: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }

    if (validImages.length > maxAllowed) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tối đa $_maxPhotos ảnh. Có thể thêm $maxAllowed ảnh nữa.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      for (final img in validImages.take(maxAllowed)) {
        onAdd(img.path);
      }
    } else if (validImages.isNotEmpty) {
      for (final img in validImages) {
        onAdd(img.path);
      }
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
            cacheWidth: 176,
            cacheHeight: 176,
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
