import 'package:isar_community/isar.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/fsm_order.dart';
import 'recurring_service.dart';

class OdooCreateResult {
  final int id;
  final bool isSkippedRejected;
  OdooCreateResult(this.id, {this.isSkippedRejected = false});
}

/// Service giao tiếp với Odoo API cho fsm.order.
/// Tất cả Odoo call đi qua đây, không gọi trực tiếp từ Provider hay Widget.
class OrdersService {
  OrdersService._();
  static final OrdersService instance = OrdersService._();

  final _odoo = OdooSessionManager.instance;
  final _isar = IsarService.instance;

  static const _model = 'fsm.order';

  // Fields cơ bản cho fsm.order
  static const _fields = [
    'id',
    'name',
    'description',
    'stage_id',
    'stage_name',
    'location_id',
    'location_directions',
    'phone',
    'scheduled_date_start',
    'scheduled_date_end',
    'date_start',
    'person_id',
    'route_sequence',
    'route_id',
    'require_signature',
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
    'state_name',
    'todo',
    // Recurring fields needed for conflict resolution
    'fsm_recurring_id',
    'is_skipped',
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
        args: [[]],
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

  Future<int?> getStageIdByKeywords(List<String> keywords) async {
    await fetchStagesIfNeeded();
    for (final entry in _stageIdsByLowerName.entries) {
      for (final kw in keywords) {
        if (entry.key.contains(kw.toLowerCase())) {
          return entry.value;
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
    } on OdooBusinessException catch (be) {
      final msg = be.message;
      final List<String> fieldsToRemove = [];
      if (msg.contains('fsm_recurring_id')) {
        fieldsToRemove.add('fsm_recurring_id');
      }
      if (msg.contains('is_skipped')) {
        fieldsToRemove.add('is_skipped');
      }
      // Generic ValueError without specific field -> rethrow
      if (fieldsToRemove.isEmpty) {
        rethrow;
      }
      logger.w('Odoo search_read rejected custom fields: ${fieldsToRemove.join(', ')}, retrying without them...', error: be);
      final reducedFields = List<String>.from(_fields)..removeWhere(fieldsToRemove.contains);
      return await _odoo.callKw(
        model: _model,
        method: 'search_read',
        args: [domain],
        kwargs: {'fields': reducedFields, 'order': 'scheduled_date_start asc'},
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

    // [WARNING] Quy ước nội bộ công ty:
    // Dùng field person_id.user_id (thường là Salesperson) để map thợ (fsm.person) với user login.
    // KHÔNG SỬA thành chuẩn Odoo (person_id.partner_id.user_ids) vì dữ liệu partner_id không chứa user.

    // Domain chính: person_id.user_id = userId
    final domain = [
      ['person_id.user_id', '=', userId]
    ];

    // Thử thêm fallback domain nếu không có kết quả:
    // Trường hợp 1: fsm.order có person_id nhưng person_id.user_id không tồn tại
    // Trường hợp 2: fsm.order có person_ids (many2many) và user có thể trong đó
    // Trường hợp 3: fsm.order không có person_id nhưng có team_id với team có user_id
    final domainFallback1 = [
      ['person_ids.user_id', '=', userId] // many2many field person_ids
    ];

    final domainFallback2 = [
      ['team_id.calendar_user_id', '=', userId] // team với calendar_user_id
    ];

    // Fetch orders với domain chính
    logger.i(
        'OrdersService.fetchMyOrders: Fetching with domain: person_id.user_id = $userId');
    final rawOrders = await _callSearchRead(domain);

    // Nếu không có kết quả, thử fallback domains
    if (rawOrders.isEmpty) {
      logger.w(
          'OrdersService.fetchMyOrders: Không có kết quả với domain chính, thử fallback domains');

      // Thử fallback 1: person_ids
      final fallbackOrders1 = await _tryFetchOrders(domainFallback1);
      if (fallbackOrders1.isNotEmpty) {
        logger.i(
            'OrdersService.fetchMyOrders: Found orders via person_ids fallback');
        return fallbackOrders1;
      }

      // Thử fallback 2: team_id.calendar_user_id
      final fallbackOrders2 = await _tryFetchOrders(domainFallback2);
      if (fallbackOrders2.isNotEmpty) {
        logger.i(
            'OrdersService.fetchMyOrders: Found orders via team_id fallback');
        return fallbackOrders2;
      }

      logger.w(
          'OrdersService.fetchMyOrders: Không có kết quả với bất kỳ domain nào');
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

      return saved;
    } catch (e) {
      logger.w('OrdersService._tryFetchOrders: Error fetching with domain',
          error: e);
      return [];
    }
  }

  /// Đọc orders từ Isar (khi offline).
  Future<List<FsmOrder>> loadCachedOrders() async {
    return _isar.db.fsmOrders.where().anyId().findAll();
  }

  /// Helper mapper từ stageId sang FsmOrderStage và tên tương ứng.
  void _updateStageFields(FsmOrder local, int newStageId) {
    local.stageId = newStageId;
    final name = (_stageNames[newStageId] ?? '').toLowerCase().trim();

    local.stage = switch (name) {
      'new' || 'draft' || 'scheduled' || 'mới' || 'nháp' || 'đã lên lịch' || 'lên lịch' || 'hold' || 'on hold' || 'on_hold' => FsmOrderStage.draft,
      'ready' || 'in_progress' || 'in progress' || 'sẵn sàng' || 'đang thực hiện' || 'thực hiện' => FsmOrderStage.inProgress,
      'done' || 'completed' || 'hoàn thành' || 'hoàn' => FsmOrderStage.done,
      'cancelled' || 'cancel' || 'huỷ' || 'hủy' || 'đã huỷ' || 'đã hủy' => FsmOrderStage.cancelled,
      // fallback checks matching exact substring patterns
      _ when name.contains('progress') || name.contains('thực hiện') || name.contains('ready') || name.contains('sẵn sàng') => FsmOrderStage.inProgress,
      _ when name.contains('done') || name.contains('completed') || name.contains('hoàn') => FsmOrderStage.done,
      _ when name.contains('cancel') || name.contains('huỷ') || name.contains('hủy') => FsmOrderStage.cancelled,
      _ => FsmOrderStage.draft,
    };

    local.stageName = switch (local.stage) {
      FsmOrderStage.inProgress => 'In Progress',
      FsmOrderStage.done => 'Completed',
      FsmOrderStage.cancelled => 'Cancelled',
      FsmOrderStage.draft => 'New',
    };
  }

  /// Cập nhật stage của một đơn dịch vụ (Offline-First).
  Future<void> updateStage(int odooId, int newStageId) async {
    // 1. Cập nhật local trước
    final local = await _isar.db.fsmOrders.getByOdooId(odooId);
    if (local != null) {
      await _isar.db.writeTxn(() async {
        _updateStageFields(local, newStageId);
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
          {'stage_id': newStageId},
        ],
      );
      if (local != null) {
        await _isar.db.writeTxn(() async {
          local.isPendingSync = false;
          await _isar.db.fsmOrders.put(local);
        });
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
        await _isar.db.fsmOrders.put(local);
      });
      if (!wasCompleted) {
        try {
          await RecurringService.instance.onOccurrenceCompleted(local);
        } on OdooApiException catch (e) {
          logger.w('Error updating recurring occurrence logic on completion (Odoo)', error: e);
        } on StateError catch (e) {
          logger.w('Error updating recurring occurrence logic on completion (State)', error: e);
        }
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

  /// Sync các order chưa push lên Odoo (isPendingSync = true).
  /// Đơn completed → gọi action_complete thay vì write stage_id raw.
  /// Đơn khác → write field data (stage_id, date_start, date_end) sang UTC.
  Future<void> syncPending() async {
    final pending =
        await _isar.db.fsmOrders.filter().isPendingSyncEqualTo(true).findAll();

    for (final order in pending) {
      try {
        bool isSkippedRejected = false;

        // 1. Nếu đây là local-only order (do logic lặp sinh ra lúc offline, odooId < 0)
        // -> Cần gọi API create trên Odoo trước để lấy odooId thật.
        if (order.odooId < 0) {
          final createResult = await _createOrderOnOdoo(order);
          if (createResult == null) {
            logger.w('OrdersService.syncPending: Skip processing local order ${order.id} due to failed Odoo creation');
            continue;
          }
          isSkippedRejected = createResult.isSkippedRejected;
          
          // Cập nhật odooId thật vào Isar. Phải làm trong txn
          final oldOdooId = order.odooId;
          await _isar.db.writeTxn(() async {
            order.odooId = createResult.id;
            await _isar.db.fsmOrders.put(order);
          });
          logger.i('OrdersService.syncPending: Swapped local order odooId: $oldOdooId -> ${createResult.id}');
        }

        // Đơn đã completed offline → gọi action chuẩn của Odoo
        if (order.stage == FsmOrderStage.done) {
          await _odoo.callKw(
            model: _model,
            method: 'action_complete',
            args: [
              [order.odooId]
            ],
          );
        } else {
          // Các stage khác → write raw
          final data = <String, dynamic>{
            'stage_id': order.stageId,
          };
          if (order.isSkipped && !isSkippedRejected) {
            data['is_skipped'] = true;
          }
          
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
            if (be.message.contains('is_skipped') || be.message.contains('ValueError')) {
              logger.w('Odoo reject is_skipped field, retrying without it...', error: be);
              data.remove('is_skipped');
              isSkippedRejected = true;
              await _odoo.callKw(
                model: _model,
                method: 'write',
                args: [
                  [order.odooId],
                  data,
                ],
              );
            } else {
              rethrow;
            }
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

        if (!isSkippedRejected) {
          await _isar.db.writeTxn(() async {
            order.isPendingSync = false;
            await _isar.db.fsmOrders.put(order);
          });
        } else {
          logger.w('OrdersService.syncPending: is_skipped was rejected/unsupported by Odoo. Retaining isPendingSync=true for order ${order.odooId}');
        }
      } catch (e) {
        logger.w('OrdersService.syncPending: failed for order ${order.odooId}',
            error: e);
      }
    }
  }

  /// Resolve conflict giữa local-only recurring instances (sinh offline, odooId < 0)
  /// và các instances thật tải từ Odoo. Lưu dữ liệu sạch vào Isar.
  Future<List<FsmOrder>> _resolveConflictsAndSave(List<FsmOrder> fetchedOrders) async {
    final cleanOrders = List<FsmOrder>.from(fetchedOrders);
    final isar = _isar.db;

    await isar.writeTxn(() async {
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
            .findFirst();

        if (localOnly != null) {
          // Case 1: Thợ đã bắt đầu/hoàn thành/skip tasks offline -> Giữ local changes, merge odooId
          if (localOnly.stage != FsmOrderStage.draft || localOnly.dateStart != null || localOnly.isSkipped) {
            logger.i(
                'Conflict Resolution: Local order ${localOnly.id} has progress. Copying real odooId: ${odooOrder.odooId}');
            localOnly.odooId = odooOrder.odooId;
            localOnly.isPendingSync = true;
            await isar.fsmOrders.put(localOnly);

            // Replace the server order with the local one in the returned collection
            final index = cleanOrders.indexWhere((o) => o.odooId == odooOrder.odooId);
            if (index != -1) {
              cleanOrders[index] = localOnly;
            }
          } else {
            // Case 2: Local order là clean (chưa làm gì) -> Odoo wins, delete local duplicate
            logger.i(
                'Conflict Resolution: Overwriting clean local order ${localOnly.id} with server order');
            await isar.fsmOrders.delete(localOnly.id);
          }
        }
      }

      if (cleanOrders.isNotEmpty) {
        await isar.fsmOrders.putAllByOdooId(cleanOrders);
      }
    });

    return cleanOrders;
  }

  /// Tạo một fsm.order thật trên Odoo từ local instance.
  /// Trả về odooId thật thu được từ Odoo server.
  Future<OdooCreateResult?> _createOrderOnOdoo(FsmOrder order) async {
    // Chống trùng lặp đơn hàng (Idempotency): kiểm tra xem Odoo đã tự động tạo
    // hoặc đã nhận được đơn hàng định kỳ này trước đó chưa để tránh tạo duplicate.
    // This MUST succeed for recurring orders; if the lookup fails we do NOT proceed to create.
    if (order.recurringId != null && order.recurringId! > 0 && order.scheduledDateStart != null) {
      final scheduledStartStr = _formatDateTimeUtc(order.scheduledDateStart!);
      final List<dynamic> exist = await _odoo.callKw(
        model: _model,
        method: 'search_read',
        args: [[
          ['scheduled_date_start', '=', scheduledStartStr],
          ['person_id', '=', order.personId],
          ['fsm_recurring_id', '=', order.recurringId]
        ]],
        kwargs: {'fields': ['id'], 'limit': 1},
      ) as List<dynamic>;
      if (exist.isNotEmpty) {
        final existingId = exist.first['id'] as int;
        logger.i('Idempotency check: Order already exists on Odoo server. Reusing ID: $existingId');
        return OdooCreateResult(existingId);
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
      'require_signature': order.requireSignature,
    };

    if (order.isSkipped) {
      data['is_skipped'] = true;
    }

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
          be.message.contains('is_skipped') ||
          be.message.contains('ValueError')) {
        logger.w('Odoo reject custom fields, retrying with basic fields...', error: be);
        data.remove('fsm_recurring_id');
        data.remove('is_skipped');
        // Retry with basic fields
        final id = await _odoo.callKw(
          model: _model,
          method: 'create',
          args: [data],
        ) as int;
        return OdooCreateResult(id, isSkippedRejected: order.isSkipped);
      }
      rethrow;
    } catch (e, stackTrace) {
      logger.e('OrdersService._createOrderOnOdoo failed for temporary order ${order.odooId}',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }
}
