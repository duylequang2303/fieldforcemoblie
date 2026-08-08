import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/logger.dart';

/// Service khởi tạo và quản lý Isar Database.
/// Isar được dùng để lưu dữ liệu offline (fsm.order, stock.move, timesheet...).
///
/// Cách dùng: gọi [IsarService.instance.init(schemas)] khi app khởi động,
/// sau đó truy cập [IsarService.instance.db].
class IsarService {
  IsarService._();
  static final IsarService instance = IsarService._();

  Isar? _db;
  Object? _initError;
  StackTrace? _initStackTrace;

  /// Trả về Isar instance đang hoạt động.
  /// Throw [StateError] nếu chưa gọi [init()] hoặc init thất bại.
  Isar get db {
    if (_initError != null) {
      throw IsarInitializationException(_initError!, _initStackTrace);
    }
    if (_db == null || !_db!.isOpen) {
      throw StateError(
        'IsarService chưa được khởi tạo. Gọi IsarService.instance.init() trước.',
      );
    }
    return _db!;
  }

  /// Trả về Isar instance dạng nullable (tránh ném StateError).
  Isar? get dbOrNull => (_db != null && _db!.isOpen && _initError == null) ? _db : null;

  @visibleForTesting
  set dbForTest(Isar isarDB) {
    _db = isarDB;
    _initError = null;
    _initStackTrace = null;
  }

  bool get isInitialized => _db != null && _db!.isOpen && _initError == null;

  /// Lỗi khởi tạo (nếu có). Null nếu init thành công hoặc chưa init.
  Object? get initializationError => _initError;

  /// Khởi tạo Isar với danh sách schema.
  /// Schemas được đăng ký từ từng feature model (FsmOrder, StockMove, ...).
  /// 
  /// Ném [IsarInitializationException] nếu khởi tạo thất bại.
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
      _initError = null;
      _initStackTrace = null;
    } catch (e, stackTrace) {
      _initError = e;
      _initStackTrace = stackTrace;
      logger.e('Lỗi khởi tạo Isar DB', error: e, stackTrace: stackTrace);
      throw IsarInitializationException(e, stackTrace);
    }
  }

  /// Đóng kết nối Isar (thường không cần gọi).
  Future<void> dispose() async {
    await _db?.close();
    _db = null;
    _initError = null;
    _initStackTrace = null;
  }
}

/// Exception được ném khi Isar khởi tạo thất bại.
class IsarInitializationException implements Exception {
  final Object error;
  final StackTrace? stackTrace;

  const IsarInitializationException(this.error, [this.stackTrace]);

  @override
  String toString() => 'IsarInitializationException: $error';
}
