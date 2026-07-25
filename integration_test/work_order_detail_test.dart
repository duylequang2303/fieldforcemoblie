import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:fieldforce_mobile/main.dart' as app;

void main() {
  patrolTest(
    'Work Order Detail Flow: Check-in, ký tên và Hoàn thành',
    nativeAutomation: true,
    ($) async {
      await app.main();
      await $.pumpAndSettle();

      // Đăng nhập nếu cần
      if (await $('Đăng nhập').exists) {
        await $(RegExp('Server URL.*')).enterText('https://demo002.crmhub.vn');
        await $('Tên Database').enterText('demo002.crmhub.vn');
        await $('Tên đăng nhập').enterText('admin');
        await $('Mật khẩu').enterText('<),9853\$6Ect');
        await $('Đăng nhập').tap();
        await $.pumpAndSettle();
      }

      // Mở màn hình chi tiết (chọn 1 đơn từ danh sách)
      await $(RegExp('WO/.*')).first.tap();
      await $.pumpAndSettle();

      // 1. Tap Key('btn_check_in') - Nếu nút tồn tại (đơn chưa check-in)
      final checkInBtn = $(const Key('btn_check_in'));
      if (await checkInBtn.exists) {
        await checkInBtn.tap();
        await $.pumpAndSettle();
      }

      // Tiếp tục bấm "Bắt đầu thực hiện" nếu có (chuyển trạng thái)
      final startBtn = $('Bắt đầu thực hiện');
      if (await startBtn.exists) {
        await startBtn.tap();
        await $.pumpAndSettle();
      }

      // 2. Vào màn hình Nghiệm thu & Chữ ký
      final signatureAction = $('Nghiệm thu & Chữ ký');
      if (await signatureAction.exists) {
        await signatureAction.tap();
        await $.pumpAndSettle();

        // Step 1: Điền "Công việc đã thực hiện" (bắt buộc để isComplete = true)
        await $('Công việc đã thực hiện *').enterText('Đã kiểm tra và bảo trì xong.');
        await $('Tiếp theo').tap();
        await $.pumpAndSettle();

        // Step 2: Tap Key('signature_pad') và dragFrom để ký tên
        final signaturePad = $(const Key('signature_pad'));
        expect(signaturePad, findsOneWidget);
        
        final offset = await $.getCenter(signaturePad);
        await $.tester.dragFrom(offset, const Offset(100, 50)); 
        await $.pumpAndSettle();

        await $('Tên khách hàng ký').enterText('Nguyễn Văn Test');
        await $('Xác nhận chữ ký').tap();
        await $.pumpAndSettle();

        // Sang Step 3: Xác nhận & Gửi
        await $('Tiếp theo').tap();
        await $.pumpAndSettle();

        await $('Gửi nghiệm thu').tap();
        await $.pumpAndSettle();
      }

      // 3. Tap Key('btn_mark_complete') ở trang Detail
      final completeBtn = $(const Key('btn_mark_complete'));
      if (await completeBtn.exists) {
        await completeBtn.tap();
        await $.pumpAndSettle();
        
        // Xác nhận trên dialog
        await $('Xác nhận').tap();
        await $.pumpAndSettle();
      }

      // 4. Assert trạng thái đơn hàng được cập nhật
      expect($('Đã hoàn thành'), findsWidgets);
    },
  );
}
