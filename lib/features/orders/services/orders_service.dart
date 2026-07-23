import 'package:isar_community/isar.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../models/fsm_order.dart';

/// Service giao tiếp với Odoo API cho fsm.order.
/// Tất cả Odoo call đi qua đây, không gọi trực tiếp từ Provider hay Widget.
class OrdersService {
  OrdersService._();
  static final OrdersService instance = OrdersService._();

  final _odoo = OdooSessionManager.instance;
  final _isar = IsarService.instance;

  static const _model = 'fsm.order';
  static const _fields = [
    'id',
    'name',
    'description',
    'stage_id',
    'location_id',
    'phone',
    'scheduled_date_start',
    'scheduled_date_end',
    'date_start',
    'person_id',
  ];

  /// Lấy danh sách đơn dịch vụ được giao cho user đang đăng nhập.
  /// Fetch từ Odoo → lưu Isar → trả về list.
  Future<List<FsmOrder>> fetchMyOrders() async {
    final userId = _odoo.currentUserId;
    final domain = userId != null
        ? [
            ['person_id.user_id', '=', userId]
          ]
        : <dynamic>[];

    final rawList = await _odoo.callKw(
      model: _model,
      method: 'search_read',
      args: [domain],
      kwargs: {'fields': _fields, 'order': 'scheduled_date_start asc'},
    ) as List<dynamic>;

    final orders = rawList
        .map((e) => FsmOrder.fromJson(e as Map<String, dynamic>))
        .toList();

    // Lưu vào Isar để dùng offline
    await _isar.db.writeTxn(() async {
      await _isar.db.fsmOrders.putAllByOdooId(orders);
    });

    return orders;
  }

  /// Đọc orders từ Isar (khi offline).
  Future<List<FsmOrder>> loadCachedOrders() async {
    return _isar.db.fsmOrders.where().anyId().findAll();
  }

  /// Cập nhật stage của một đơn dịch vụ.
  Future<void> updateStage(int odooId, int newStageId) async {
    await _odoo.callKw(
      model: _model,
      method: 'write',
      args: [
        [odooId],
        {'stage_id': newStageId},
      ],
    );

    // Cập nhật local
    final local = await _isar.db.fsmOrders.getByOdooId(odooId);
    if (local != null) {
      await _isar.db.writeTxn(() async {
        local.stageId = newStageId;
        await _isar.db.fsmOrders.put(local);
      });
    }
  }

  /// Ghi nhận giờ bắt đầu thực tế khi Worker check-in tại địa điểm.
  Future<void> checkIn(int odooId) async {
    final now = DateTime.now().toIso8601String();
    await _odoo.callKw(
      model: _model,
      method: 'write',
      args: [
        [odooId],
        {'date_start': now},
      ],
    );
  }

  /// Sync các order chưa push lên Odoo (isPendingSync = true).
  Future<void> syncPending() async {
    final pending = await _isar.db.fsmOrders
        .filter()
        .isPendingSyncEqualTo(true)
        .findAll();

    for (final order in pending) {
      try {
        await _odoo.callKw(
          model: _model,
          method: 'write',
          args: [
            [order.odooId],
            {'stage_id': order.stageId},
          ],
        );
        await _isar.db.writeTxn(() async {
          order.isPendingSync = false;
          await _isar.db.fsmOrders.put(order);
        });
      } catch (_) {
        // Giữ nguyên isPendingSync = true, retry lần sau
      }
    }
  }
}
