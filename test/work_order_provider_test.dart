import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/work_order/models/work_report.dart';
import 'package:fieldforce_mobile/features/work_order/providers/work_order_provider.dart';
import 'package:fieldforce_mobile/features/work_order/services/work_order_service.dart';

class MockWorkOrderService implements WorkOrderService {
  bool isRequireSignature = false;
  WorkReport? initialReport;

  @override
  Future<WorkReport> getOrCreateReport(int orderOdooId) async {
    return initialReport ?? WorkReport.create(orderOdooId: orderOdooId);
  }

  @override
  Future<FsmOrder?> getOrder(int orderOdooId) async {
    return FsmOrder()
      ..odooId = orderOdooId
      ..requireSignature = isRequireSignature;
  }

  @override
  Future<void> saveReport(WorkReport report) async {}

  @override
  Future<void> submitReport(WorkReport report) async {}

  @override
  Future<void> uploadPhotos(WorkReport report) async {}
}

void main() {
  group('WorkOrderProvider - isComplete Validator', () {
    late MockWorkOrderService mockService;
    late WorkOrderProvider provider;

    setUp(() {
      mockService = MockWorkOrderService();
      provider = WorkOrderProvider(service: mockService as WorkOrderService);
    });

    test('Báo cáo chưa có gì -> KHÔNG cho phép submit', () async {
      await provider.loadReport(1);
      
      expect(provider.isComplete, isFalse);
    });

    test('Đơn KHÔNG bắt buộc chữ ký + ĐÃ ĐIỀN workDone -> CHO PHÉP submit', () async {
      mockService.isRequireSignature = false;
      await provider.loadReport(1);
      provider.updateWorkDone('Đã sửa xong điều hoà');

      expect(provider.isComplete, isTrue);
    });

    test('Đơn BẮT BUỘC chữ ký + ĐÃ ĐIỀN workDone nhưng CHƯA CÓ chữ ký -> KHÔNG cho phép submit', () async {
      mockService.isRequireSignature = true;
      await provider.loadReport(1);
      provider.updateWorkDone('Đã sửa xong điều hoà');

      expect(provider.isComplete, isFalse);
    });

    test('Đơn BẮT BUỘC chữ ký + ĐÃ ĐIỀN workDone + ĐÃ KÝ -> CHO PHÉP submit', () async {
      mockService.isRequireSignature = true;
      await provider.loadReport(1);
      provider.updateWorkDone('Đã sửa xong điều hoà');
      provider.setSignature('/path/to/sig.png', 'Nguyen Van A');

      expect(provider.isComplete, isTrue);
    });
  });
}
