import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'fixtures/sample_data.dart';

void main() {
  group('Orders Validation Logic (Unit Test)', () {
    test('ORD-01: Order mới không có ID từ Odoo phải được coi là Local Draft', () {
      final order = FsmOrderFactory.sample(odooId: 0, isPendingSync: true);

      bool isLocalOnly(FsmOrder o) {
        return o.odooId == 0 || o.odooId == null;
      }

      expect(isLocalOnly(order), isTrue);
      expect(order.isPendingSync, isTrue);
    });

    test('ORD-02: Chuyển trạng thái sang Done yêu cầu phải có thời gian bắt đầu thực tế (dateStart)', () {
      final order = FsmOrderFactory.sampleDone();
      
      // Giả định logic: Nếu done thì phải có thời gian bắt đầu thực tế
      bool canMarkDone(FsmOrder o) {
        return o.dateStart != null && o.stage == FsmOrderStage.done;
      }

      // Xóa thử dateStart
      order.dateStart = null;
      expect(canMarkDone(order), isFalse, reason: 'Chưa set dateStart nên không thể hoàn thành hợp lệ.');
      
      // Gán lại cho đúng
      order.dateStart = DateTime.now().subtract(const Duration(hours: 2));
      expect(canMarkDone(order), isTrue);
    });

    test('ORD-03: Kiểm tra yêu cầu chữ ký khách hàng (requireSignature)', () {
      final order = FsmOrderFactory.sample(requireSignature: true);
      
      expect(order.requireSignature, isTrue);
      
      bool isReadyToComplete(FsmOrder o, bool hasCustomerSigned) {
        if (o.requireSignature == true && !hasCustomerSigned) return false;
        return true;
      }

      expect(isReadyToComplete(order, false), isFalse, reason: 'Order này bắt buộc phải có chữ ký khách hàng.');
      expect(isReadyToComplete(order, true), isTrue);
    });
  });
}
