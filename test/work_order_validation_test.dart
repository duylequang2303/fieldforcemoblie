import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/work_order/models/work_report.dart';
import 'fixtures/sample_data.dart';

void main() {
  group('Work Report Validation (Unit Test)', () {
    test('WO-01: Báo cáo công việc không được để trống nội dung', () {
      final report = WorkReportFactory.sample(content: '');

      bool isValid(WorkReport r) {
        return r.content != null && r.content!.trim().isNotEmpty;
      }

      expect(isValid(report), isFalse, reason: 'Nội dung báo cáo công việc đang trống.');
    });

    test('WO-02: Báo cáo công việc hợp lệ', () {
      final report = WorkReportFactory.sample(content: 'Đã hoàn tất thay thế linh kiện A và vệ sinh thiết bị.');

      bool isValid(WorkReport r) {
        return r.content != null && r.content!.trim().isNotEmpty;
      }

      expect(isValid(report), isTrue);
      expect(report.isPendingSync, isFalse);
    });
  });
}
