import 'dart:io';
import 'package:flutter/material.dart';

/// Dựng Image.file thực tế bằng thư viện `dart:io` cho thiết bị di động.
Widget buildImageFile(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  int? cacheWidth,
  int? cacheHeight,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    cacheWidth: cacheWidth,
    cacheHeight: cacheHeight,
    errorBuilder: errorBuilder,
  );
}
