import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:fieldforce_mobile/main.dart' as app;

void main() {
  patrolTest(
    'AUTH-01: Đăng nhập thành công',
    nativeAutomation: true,
    ($) async {
      await app.main();
      await $.pumpAndSettle();

      // Kiểm tra có đang ở màn hình Đăng nhập (Fieldforce Worker) không
      expect($('Fieldforce Worker'), findsOneWidget);

      // Nhập các thông tin Test P0
      // Lưu ý: TextFormField thường có thể tìm thông qua labelText hoặc Type
      await $(RegExp('Server URL.*')).enterText('https://demo002.crmhub.vn');
      await $('Tên Database').enterText('demo002.crmhub.vn');
      await $('Tên đăng nhập').enterText('admin');
      await $('Mật khẩu').enterText('<),9853\$6Ect');

      // Ẩn bàn phím để nút Đăng nhập không bị che
      // await $.native.pressHome(); -> không, chỉ cần ấn nút Đăng nhập
      await $('Đăng nhập').tap();
      await $.pumpAndSettle();

      // Kiểm tra xem đã điều hướng sang màn hình Orders (Danh sách đơn hàng) chưa
      // Thường thì List Page sẽ có title 'Danh sách đơn hàng' hoặc 'Đơn dịch vụ'
      expect($('Đơn dịch vụ'), findsOneWidget);
    },
  );
}