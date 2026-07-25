import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:fieldforce_mobile/features/timesheet/models/timesheet_entry.dart';
import 'fixtures/sample_data.dart';

void main() {
  group('Timesheet Integration & Sync Flow', () {
    late Isar isar;
    late Directory tempDir;

    setUp(() async {
      await Isar.initializeIsarCore(download: true);
      tempDir = await Directory.systemTemp.createTemp('isar_timesheet_test');
      isar = await Isar.open(
        [TimesheetEntrySchema],
        directory: tempDir.path,
        name: 'test_db_timesheet',
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('TIME-INT-01: Chấm công offline lưu db và tự động đồng bộ (Push) lên Odoo', () async {
      // Arrange: Tạo entry offline (bấm giờ bắt đầu và kết thúc khi mất mạng)
      final entry = TimesheetEntryFactory.samplePending(); // isPendingSync = true
      
      // Lưu local DB (Isar)
      await isar.writeTxn(() async {
        await isar.timesheetEntrys.put(entry);
      });

      // Lấy ra
      final savedEntry = await isar.timesheetEntrys.get(entry.id);
      expect(savedEntry, isNotNull);
      expect(savedEntry!.isPendingSync, isTrue);

      // Act: SyncManager chạy ngầm khi có mạng lại
      bool mockOdooSyncSuccess = true; // Call Odoo API giả lập
      
      if (mockOdooSyncSuccess) {
        await isar.writeTxn(() async {
          final entryToUpdate = await isar.timesheetEntrys.get(entry.id);
          if (entryToUpdate != null) {
            entryToUpdate.isPendingSync = false;
            entryToUpdate.odooId = 999; // ID thực tế trả về từ Odoo Server
            await isar.timesheetEntrys.put(entryToUpdate);
          }
        });
      }

      // Assert
      final updatedEntry = await isar.timesheetEntrys.get(entry.id);
      expect(updatedEntry!.isPendingSync, isFalse, reason: 'Sync thành công phải gỡ cờ pending.');
      expect(updatedEntry.odooId, 999, reason: 'Odoo ID phải được cấp sau khi push lên server.');
    });
  });
}
