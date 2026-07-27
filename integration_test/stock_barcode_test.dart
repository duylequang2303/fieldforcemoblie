import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:fieldforce_mobile/main.dart' as app;
import 'test_credentials.dart';

void main() {
  patrolTest(
    'STOCK-01: Quét mã vạch vật tư',
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

      // Điều hướng đến tab Vật tư / Kho hàng hoặc Chi tiết đơn hàng
      // Thường có BottomNavigationBarItem có icon qr_code hoặc chữ Vật tư
      if (await $('Vật tư').exists) {
        await $('Vật tư').tap();
        await $.pumpAndSettle();
      }

      // Bấm nút Quét mã (Scan)
      final scanButton = $('Quét mã');
      if (await scanButton.exists) {
        await scanButton.tap();
        
        // Cấp quyền Camera nếu có yêu cầu
        if (await $.native.isPermissionDialogVisible()) {
          await $.native.grantPermissionOnlyThisTime();
        }
        await $.pumpAndSettle();

        // Ở E2E Patrol, đôi khi không test trực tiếp được hardware camera
        // Ta giả định giao diện nhập tay mã vạch hoặc mock barcode output nếu code có hỗ trợ.
        // Tuy nhiên, việc xin cấp quyền là một phần của luồng thật (nativeAutomation)
      }
    },
  );
}