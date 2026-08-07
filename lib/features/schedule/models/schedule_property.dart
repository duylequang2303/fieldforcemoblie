import 'package:isar_community/isar.dart';

part 'schedule_property.g.dart';

/// Model Isar lưu offline cho fsm.location (properties) từ Odoo.
@collection
class ScheduleProperty {
  Id id = Isar.autoIncrement;

  /// ID record trên Odoo (khác với [id] local của Isar).
  @Index(unique: true)
  late int odooId;

  late String address;
  late String suburb;
  late String postcode;
  late String ownerName;
  String? imageUrl;
  double? lat;
  double? lng;
  String? phone;
  String? email;

  /// Thời điểm lần cuối sync từ Odoo.
  late DateTime lastSyncAt;

  /// Cờ đánh dấu bản ghi đang chờ sync (không dùng cho properties read-only, nhưng để đồng bộ).
  late bool isPendingSync;

  ScheduleProperty();

  /// Tạo từ JSON trả về từ Odoo API (tương thích với PropertiesService.fetchProperties).
  factory ScheduleProperty.fromOdooJson(Map<String, dynamic> m) {
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

    final city = str('city');
    final owner = m['owner_id'];
    final ownerName =
        (owner is List && owner.length > 1) ? owner[1] as String : '';

    final phone = str('phone');
    final email = str('email');

    return ScheduleProperty()
      ..odooId = m['id'] as int
      ..address = address.isEmpty ? 'Unnamed location' : address
      ..suburb = city
      ..postcode = str('zip')
      ..ownerName = ownerName
      ..lat = (m['partner_latitude'] as num?)?.toDouble()
      ..lng = (m['partner_longitude'] as num?)?.toDouble()
      ..phone = phone.isEmpty ? null : phone
      ..email = email.isEmpty ? null : email
      ..lastSyncAt = DateTime.now()
      ..isPendingSync = false;
  }

  /// Helper để tạo bản ghi mới (local only).
  factory ScheduleProperty.create({
    required int odooId,
    required String address,
    required String suburb,
    required String postcode,
    required String ownerName,
    String? imageUrl,
    double? lat,
    double? lng,
    String? phone,
    String? email,
  }) {
    return ScheduleProperty()
      ..odooId = odooId
      ..address = address
      ..suburb = suburb
      ..postcode = postcode
      ..ownerName = ownerName
      ..imageUrl = imageUrl
      ..lat = lat
      ..lng = lng
      ..phone = phone
      ..email = email
      ..lastSyncAt = DateTime.now()
      ..isPendingSync = false;
  }
}