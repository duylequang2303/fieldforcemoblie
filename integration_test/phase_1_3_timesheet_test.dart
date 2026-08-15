import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fieldforce_mobile/main.dart' as app;
import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupIntegrationTest();
    // Launch app MỘT LẦN cho cả group
    await app.main();
  });

  testWidgets('Login → Schedule → Order → Timesheet page',
      (tester) async {
    // Login (sẽ skip nếu đã login từ test trước)
    await performLogin(tester);
    await waitForFirstOrderCard(tester);

    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    final timesheetBtn = find.byKey(const Key('btn_timesheet'));
    expect(timesheetBtn, findsOneWidget);
    await tester.tap(timesheetBtn);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('Ghi Nhận Giờ Công'), findsOneWidget);
    expect(find.text('Thêm giờ công'), findsOneWidget);
  });

  testWidgets('Timesheet FAB → form opens',
      (tester) async {
    // Login (sẽ skip nếu đã login từ test trước)
    await performLogin(tester);
    await waitForFirstOrderCard(tester);

    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    await tester.tap(find.byKey(const Key('btn_timesheet')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await tester.tap(find.text('Thêm giờ công'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byKey(const Key('btn_save_timesheet')), findsOneWidget);
    expect(find.byKey(const Key('btn_close_timesheet')), findsOneWidget);
    expect(find.byKey(const Key('btn_select_date')), findsOneWidget);
    expect(find.text('Add Time Entry'), findsOneWidget);
  });
}
