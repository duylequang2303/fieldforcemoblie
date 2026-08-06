import 'package:flutter/material.dart';

/// Dựng Image bằng Image.network cho môi trường Web (tránh dùng `dart:io` File).
Widget buildImageFile(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  int? cacheWidth,
  int? cacheHeight,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return Image.network(
    path,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}
