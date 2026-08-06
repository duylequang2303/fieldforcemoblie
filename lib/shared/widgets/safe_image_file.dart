import 'package:flutter/material.dart';
import 'image_loader/image_loader.dart';

/// Wrapper an toàn cho Image.file (hoặc Image.network trên web) có errorBuilder mặc định.
/// Tránh crash giao diện khi tệp tin vật lý bị mất (xóa, di chuyển, quyền truy cập).
class SafeImageFile extends StatelessWidget {
  const SafeImageFile({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.cacheWidth,
    this.cacheHeight,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 28),
          );
    }

    final child = buildImageFile(
      path,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey, size: 28),
            );
      },
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}
