import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Wrapper an toàn cho Image.file có errorBuilder mặc định
/// Tránh crash giao diện khi file vật lý bị mất (xóa, di chuyển, quyền truy cập).
class SafeImageFile extends StatelessWidget {
  const SafeImageFile({
    super.key,
    required this.file,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
  });

  final File file;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final child = Image.file(
      file,
      width: width,
      height: height,
      fit: fit,
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