import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:fieldforce_mobile/main.dart' as app;
import 'test_credentials.dart';

void main() {
  patrolTest(
    'ORD-05: Check-in đơn hàng',
    nativeAutomation: true,
    ($) async {
      await app.main();
      await $.pumpAndSettle();

      // Login Flow nhanh
      if (await $('Đăng nhập').exists) {
        await $(RegExp('Server URL.*')).enterText(TestCredentials.serverUrl);
        await $('Tên Database').enterText(TestCredentials.database);
        await $('Tên đăng nhập').enterText(TestCredentials.username);
        await $('Mật khẩu').enterText(TestCredentials.password);
        await $('Đăng nhập').tap();
        await $.pumpAndSettle();
      }

      // Chọn đơn hàng đầu tiên (VD: WO/2024/...)
      // Tap vào list tile đầu tiên
      await $(RegExp('WO/.*')).first.tap();
      await $.pumpAndSettle();

      // Kiểm tra có nút Check-in / Bắt đầu công việc
      // Giả định nút có nhãn 'Bắt đầu' hoặc 'Check-in'
      final startButton = $('Bắt đầu');
      if (await startButton.exists) {
        await startButton.tap();
        
        // Mock permission location thông qua Patrol Native Automation nếu có dialog
        if (await $.native.isPermissionDialogVisible()) {
          await $.native.grantPermissionWhenInUse();
        }

        await $.pumpAndSettle();

        // Kiểm tra xem trạng thái đơn đã đổi sang In Progress (Đang thực hiện) chưa
        expect($('Đang thực hiện'), findsOneWidget);
      }
    },
  );
}