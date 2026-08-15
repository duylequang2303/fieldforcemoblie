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

  testWidgets('OrderCard tap → WorkOrderDetailScreen appears', (tester) async {
    // Login (sẽ skip nếu đã login từ test trước)
    await performLogin(tester);
    await waitForFirstOrderCard(tester);

    // Find first OrderCard
    final firstOrderCard = find.byType(Card).first;
    expect(firstOrderCard, findsOneWidget);
    await tester.tap(firstOrderCard);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify detail screen keys
    final detailKeys = [
      find.byKey(const Key('btn_mark_complete')),
      find.byKey(const Key('btn_check_in')),
      find.byKey(const Key('btn_timesheet')),
    ];
    final found = detailKeys.where((f) => f.evaluate().isNotEmpty);
    expect(found.isNotEmpty, isTrue,
        reason: 'WorkOrderDetailScreen keys must appear');
  });

  testWidgets('Back button từ detail → quay về Schedule', (tester) async {
    // Đảm bảo đang ở Schedule (không login lại)
    if (find.byType(Card).evaluate().isEmpty) {
      await waitForFirstOrderCard(tester);
    }

    // Mở detail
    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Back
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
    } else {
      await tester.binding.handlePopRoute();
    }
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify quay về Schedule
    await waitForFirstOrderCard(tester, timeout: const Duration(seconds: 10));
  });
}
