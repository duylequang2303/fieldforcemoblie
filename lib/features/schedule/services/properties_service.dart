import 'package:isar_community/isar.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/schedule_property.dart';

/// Đọc danh sách địa điểm (fsm.location) từ Odoo cho tab Properties.
/// Có cache Isar offline-first.
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

  /// Lấy danh sách properties, ưu tiên cache Isar (offline-first).
  /// Nếu online, fetch Odoo và update cache.
  Future<List<ScheduleProperty>> fetchProperties() async {
    // 1. Thử lấy từ cache Isar trước (offline-first)
    final cached = await _loadFromCache();
    if (cached.isNotEmpty) {
      logger.i('PropertiesService: loaded ${cached.length} properties from Isar cache');
    }

    // 2. Nếu online, fetch từ Odoo và update cache
    if (_odoo.isAuthenticated) {
      try {
        final fresh = await _fetchFromOdooAndCache();
        logger.i('PropertiesService: loaded ${fresh.length} properties from Odoo (online)');
        return fresh;
      } on OdooAuthException {
        rethrow;
      } on OdooConnectionException {
        // Offline - trả về cache nếu có
        if (cached.isNotEmpty) {
          logger.w('PropertiesService: offline, returning cached data');
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
      // Không authenticated - trả về cache nếu có
      if (cached.isNotEmpty) {
        logger.w('PropertiesService: not authenticated, returning cached data');
        return cached;
      }
      throw OdooAuthException('Not authenticated and no cached data');
    }
  }

  /// Lấy properties từ Isar cache.
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

  /// Fetch từ Odoo và lưu vào Isar cache.
  Future<List<ScheduleProperty>> _fetchFromOdooAndCache() async {
    final raw = await _odoo.callKw(
      model: 'fsm.location',
      method: 'search_read',
      args: [<dynamic>[]],
      kwargs: {'fields': _locationFields, 'limit': 100, 'order': 'id'},
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

  /// Clear cache (dùng khi logout hoặc cần reset).
  Future<void> clearCache() async {
    await _isar.db.writeTxn(() async {
      await _isar.db.schedulePropertys.clear();
    });
  }
}