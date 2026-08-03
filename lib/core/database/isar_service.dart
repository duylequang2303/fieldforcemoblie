import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

/// Service khởi tạo và quản lý Isar Database.
/// Isar được dùng để lưu dữ liệu offline (fsm.order, stock.move, timesheet...).
///
/// Cách dùng: gọi [IsarService.instance.init(schemas)] khi app khởi động,
/// sau đó truy cập [IsarService.instance.db].
class IsarService {
  IsarService._();
  static final IsarService instance = IsarService._();

  Isar? _db;

  /// Trả về Isar instance đang hoạt động.
  /// Throw [StateError] nếu chưa gọi [init()].
  Isar get db {
    if (_db == null || !_db!.isOpen) {
      throw StateError(
        'IsarService chưa được khởi tạo. Gọi IsarService.instance.init() trước.',
      );
    }
    return _db!;
  }

  @visibleForTesting
  set dbForTest(Isar isarDB) {
    _db = isarDB;
  }

  bool get isInitialized => _db != null && _db!.isOpen;

  /// Khởi tạo Isar với danh sách schema.
  /// Schemas được đăng ký từ từng feature model (FsmOrder, StockMove, ...).
  Future<void> init(List<CollectionSchema<dynamic>> schemas) async {
    if (isInitialized) return;

    try {
      String path = '';
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        path = dir.path;
      }

      _db = await Isar.open(
        schemas,
        directory: path,
        name: 'fieldforce_db',
        inspector: false,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Lỗi khởi tạo Isar DB: $e\n$stackTrace');
      }
    }
  }

  /// Đóng kết nối Isar (thường không cần gọi).
  Future<void> dispose() async {
    await _db?.close();
    _db = null;
  }
}
