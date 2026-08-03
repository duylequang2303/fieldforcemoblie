import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Ước lượng dung lượng dữ liệu ngoại tuyến (thư mục documents của app).
/// Dùng cho dòng "Dữ liệu ngoại tuyến" trong Settings.
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

  /// Chuỗi định dạng MB, ví dụ "12.4 MB".
  Future<String> formatted() async {
    final b = await bytes();
    final mb = b / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}
