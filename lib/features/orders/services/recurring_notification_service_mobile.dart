import 'dart:async';
import 'dart:io' show Platform;
import 'package:isar_community/isar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/fsm_order.dart';

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

    // Initialize timezone dynamically
    tz.initializeTimeZones();
    
    String timeZoneName = 'Asia/Ho_Chi_Minh'; // Fallback
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      timeZoneName = tzInfo.identifier;
    } catch (e) {
      logger.w('Failed to get local timezone dynamically, fallback to Asia/Ho_Chi_Minh', error: e);
    }
    
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      logger.w('Timezone $timeZoneName not found, fallback to Asia/Ho_Chi_Minh', error: e);
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
      } catch (fallbackError, fallbackStack) {
        logger.e(
            'Fallback timezone Asia/Ho_Chi_Minh unavailable, reminders use UTC',
            error: fallbackError,
            stackTrace: fallbackStack);
      }
    }

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

    /// Android 12+ exact alarm permission (for exactAllowWhileIdle)
    try {
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (e) {
      logger.w('requestExactAlarmsPermission not available or failed', error: e);
    }

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
      await _scheduleNotification(
        id: order.odooId * 2,
        title: 'Nhắc nhở đơn định kỳ',
        body: 'Đơn "${order.name}" sẽ bắt đầu vào ngày ${_formatDate(scheduledStart)}',
        scheduledDate: oneDayBefore,
        payload: 'order:${order.odooId}',
      );
    }

    if (oneHourBefore.isAfter(now)) {
      await _scheduleNotification(
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

    // Lấy tất cả recurring instances sắp tới (loại trừ done và cancelled)
    final upcomingOrders = await _isar.db.fsmOrders
        .filter()
        .isRecurringInstanceEqualTo(true)
        .scheduledDateStartGreaterThan(now)
        .scheduledDateStartLessThan(future)
        .and()
        .not()
        .stageEqualTo(FsmOrderStage.done)
        .and()
        .not()
        .stageEqualTo(FsmOrderStage.cancelled)
        .findAll();

    for (final order in upcomingOrders) {
      await scheduleOrderReminder(order);
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
    _pendingTimers.remove(orderOdooId * 2)?.cancel();
    _pendingTimers.remove(orderOdooId * 2 + 1)?.cancel();
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
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
      final timer = Timer(diff, () async {
        try {
          await _showNotification(id, title, body, payload);
        } catch (e, stackTrace) {
          logger.e('Failed to show notification $id', error: e, stackTrace: stackTrace);
        } finally {
          _pendingTimers.remove(id);
        }
      });
      _pendingTimers[id] = timer;
    } else {
      // Use zoned schedule for future dates
      final tz.TZDateTime tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);
      try {
        await _notifications.zonedSchedule(
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
      } catch (e, stackTrace) {
        logger.e('Failed to schedule notification $id via zonedSchedule', error: e, stackTrace: stackTrace);
      }
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

  static const int _upcomingReminderIdOffset = 100000000;

  bool _shouldSkipUpcoming(FsmOrder order) {
    return order.scheduledDateStart == null ||
        order.dateStart != null ||
        order.stage == FsmOrderStage.done ||
        order.stage == FsmOrderStage.cancelled ||
        order.isSkipped;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> scheduleUpcomingReminders(List<FsmOrder> orders) async {
    if (!_initialized) await init();
    for (final order in orders) {
      try {
        await scheduleUpcomingReminder(order);
      } catch (e, stackTrace) {
        logger.e('Failed to schedule upcoming reminder for order ${order.odooId}',
            error: e, stackTrace: stackTrace);
      }
    }
  }

  Future<void> scheduleUpcomingReminder(FsmOrder order) async {
    if (!_initialized) await init();
    final reminderId = order.odooId + _upcomingReminderIdOffset;
    await _cancelUpcomingNotification(reminderId);
    if (_shouldSkipUpcoming(order)) return;

    final now = DateTime.now();
    final scheduledStart = order.scheduledDateStart!;

    if (scheduledStart.isBefore(now)) return;
    if (scheduledStart.isAfter(now.add(const Duration(hours: 24)))) return;

    final reminderTime = scheduledStart.subtract(const Duration(minutes: 30));
    if (reminderTime.isBefore(now)) return;

    await _scheduleNotification(
      id: reminderId,
      title: 'Sắp có visit: ${order.locationAddress ?? order.name}',
      body: 'Bắt đầu lúc ${_formatTime(scheduledStart)}',
      scheduledDate: reminderTime,
      payload: 'upcoming:${order.odooId}',
    );
  }

  Future<void> cancelUpcomingReminder(int orderOdooId) async {
    await _cancelUpcomingNotification(orderOdooId + _upcomingReminderIdOffset);
  }

  Future<void> _cancelUpcomingNotification(int reminderId) async {
    _pendingTimers.remove(reminderId)?.cancel();
    await _notifications.cancel(reminderId);
  }

  Future<void> rescheduleAllUpcomingReminders() async {
    if (!_initialized) await init();
    final currentUserId = OdooSessionManager.instance.currentUserId;
    if (currentUserId == null) {
      logger.w('Skip rescheduleAllUpcomingReminders: no active user');
      return;
    }

    final now = DateTime.now();
    final futureLimit = now.add(const Duration(hours: 24));

    final upcomingOrders = await _isar.db.fsmOrders
        .filter()
        .localOwnerIdEqualTo(currentUserId)
        .and()
        .scheduledDateStartGreaterThan(now)
        .scheduledDateStartLessThan(futureLimit)
        .and()
        .not()
        .stageEqualTo(FsmOrderStage.done)
        .and()
        .not()
        .stageEqualTo(FsmOrderStage.cancelled)
        .findAll();

    for (final order in upcomingOrders) {
      await scheduleUpcomingReminder(order);
    }

    logger.i('Rescheduled upcoming reminders for ${upcomingOrders.length} orders');
  }

  /// Cleanup khi app đóng
  void dispose() {
    for (final timer in _pendingTimers.values) {
      timer.cancel();
    }
    _pendingTimers.clear();
  }
}