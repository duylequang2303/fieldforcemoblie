import 'package:isar_community/isar.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/fsm_order.dart';

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
        kwargs: {'fields': ['id', 'name']},
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
        kwargs: {'fields': ['res_id'], 'limit': 1},
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
    logger.i('OrdersService.fetchMyOrders: Fetching with domain: person_id.user_id = $userId');
    final rawOrders = await _odoo.callKw(
      model: _model,
      method: 'search_read',
      args: [domain],
      kwargs: {'fields': _fields, 'order': 'scheduled_date_start asc'},
    ) as List<dynamic>;

    // Nếu không có kết quả, thử fallback domains
    if (rawOrders.isEmpty) {
      logger.w('OrdersService.fetchMyOrders: Không có kết quả với domain chính, thử fallback domains');

      // Thử fallback 1: person_ids
      final fallbackOrders1 = await _tryFetchOrders(domainFallback1);
      if (fallbackOrders1.isNotEmpty) {
        logger.i('OrdersService.fetchMyOrders: Found orders via person_ids fallback');
        return fallbackOrders1;
      }

      // Thử fallback 2: team_id.calendar_user_id
      final fallbackOrders2 = await _tryFetchOrders(domainFallback2);
      if (fallbackOrders2.isNotEmpty) {
        logger.i('OrdersService.fetchMyOrders: Found orders via team_id fallback');
        return fallbackOrders2;
      }

      logger.w('OrdersService.fetchMyOrders: Không có kết quả với bất kỳ domain nào');
    }

    // Process location_ids và route_ids như cũ
    final locationIds = rawOrders
        .where((e) => (e as Map)['location_id'] != null && e['location_id'] is List)
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
          kwargs: {'fields': ['state']},
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

    // Lưu vào Isar để dùng offline
    await _isar.db.writeTxn(() async {
      await _isar.db.fsmOrders.putAllByOdooId(orders);
    });

    return orders;
  }

  /// Helper method để thử fetch orders với một domain khác.
  Future<List<FsmOrder>> _tryFetchOrders(List<dynamic> domain) async {
    try {
      final rawOrders = await _odoo.callKw(
        model: _model,
        method: 'search_read',
        args: [domain],
        kwargs: {'fields': _fields, 'order': 'scheduled_date_start asc'},
      ) as List<dynamic>;

      if (rawOrders.isEmpty) {
        return [];
      }

      // Process location_ids và route_ids
      final locationIds = rawOrders
          .where((e) => (e as Map)['location_id'] != null && e['location_id'] is List)
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
            kwargs: {'fields': ['state']},
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

        return FsmOrder.fromJson(oMap, locationCoordinates: locationCoordinates);
      }).toList();

      await _isar.db.writeTxn(() async {
        await _isar.db.fsmOrders.putAllByOdooId(orders);
      });

      return orders;
    } catch (e) {
      logger.w('OrdersService._tryFetchOrders: Error fetching with domain', error: e);
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
    final name = _stageNames[newStageId] ?? '';
    
    if (name.contains('progress') || name.contains('thực hiện')) {
      local.stageName = 'In Progress';
      local.stage = FsmOrderStage.inProgress;
    } else if (name.contains('completed') || name.contains('done') || name.contains('hoàn')) {
      local.stageName = 'Completed';
      local.stage = FsmOrderStage.done;
    } else if (name.contains('cancel') || name.contains('huỷ')) {
      local.stageName = 'Cancelled';
      local.stage = FsmOrderStage.cancelled;
    } else {
      local.stageName = 'New';
      local.stage = FsmOrderStage.draft;
    }
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
      logger.w('OrdersService.updateStage: offline, queued local update', error: e);
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
      await _isar.db.writeTxn(() async {
        local.stage = FsmOrderStage.done;
        local.stageName = 'Completed';
        if (doneStageId != null) {
          local.stageId = doneStageId;
        }
        local.isPendingSync = true;
        await _isar.db.fsmOrders.put(local);
      });
    }

    // 2. Cố gắng ghi nhận lên Odoo
    try {
      await _odoo.callKw(
        model: _model,
        method: 'action_complete',
        args: [[odooId]],
      );
      
      if (local != null) {
        await _isar.db.writeTxn(() async {
          local.isPendingSync = false;
          await _isar.db.fsmOrders.put(local);
        });
      }
    } on OdooApiException catch (e) {
      logger.w('OrdersService.completeOrder: API call failed, saved local completion draft', error: e);
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
      logger.w('OrdersService.checkIn: offline, queued local check-in', error: e);
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
      logger.w('OrdersService.checkOut: offline, queued local check-out', error: e);
      rethrow;
    }
  }

  /// Sync các order chưa push lên Odoo (isPendingSync = true).
  /// Đơn completed → gọi action_complete thay vì write stage_id raw.
  /// Đơn khác → write field data (stage_id, date_start, date_end) sang UTC.
  Future<void> syncPending() async {
    final pending = await _isar.db.fsmOrders
        .filter()
        .isPendingSyncEqualTo(true)
        .findAll();

    for (final order in pending) {
      try {
        // Đơn đã completed offline → gọi action chuẩn của Odoo
        if (order.stage == FsmOrderStage.done) {
          await _odoo.callKw(
            model: _model,
            method: 'action_complete',
            args: [[order.odooId]],
          );
        } else {
          // Các stage khác → write raw
          final data = <String, dynamic>{
            'stage_id': order.stageId,
          };
          await _odoo.callKw(
            model: _model,
            method: 'write',
            args: [
              [order.odooId],
              data,
            ],
          );
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

        await _isar.db.writeTxn(() async {
          order.isPendingSync = false;
          await _isar.db.fsmOrders.put(order);
        });
      } catch (e) {
        logger.w('OrdersService.syncPending: failed for order ${order.odooId}', error: e);
      }
    }
  }
}
