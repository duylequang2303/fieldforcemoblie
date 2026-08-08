import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/work_order/models/work_report.dart';

void main() {
  group('WorkReport.create', () {
    test('should initialise an empty report attached to the order', () {
      final report = WorkReport.create(orderOdooId: 42);

      expect(report.orderOdooId, 42);
      expect(report.workDone, '');
      expect(report.photoPaths, isEmpty);
      expect(report.odooId, isNull);
      expect(report.localOwnerId, isNull);
      expect(report.problemsFound, isNull);
      expect(report.recommendation, isNull);
      expect(report.customerName, isNull);
      expect(report.customerSignaturePath, isNull);
      expect(report.signedAt, isNull);
      expect(report.createdAt, isA<DateTime>());
    });

    test('should start with nothing pending nor synced', () {
      final report = WorkReport.create(orderOdooId: 1);

      expect(report.isPendingSync, isFalse);
      expect(report.isResolutionSynced, isFalse);
      expect(report.isSignatureSynced, isFalse);
      expect(report.syncedPhotoPaths, isEmpty);
      expect(report.syncedAttachmentEntries, isEmpty);
    });

    test('should give each report independent photo lists', () {
      final first = WorkReport.create(orderOdooId: 1);
      final second = WorkReport.create(orderOdooId: 2);

      first.photoPaths.add('/tmp/a.jpg');
      first.syncedPhotoPaths.add('/tmp/a.jpg');
      first.syncedAttachmentEntries.add('/tmp/a.jpg|101');

      expect(second.photoPaths, isEmpty);
      expect(second.syncedPhotoPaths, isEmpty);
      expect(second.syncedAttachmentEntries, isEmpty);
    });

    test('should track partial sync progress independently per step', () {
      final report = WorkReport.create(orderOdooId: 7)
        ..workDone = 'Thay bơm'
        ..isPendingSync = true
        ..isResolutionSynced = true;

      expect(report.isResolutionSynced, isTrue);
      expect(report.isSignatureSynced, isFalse);
      expect(report.isPendingSync, isTrue);
    });
  });

  group('WorkReport signature', () {
    test('should record signer name and timestamp once signed', () {
      final signedAt = DateTime(2026, 8, 8, 10, 30);
      final report = WorkReport.create(orderOdooId: 3)
        ..customerName = 'Nguyễn Văn A'
        ..customerSignaturePath = '/tmp/sign.png'
        ..signedAt = signedAt
        ..isPendingSync = true;

      expect(report.customerName, 'Nguyễn Văn A');
      expect(report.customerSignaturePath, '/tmp/sign.png');
      expect(report.signedAt, signedAt);
      expect(report.isSignatureSynced, isFalse);
    });
  });
}
