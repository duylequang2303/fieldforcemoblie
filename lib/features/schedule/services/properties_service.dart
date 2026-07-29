import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/utils/logger.dart';
import '../models/schedule_property.dart';

/// Đọc danh sách địa điểm (fsm.location) từ Odoo cho tab Properties.
class PropertiesService {
  PropertiesService._();
  static final PropertiesService instance = PropertiesService._();
  final OdooSessionManager _odoo = OdooSessionManager.instance;

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

  Future<List<ScheduleProperty>> fetchProperties() async {
    try {
      final raw = await _odoo.callKw(
        model: 'fsm.location',
        method: 'search_read',
        args: [<dynamic>[]],
        kwargs: {'fields': _locationFields, 'limit': 100, 'order': 'id'},
      ) as List<dynamic>;

      logger.i('PropertiesService: loaded ${raw.length} locations');

      return raw.map((e) {
        final m = e as Map<String, dynamic>;
        // Odoo returns false (bool) instead of null for empty fields — handle both
        String str(String key) {
          final v = m[key];
          return (v is String) ? v.trim() : '';
        }

        final name = str('name');
        final street = str('street');
        final street2 = str('street2');
        final address = name.isNotEmpty
            ? name
            : [street, street2].where((s) => s.isNotEmpty).join(', ');

        final partner = m['partner_id'];
        final city = str('city');
        final owner = m['owner_id'];
        final ownerName =
            (owner is List && owner.length > 1) ? owner[1] as String : '';

        final phone = str('phone');
        final email = str('email');
        return ScheduleProperty(
          id: m['id'] as int,
          address: address.isEmpty ? 'Unnamed location' : address,
          suburb: city,
          postcode: str('zip'),
          ownerName: ownerName,
          lat: (m['partner_latitude'] as num?)?.toDouble(),
          lng: (m['partner_longitude'] as num?)?.toDouble(),
          phone: phone.isEmpty ? null : phone,
          email: email.isEmpty ? null : email,
        );
      }).toList();
    } on OdooAuthException {
      rethrow;
    } on OdooConnectionException {
      rethrow;
    } catch (e) {
      logger.e('PropertiesService.fetchProperties failed', error: e);
      rethrow;
    }
  }
}
