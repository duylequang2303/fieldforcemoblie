import 'package:isar_community/isar.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/schedule_property.dart';

/// Đọc danh sách địa điểm (fsm.location) từ Odoo cho tab Properties.
/// Có cache Isar offline-first và hỗ trợ phân trang.
class PropertiesService {
  PropertiesService._();
  static final PropertiesService instance = PropertiesService._();
  final OdooSessionManager _odoo = OdooSessionManager.instance;
  final IsarService _isar = IsarService.instance;

  // Tái dùng field thật của fsm.location (khớp OrdersService._locationFields).
  static const _locationFields = [
    'id',
    'name',
    'partner_latitude',
    'partner_longitude',
    'partner_id',
    'street',
    'street2',
    'city',
    'zip',
    'owner_id',
    'direction',
    'phone',
    'email',
  ];

  /// Mặc định số lượng item mỗi trang.
  static const int defaultPageSize = 50;

  /// Lấy danh sách properties, ưu tiên cache Isar (offline-first).
  /// Nếu online, fetch Odoo và update cache.
  Future<List<ScheduleProperty>> fetchProperties() async {
    // Mặc định load page đầu tiên (pageSize items)
    return fetchPropertiesPaginated(page: 0, pageSize: defaultPageSize);
  }

  /// Lấy properties theo phân trang từ cache Isar (offline-first).
  /// Nếu online và page = 0, fetch Odoo và update cache.
  Future<List<ScheduleProperty>> fetchPropertiesPaginated({
    required int page,
    int pageSize = defaultPageSize,
  }) async {
    final offset = page * pageSize;

    // 1. Thử lấy từ cache Isar trước (offline-first)
    final cached = await _loadFromCachePaginated(offset: offset, limit: pageSize);
    if (cached.isNotEmpty) {
      logger.i('PropertiesService: loaded ${cached.length} properties from Isar cache (page $page)');
    }

    // 2. Nếu online và là page đầu tiên, fetch từ Odoo và update cache
    if (page == 0 && _odoo.isAuthenticated) {
      try {
        final fresh = await _fetchFromOdooAndCache();
        logger.i('PropertiesService: loaded ${fresh.length} properties from Odoo (online)');
        // Trả về page đầu tiên từ dữ liệu mới
        return fresh.take(pageSize).toList();
      } on OdooAuthException {
        rethrow;
      } on OdooConnectionException {
        // Offline - trả về cache nếu có
        if (cached.isNotEmpty) {
          logger.w('PropertiesService: offline, returning cached data (page $page)');
          return cached;
        }
        rethrow;
      } catch (e) {
        logger.e('PropertiesService: unexpected error fetching from Odoo', error: e);
        if (cached.isNotEmpty) {
          return cached;
        }
        rethrow;
      }
    } else {
      // Không authenticated hoặc không phải page 0 - trả về cache
      if (cached.isNotEmpty) {
        logger.w('PropertiesService: returning cached data (page $page)');
        return cached;
      }
      if (page == 0) {
        throw OdooAuthException('Not authenticated and no cached data');
      }
      return []; // Các page sau không có dữ liệu cache thì trả về rỗng
    }
  }

  /// Lấy tổng số properties trong cache (dùng để biết khi nào dừng pagination).
  Future<int> getTotalCount() async {
    try {
      return await _isar.db.schedulePropertys.where().count();
    } catch (e) {
      logger.w('PropertiesService: failed to count cache', error: e);
      return 0;
    }
  }

  /// Lấy properties từ Isar cache với phân trang.
  Future<List<ScheduleProperty>> _loadFromCachePaginated({
    required int offset,
    required int limit,
  }) async {
    try {
      final properties = await _isar.db.schedulePropertys
          .where()
          .offset(offset)
          .limit(limit)
          .findAll();
      return properties;
    } catch (e) {
      logger.w('PropertiesService: failed to load from cache', error: e);
      return [];
    }
  }

  /// Fetch từ Odoo và lưu vào Isar cache.
  Future<List<ScheduleProperty>> _fetchFromOdooAndCache() async {
    final raw = await _odoo.callKw(
      model: 'fsm.location',
      method: 'search_read',
      args: [<dynamic>[]],
      kwargs: {'fields': _locationFields, 'limit': 200, 'order': 'id'},
    ) as List<dynamic>;

    logger.i('PropertiesService: fetched ${raw.length} locations from Odoo');

    final fresh = raw.map((e) {
      final m = e as Map<String, dynamic>;
      return ScheduleProperty.fromOdooJson(m);
    }).toList();

    // Lưu vào Isar cache (replace all)
    await _isar.db.writeTxn(() async {
      // Xóa cache cũ
      await _isar.db.schedulePropertys.clear();
      // Lưu mới
      await _isar.db.schedulePropertys.putAll(fresh);
    });

    return fresh;
  }

  /// Lấy tất cả properties từ cache (dùng cho search/filter).
  Future<List<ScheduleProperty>> fetchAllFromCache() async {
    return _loadFromCache();
  }

  /// Clear cache (dùng khi logout hoặc cần reset).
  Future<void> clearCache() async {
    await _isar.db.writeTxn(() async {
      await _isar.db.schedulePropertys.clear();
    });
  }

  /// Lấy properties từ Isar cache (dùng trong search).
  Future<List<ScheduleProperty>> _loadFromCache() async {
    try {
      final properties = await _isar.db.schedulePropertys
          .where()
          .findAll();
      return properties;
    } catch (e) {
      logger.w('PropertiesService: failed to load from cache', error: e);
      return [];
    }
  }
}