import 'dart:async';
import 'dart:io' show Platform;
import 'package:isar_community/isar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:fieldforce_mobile/core/database/isar_service.dart';
import 'package:fieldforce_mobile/core/utils/logger.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';

class RecurringNotificationService {
  RecurringNotificationService._();
  static final RecurringNotificationService instance = RecurringNotificationService._();

  final _isar = IsarService.instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  final Map<int, Timer> _pendingTimers = {};

  /// Khởi tạo notification service.
  /// Gọi một lần khi app khởi động.
  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    // Android initialization settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    _initialized = true;
    logger.i('RecurringNotificationService initialized');
  }

  Future<void> _requestPermissions() async {
    // Android 13+ permissions
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    // iOS permissions
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to order detail when notification is tapped
    // This would typically use a global navigator key or event bus
    logger.i('Notification tapped: ${response.payload}');
  }

  /// Lên lịch thông báo cho một order lặp định kỳ.
  /// Gọi khi: order được tạo local, hoặc khi app mở để reschedule.
  Future<void> scheduleOrderReminder(FsmOrder order) async {
    if (!_initialized) await init();

    final scheduledStart = order.scheduledDateStart;
    if (scheduledStart == null) return;

    switch (order.stage) {
      case FsmOrderStage.done:
      case FsmOrderStage.cancelled:
        return;
      default:
        break;
    }

    final now = DateTime.now();

    // Không schedule cho quá khứ
    if (scheduledStart.isBefore(now)) return;

    // Huỷ timer cũ nếu có
    _cancelTimer(order.odooId);

    // Schedule 2 notifications: 1 day before, 1 hour before
    final oneDayBefore = scheduledStart.subtract(const Duration(days: 1));
    final oneHourBefore = scheduledStart.subtract(const Duration(hours: 1));

    if (oneDayBefore.isAfter(now)) {
      _scheduleNotification(
        id: order.odooId * 2,
        title: 'Nhắc nhở đơn định kỳ',
        body: 'Đơn "${order.name}" sẽ bắt đầu vào ngày ${_formatDate(scheduledStart)}',
        scheduledDate: oneDayBefore,
        payload: 'order:${order.odooId}',
      );
    }

    if (oneHourBefore.isAfter(now)) {
      _scheduleNotification(
        id: order.odooId * 2 + 1,
        title: 'Sắp đến giờ',
        body: 'Đơn "${order.name}" bắt đầu sau 1 giờ',
        scheduledDate: oneHourBefore,
        payload: 'order:${order.odooId}',
      );
    }
  }

  /// Reschedule tất cả notifications cho recurring orders khi app mở.
  /// Fix bug: notifications chỉ hoạt động 7 ngày - khi app mở, reschedule các notifications tiếp theo.
  Future<void> rescheduleAllRecurringReminders() async {
    if (!_initialized) await init();

    final now = DateTime.now();
    final future = now.add(const Duration(days: 30)); // Look ahead 30 days

    // Lấy tất cả recurring instances sắp tới
    final upcomingOrders = await _isar.db.fsmOrders
        .filter()
        .isRecurringInstanceEqualTo(true)
        .scheduledDateStartGreaterThan(now)
        .scheduledDateStartLessThan(future)
        .stageEqualTo(FsmOrderStage.draft)
        .findAll();

    for (final order in upcomingOrders) {
      if (order.stage != FsmOrderStage.done && order.stage != FsmOrderStage.cancelled) {
        await scheduleOrderReminder(order);
      }
    }

    logger.i('Rescheduled reminders for ${upcomingOrders.length} recurring orders');
  }

  /// Huỷ notification cho một order cụ thể.
  Future<void> cancelOrderReminders(int orderOdooId) async {
    _cancelTimer(orderOdooId);
    await _notifications.cancel(orderOdooId * 2);
    await _notifications.cancel(orderOdooId * 2 + 1);
  }

  void _cancelTimer(int orderOdooId) {
    _pendingTimers.remove(orderOdooId)?.cancel();
  }

  void _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) {
    // Skip zonedSchedule on Linux - it's not supported
    if (Platform.isLinux) {
      logger.w('Skipping zonedSchedule on Linux (unsupported). Notification $id will not fire in background.');
      return;
    }

    // If scheduled date is within a few minutes, use a timer instead
    final now = DateTime.now();
    final diff = scheduledDate.difference(now);

    if (diff.inMinutes <= 5 && diff.inMinutes > 0) {
      // Use a short timer
      final timer = Timer(diff, () {
        _showNotification(id, title, body, payload);
        _pendingTimers.remove(id);
      });
      _pendingTimers[id] = timer;
    } else {
      // Use zoned schedule for future dates
      final tz.TZDateTime tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);
      _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'recurring_orders',
            'Recurring Orders',
            channelDescription: 'Reminders for recurring service orders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }
  }

  Future<void> _showNotification(
    int id,
    String title,
    String body,
    String payload,
  ) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recurring_orders',
          'Recurring Orders',
          channelDescription: 'Reminders for recurring service orders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  /// Cleanup khi app đóng
  void dispose() {
    for (final timer in _pendingTimers.values) {
      timer.cancel();
    }
    _pendingTimers.clear();
  }
}