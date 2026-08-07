import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Ước lượng dung lượng dữ liệu ngoại tuyến (thư mục documents của app).
/// Dùng cho dòng "Dữ liệu ngoại tuyến" trong Settings, đồng thời cung cấp tuỳ chọn Clear Cache.
class OfflineStorageService {
  OfflineStorageService._();
  static final OfflineStorageService instance = OfflineStorageService._();

  /// Tổng byte của mọi file trong thư mục documents (đệ quy).
  Future<int> bytes() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      int total = 0;
      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            total += await entity.length();
          } catch (_) {}
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<Directory?> _cacheDirectory() async {
    try {
      return await getTemporaryDirectory();
    } catch (_) {
      return null;
    }
  }

  /// Lấy dung lượng có thể xóa (hạt nhân là ảnh cached và temp, KHÔNG bao gồm Isar DB)
  Future<int> clearableBytes() async {
    try {
      final dir = await _cacheDirectory();
      if (dir == null || !await dir.exists()) return 0;
      int total = 0;
      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            total += await entity.length();
          } catch (_) {}
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Xóa cache files (hình ảnh, temp - KHÔNG xóa Isar DB)
  Future<int> clearCache() async {
    try {
      final dir = await _cacheDirectory();
      if (dir == null || !await dir.exists()) return 0;
      int cleared = 0;
      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            final size = await entity.length();
            await entity.delete();
            cleared += size;
          } catch (_) {}
        }
      }
      return cleared;
    } catch (_) {
      return 0;
    }
  }

  /// Chuỗi định dạng MB, ví dụ "12.4 MB".
  Future<String> formatted() async {
    final b = await bytes();
    final mb = b / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  /// Định dạng số bytes truyền vào sang chuỗi MB.
  String formatBytes(int b) {
    final mb = b / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}
