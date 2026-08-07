import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:fieldforce_mobile/core/api/api_exception.dart';
import 'package:fieldforce_mobile/core/api/odoo_client.dart';
import 'package:fieldforce_mobile/core/api/odoo_session_manager.dart';
import 'package:fieldforce_mobile/core/database/isar_service.dart';
import 'package:fieldforce_mobile/core/utils/logger.dart';
import 'package:fieldforce_mobile/features/schedule/models/schedule_property.dart';

/// Đọc danh sách địa điểm (fsm.location) từ Odoo cho tab Properties.
/// Có cache Isar offline-first và hỗ trợ phân trang.
class PropertiesService {
  PropertiesService._();
  static final PropertiesService instance = PropertiesService._();
  final OdooSessionManager _odoo = OdooSessionManager.instance;
  final IsarService _isar = IsarService.instance;
  List<ScheduleProperty> _webCache = [];

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

    if (kIsWeb) {
      if (page == 0) {
        if (_odoo.isAuthenticated) {
          try {
            final fresh = await _fetchFromOdooAndCache();
            _webCache = fresh;
            logger.i(
                'PropertiesService: loaded ${fresh.length} properties from Odoo (web)');
            return fresh.take(pageSize).toList();
          } on OdooAuthException {
            rethrow;
          } on OdooConnectionException {
            rethrow;
          } catch (e) {
            rethrow;
          }
        } else {
          throw OdooAuthException('Not authenticated');
        }
      } else {
        if (offset < _webCache.length) {
          return _webCache.skip(offset).take(pageSize).toList();
        }
        return [];
      }
    }

    // 1. Thử lấy từ cache Isar trước (offline-first)
    final cached =
        await _loadFromCachePaginated(offset: offset, limit: pageSize);
    if (cached.isNotEmpty) {
      logger.i(
          'PropertiesService: loaded ${cached.length} properties from Isar cache (page $page)');
    }

    // 2. Nếu online và là page đầu tiên, fetch từ Odoo và update cache
    if (page == 0 && _odoo.isAuthenticated) {
      try {
        final fresh = await _fetchFromOdooAndCache();
        logger.i(
            'PropertiesService: loaded ${fresh.length} properties from Odoo (online)');
        // Trả về page đầu tiên từ dữ liệu mới
        return fresh.take(pageSize).toList();
      } on OdooAuthException {
        rethrow;
      } on OdooConnectionException {
        // Offline - trả về cache nếu có
        if (cached.isNotEmpty) {
          logger.w(
              'PropertiesService: offline, returning cached data (page $page)');
          return cached;
        }
        rethrow;
      } catch (e) {
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
    if (kIsWeb) return _webCache.length;
    return await _isar.db.schedulePropertys.where().count();
  }

  /// Lấy properties từ Isar cache với phân trang.
  Future<List<ScheduleProperty>> _loadFromCachePaginated({
    required int offset,
    required int limit,
  }) async {
    return await _isar.db.schedulePropertys
        .where()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  /// Fetch từ Odoo và lưu vào Isar cache (paginated).
  Future<List<ScheduleProperty>> _fetchFromOdooAndCache() async {
    final allRaw = <dynamic>[];
    int offset = 0;
    const limit = 200;

    while (true) {
      final page = await OdooApiClient.instance.callKw(
        model: 'fsm.location',
        method: 'search_read',
        args: [<dynamic>[]],
        kwargs: {
          'fields': _locationFields,
          'limit': limit,
          'offset': offset,
          'order': 'id'
        },
      ) as List<dynamic>;

      allRaw.addAll(page);
      if (page.length < limit) break;
      offset += limit;
    }

    logger.i('PropertiesService: fetched ${allRaw.length} locations from Odoo');

    final fresh = allRaw.map((e) {
      final m = e as Map<String, dynamic>;
      return ScheduleProperty.fromOdooJson(m);
    }).toList();

    if (!kIsWeb) {
      await _isar.db.writeTxn(() async {
        await _isar.db.schedulePropertys.clear();
        await _isar.db.schedulePropertys.putAll(fresh);
      });
    }

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
      final properties = await _isar.db.schedulePropertys.where().findAll();
      return properties;
    } catch (e) {
      logger.w('PropertiesService: failed to load from cache', error: e);
      return [];
    }
  }
}
