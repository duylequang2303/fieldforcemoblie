import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TestCredentials {
  static late String odooUrl;
  static late String odooDb;
  static late String testUser;
  static late String testPassword;

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
    odooUrl = dotenv.env['ODOO_URL'] ?? '';
    odooDb = dotenv.env['ODOO_DB'] ?? '';
    testUser = dotenv.env['ODOO_TEST_USER'] ?? '';
    testPassword = dotenv.env['ODOO_TEST_PASSWORD'] ?? '';

    if (odooUrl.isNotEmpty &&
        !odooUrl.startsWith('http://') &&
        !odooUrl.startsWith('https://')) {
      odooUrl = 'https://$odooUrl';
    }
  }
}

/// Kiểm tra app có đang ở màn login không
bool _isOnLoginScreen(WidgetTester tester) {
  // Màn login có title "Fieldforce Worker" và button "Đăng nhập"
  final hasLoginTitle = find.text('Fieldforce Worker').evaluate().isNotEmpty;
  final hasLoginButton = find.text('Đăng nhập').evaluate().isNotEmpty;
  return hasLoginTitle && hasLoginButton;
}

Future<void> performLogin(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // FIX LỖI 2: Nếu đã login rồi (app đang ở Schedule), skip login
  if (!_isOnLoginScreen(tester)) {
    print('ℹ️ Already logged in, skipping login step');
    return;
  }

  // Tìm tất cả TextFormField
  final textFields = find.byType(TextFormField);
  expect(textFields, findsAtLeastNWidgets(4),
      reason: 'Login form must have 4 TextFormFields');

  // Fill từng field
  await tester.tap(textFields.at(0));
  await tester.pump();
  await tester.enterText(textFields.at(0), TestCredentials.odooUrl);
  await tester.pump();

  await tester.tap(textFields.at(1));
  await tester.pump();
  await tester.enterText(textFields.at(1), TestCredentials.odooDb);
  await tester.pump();

  await tester.tap(textFields.at(2));
  await tester.pump();
  await tester.enterText(textFields.at(2), TestCredentials.testUser);
  await tester.pump();

  await tester.tap(textFields.at(3));
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  await tester.enterText(textFields.at(3), TestCredentials.testPassword);
  await tester.pump();

  // Đóng keyboard
  tester.testTextInput.closeConnection();
  await tester.pump();

  // FIX LỖI 1: Dùng await trước receiveAction (trả về Future<void>)
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle(const Duration(seconds: 15));

  // Fallback: nếu Enter không submit, tap button "Đăng nhập"
  if (_isOnLoginScreen(tester)) {
    final loginButton = find.widgetWithText(ElevatedButton, 'Đăng nhập');
    if (loginButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 15));
    }
  }
}

Future<void> waitForFirstOrderCard(WidgetTester tester,
    {Duration timeout = const Duration(seconds: 20)}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    final cards = find.byType(Card);
    if (cards.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 500));
  }
  fail('No order card appeared within $timeout');
}

Future<void> setupIntegrationTest() async {
  await TestCredentials.load();
}
