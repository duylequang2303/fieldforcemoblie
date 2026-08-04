import '../models/fsm_order.dart';

/// Đơn định kỳ sắp đến hạn hiển thị trên tab "ĐỊNH KỲ".
///
/// Chỉ chứa logic thuần — không import Odoo API, không đụng mạng/DB.
/// Widget/Provider chỉ gọi các hàm của service này.
class RecurringDueOrder {
  const RecurringDueOrder({
    required this.odooId,
    required this.name,
    this.partnerName,
    this.serviceName,
    this.dueDate,
    this.stageName,
  });

  /// ID fsm.order trên Odoo.
  final int odooId;

  /// Số hiệu đơn (fsm.order.name).
  final String name;

  /// Tên khách hàng / địa điểm (partner_id hoặc location).
  final String? partnerName;

  /// Tên dịch vụ / loại đơn (service_type hoặc mô tả).
  final String? serviceName;

  /// Ngày đến hạn (fsm.order.scheduled_date_start).
  final DateTime? dueDate;

  /// Tên stage hiện tại.
  final String? stageName;

  RecurringDueOrder copyWith({String? stageName}) {
    return RecurringDueOrder(
      odooId: odooId,
      name: name,
      partnerName: partnerName,
      serviceName: serviceName,
      dueDate: dueDate,
      stageName: stageName ?? this.stageName,
    );
  }
}

/// Service chứa toàn bộ logic thuần cho tính năng ĐỊNH KỲ + nhắc nhở.
class RecurringService {
  RecurringService._();

  // ── Helpers (pattern giống FsmOrder, chống type cast khi Odoo trả false/null) ──
  static String? _strOrNull(dynamic v) =>
      (v == null || v == false) ? null : v as String;

  static int? _intOrNull(dynamic v) =>
      (v == null || v == false) ? null : v as int;

  static DateTime? _dateOrNull(dynamic v) =>
      (v == null || v == false) ? null : DateTime.tryParse(v as String);

  /// Lấy chuỗi display của field many2one do Odoo trả dạng `[id, name]` hoặc `false/null`.
  /// Với một số field Odoo trả thẳng tên (không phải list) → fallback cast String.
  static String _nameFromManyOrDirect(dynamic v) {
    if (v == null || v == false) return '';
    if (v is List) return v.isNotEmpty ? v[1]?.toString() ?? '' : '';
    return v.toString();
  }

  /// Parse JSON danh sách fsm.order (đã fetch, có kèm fsm_recurring_id) → [RecurringDueOrder].
  ///
  /// - Dùng `_strOrNull` / `_intOrNull` để chống type cast khi Odoo trả `false`/`null`.
  /// - Chỉ giữ những đơn có `fsm_recurring_id` (là đơn định kỳ).
  static List<RecurringDueOrder> parseRecurringOrders(
    List<Map<String, dynamic>> jsonList,
  ) {
    final result = <RecurringDueOrder>[];
    for (final json in jsonList) {
      final recurringId = _intOrNull(json['fsm_recurring_id']);
      if (recurringId == null) continue; // Không phải đơn định kỳ → bỏ qua

      final odooId = _intOrNull(json['id']);
      if (odooId == null) continue;

      result.add(RecurringDueOrder(
        odooId: odooId,
        name: _strOrNull(json['name']) ?? '',
        partnerName: _nameFromManyOrDirect(json['partner_id']) == ''
            ? _nameFromManyOrDirect(json['location_id'])
            : _nameFromManyOrDirect(json['partner_id']),
        serviceName: _strOrNull(json['service_type']) ??
            _nameFromManyOrDirect(json['stage_id']),
        dueDate: _dateOrNull(json['scheduled_date_start']),
        stageName: _nameFromManyOrDirect(json['stage_id']),
      ));
    }
    return result;
  }

  /// Chuyển danh sách [FsmOrder] (đọc từ Isar cache) → [RecurringDueOrder].
  /// Chỉ giữ những đơn có `fsmRecurringId != null` (là đơn định kỳ).
  /// Widget dùng hàm này để tab ĐỊNH KỲ không chứa logic parse.
  static List<RecurringDueOrder> fromFsmOrders(List<FsmOrder> fsmOrders) {
    final result = <RecurringDueOrder>[];
    for (final order in fsmOrders) {
      if (order.fsmRecurringId == null) continue; // Không phải đơn định kỳ
      result.add(RecurringDueOrder(
        odooId: order.odooId,
        name: order.name,
        partnerName: order.partnerName,
        serviceName: order.serviceType ?? order.description,
        dueDate: order.scheduledDateStart,
        stageName: order.stageName,
      ));
    }
    return result;
  }

  /// Lọc đơn định kỳ đến hạn trong khoảng [days] ngày kể từ [now].
  ///
  /// Pure function — không đọc DB/mạng. Khoảng tính gồm cả ngày hôm nay
  /// (dueDate trong [today, today + days]). Bỏ qua đơn đã hoàn thành.
  static List<RecurringDueOrder> filterDueOrders(
    List<RecurringDueOrder> orders,
    DateTime now, {
    int days = 7,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final horizon = today.add(Duration(days: days));

    return orders.where((o) {
      final due = o.dueDate;
      if (due == null) return false;
      final dueDay = DateTime(due.year, due.month, due.day);
      if (dueDay.isBefore(today)) return false; // quá hạn, không nhắc nữa
      // Loại đơn đã "done/completed/cancelled"
      final stage = (o.stageName ?? '').toLowerCase();
      if (stage.contains('done') ||
          stage.contains('complet') ||
          stage.contains('hoàn') ||
          stage.contains('cancel') ||
          stage.contains('huỷ')) {
        return false;
      }
      return !dueDay.isAfter(horizon);
    }).toList();
  }

  /// Đếm đơn đến hạn đúng hôm nay ([now] cùng ngày).
  static List<RecurringDueOrder> filterDueToday(
    List<RecurringDueOrder> orders,
    DateTime now,
  ) {
    return filterDueOrders(orders, now, days: 0);
  }

  /// Xây nội dung notification 8h sáng.
  ///
  /// Trả về `count`, `title`, `body` hoàn chỉnh cho [RecurringDueOrder] đã lọc.
  static ({int count, String title, String body}) buildNotificationContent(
    List<RecurringDueOrder> dueOrders,
  ) {
    final count = dueOrders.length;
    if (count == 0) {
      return (
        count: 0,
        title: 'Công việc định kỳ',
        body: 'Hôm nay không có công việc định kỳ nào đến hạn.',
      );
    }
    if (count == 1) {
      final o = dueOrders.first;
      final who = (o.partnerName == null || o.partnerName!.isEmpty)
          ? o.name
          : o.partnerName!;
      return (
        count: 1,
        title: '1 công việc định kỳ hôm nay',
        body: 'Đến hạn: $who${o.serviceName == null ? '' : ' — ${o.serviceName}.'}',
      );
    }
    final list = dueOrders
        .take(3)
        .map((o) =>
            '- ${o.partnerName == null || o.partnerName!.isEmpty ? o.name : o.partnerName}')
        .join('\n');
    return (
      count: count,
      title: '$count công việc định kỳ hôm nay',
      body: list,
    );
  }
}