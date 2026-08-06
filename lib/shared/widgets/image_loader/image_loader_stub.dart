import 'package:flutter/material.dart';

/// Hàm dựng Image.file stub (báo lỗi nếu chạy trên nền tảng không hỗ trợ).
Widget buildImageFile(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  int? cacheWidth,
  int? cacheHeight,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  throw UnsupportedError('Không hỗ trợ Image.file trên nền tảng này.');
}
