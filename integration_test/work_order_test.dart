import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:fieldforce_mobile/main.dart' as app;
import 'test_credentials.dart';

void main() {
  patrolTest(
    'WO-07 & WO-09: Khách hàng ký số và Hoàn thành nghiệm thu',
    nativeAutomation: true,
    ($) async {
      await app.main();
      await $.pumpAndSettle();

      // 1. Luồng đăng nhập nhanh
      if (await $('Đăng nhập').exists) {
        await $(RegExp('Server URL.*')).enterText(TestCredentials.serverUrl);
        await $('Tên Database').enterText(TestCredentials.database);
        await $('Tên đăng nhập').enterText(TestCredentials.workerUsername);
        await $('Mật khẩu').enterText(TestCredentials.workerPassword);
        await $('Đăng nhập').tap();
        await $.pumpAndSettle();
      }

      // 2. Mở một đơn hàng đang thực hiện
      await $(RegExp('WO/.*')).first.tap();
      await $.pumpAndSettle();

      // 3. Chọn tab hoặc nút "Báo cáo công việc / Ký nhận"
      if (await $('Báo cáo').exists) {
        await $('Báo cáo').tap();
        await $.pumpAndSettle();
      }

      // 4. Ký số khách hàng (Customer Signature)
      final signaturePad = $(Key('signature_pad')); // Giả định widget chữ ký có Key
      if (await signaturePad.exists) {
        // Thực hiện vuốt (swipe) để vẽ chữ ký
        // Patrol cung cấp thao tác scroll/drag cơ bản
        final offset = await $.getCenter(signaturePad);
        await $.tester.dragFrom(offset, const Offset(50, 50)); 
        await $.pumpAndSettle();

        // Nhập tên khách hàng ký
        await $('Tên khách hàng').enterText('Nguyễn Văn A');
        
        // Bấm Xác nhận chữ ký
        await $('Xác nhận chữ ký').tap();
        await $.pumpAndSettle();
      }

      // 5. Hoàn thành công việc
      final completeBtn = $('Hoàn thành đơn');
      if (await completeBtn.exists) {
        await completeBtn.tap();
        await $.pumpAndSettle();

        // Xác nhận trạng thái đơn hàng đã thành "Hoàn thành" (Done)
        expect($('Đã hoàn thành'), findsOneWidget);
      }
    },
  );
}
