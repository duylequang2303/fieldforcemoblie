import 'package:isar_community/isar.dart';
import 'package:meta/meta.dart' show visibleForTesting;
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/fsm_order.dart';
import 'recurring_notification_service.dart';
import 'recurring_service.dart';

class OdooCreateResult {
  final int id;
  final bool isSkippedRejected;
  OdooCreateResult(this.id, {this.isSkippedRejected = false});
}

/// Service giao tiếp với Odoo API cho fsm.order.
/// Tất cả Odoo call đi qua đây, không gọi trực tiếp từ Provider hay Widget.
class OrdersService {
  OrdersService._({OdooSessionManager? odoo, IsarService? isar})
      : _odoo = odoo ?? OdooSessionManager.instance,
        _isar = isar ?? IsarService.instance;
  static final OrdersService instance = OrdersService._();

  @visibleForTesting
  factory OrdersService.testConstructor(
      OdooSessionManager odoo, IsarService isar) {
    return OrdersService._(odoo: odoo, isar: isar);
  }

  final OdooSessionManager _odoo;
  final IsarService _isar;

  static const _model = 'fsm.order';

  static const _coreFields = [
    'id',
    'name',
    'description',
    'stage_id',
    'location_id',
    'location_directions',
    'phone',
    'scheduled_date_start',
    'scheduled_date_end',
    'date_start',
    'person_id',
    'route_sequence',
    'route_id',
    'warehouse_id',
    'team_id',
    'priority',
    'tag_ids',
    'territory_id',
    'branch_id',
    'district_id',
    'region_id',
    'person_ids',
    'scheduled_duration',
    'date_end',
    'resolution',
    'inventory_location_id',
    'color',
    'todo',
  ];

  static const _optionalFields = [
    'fsm_recurring_id',
  ];

  static List<String> get _fields => [
        ..._coreFields,
        ..._optionalFields,
      ];

  static const _locationFields = [
    'id',
    'partner_latitude',
    'partner_longitude',
    'partner_id',
    'inventory_location_id',
    'street',
    'street2',
    'city',
    'zip',
    'state_id',
    'country_id',
    'owner_id',
    'direction',
  ];

  // Cache for stages
  static final Map<int, String> _stageNames = {};
  static final Map<String, int> _stageIdsByLowerName = {};
  static int? _completedStageId;

  Future<void> fetchStagesIfNeeded() async {
    if (_stageNames.isNotEmpty) return;
    try {
      final rawList = await _odoo.callKw(
        model: 'fsm.stage',
        method: 'search_read',
        args: [<dynamic>[]],
        kwargs: {
          'fields': ['id', 'name']
        },
      ) as List<dynamic>;

      for (final s in rawList) {
        final id = s['id'] as int;
        final name = (s['name'] as String).toLowerCase();
        _stageNames[id] = name;
        _stageIdsByLowerName[name] = id;
      }
    } catch (e) {
      logger.e('Failed to fetch fsm.stage', error: e);
    }
  }

  /// Resolve stage Completed bằng XML ID chuẩn của Odoo thay vì keyword.
  /// Dùng ir.model.data(module=fieldservice, name=fsm_stage_completed).
  Future<int?> getCompletedStageId() async {
    if (_completedStageId != null) return _completedStageId;
    try {
      final result = await _odoo.callKw(
        model: 'ir.model.data',
        method: 'search_read',
        args: [
          [
            ['module', '=', 'fieldservice'],
            ['name', '=', 'fsm_stage_completed'],
          ]
        ],
        kwargs: {
          'fields': ['res_id'],
          'limit': 1
        },
      ) as List<dynamic>;
      if (result.isNotEmpty) {
        _completedStageId = result.first['res_id'] as int;
      }
    } catch (e) {
      logger.e('Failed to resolve fsm_stage_completed XML ID', error: e);
    }
    return _completedStageId;
  }

  Future<int?> getStageIdByKeywords(List<String> keywords, {List<int>? fallbackIds}) async {
    await fetchStagesIfNeeded();
    for (final entry in _stageIdsByLowerName.entries) {
      for (final kw in keywords) {
        if (entry.key.contains(kw.toLowerCase())) {
          return entry.value;
        }
      }
    }

    if (fallbackIds != null) {
      for (final id in fallbackIds) {
        if (_stageNames.containsKey(id)) {
          return id;
        }
      }
    }

    return null;
  }

  /// Helper method để gọi search_read với fallback khi custom fields bị từ chối
  Future<List<dynamic>> _callSearchRead(List<dynamic> domain) async {
    try {
      return await _odoo.callKw(
        model: _model,
        method: 'search_read',
        args: [domain],
        kwargs: {'fields': _fields, 'order': 'scheduled_date_start asc'},
      ) as List<dynamic>;
    } on OdooBusinessException catch (error) {
      final message = error.message.toLowerCase();
      if (!message.contains('fsm_recurring_id') &&
          !message.contains('invalid field')) {
        rethrow;
      }
      logger.w(
          'Odoo search_read rejected optional fields, retrying with core fields only...');
      return await _odoo.callKw(
        model: _model,
        method: 'search_read',
        args: [domain],
        kwargs: {'fields': _coreFields, 'order': 'scheduled_date_start asc'},
      ) as List<dynamic>;
    }
  }

