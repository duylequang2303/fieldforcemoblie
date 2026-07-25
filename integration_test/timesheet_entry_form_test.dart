import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:fieldforce_mobile/widgets/timesheet_entry_form.dart';

void main() {
  patrolTest(
    'Thêm giờ làm: Chọn nhân viên, nhập giờ, chọn giờ nghỉ và lưu',
    nativeAutomation: true,
    ($) async {
      bool isSaved = false;

      // 1. Mở app (Mock màn hình có chứa TimesheetEntryForm)
      await $.pumpWidgetAndSettle(
        MaterialApp(
          home: Scaffold(
            body: TimesheetEntryForm(
              onSaved: () {
                isSaved = true;
              },
            ),
          ),
        ),
      );

      // 2. Chọn nhân viên: mặc định 'Just Me' đã được chọn, ta chọn thêm 'Crew'
      final chipCrew = $(const Key('chip_employee_Crew'));
      await chipCrew.tap();
      await $.pumpAndSettle();

      // 3. Nhập giờ bắt đầu (Ví dụ: 08:00)
      await $(const Key('btn_start_time')).tap();
      await $.pumpAndSettle();
      // Chuyển sang chế độ nhập text trong TimePicker
      await $(Icons.keyboard).tap();
      await $.pumpAndSettle();
      await $(TextField).at(0).enterText('08');
      await $(TextField).at(1).enterText('00');
      // Bấm OK
      await $('OK').tap();
      await $.pumpAndSettle();

      // 4. Nhập giờ kết thúc (Ví dụ: 17:00)
      await $(const Key('btn_end_time')).tap();
      await $.pumpAndSettle();
      await $(Icons.keyboard).tap();
      await $.pumpAndSettle();
      await $(TextField).at(0).enterText('17');
      await $(TextField).at(1).enterText('00');
      await $('OK').tap();
      await $.pumpAndSettle();

      // 5. Chọn thời gian nghỉ (Break: 1 hour)
      await $(const Key('dropdown_break')).tap();
      await $.pumpAndSettle();
      await $('1 hour').tap();
      await $.pumpAndSettle();

      // 6. Assert giờ tự động tính đúng
      // Từ 08:00 đến 17:00 là 9 tiếng, trừ 1 tiếng break -> còn 8 tiếng
      // UI sẽ hiển thị text '8.00'
      expect($('8.00'), findsOneWidget);

      // 7. Nhấn Lưu
      await $(const Key('btn_save_timesheet')).tap();
      await $.pumpAndSettle();

      // 8. Assert onSaved đã được gọi
      expect(isSaved, true);
    },
  );
}
