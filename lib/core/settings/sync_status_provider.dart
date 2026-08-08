import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'settings_repository.dart';
import '../../../core/database/isar_service.dart';
import '../../../features/orders/models/fsm_order.dart';
import '../utils/logger.dart';

/// Theo dõi trạng thái đồng bộ cho màn Settings.
///
/// - [pendingCount]: số bản ghi chờ tải lên (đọc từ Isar).
/// - [isSyncing]: đang mô phỏng đồng bộ.
/// - [lastSyncedAt]: lần đồng bộ thành công cuối (lưu trong SettingsRepository).
///
/// TODO-ISAR: [pendingCount] hiện trả về 0 (Isar chưa có data thật).
/// Khi Isar đã nạp data (Lát 6), hãy triển khai [_countPendingFromIsar]
/// theo mẫu trong comment để con số tự đúng.
class SyncStatusProvider extends ChangeNotifier {
  bool _disposed = false;
  int _pendingCount = 0;
  bool _isSyncing = false;
  DateTime? _lastSyncedAt;

  int get pendingCount => _pendingCount;
  bool get isSyncing => _isSyncing;
  bool get hasPending => _pendingCount > 0;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  /// Nạp lại pending + lastSynced. Gọi khi mở màn Settings.
  Future<void> refresh() async {
    final lastSynced = SettingsRepository.instance.lastSyncedAt;
    final pending = await _countPendingFromIsar();
    if (_disposed) return;
    _lastSyncedAt = lastSynced;
    _pendingCount = pending;
    notifyListeners();
  }

  /// Mô phỏng đồng bộ (chưa nối Odoo thật — Lát 7).
  /// KHÔNG tự ghi lastSyncedAt vì chưa có sync thật.
  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (_disposed) return;
    _isSyncing = false;
    _pendingCount = await _countPendingFromIsar();
    notifyListeners();
  }

  Future<int> _countPendingFromIsar() async {
    try {
      final db = IsarService.instance.db;
      return await db.fsmOrders.filter().isPendingSyncEqualTo(true).count();
    } catch (e, stack) {
      logger.w('SyncStatusProvider: pending count unavailable, reporting 0',
          error: e, stackTrace: stack);
      return 0;
    }
  }
}
