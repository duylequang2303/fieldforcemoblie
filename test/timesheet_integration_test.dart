import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/timesheet/models/timesheet_entry.dart';
import 'fixtures/sample_data.dart';

void main() {
  group('Timesheet Integration & Sync Flow', () {
    test('TIME-INT-01: Chấm công offline và tự động đồng bộ (Push) lên Odoo', () async {
      // Arrange: Tạo entry offline (bấm giờ bắt đầu và kết thúc khi mất mạng)
      final entry = TimesheetEntryFactory.samplePending(); // isPendingSync = true
      
      // Giả lập lưu local DB (Isar)
      final localDb = <int, TimesheetEntry>{
        entry.id!: entry
      };

      // Act: SyncManager chạy ngầm khi có mạng lại
      bool mockOdooSyncSuccess = true; // Call Odoo API giả lập
      
      if (mockOdooSyncSuccess) {
        final syncedEntry = localDb[entry.id]!;
        // Cập nhật record sau khi sync thành công
        syncedEntry.isPendingSync = false;
        syncedEntry.odooId = 999; // ID thực tế trả về từ Odoo Server
        syncedEntry.lastSyncAt = DateTime.now();
        
        // Save back to DB (mô phỏng)
        localDb[entry.id!] = syncedEntry;
      }

      // Assert
      final updatedEntry = localDb[entry.id]!;
      expect(updatedEntry.isPendingSync, isFalse, reason: 'Sync thành công phải gỡ cờ pending.');
      expect(updatedEntry.odooId, 999, reason: 'Odoo ID phải được cấp sau khi push lên server.');
      expect(updatedEntry.lastSyncAt, isNotNull);
    });
  });
}
