import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:fieldforce_mobile/main.dart' as app;

void main() {
  patrolTest(
    'TIME-01: Chấm công (Check-in/Check-out)',
    nativeAutomation: true,
    ($) async {
      await app.main();
      await $.pumpAndSettle();

      // 1. Luồng đăng nhập nhanh (Nếu ứng dụng yêu cầu đăng nhập)
      if (await $('Đăng nhập').exists) {
        await $(RegExp('Server URL.*')).enterText('https://demo002.crmhub.vn');
        await $('Tên Database').enterText('demo002.crmhub.vn');
        await $('Tên đăng nhập').enterText('admin');
        await $('Mật khẩu').enterText('<),9853\$6Ect');
        await $('Đăng nhập').tap();
        await $.pumpAndSettle();
      }

      // 2. Điều hướng đến tab/màn hình "Chấm công" (Timesheet)
      // Giả định Tab bar hoặc Menu có chữ "Chấm công"
      if (await $('Chấm công').exists) {
        await $('Chấm công').tap();
        await $.pumpAndSettle();
      }

      // 3. Thực hiện Check-in (Vào ca)
      // Tìm nút "Vào ca" hoặc "Check-in"
      final checkInBtn = $('Vào ca');
      if (await checkInBtn.exists) {
        await checkInBtn.tap();
        await $.pumpAndSettle();
        
        // Xác nhận trạng thái đã thay đổi thành "Đang trong ca"
        expect($('Đang trong ca'), findsOneWidget);
      }

      // 4. (Tùy chọn) Thực hiện Check-out nếu cần thiết trong luồng test
      final checkOutBtn = $('Kết thúc ca');
      if (await checkOutBtn.exists) {
        await checkOutBtn.tap();
        await $.pumpAndSettle();
        
        // Xác nhận báo cáo tổng số giờ hoặc quay về trạng thái chưa vào ca
        expect($('Vào ca'), findsOneWidget);
      }
    },
  );
}
