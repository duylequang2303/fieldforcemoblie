import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/timesheet/models/timesheet_entry.dart';
import 'fixtures/sample_data.dart';

void main() {
  group('Timesheet Validation Logic (Unit Test)', () {
    test('TIME-01: Timesheet hợp lệ với duration chính xác', () {
      // Arrange
      final startTime = DateTime(2024, 12, 1, 8, 0);
      final endTime = DateTime(2024, 12, 1, 12, 0);
      final entry = TimesheetEntryFactory.sample(
        startTime: startTime,
        endTime: endTime,
      );

      // Act & Assert
      expect(entry.hours, 4.0, reason: 'Thời gian làm việc từ 8h đến 12h phải là 4 tiếng.');
      
      bool isValid(TimesheetEntry t) {
        return t.hours > 0;
      }
      expect(isValid(entry), isTrue);
    });

    test('TIME-02: Tạo timesheet kết thúc trước khi bắt đầu -> Validation error', () {
      // Arrange: endTime < startTime
      final entry = TimesheetEntryFactory.sample(
        startTime: DateTime(2024, 12, 1, 10, 0),
        endTime: DateTime(2024, 12, 1, 8, 0),
      );

      // Act & Assert
      bool isValid(TimesheetEntry t) {
        return t.hours > 0;
      }

      expect(isValid(entry), isFalse, reason: 'Giờ kết thúc không được nhỏ hơn giờ bắt đầu (hours <= 0).');
    });

    test('TIME-03: Timesheet vượt quá 24h -> Validation warning', () {
      final entry = TimesheetEntryFactory.sample(
        startTime: DateTime(2024, 12, 1, 8, 0),
        endTime: DateTime(2024, 12, 3, 8, 0), // 48 tiếng
      );

      bool isValidDuration(TimesheetEntry t) {
        return t.hours <= 24 && t.hours > 0; // Rule: Timesheet 1 ngày không vượt quá 24h
      }

      expect(isValidDuration(entry), isFalse, reason: 'Thời lượng timesheet không được vượt quá 24h.');
    });
  });
}
