import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_recurring.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_frequency_set.dart';

void main() {
  group('FsmOrder', () {
    test('fromJson should handle normal and false/empty values safely', () {
      final jsonPayload = {
        'id': 123,
        'name': 'WO/2024/001',
        'description': false, // Odoo returns false for empty text
        'stage_id': [4, 'In Progress'],
        'location_id': false,
        'location_address': false,
        'phone': false,
        'fsm_recurring_id': false,
        'is_recurring_instance': false,
        'is_skipped': false,
        'is_recurring_processed': false,
        'scheduled_date_start': false,
        'scheduled_date_end': false,
        'date_start': false,
        'date_end': false,
        'person_id': false,
        'priority': false,
        'route_sequence': false,
        'route_id': false,
        'route_state': false,
        'require_signature': false,
        'warehouse_id': false,
      };

      final order = FsmOrder.fromJson(jsonPayload);

      expect(order.odooId, 123);
      expect(order.name, 'WO/2024/001');
      expect(order.description, isNull);
      expect(order.stageId, 4);
      expect(order.stageName, 'In Progress');
      expect(order.stage, FsmOrderStage.inProgress);
      expect(order.locationName, '');
      expect(order.locationAddress, '');
      expect(order.partnerPhone, isNull);
      expect(order.recurringId, isNull);
      expect(order.isRecurringInstance, isFalse);
      expect(order.isSkipped, isFalse);
      expect(order.isRecurringProcessed, isFalse);
      expect(order.scheduledDateStart, isNull);
      expect(order.scheduledDateEnd, isNull);
      expect(order.dateStart, isNull);
      expect(order.dateEnd, isNull);
      expect(order.personId, isNull);
      expect(order.personName, '');
      expect(order.priority, isNull);
      expect(order.routeSequence, isNull);
      expect(order.routeId, isNull);
      expect(order.routeState, isNull);
      expect(order.requireSignature, isFalse);
      expect(order.warehouseId, isNull);
    });

    test(
        'fromJson should handle raw inputs and type variations safely (no crash)',
        () {
      final jsonPayload = {
        'id': 123.0, // double ID parsed safe
        'name': 'WO/2024/002',
        'description': 'Mô tả test',
        'stage_id': 99, // stage_id as direct flat integer, not list tuple
        'location_id': 'Location name directly', // location_id as string
        'location_address': 'Address string',
        'phone': 8498888888, // integer phone
        'fsm_recurring_id': [45], // relational list with only ID
        'is_recurring_instance': true,
        'is_skipped': true,
        'is_recurring_processed': true,
        'scheduled_date_start': '2026-08-05 08:00:00',
        'scheduled_date_end': '2026-08-05 10:00:00',
        'date_start': '2026-08-05 08:15:00',
        'date_end': '2026-08-05 09:45:00',
        'person_id': [12, 'Worker 1'],
        'priority': 1, // priority returned as integer instead of string '1'
        'route_sequence': '5', // route_sequence returned as string
        'route_id': 100, // route_id as flat integer
        'route_state': 'planned',
        'require_signature': true,
        'warehouse_id': [500, 'Warehouse 1'],
      };

      final locationCoordinates = {
        12: {
          'partner_latitude': '10.7769', // String representation of float
          'partner_longitude': 106.7009, // Double representation of float
          'partner_id': [50, 'Partner 50'],
          'inventory_location_id': 200, // flat int
        }
      };

      final order = FsmOrder.fromJson(jsonPayload,
          locationCoordinates: locationCoordinates);

      expect(order.odooId, 123);
      expect(order.description, 'Mô tả test');
      expect(order.stageId, 99);
      expect(order.stageName, '99'); // Fallback to v.toString()
      expect(order.locationName, 'Location name directly');
      expect(order.locationAddress, 'Address string');
      expect(order.partnerPhone, '8498888888'); // toString() fallback
      expect(order.recurringId, 45);
      expect(order.isRecurringInstance, isTrue);
      expect(order.isSkipped, isTrue);
      expect(order.isRecurringProcessed, isTrue);
      expect(order.scheduledDateStart, DateTime(2026, 8, 5, 8, 0, 0));
      expect(order.scheduledDateEnd, DateTime(2026, 8, 5, 10, 0, 0));
      expect(order.dateStart, DateTime(2026, 8, 5, 8, 15, 0));
      expect(order.dateEnd, DateTime(2026, 8, 5, 9, 45, 0));
      expect(order.personId, 12);
      expect(order.personName, 'Worker 1');
      expect(order.priority, '1'); // toString() fallback
      expect(order.routeSequence, 5); // String parsed to int
      expect(order.routeId, 100);
      expect(order.routeState, 'planned');
      expect(order.requireSignature, isTrue);
      expect(order.warehouseId, 500);

      final jsonPayloadWithListLocation = Map<String, dynamic>.from(jsonPayload)
        ..['location_id'] = [12, 'Location A'];
      final orderWithCoords = FsmOrder.fromJson(jsonPayloadWithListLocation,
          locationCoordinates: locationCoordinates);
      expect(orderWithCoords.locationLat, 10.7769);
      expect(orderWithCoords.locationLng, 106.7009);
      expect(orderWithCoords.partnerId, 50);
      expect(orderWithCoords.partnerName, 'Partner 50');
      expect(orderWithCoords.inventoryLocationId, 200);
    });
  });

  group('FsmRecurring', () {
    test('fromJson should handle false and template/company fields', () {
      final jsonPayload = {
        'id': 10,
        'name': 'Weekly Recurring Test',
        'fsm_frequency_set_id': [2, 'Weekly'],
        'fsm_order_template_id':
            false, // unset Many2one -> should parse to null
        'company_id': false, // unset Many2one -> should parse to null
        'start_date': '2026-08-01',
        'end_date': false,
        'next_date': false,
        'generated_count': 5,
        'active': false,
        'recurrence_rule_type': false,
        'recurrence_completion_interval': false, // empty int -> 0
        'recurrence_completed_count': '3', // string int -> 3
        'recurrence_skipped_count': 1.0 // double int -> 1
      };

      final recurring = FsmRecurring.fromJson(jsonPayload);

      expect(recurring.odooId, 10);
      expect(recurring.name, 'Weekly Recurring Test');
      expect(recurring.frequencySetId, 2);
      expect(recurring.orderTemplateId, isNull);
      expect(recurring.companyId, isNull);
      expect(recurring.startDate, DateTime(2026, 8, 1));
      expect(recurring.endDate, isNull);
      expect(recurring.nextDate, isNull);
      expect(recurring.generatedCount, 5);
      expect(recurring.isActive, isFalse);
      expect(recurring.ruleType, 'date');
      expect(recurring.completionInterval, 0);
      expect(recurring.completedCount, 3);
      expect(recurring.skippedCount, 1);
    });
  });

  group('FsmFrequencySet', () {
    test('fromJson should handle false and null fields', () {
      final jsonPayload = {
        'id': 5,
        'name': 'Bi-Weekly',
        'interval': false, // unset -> fallback to 1
        'interval_type': false, // unset -> fallback to weekly
        'duration': false, // unset -> null
      };

      final freqSet = FsmFrequencySet.fromJson(jsonPayload);

      expect(freqSet.odooId, 5);
      expect(freqSet.name, 'Bi-Weekly');
      expect(freqSet.interval, 1);
      expect(freqSet.intervalType, FrequencyIntervalType.weekly);
      expect(freqSet.duration, isNull);
    });

    test('fromJson should parse Odoo interval types correctly', () {
      final dailyJson = {
        'id': 1,
        'name': 'Daily',
        'interval': 1,
        'interval_type': 'days',
      };
      final monthlyJson = {
        'id': 2,
        'name': 'Monthly',
        'interval': 1,
        'interval_type': 'months',
      };
      final yearlyJson = {
        'id': 3,
        'name': 'Yearly',
        'interval': 1,
        'interval_type': 'years',
      };

      final dailySet = FsmFrequencySet.fromJson(dailyJson);
      final monthlySet = FsmFrequencySet.fromJson(monthlyJson);
      final yearlySet = FsmFrequencySet.fromJson(yearlyJson);

      expect(dailySet.intervalType, FrequencyIntervalType.daily);
      expect(monthlySet.intervalType, FrequencyIntervalType.monthly);
      expect(yearlySet.intervalType, FrequencyIntervalType.yearly);
    });
  });
}
