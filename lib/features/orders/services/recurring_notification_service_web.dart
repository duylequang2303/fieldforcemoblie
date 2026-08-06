import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';

/// Bản mô phỏng (no-op stub) của [RecurringNotificationService] cho môi trường Web.
/// Tránh import `dart:io` và `flutter_local_notifications` gây crash khi compile web.
class RecurringNotificationService {
  RecurringNotificationService._();
  static final RecurringNotificationService instance = RecurringNotificationService._();

  Future<void> init() async {
    // No-op trên Web
  }

  Future<void> scheduleOrderReminder(FsmOrder order) async {
    // No-op trên Web
  }

  Future<void> cancelOrderReminder(int orderOdooId) async {
    // No-op trên Web
  }

  Future<void> rescheduleAllRecurringReminders() async {
    // No-op trên Web
  }

  void dispose() {
    // No-op trên Web
  }
}
