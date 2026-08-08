import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/schedule/models/schedule_property.dart';

void main() {
  group('ScheduleProperty.fromOdooJson', () {
    test('should map a fully populated fsm.location payload', () {
      final property = ScheduleProperty.fromOdooJson({
        'id': 18,
        'name': 'Toà nhà Sunrise',
        'street': '12 Nguyễn Huệ',
        'city': 'Quận 1',
        'zip': '700000',
        'owner_id': [11, 'Kỹ thuật viên 1'],
        'partner_latitude': 10.7769,
        'partner_longitude': 106.7009,
        'phone': '0901234567',
        'email': 'owner@example.com',
      });

      expect(property.odooId, 18);
      expect(property.address, 'Toà nhà Sunrise');
      expect(property.suburb, 'Quận 1');
      expect(property.postcode, '700000');
      expect(property.ownerName, 'Kỹ thuật viên 1');
      expect(property.lat, 10.7769);
      expect(property.lng, 106.7009);
      expect(property.phone, '0901234567');
      expect(property.email, 'owner@example.com');
      expect(property.isPendingSync, isFalse);
      expect(property.lastSyncAt, isA<DateTime>());
    });

    test('should build the address from street parts when name is missing', () {
      final property = ScheduleProperty.fromOdooJson({
        'id': 1,
        'name': '',
        'street': '12 Nguyễn Huệ',
        'street2': 'Lầu 3',
      });

      expect(property.address, '12 Nguyễn Huệ, Lầu 3');
    });

    test('should skip empty street2 when joining the address', () {
      final property = ScheduleProperty.fromOdooJson({
        'id': 1,
        'street': '12 Nguyễn Huệ',
        'street2': '',
      });

      expect(property.address, '12 Nguyễn Huệ');
    });

    test('should fall back to a placeholder address when nothing is provided', () {
      final property = ScheduleProperty.fromOdooJson({'id': 2});

      expect(property.address, 'Unnamed location');
      expect(property.suburb, '');
      expect(property.postcode, '');
      expect(property.ownerName, '');
    });

    test('should treat Odoo false values as missing strings', () {
      final property = ScheduleProperty.fromOdooJson({
        'id': 3,
        'name': false,
        'street': false,
        'city': false,
        'zip': false,
        'owner_id': false,
        'phone': false,
        'email': false,
      });

      expect(property.address, 'Unnamed location');
      expect(property.suburb, '');
      expect(property.postcode, '');
      expect(property.ownerName, '');
      expect(property.phone, isNull);
      expect(property.email, isNull);
    });

    test('should trim surrounding whitespace of string fields', () {
      final property = ScheduleProperty.fromOdooJson({
        'id': 4,
        'name': '  Toà nhà Sunrise  ',
        'city': '  Quận 1 ',
        'zip': ' 700000 ',
      });

      expect(property.address, 'Toà nhà Sunrise');
      expect(property.suburb, 'Quận 1');
      expect(property.postcode, '700000');
    });

    test('should keep coordinates null and coerce integers to double', () {
      final missing = ScheduleProperty.fromOdooJson({'id': 5});
      expect(missing.lat, isNull);
      expect(missing.lng, isNull);

      final integral = ScheduleProperty.fromOdooJson({
        'id': 6,
        'partner_latitude': 10,
        'partner_longitude': 106,
      });
      expect(integral.lat, 10.0);
      expect(integral.lng, 106.0);
    });

    test('should ignore a malformed owner_id tuple', () {
      final property = ScheduleProperty.fromOdooJson({
        'id': 7,
        'owner_id': [11],
      });

      expect(property.ownerName, '');
    });
  });

  group('ScheduleProperty.create', () {
    test('should build a local record with the given values', () {
      final property = ScheduleProperty.create(
        odooId: 20,
        address: '5 Lê Lợi',
        suburb: 'Quận 3',
        postcode: '700000',
        ownerName: 'Trần Thị B',
        imageUrl: 'https://cdn.example.com/p.png',
        lat: 10.1,
        lng: 106.2,
        phone: '0909999999',
        email: 'b@example.com',
      );

      expect(property.odooId, 20);
      expect(property.address, '5 Lê Lợi');
      expect(property.suburb, 'Quận 3');
      expect(property.postcode, '700000');
      expect(property.ownerName, 'Trần Thị B');
      expect(property.imageUrl, 'https://cdn.example.com/p.png');
      expect(property.lat, 10.1);
      expect(property.lng, 106.2);
      expect(property.phone, '0909999999');
      expect(property.email, 'b@example.com');
      expect(property.isPendingSync, isFalse);
    });

    test('should leave optional fields null when omitted', () {
      final property = ScheduleProperty.create(
        odooId: 21,
        address: '5 Lê Lợi',
        suburb: 'Quận 3',
        postcode: '700000',
        ownerName: 'Trần Thị B',
      );

      expect(property.imageUrl, isNull);
      expect(property.lat, isNull);
      expect(property.lng, isNull);
      expect(property.phone, isNull);
      expect(property.email, isNull);
    });
  });
}