  /// Lấy danh sách đơn dịch vụ được giao cho user đang đăng nhập.
  /// Fetch từ Odoo → lưu Isar → trả về list.
  Future<List<FsmOrder>> fetchMyOrders() async {
    final userId = _odoo.currentUserId;

    if (userId == null) {
      logger.w('OrdersService.fetchMyOrders: userId null, trả về empty list');
      return [];
    }

    // Tìm person_id liên kết với user đăng nhập thông qua fsm.person.calendar.filter
    // (module fieldservice_calendar). Nếu không có, fallback sang team calendar.
    int? personId;
    try {
      final personFilter = await _odoo.callKw(
        model: 'fsm.person.calendar.filter',
        method: 'search_read',
        args: [
          [
            ['user_id', '=', userId]
          ]
        ],
        kwargs: {
          'fields': ['person_id'],
          'limit': 1,
        },
      ) as List<dynamic>;
      if (personFilter.isNotEmpty) {
        personId = (personFilter.first['person_id'] as List?)?.first as int?;
      }
    } on OdooBusinessException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('model') && msg.contains('does not exist') ||
          msg.contains('field') && msg.contains('does not exist') ||
          msg.contains('undefined') ||
          msg.contains('access denied')) {
        logger.w('OrdersService.fetchMyOrders: fieldservice_calendar module missing or inaccessible');
      } else {
        rethrow;
      }
    } catch (_) {
      // Network or other transient error - silent fallback
    }

    // Fallback: Try direct user_id on fsm.person (if exists)
    if (personId == null) {
      try {
        final person = await _odoo.callKw(
          model: 'fsm.person',
          method: 'search_read',
          args: [
            [
              ['user_id', '=', userId]
            ]
          ],
          kwargs: {
            'fields': ['id'],
            'limit': 1,
          },
        ) as List<dynamic>;
        if (person.isNotEmpty) {
          personId = person.first['id'] as int;
          logger.i('OrdersService.fetchMyOrders: Found personId=$personId via fsm.person.user_id for user=$userId');
        }
      } on OdooBusinessException catch (e) {
        final msg = e.message.toLowerCase();
        if (!(msg.contains('model') && msg.contains('does not exist') ||
            msg.contains('field') && msg.contains('does not exist') ||
            msg.contains('undefined') ||
            msg.contains('access denied'))) {
          rethrow;
        }
        logger.w('OrdersService.fetchMyOrders: fsm.person.user_id field missing');
      } catch (_) {
        // Network or other transient error - silent fallback
      }
    }

    List<dynamic> rawOrders = [];
    if (personId != null) {
      // Ưu tiên domain chính xác: person_id = personId
      logger.i('OrdersService.fetchMyOrders: personId=$personId for user=$userId');
      rawOrders = await _callSearchRead([
        ['person_id', '=', personId]
      ]);
    }

    // Fallback 1: team calendar (fieldservice_calendar module)
    if (rawOrders.isEmpty) {
      logger.w(
          'OrdersService.fetchMyOrders: Không có kết quả với person_id, thử team calendar fallback');
      final fallbackOrders = await _tryFetchOrders([
        ['team_id.calendar_user_id', '=', userId]
      ]);
      if (fallbackOrders.isNotEmpty) {
        logger.i('OrdersService.fetchMyOrders: Found orders via team calendar fallback');
        return fallbackOrders;
      }
    }

    // Fallback 2: person_ids (many2many) - legacy nếu có custom field mapping
    if (rawOrders.isEmpty) {
      logger.w(
          'OrdersService.fetchMyOrders: Thử person_ids fallback');
      final fallbackOrders = await _tryFetchOrders([
        ['person_ids.user_id', '=', userId]
      ]);
      if (fallbackOrders.isNotEmpty) {
        logger.i('OrdersService.fetchMyOrders: Found orders via person_ids fallback');
        return fallbackOrders;
      }
    }

    // Fallback 3: Try to fetch ALL orders (for debugging - limit 50)
    // This helps identify if orders exist but aren't assigned correctly
    if (rawOrders.isEmpty) {
      logger.w(
          'OrdersService.fetchMyOrders: Thử fetch all orders (debug)');
      try {
        final allOrders = await _callSearchRead([
          ['stage_id.name', 'in', ['New', 'In Progress', 'Mới', 'Đang thực hiện']]
        ]);
        if (allOrders.isNotEmpty) {
          logger.i('OrdersService.fetchMyOrders: Found ${allOrders.length} orders in backend (but not assigned to user). First few: ${allOrders.take(3).map((e) => e['name']).toList()}');
          // Log the person_id of first order to debug assignment
          if (allOrders.first['person_id'] != null) {
            logger.i('OrdersService.fetchMyOrders: First order person_id: ${allOrders.first['person_id']}');
          }
        }
      } catch (e) {
        logger.w('OrdersService.fetchMyOrders: Debug fetch all orders failed', error: e);
      }
    }

    if (rawOrders.isEmpty) {
      logger.w('OrdersService.fetchMyOrders: Không có kết quả với bất kỳ domain nào');
      return [];
    }

    // Process location_ids và route_ids như cũ
    final locationIds = rawOrders
        .where((e) =>
            (e as Map)['location_id'] != null && e['location_id'] is List)
        .map((e) => ((e as Map)['location_id'] as List)[0] as int)
        .toSet()
        .toList();

    Map<int, Map<String, dynamic>> locationCoordinates = {};
    if (locationIds.isNotEmpty) {
      final locData = await _odoo.callKw(
        model: 'fsm.location',
        method: 'read',
        args: [locationIds],
        kwargs: {'fields': _locationFields},
      ) as List<dynamic>;
      for (var loc in locData) {
        locationCoordinates[loc['id'] as int] = loc as Map<String, dynamic>;
      }
    }

    // Bóc tách route_id để lấy state
    final routeIds = rawOrders
        .where((e) => (e as Map)['route_id'] != null && e['route_id'] is List)
        .map((e) => ((e as Map)['route_id'] as List)[0] as int)
        .toSet()
        .toList();

    Map<int, String> routeStates = {};
    if (routeIds.isNotEmpty) {
      try {
        final routeData = await _odoo.callKw(
          model: 'fsm.route',
          method: 'read',
          args: [routeIds],
          kwargs: {
            'fields': ['state']
          },
        ) as List<dynamic>;
        for (var route in routeData) {
          final id = route['id'] as int;
          final state = route['state'] as String?;
          if (state != null) {
            routeStates[id] = state;
          }
        }
      } catch (e) {
        logger.w('Failed to fetch fsm.route states', error: e);
      }
    }

    // Parse JSON -> Model Isar
    final orders = rawOrders.map((o) {
      final oMap = o as Map<String, dynamic>;

      // Inject route_state
      final rData = oMap['route_id'];
      if (rData != null && rData is List && rData.isNotEmpty) {
        final rId = rData[0] as int;
        oMap['route_state'] = routeStates[rId];
      }

      return FsmOrder.fromJson(oMap, locationCoordinates: locationCoordinates);
    }).toList();

    // Resolve conflicts và lưu vào Isar để dùng offline
    final saved = await _resolveConflictsAndSave(orders);

    await _scheduleUpcomingRemindersSafely(saved);

    return saved;
  }

  /// Helper method để thử fetch orders với một domain khác.
  Future<List<FsmOrder>> _tryFetchOrders(List<dynamic> domain) async {
    try {
      final rawOrders = await _callSearchRead(domain);

      if (rawOrders.isEmpty) {
        return [];
      }

      // Process location_ids và route_ids
      final locationIds = rawOrders
          .where((e) =>
              (e as Map)['location_id'] != null && e['location_id'] is List)
          .map((e) => ((e as Map)['location_id'] as List)[0] as int)
          .toSet()
          .toList();

      Map<int, Map<String, dynamic>> locationCoordinates = {};
      if (locationIds.isNotEmpty) {
        final locData = await _odoo.callKw(
          model: 'fsm.location',
          method: 'read',
          args: [locationIds],
          kwargs: {'fields': _locationFields},
        ) as List<dynamic>;
        for (var loc in locData) {
          locationCoordinates[loc['id'] as int] = loc as Map<String, dynamic>;
        }
      }

      final routeIds = rawOrders
          .where((e) => (e as Map)['route_id'] != null && e['route_id'] is List)
          .map((e) => ((e as Map)['route_id'] as List)[0] as int)
          .toSet()
          .toList();

      Map<int, String> routeStates = {};
      if (routeIds.isNotEmpty) {
        try {
          final routeData = await _odoo.callKw(
            model: 'fsm.route',
            method: 'read',
            args: [routeIds],
            kwargs: {
              'fields': ['state']
            },
          ) as List<dynamic>;
          for (var route in routeData) {
            final id = route['id'] as int;
            final state = route['state'] as String?;
            if (state != null) {
              routeStates[id] = state;
            }
          }
        } catch (e) {
          logger.w('Failed to fetch fsm.route states in fallback', error: e);
        }
      }

      final orders = rawOrders.map((o) {
        final oMap = o as Map<String, dynamic>;

        final rData = oMap['route_id'];
        if (rData != null && rData is List && rData.isNotEmpty) {
          final rId = rData[0] as int;
          oMap['route_state'] = routeStates[rId];
        }

        return FsmOrder.fromJson(oMap,
            locationCoordinates: locationCoordinates);
      }).toList();

      final saved = await _resolveConflictsAndSave(orders);
      await _scheduleUpcomingRemindersSafely(saved);

      return saved;
    } catch (e) {
      logger.w('OrdersService._tryFetchOrders: Error fetching with domain',
          error: e);
      return [];
    }
  }

  Future<void> _scheduleUpcomingRemindersSafely(List<FsmOrder> orders) async {
    try {
      await RecurringNotificationService.instance.scheduleUpcomingReminders(orders);
    } catch (e, stackTrace) {
      logger.e('Failed to schedule upcoming reminders',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Đọc orders từ Isar (khi offline).
  Future<List<FsmOrder>> loadCachedOrders() async {
    final currentUserId = _odoo.currentUserId;
    if (currentUserId == null) return [];
    // Lọc theo user chính xác để tránh leak dữ liệu offline giữa các phiên
    return _isar.db.fsmOrders
        .filter()
        .localOwnerIdEqualTo(currentUserId)
        .findAll();
  }

  /// Helper mapper từ stageId sang FsmOrderStage và tên tương ứng.
  void _updateStageFields(FsmOrder local, int newStageId) {
    local.stageId = newStageId;
    final name = _stageNames[newStageId] ?? '';
    local.stage = FsmOrder.parseStageName(name);

    // Giữ nguyên nhãn Odoo gốc nếu có, chỉ fallback sang tiếng Anh mặc định nếu rỗng
    if (name.isNotEmpty) {
      local.stageName = name;
    } else {
      local.stageName = switch (local.stage) {
        FsmOrderStage.inProgress => 'In Progress',
        FsmOrderStage.done => 'Completed',
        FsmOrderStage.cancelled => 'Cancelled',
        FsmOrderStage.draft => 'New',
      };
    }
  }

  /// Cập nhật stage của một đơn dịch vụ (Offline-First).
  Future<void> updateStage(int odooId, int newStageId) async {
    // 1. Cập nhật local trước
    final local = await _isar.db.fsmOrders.getByOdooId(odooId);
    if (local != null) {
      if (local.isSkipped ||
          local.isRecurringProcessed ||
          local.stage == FsmOrderStage.done ||
          local.stage == FsmOrderStage.cancelled) {
        throw StateError(
            'Đơn hàng đã hoàn thành, bị huỷ hoặc bỏ qua. Không thể cập nhật trạng thái.');
      }
      await _isar.db.writeTxn(() async {
        _updateStageFields(local, newStageId);
        local.isPendingSync = true;
        local.isStagePendingSync = true;
        await _isar.db.fsmOrders.put(local);
      });

      // Cancel reminders if order is now done or cancelled
      if (local.stage == FsmOrderStage.done || local.stage == FsmOrderStage.cancelled) {
        try {
          await RecurringNotificationService.instance.cancelUpcomingReminder(odooId);
        } catch (e, stackTrace) {
          logger.e('Failed to cancel upcoming reminder on stage update',
              error: e, stackTrace: stackTrace);
        }
        try {
          await RecurringNotificationService.instance.cancelOrderReminders(odooId);
        } catch (e, stackTrace) {
          logger.e('Failed to cancel order reminders on stage update',
              error: e, stackTrace: stackTrace);
        }
      }
    }

    // 2. Cố gắng ghi nhận lên Odoo
    try {
      await _odoo.callKw(
        model: _model,
        method: 'write',
        args: [
          [odooId],
          {'stage_id': newStageId},
        ],
      );
      if (local != null) {
        final current = await _isar.db.fsmOrders.getByOdooId(odooId);
        if (current != null &&
            current.isStagePendingSync &&
            current.stageId == newStageId) {
          await _isar.db.writeTxn(() async {
            current.isPendingSync = false;
            current.isStagePendingSync = false;
            await _isar.db.fsmOrders.put(current);
          });
        }
      }
    } on OdooApiException catch (e) {
      logger.w('OrdersService.updateStage: offline, queued local update',
          error: e);
      rethrow;
    }
  }

  /// Đánh dấu hoàn thành đơn dịch vụ qua action chuẩn của Odoo thay vì ghi đè stage_id.
  ///
  /// Thực hiện theo chiến lược Offline-First:
  /// 1. Cập nhật trạng thái local Isar ngay lập tức (stage = done, isPendingSync = true).
  /// 2. Cố gắng ghi nhận lên Odoo qua action_complete.
  /// 3. Nếu API thành công, xóa cờ isPendingSync.
  /// 4. Nếu API thất bại, giữ nguyên bản ghi local với isPendingSync = true để đồng bộ sau.
  Future<void> completeOrder(int odooId) async {
    final local = await _isar.db.fsmOrders.getByOdooId(odooId);
    if (local != null) {
      if (local.isSkipped ||
          local.isRecurringProcessed ||
          local.stage == FsmOrderStage.done ||
          local.stage == FsmOrderStage.cancelled) {
        throw StateError(
            'Đơn hàng đã hoàn thành, bị huỷ hoặc bỏ qua. Không thể hoàn thành.');
      }
      if (local.stage != FsmOrderStage.inProgress) {
        throw StateError(
            'Đơn hàng không ở trạng thái "In Progress". Không thể hoàn thành.');
      }
    }
    final doneStageId = await getCompletedStageId() ??
        await getStageIdByKeywords(['done', 'completed']);

    // 1. Cập nhật local trước (Offline-First)
    if (local != null) {
      final wasCompleted = local.stage == FsmOrderStage.done;
      await _isar.db.writeTxn(() async {
        local.stage = FsmOrderStage.done;
        local.stageName = 'Completed';
        if (doneStageId != null) {
          local.stageId = doneStageId;
        }
        local.isPendingSync = true;
        local.isStagePendingSync = true;
        local.isActionCompletePendingSync = true;
        await _isar.db.fsmOrders.put(local);
      });
      if (!wasCompleted) {
        try {
          await RecurringService.instance.onOccurrenceCompleted(local);
        } on OdooApiException catch (e) {
          logger.w(
              'Error updating recurring occurrence logic on completion (Odoo)',
              error: e);
        } on StateError catch (e) {
          logger.w(
              'Error updating recurring occurrence logic on completion (State)',
              error: e);
        }
      }

      // Cancel upcoming and recurring reminders since order is now done
      try {
        await RecurringNotificationService.instance.cancelUpcomingReminder(odooId);
      } catch (e, stackTrace) {
        logger.e('Failed to cancel upcoming reminder on completion',
            error: e, stackTrace: stackTrace);
      }
      try {
        await RecurringNotificationService.instance.cancelOrderReminders(odooId);
      } catch (e, stackTrace) {
        logger.e('Failed to cancel order reminders on completion',
            error: e, stackTrace: stackTrace);
      }
    }

    // 2. Cố gắng ghi nhận lên Odoo
    try {
      await _odoo.callKw(
        model: _model,
        method: 'action_complete',
        args: [
          [odooId]
        ],
      );

      if (local != null) {
        await _isar.db.writeTxn(() async {
          local.isPendingSync = false;
          local.isStagePendingSync = false;
          local.isActionCompletePendingSync = false;
          await _isar.db.fsmOrders.put(local);
        });
      }
    } on OdooApiException catch (e) {
      logger.w(
          'OrdersService.completeOrder: API call failed, saved local completion draft',
          error: e);
      rethrow;
    }
  }

  /// Format DateTime sang chuỗi UTC chuẩn Odoo Datetime ('YYYY-MM-DD HH:MM:SS').
  /// Odoo lưu Datetime theo UTC, nên phải convert local → UTC trước khi gửi.
  String _formatDateTimeUtc(DateTime dt) {
    final utc = dt.toUtc();
    return '${utc.year}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')} '
        '${utc.hour.toString().padLeft(2, '0')}:${utc.minute.toString().padLeft(2, '0')}:${utc.second.toString().padLeft(2, '0')}';
  }

  /// Ghi nhận giờ bắt đầu thực tế khi Worker check-in tại địa điểm (Offline-First).
  Future<void> checkIn(int odooId) async {
    final now = DateTime.now();

    // 1. Cập nhật local trước
    final local = await _isar.db.fsmOrders.getByOdooId(odooId);
    if (local != null) {
      if (local.isSkipped ||
          local.isRecurringProcessed ||
          local.stage == FsmOrderStage.done ||
          local.stage == FsmOrderStage.cancelled) {
        throw StateError(
            'Đơn hàng đã hoàn thành, bị huỷ hoặc bỏ qua. Không thể Check-in.');
      }
      await _isar.db.writeTxn(() async {
        local.dateStart = now;
        local.isPendingSync = true;
        await _isar.db.fsmOrders.put(local);
      });
    }

    // 2. Cố gắng ghi nhận lên Odoo
    try {
      await _odoo.callKw(
        model: _model,
        method: 'write',
        args: [
          [odooId],
          {'date_start': _formatDateTimeUtc(now)},
        ],
      );
      if (local != null) {
        await _isar.db.writeTxn(() async {
          local.isPendingSync = false;
          await _isar.db.fsmOrders.put(local);
        });
      }
    } on OdooApiException catch (e) {
      logger.w('OrdersService.checkIn: offline, queued local check-in',
          error: e);
      rethrow;
    }
  }

  /// Ghi nhận giờ kết thúc thực tế khi Worker check-out (Offline-First).
  Future<void> checkOut(int odooId) async {
    final now = DateTime.now();

    // 1. Cập nhật local trước
    final local = await _isar.db.fsmOrders.getByOdooId(odooId);
    if (local != null) {
      if (local.isSkipped ||
          local.isRecurringProcessed ||
          local.stage == FsmOrderStage.done ||
          local.stage == FsmOrderStage.cancelled) {
        throw StateError(
            'Đơn hàng đã hoàn thành, bị huỷ hoặc bỏ qua. Không thể Check-out.');
      }
      await _isar.db.writeTxn(() async {
        local.dateEnd = now;
        local.isPendingSync = true;
        await _isar.db.fsmOrders.put(local);
      });
    }

    // 2. Cố gắng ghi nhận lên Odoo
    try {
      await _odoo.callKw(
        model: _model,
        method: 'write',
        args: [
          [odooId],
          {'date_end': _formatDateTimeUtc(now)},
        ],
      );
      if (local != null) {
        await _isar.db.writeTxn(() async {
          local.isPendingSync = false;
          await _isar.db.fsmOrders.put(local);
        });
      }
    } on OdooApiException catch (e) {
      logger.w('OrdersService.checkOut: offline, queued local check-out',
          error: e);
      rethrow;
    }
  }

  Future<int> pendingSyncCount() async {
    final currentUserId = _odoo.currentUserId;
    if (currentUserId == null) return 0;
    final pending = await _isar.db.fsmOrders
        .filter()
        .localOwnerIdEqualTo(currentUserId)
        .isPendingSyncEqualTo(true)
        .findAll();
    return pending.length;
  }

  /// Sync các order chưa push lên Odoo (isPendingSync = true).
  /// Đơn completed → gọi action_complete thay vì write stage_id raw.
  /// Đơn khác → write field data (stage_id, date_start, date_end) sang UTC.
  Future<void> syncPending() async {
    final currentUserId = _odoo.currentUserId;
    if (currentUserId == null) return;
    final pending = await _isar.db.fsmOrders
        .filter()
        .localOwnerIdEqualTo(currentUserId)
        .isPendingSyncEqualTo(true)
        .findAll();

    for (final order in pending) {
      try {
        // 1. Nếu đây là local-only order (do logic lặp sinh ra lúc offline, odooId < 0)
        // -> Cần gọi API create trên Odoo trước để lấy odooId thật.
        if (order.odooId < 0) {
          final createResult = await _createOrderOnOdoo(order);
          if (createResult == null) {
            logger.w(
                'OrdersService.syncPending: Skip processing local order ${order.id} due to failed Odoo creation');
            continue;
          }

          // Cập nhật odooId thật vào Isar. Phải làm trong txn
          final oldOdooId = order.odooId;
          await _isar.db.writeTxn(() async {
            order.odooId = createResult.id;
            await _isar.db.fsmOrders.put(order);
          });
          logger.i(
              'OrdersService.syncPending: Swapped local order odooId: $oldOdooId -> ${createResult.id}');
        }

        // Đơn đã completed offline → gọi action chuẩn của Odoo
        if (order.stage == FsmOrderStage.done &&
            order.isActionCompletePendingSync) {
          await _odoo.callKw(
            model: _model,
            method: 'action_complete',
            args: [
              [order.odooId]
            ],
          );

          final current = await _isar.db.fsmOrders.getByOdooId(order.odooId);
          if (current != null) {
            await _isar.db.writeTxn(() async {
              current.isActionCompletePendingSync = false;
              await _isar.db.fsmOrders.put(current);
            });
          }
        } else {
          // Các stage khác → write raw
          final data = <String, dynamic>{
            'stage_id': order.stageId,
          };

          try {
            await _odoo.callKw(
              model: _model,
              method: 'write',
              args: [
                [order.odooId],
                data,
              ],
            );
          } on OdooBusinessException catch (be) {
            if (be.message.contains('ValueError')) {
              logger.w('Odoo reject write, skipping order ${order.odooId}',
                  error: be);
              continue;
            }
            rethrow;
          }
        }

        // Sync date_start / date_end nếu có (UTC)
        final dateData = <String, dynamic>{};
        if (order.dateStart != null) {
          dateData['date_start'] = _formatDateTimeUtc(order.dateStart!);
        }
        if (order.dateEnd != null) {
          dateData['date_end'] = _formatDateTimeUtc(order.dateEnd!);
        }
        if (dateData.isNotEmpty) {
          await _odoo.callKw(
            model: _model,
            method: 'write',
            args: [
              [order.odooId],
              dateData,
            ],
          );
        }

        final current = await _isar.db.fsmOrders.getByOdooId(order.odooId);
        if (current != null &&
            current.isStagePendingSync &&
            current.stageId == order.stageId) {
          await _isar.db.writeTxn(() async {
            current.isPendingSync = false;
            current.isStagePendingSync = false;
            current.isActionCompletePendingSync = false;
            await _isar.db.fsmOrders.put(current);
          });
        }
      } catch (e) {
        logger.w('OrdersService.syncPending: failed for order ${order.odooId}',
            error: e);
      }
    }
  }

  /// Resolve conflict giữa local và server orders.
  /// Xử lý 3 cases:
  /// 1. Local-only (odooId < 0) duplicate vs server order
  /// 2. Same odooId on both sides - merge based on lastSyncAt/isPendingSync
  /// 3. Local has odooId but server deleted it (mark for deletion)
  Future<List<FsmOrder>> _resolveConflictsAndSave(
      List<FsmOrder> fetchedOrders) async {
    final currentUserId = _odoo.currentUserId;
    final cleanOrders = fetchedOrders.map((order) {
      order.localOwnerId = currentUserId;
      return order;
    }).toList();
    final isar = _isar.db;

    // Build map of server orders by odooId for quick lookup
    final serverOrdersMap = <int, FsmOrder>{};
    for (final o in fetchedOrders) {
      serverOrdersMap[o.odooId] = o;
    }

    try {
      await isar.writeTxn(() async {
        // Use a map to collect final orders by odooId to avoid unique index violations
        // This replaces individual put() calls with in-memory deduplication
        final finalOrdersMap = <int, FsmOrder>{};

        // Helper to add/update order in finalOrdersMap and cleanOrders
        void upsertOrder(FsmOrder order) {
          finalOrdersMap[order.odooId] = order;
          final idx = cleanOrders.indexWhere((o) => o.odooId == order.odooId);
          if (idx != -1) {
            cleanOrders[idx] = order;
          }
        }

        // Helper to remove order from finalOrdersMap
        void removeOrder(int odooId) {
          finalOrdersMap.remove(odooId);
        }

        // 1. Handle local-only duplicates vs server orders (existing logic)
        for (final odooOrder in fetchedOrders) {
          if (odooOrder.recurringId == null ||
              odooOrder.recurringId! <= 0 ||
              odooOrder.scheduledDateStart == null) {
            continue;
          }

          // Tìm local-only duplicate: odooId < 0, same recurringId, same scheduledDateStart
          final localOnly = await isar.fsmOrders
              .filter()
              .odooIdLessThan(0)
              .recurringIdEqualTo(odooOrder.recurringId!)
              .scheduledDateStartEqualTo(odooOrder.scheduledDateStart)
              .localOwnerIdEqualTo(currentUserId)
              .findFirst();

          if (localOnly != null) {
            // Case 1: Thợ đã bắt đầu/hoàn thành/skip tasks offline -> Giữ local changes, merge odooId
            if (localOnly.stage != FsmOrderStage.draft ||
                localOnly.dateStart != null ||
                localOnly.isSkipped) {
              logger.i(
                  'Conflict Resolution: Local order ${localOnly.id} has progress. Copying real odooId: ${odooOrder.odooId}');
              // Delete any existing order with the server's odooId from map (will be replaced)
              removeOrder(odooOrder.odooId);
              await isar.fsmOrders.deleteByOdooId(odooOrder.odooId);
              localOnly.odooId = odooOrder.odooId;
              localOnly.requirePhoto = odooOrder.requirePhoto;
              localOnly.isPendingSync = true;
              upsertOrder(localOnly);
            } else {
              // Case 2: Local order là clean (chưa làm gì) -> Odoo wins, delete local duplicate
              logger.i(
                  'Conflict Resolution: Overwriting clean local order ${localOnly.id} with server order');
              await isar.fsmOrders.delete(localOnly.id);
              // Ensure server order is in the map
              upsertOrder(odooOrder);
            }
          } else {
            // No local-only duplicate, ensure server order is in map
            upsertOrder(odooOrder);
          }
        }

        // 2. Handle conflicts where both local and server have same odooId > 0
        // RE-QUERY local orders AFTER local-only processing (which may have deleted/updated some)
        // to avoid stale snapshot bug where deleted/updated orders were re-processed
        final allLocalOrders = await isar.fsmOrders
            .filter()
            .odooIdGreaterThan(0)
            .localOwnerIdEqualTo(currentUserId)
            .findAll();

        // Build set of server odooIds for quick lookup
        final serverOdooIds = fetchedOrders.map((o) => o.odooId).toSet();

        // Filter local orders that have matching server odooId
        final localOrdersWithSameOdooId = allLocalOrders
            .where((o) => serverOdooIds.contains(o.odooId))
            .toList();

        for (final localOrder in localOrdersWithSameOdooId) {
          final serverOrder = serverOrdersMap[localOrder.odooId];
          if (serverOrder == null) continue; // Server deleted this order

          // Check if local has pending changes
          final localHasPendingChanges = localOrder.isPendingSync ||
              localOrder.dateStart != null ||
              localOrder.isSkipped ||
              localOrder.stage != FsmOrderStage.draft;

          // Check if server has newer data (server's lastSyncAt would be updated on fetch)
          final serverIsNewer =
              serverOrder.lastSyncAt.isAfter(localOrder.lastSyncAt);

          if (localOrder.isPendingSync && localHasPendingChanges) {
            // Local has uncommitted changes - keep local, mark for sync
            logger.i(
                'Conflict Resolution: Local order ${localOrder.odooId} has pending changes. Keeping local, marking for sync.');
            // Merge server's non-conflicting fields (e.g., scheduledDateStart/End from server if local didn't change them)
            if (localOrder.scheduledDateStart == serverOrder.scheduledDateStart &&
                localOrder.scheduledDateEnd == serverOrder.scheduledDateEnd) {
              // Local didn't modify schedule, accept server's schedule
              localOrder.scheduledDateStart = serverOrder.scheduledDateStart;
              localOrder.scheduledDateEnd = serverOrder.scheduledDateEnd;
            }
            // Update server's non-conflicting metadata (preserve local stage when pending)
            if (!localOrder.isStagePendingSync) {
              localOrder.stageId = serverOrder.stageId;
              localOrder.stageName = serverOrder.stageName;
              localOrder.stage = serverOrder.stage;
            }
            localOrder.personId = serverOrder.personId;
            localOrder.personName = serverOrder.personName;
            localOrder.priority = serverOrder.priority;
            localOrder.routeSequence = serverOrder.routeSequence;
            localOrder.routeId = serverOrder.routeId;
            localOrder.routeState = serverOrder.routeState;
            localOrder.requirePhoto = serverOrder.requirePhoto;
            localOrder.isPendingSync = true;
            localOrder.lastSyncAt = DateTime.now();
            upsertOrder(localOrder);
          } else if (serverIsNewer && !localHasPendingChanges) {
            // Server has newer data and local has no pending changes - use server
            logger.i(
                'Conflict Resolution: Server order ${serverOrder.odooId} is newer. Updating local with server data.');
            serverOrder.localOwnerId = currentUserId;
            upsertOrder(serverOrder);
          } else {
            // Local has changes but not pending sync, or timestamps equal - keep local but update non-conflicting server fields
            logger.i(
                'Conflict Resolution: Order ${localOrder.odooId} - keeping local, merging server metadata.');
            if (!localOrder.isStagePendingSync) {
              localOrder.stageId = serverOrder.stageId;
              localOrder.stageName = serverOrder.stageName;
              localOrder.stage = serverOrder.stage;
            }
            localOrder.personId = serverOrder.personId;
            localOrder.personName = serverOrder.personName;
            localOrder.priority = serverOrder.priority;
            localOrder.routeSequence = serverOrder.routeSequence;
            localOrder.routeId = serverOrder.routeId;
            localOrder.routeState = serverOrder.routeState;
            localOrder.requirePhoto = serverOrder.requirePhoto;
            localOrder.lastSyncAt = DateTime.now();
            upsertOrder(localOrder);
          }
        }

        // 3. Handle local orders that server deleted (exist locally but not in server response)
        final allLocalOrdersWithOdooId =
            allLocalOrders.where((o) => o.odooId > 0).toList();
        final fetchedOdooIds = serverOdooIds;

        for (final localOrder in allLocalOrdersWithOdooId) {
          if (!fetchedOdooIds.contains(localOrder.odooId)) {
            // Server doesn't have this order anymore - it was deleted on server
            if (localOrder.isPendingSync ||
                localOrder.dateStart != null ||
                localOrder.isSkipped) {
              // Local has work - keep record as cancelled, do not queue sync
              logger.i(
                  'Conflict Resolution: Server deleted order ${localOrder.odooId} but local has work. Retaining cancelled local record.');
              localOrder.stage = FsmOrderStage.cancelled;
              localOrder.isPendingSync = false;
              localOrder.isStagePendingSync = false;
              upsertOrder(localOrder);
            } else {
              // Local is clean - safe to delete locally
              logger.i(
                  'Conflict Resolution: Server deleted order ${localOrder.odooId}, deleting clean local copy.');
              removeOrder(localOrder.odooId);
              await isar.fsmOrders.delete(localOrder.id);
            }
          }
        }

        // 4. Ensure all fetched orders are in the final map (for any not handled above)
        for (final odooOrder in fetchedOrders) {
          if (!finalOrdersMap.containsKey(odooOrder.odooId)) {
            upsertOrder(odooOrder);
          }
        }

        // 5. Single batch upsert - this avoids unique index violations
        if (finalOrdersMap.isNotEmpty) {
          await isar.fsmOrders.putAll(finalOrdersMap.values.toList());
        }
      });
    } on IsarError catch (e, stackTrace) {
      logger.e('_resolveConflictsAndSave: Isar error, falling back to non-persistent fetch',
          error: e, stackTrace: stackTrace);
      for (final o in fetchedOrders) {
        o.localOwnerId = currentUserId;
      }
      return fetchedOrders;
    }

    return cleanOrders;
  }

  /// Tạo một fsm.order thật trên Odoo từ local instance.
  /// Trả về odooId thật thu được từ Odoo server.
  Future<OdooCreateResult?> _createOrderOnOdoo(FsmOrder order) async {
    // Chống trùng lặp đơn hàng (Idempotency): kiểm tra xem Odoo đã tự động tạo
    // hoặc đã nhận được đơn hàng định kỳ này trước đó chưa để tránh tạo duplicate.
    // This MUST succeed for recurring orders; if the lookup fails we do NOT proceed to create.
    if (order.recurringId != null &&
        order.recurringId! > 0 &&
        order.scheduledDateStart != null) {
      final scheduledStartStr = _formatDateTimeUtc(order.scheduledDateStart!);
      try {
        final List<dynamic> exist = await _odoo.callKw(
          model: _model,
          method: 'search_read',
          args: [
            [
              ['scheduled_date_start', '=', scheduledStartStr],
              ['person_id', '=', order.personId],
              ['fsm_recurring_id', '=', order.recurringId]
            ]
          ],
          kwargs: {
            'fields': ['id'],
            'limit': 1
          },
        ) as List<dynamic>;
        if (exist.isNotEmpty) {
          final existingId = exist.first['id'] as int;
          logger.i(
              'Idempotency check: Order already exists on Odoo server. Reusing ID: $existingId');
          return OdooCreateResult(existingId);
        }
      } on OdooBusinessException catch (e) {
        // Chỉ fallback khi lỗi phát sinh từ unsupported-field 'fsm_recurring_id'
        if (e.message.contains('fsm_recurring_id') ||
            e.message.contains('Invalid field')) {
          logger.w(
              'Idempotency check: custom field not supported. Retrying with basic fields...',
              error: e);
          try {
            final List<dynamic> existFallback = await _odoo.callKw(
              model: _model,
              method: 'search_read',
              args: [
                [
                  ['scheduled_date_start', '=', scheduledStartStr],
                  ['person_id', '=', order.personId],
                ]
              ],
              kwargs: {
                'fields': ['id', 'name'],
                'limit': 10
              },
            ) as List<dynamic>;
            if (existFallback.isNotEmpty) {
              // Đối sánh chặt chẽ theo name để đảm bảo không gán nhầm sang order bất kỳ khác
              final matches = existFallback.where((item) {
                final remoteName = item['name'] as String?;
                return remoteName != null &&
                    remoteName.trim() == order.name.trim();
              }).toList();

              if (matches.length == 1) {
                final existingId = matches.first['id'] as int;
                logger.i(
                    'Idempotency check fallback: Order already exists with matching name. Reusing ID: $existingId');
                return OdooCreateResult(existingId);
              } else if (matches.length > 1) {
                // Có sự mập mờ (nhiều hơn 1 order trùng lặp): treat as unresolved và rethrow lỗi gốc
                logger.e(
                    'Ambiguous matches found during fallback. Count: ${matches.length}');
                rethrow;
              }
            }
          } catch (fallbackError) {
            logger.e('Idempotency check fallback failed entirely',
                error: fallbackError);
            rethrow;
          }
        } else {
          rethrow;
        }
      } catch (e) {
        // Các loại lỗi khác (mạng, authen, ...): ném ra ngoài để lưu local chờ retry, không bỏ qua hoặc fallback bừa bãi
        logger.e(
            'Idempotency check failed due to connection/auth/other error. Aborting.',
            error: e);
        rethrow;
      }
      // If lookup succeeded but no existing order found, proceed to create.
    }

    final data = <String, dynamic>{
      'name': order.name,
      'description': order.description,
      'stage_id': order.stageId,
      'scheduled_date_start': order.scheduledDateStart != null
          ? _formatDateTimeUtc(order.scheduledDateStart!)
          : null,
      'scheduled_date_end': order.scheduledDateEnd != null
          ? _formatDateTimeUtc(order.scheduledDateEnd!)
          : null,
      'priority': order.priority ?? '0',
    };

    // Map relation fields an toàn (nếu có gán)
    if (order.partnerId != null && order.partnerId! > 0) {
      data['partner_id'] = order.partnerId;
    }
    if (order.warehouseId != null && order.warehouseId! > 0) {
      data['warehouse_id'] = order.warehouseId;
    }
    if (order.personId != null && order.personId! > 0) {
      data['person_id'] = order.personId;
    }

    // Link về recurring parent nếu có
    if (order.recurringId != null && order.recurringId! > 0) {
      data['fsm_recurring_id'] = order.recurringId;
    }

    try {
      final id = await _odoo.callKw(
        model: _model,
        method: 'create',
        args: [data],
      ) as int;
      return OdooCreateResult(id);
    } on OdooBusinessException catch (be) {
      // Chỉ fallback khi lỗi là do field không tồn tại (custom fields chưa được hỗ trợ)
      // Các lỗi khác (auth, connection, business logic) rethrow để fail closed
      if (be.message.contains('fsm_recurring_id') ||
          be.message.contains('ValueError')) {
        logger.w('Odoo reject custom fields, retrying with basic fields...',
            error: be);
        data.remove('fsm_recurring_id');
        // Retry with basic fields
        final id = await _odoo.callKw(
          model: _model,
          method: 'create',
          args: [data],
        ) as int;
        return OdooCreateResult(id);
      }
      rethrow;
    } catch (e, stackTrace) {
      logger.e(
          'OrdersService._createOrderOnOdoo failed for temporary order ${order.odooId}',
          error: e,
          stackTrace: stackTrace);
      return null;
    }
  }
}
