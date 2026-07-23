import '../connectivity/connectivity_service.dart';

/// Điều phối đồng bộ dữ liệu từ local (Isar) lên Odoo server.
/// Được gọi khi mạng trở lại sau khi offline.
///
/// Cơ chế: mỗi model Isar có field [isPendingSync].
/// SyncManager duyệt qua các records pending và push lên Odoo.
class SyncManager {
  SyncManager._();
  static final SyncManager instance = SyncManager._();

  final _connectivity = ConnectivityService.instance;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// Đăng ký lắng nghe kết nối mạng.
  /// Khi online trở lại → tự động gọi [syncPending].
  void startListening() {
    _connectivity.onConnectivityChanged.listen((results) async {
      final isOnline = await _connectivity.isOnline;
      if (isOnline && !_isSyncing) {
        await syncPending();
      }
    });
  }

  /// Thực hiện đồng bộ tất cả dữ liệu đang chờ (isPendingSync = true).
  /// Mỗi feature service sẽ đăng ký handler riêng qua [registerSyncHandler].
  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      for (final handler in _syncHandlers) {
        try {
          await handler();
        } catch (_) {
          // Tiếp tục sync các handler khác dù 1 handler lỗi
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  // Danh sách sync handlers đăng ký từ các feature
  final List<Future<void> Function()> _syncHandlers = [];

  /// Feature service gọi hàm này để đăng ký logic sync của mình.
  /// Ví dụ: TimesheetService.instance.registerSync()
  void registerSyncHandler(Future<void> Function() handler) {
    _syncHandlers.add(handler);
  }
}
