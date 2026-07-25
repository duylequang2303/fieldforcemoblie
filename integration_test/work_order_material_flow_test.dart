import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:fieldforce_mobile/screens/work_order_detail_screen.dart';
import 'package:fieldforce_mobile/features/orders/models/fsm_order.dart';

void main() {
  patrolTest(
    'Work Order Material Flow: Thêm vật tư vào đơn hàng',
    nativeAutomation: true,
    ($) async {
      final mockOrder = FsmOrder(
        id: 1,
        odooId: 101,
        name: 'WO/2024/001',
        scheduledDateStart: DateTime.now(),
        scheduledDateEnd: DateTime.now().add(const Duration(hours: 2)),
        locationAddress: '123 Test Street',
        partnerName: 'Test Customer',
      );

      await $.pumpWidgetAndSettle(
        MaterialApp(
          home: WorkOrderDetailScreen(order: mockOrder),
        ),
      );

      // 1. Expand section nếu cần (Mặc định có thể đã mở hoặc chưa, ta scroll đến)
      final addBtn = $(const Key('btn_add_material'));
      await $.scrollUntilVisible(finder: addBtn);
      await addBtn.tap();
      await $.pumpAndSettle();

      // 2. Form mở ra, nhập dữ liệu (MaterialEntryForm tự động dùng _mockProducts nội bộ)
      final searchInput = $(const Key('input_material_search'));
      await searchInput.enterText('Copper');
      await $.pumpAndSettle();

      // Chọn Copper Pipe (1m) từ autocomplete
      await $('Copper Pipe (1m)').tap();
      await $.pumpAndSettle();

      // Nhập số lượng
      final qtyInput = $(const Key('input_quantity'));
      await qtyInput.enterText('3');
      await $.pumpAndSettle();

      // Lưu form
      final saveBtn = $(const Key('btn_save_material'));
      await saveBtn.tap();
      await $.pumpAndSettle();

      // 3. Form đóng lại, Assert rằng vật tư vừa chọn xuất hiện trên màn hình
      expect($('Copper Pipe (1m)'), findsWidgets);
      expect($('x3'), findsWidgets);
    },
  );
}
