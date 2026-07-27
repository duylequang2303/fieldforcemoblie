import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:fieldforce_mobile/main.dart' as app;
import 'test_credentials.dart';

void main() {
  patrolTest(
    'Mở WorkOrderPage → Ký tên → Submit report',
    nativeAutomation: true,
    ($) async {
      await app.main();
      await $.pumpAndSettle();

      if (await $('Đăng nhập').exists) {
        await $(RegExp('Server URL.*')).enterText(TestCredentials.serverUrl);
        await $('Tên Database').enterText(TestCredentials.database);
        await $('Tên đăng nhập').enterText(TestCredentials.workerUsername);
        await $('Mật khẩu').enterText(TestCredentials.workerPassword);
        await $('Đăng nhập').tap();
        await $.pumpAndSettle();
      }

      final signatureEntry = $('Nghiệm thu & Chữ ký');
      if (await signatureEntry.exists) {
        await signatureEntry.tap();
        await $.pumpAndSettle();
      } else {
        await $(RegExp('WO/.*')).first.tap();
        await $.pumpAndSettle();
        await $('Nghiệm thu & Chữ ký').tap();
        await $.pumpAndSettle();
      }

      await $(const Key('work_done_input')).enterText('Sửa chữa hệ thống điện');
      await $('Tiếp theo').tap();
      await $.pumpAndSettle();

      final signaturePad = $(const Key('signature_pad'));
      expect(signaturePad, findsOneWidget);
      final offset = await $.getCenter(signaturePad);
      await $.tester.dragFrom(offset, const Offset(100, 50));
      await $.pumpAndSettle();

      await $(const Key('customer_name_input')).enterText('Nguyễn Văn A');
      await $('Xác nhận chữ ký').tap();
      await $.pumpAndSettle();

      await $('Tiếp theo').tap();
      await $.pumpAndSettle();
      await $('Gửi nghiệm thu').tap();
      await $.pumpAndSettle();

      expect($('Nghiệm thu đã được gửi thành công!'), findsOneWidget);
      expect($('Đang gửi...'), findsNothing);
    },
  );
}
