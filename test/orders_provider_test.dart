import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/core/api/api_exception.dart';
import 'package:fieldforce_mobile/core/connectivity/connectivity_service.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';
import 'package:fieldforce_mobile/features/orders/providers/orders_provider.dart';
import 'package:fieldforce_mobile/features/orders/services/orders_service.dart';

// -- Các lớp Mock thủ công (Manual Mocks) --

class MockConnectivityService implements ConnectivityService {
  @override
  Stream<bool> get onStatusChanged => const Stream.empty();

  @override
  Future<bool> checkConnectivity() async => true;
  
  @override
  Future<bool> get isOnline async => true;

  // Trả về stream rỗng vì test không phụ thuộc gói connectivity_plus thật
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => const Stream.empty();
}

class MockOrdersService implements OrdersService {
  bool shouldThrowError = false;
  bool isCompleteOrderCalled = false;

  @override
  Future<List<FsmOrder>> fetchMyOrders() async {
    return [];
  }

  @override
  Future<List<FsmOrder>> loadCachedOrders() async {
    return [];
  }

  @override
  Future<void> completeOrder(int odooId) async {
    isCompleteOrderCalled = true;
    if (shouldThrowError) {
      throw OdooBusinessException('Thiếu vật tư tiêu hao, không thể chốt đơn.');
    }
  }

  // Khai báo các method khác của OrdersService nhưng không cần implement cho test này
  @override
  Future<void> checkIn(int odooId) async {}
  @override
  Future<int?> getStageIdByKeywords(List<String> keywords) async => 1;
  @override
  Future<void> fetchStagesIfNeeded() async {}
  @override
  Future<void> updateStage(int odooId, int newStageId) async {}
  @override
  Future<void> syncPending() async {}
}

void main() {
  group('OrdersProvider - updateOrderToDone', () {
    late MockOrdersService mockService;
    late MockConnectivityService mockConnectivity;
    late OrdersProvider provider;

    setUp(() {
      mockService = MockOrdersService();
      mockConnectivity = MockConnectivityService();
      provider = OrdersProvider(
        service: mockService as OrdersService,
        connectivity: mockConnectivity as ConnectivityService,
      );
    });

    test('Gọi action_complete thành công và tải lại danh sách', () async {
      // Act
      final future = provider.updateOrderToDone(123);
      
      // Kiểm tra trạng thái isLoading đang bật
      expect(provider.isLoading, true);
      
      await future;

      // Assert
      expect(mockService.isCompleteOrderCalled, true);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
    });

    test('Bắt lỗi nghiệp vụ (Validation) từ Odoo và hiển thị lên UI', () async {
      // Arrange
      mockService.shouldThrowError = true;

      // Act
      await provider.updateOrderToDone(456);

      // Assert
      expect(mockService.isCompleteOrderCalled, true);
      expect(provider.isLoading, false);
      // Thông báo lỗi phải hiển thị nguyên văn lỗi từ Odoo, chứ không phải lỗi chung chung
      expect(provider.errorMessage, 'Thiếu vật tư tiêu hao, không thể chốt đơn.');
    });
  });
}
