import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/orders/services/recurring_service.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';

/// Test logic thuần trong RecurringService:
/// parse (JSON chuẩn + Odoo trả false/null), filterDueOrders (hôm nay / 7 ngày /
/// quá hạn / ngoài 7 ngày), buildNotificationContent (0 đơn / nhiều đơn).
void main() {
  group('RecurringService', () {
    group('parseRecurringOrders', () {
      test('should parse valid recurring JSON and fill fields', () {
        const json = [
          {
            'id': 101,
            'name': 'WO/2024/001',
            'fsm_recurring_id': [5, 'Weekly Service'],
            'partner_id': [10, 'Nguyễn Văn A'],
            'service_type': 'ac',
            'scheduled_date_start': '2026-04-08 08:00:00',
            'stage_id': [3, 'In Progress'],
          },
        ];

        final result = RecurringService.parseRecurringOrders(json);

        expect(result, hasLength(1));
        final order = result.first;
        expect(order.odooId, 101);
        expect(order.name, 'WO/2024/001');
        expect(order.partnerName, 'Nguyễn Văn A');
        expect(order.serviceName, 'ac');
        expect(order.dueDate, DateTime.parse('2026-04-08 08:00:00'));
        expect(order.stageName, 'In Progress');
      });

      test('should skip orders without fsm_recurring_id', () {
        const json = [
          {'id': 1, 'name': 'WO/1', 'service_type': 'ac'},
          {
            'id': 2,
            'name': 'WO/2',
            'fsm_recurring_id': [9, 'Every 2 Weeks'],
            'partner_id': [1, 'B'],
          },
        ];

        final result = RecurringService.parseRecurringOrders(json);
        expect(result, hasLength(1));
        expect(result.first.odooId, 2);
      });

      test('should tolerate Odoo returning false/null for optional fields', () {
        const json = [
          {
            'id': 202,
            'name': 'WO/2024/002',
            'fsm_recurring_id': [7, 'Monthly'],
            'partner_id': false, // Odoo trả false cho many2one rỗng
            'service_type': false,
            'scheduled_date_start': false, // rỗng
            'stage_id': null,
          },
        ];

        final result = RecurringService.parseRecurringOrders(json);
        expect(result, hasLength(1));
        final order = result.first;
        expect(order.odooId, 202);
        expect(order.partnerName, isEmpty);
        // service_type=false và stage_id=null → serviceName fallback chuỗi rỗng
        expect(order.serviceName, isEmpty);
        expect(order.dueDate, isNull);
        expect(order.stageName, isEmpty);
      });

      test('should not crash when partner_id is plain string (not list)', () {
        const json = [
          {
            'id': 303,
            'name': 'WO/303',
            'fsm_recurring_id': [3, 'Weekly'],
            'partner_id': 'Khách lẻ',
            'scheduled_date_start': '2026-04-08 08:00:00',
          },
        ];

        final result = RecurringService.parseRecurringOrders(json);
        expect(result, hasLength(1));
        expect(result.first.partnerName, 'Khách lẻ');
      });

      test('should parse fsm_recurring_id in FsmOrder.fromJson supporting list, int, null, false', () {
        final order1 = FsmOrder.fromJson({
          'id': 1001,
          'name': 'Order 1',
          'fsm_recurring_id': [42, 'Every Month'],
          'stage_id': [1, 'Draft'],
        });
        expect(order1.fsmRecurringId, 42);

        final order2 = FsmOrder.fromJson({
          'id': 1002,
          'name': 'Order 2',
          'fsm_recurring_id': 99,
          'stage_id': [1, 'Draft'],
        });
        expect(order2.fsmRecurringId, 99);

        final order3 = FsmOrder.fromJson({
          'id': 1003,
          'name': 'Order 3',
          'fsm_recurring_id': false,
          'stage_id': [1, 'Draft'],
        });
        expect(order3.fsmRecurringId, isNull);

        final order4 = FsmOrder.fromJson({
          'id': 1004,
          'name': 'Order 4',
          'fsm_recurring_id': null,
          'stage_id': [1, 'Draft'],
        });
        expect(order4.fsmRecurringId, isNull);
      });
    });

    group('filterDueOrders', () {
      final now = DateTime(2026, 4, 8, 10, 30); // mốc thời gian cố định

      RecurringDueOrder order(DateTime when, {String stage = 'In Progress'}) {
        return RecurringDueOrder(
          odooId: 1,
          name: 'WO/1',
          partnerName: 'A',
          serviceName: 'ac',
          dueDate: when,
          stageName: stage,
        );
      }

      test('should include orders due today', () {
        final list = [
          order(DateTime(2026, 4, 8, 8, 0)), // hôm nay
        ];
        final result = RecurringService.filterDueOrders(list, now);
        expect(result, hasLength(1));
      });

      test('should include orders within next 7 days and exclude beyond', () {
        final list = [
          order(DateTime(2026, 4, 8)), // hôm nay
          order(DateTime(2026, 4, 10)), // trong 7 ngày
          order(DateTime(2026, 4, 15)), // hạn 7 ngày (ngày 15 = 8 + 7)
          order(DateTime(2026, 4, 16)), // ngoài 7 ngày → loại
        ];
        final result = RecurringService.filterDueOrders(list, now);
        expect(result, hasLength(3));
      });

      test('should exclude overdue orders (past due date)', () {
        final list = [
          order(DateTime(2026, 4, 1)), // quá hạn
          order(DateTime(2026, 4, 8)), // hôm nay
        ];
        final result = RecurringService.filterDueOrders(list, now);
        expect(result, hasLength(1));
        expect(result.first.dueDate, DateTime(2026, 4, 8));
      });

      test('should exclude orders without due date', () {
        final list = [
          RecurringDueOrder(odooId: 1, name: 'WO/1', partnerName: 'A'),
        ];
        final result = RecurringService.filterDueOrders(list, now);
        expect(result, isEmpty);
      });

      test('should exclude completed/cancelled orders', () {
        final list = [
          order(DateTime(2026, 4, 8), stage: 'Completed'),
          order(DateTime(2026, 4, 8), stage: 'Cancelled'),
          order(DateTime(2026, 4, 8), stage: 'In Progress'),
        ];
        final result = RecurringService.filterDueOrders(list, now);
        expect(result, hasLength(1));
      });

      test('should respect custom days window', () {
        final list = [
          order(DateTime(2026, 4, 8)), // hôm nay
          order(DateTime(2026, 4, 10)), // hạn 2 ngày → loại khi days=1
        ];
        final result = RecurringService.filterDueOrders(list, now, days: 1);
        expect(result, hasLength(1));
        expect(result.first.dueDate, DateTime(2026, 4, 8));
      });
    });

    group('buildNotificationContent', () {
      DateTime monday() => DateTime(2026, 4, 8, 9, 0);

      test('should return count 0 and "no orders" body when empty', () {
        final content = RecurringService.buildNotificationContent([]);
        expect(content.count, 0);
        expect(content.title, contains('định kỳ'));
        expect(content.body, contains('không có'));
      });

      test('should return single-order content for exactly 1 order', () {
        final list = [
          RecurringDueOrder(
            odooId: 1,
            name: 'WO/1',
            partnerName: 'Nguyễn Văn A',
            serviceName: 'ac',
            dueDate: monday(),
          ),
        ];
        final content = RecurringService.buildNotificationContent(list);
        expect(content.count, 1);
        expect(content.title, contains('1'));
        expect(content.body, contains('Nguyễn Văn A'));
        expect(content.body, contains('ac'));
      });

      test('should return aggregated content for multiple orders', () {
        final list = [
          RecurringDueOrder(odooId: 1, name: 'WO/1', partnerName: 'A'),
          RecurringDueOrder(odooId: 2, name: 'WO/2', partnerName: 'B'),
          RecurringDueOrder(odooId: 3, name: 'WO/3', partnerName: 'C'),
        ];
        final content = RecurringService.buildNotificationContent(list);
        expect(content.count, 3);
        expect(content.title, contains('3'));
        expect(content.body, contains('A'));
        expect(content.body, contains('B'));
      });

      test('should fall back to order name when partnerName is empty', () {
        final list = [
          RecurringDueOrder(odooId: 1, name: 'WO/99'),
        ];
        final content = RecurringService.buildNotificationContent(list);
        expect(content.title, contains('1'));
        expect(content.body, contains('WO/99'));
      });

      test('should sanitize HTML tags from serviceName and body', () {
        final list = [
          RecurringDueOrder(
            odooId: 1,
            name: 'WO/1',
            partnerName: 'Nguyễn Văn A',
            serviceName: '<p>Bảo trì <b>máy lạnh</b></p>&nbsp;ac',
            dueDate: monday(),
          ),
        ];
        final content = RecurringService.buildNotificationContent(list);
        expect(content.body, isNot(contains('<p>')));
        expect(content.body, isNot(contains('&nbsp;')));
        expect(content.body, contains('Bảo trì máy lạnh ac'));
      });
    });
  });
}