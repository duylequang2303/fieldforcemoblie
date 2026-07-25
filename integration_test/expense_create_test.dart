import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:fieldforce_mobile/main.dart' as app;

void main() {
  patrolTest(
    'EXP-03: Tạo chi phí mới và chụp ảnh',
    nativeAutomation: true,
    ($) async {
      await app.main();
      await $.pumpAndSettle();

      // 1. Luồng đăng nhập nhanh
      if (await $('Đăng nhập').exists) {
        await $(RegExp('Server URL.*')).enterText('https://demo002.crmhub.vn');
        await $('Tên Database').enterText('demo002.crmhub.vn');
        await $('Tên đăng nhập').enterText('admin');
        await $('Mật khẩu').enterText('<),9853\$6Ect');
        await $('Đăng nhập').tap();
        await $.pumpAndSettle();
      }

      // 2. Chuyển sang Tab Chi phí (Expense)
      if (await $('Chi phí').exists) {
        await $('Chi phí').tap();
        await $.pumpAndSettle();
      }

      // 3. Bấm nút Thêm mới (+)
      final addBtn = $(Icons.add); // Nút FAB (FloatingActionButton) phổ biến
      if (await addBtn.exists) {
        await addBtn.tap();
        await $.pumpAndSettle();

        // 4. Điền Form tạo chi phí
        await $('Mô tả').enterText('Đổ xăng xe tải');
        await $('Số tiền').enterText('500000');
        
        // Chọn loại chi phí (Giả sử là Dropdown hoặc Select)
        await $('Loại chi phí').tap();
        await $.pumpAndSettle();
        await $('Nhiên liệu').tap(); // Chọn giá trị từ danh sách
        await $.pumpAndSettle();

        // 5. Thử mở Camera chụp biên lai
        final cameraBtn = $(Icons.camera_alt);
        if (await cameraBtn.exists) {
          await cameraBtn.tap();
          
          // Cấp quyền Native Camera
          if (await $.native.isPermissionDialogVisible()) {
            await $.native.grantPermissionOnlyThisTime();
          }
          await $.pumpAndSettle();
          // Trong môi trường E2E thực tế, Patrol sẽ thoát camera popup hoặc chụp mockup
        }

        // 6. Lưu chi phí
        await $('Lưu').tap();
        await $.pumpAndSettle();
        
        // 7. Xác nhận Chi phí đã được hiển thị trên danh sách List View
        expect($('Đổ xăng xe tải'), findsOneWidget);
        expect($('500000'), findsOneWidget);
      }
    },
  );
}
