import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/work_report.dart';
import '../../orders/models/fsm_order.dart';

/// Detect mimetype từ extension file thay vì hardcode.
String _mimeFromExtension(String path) {
  final ext = path.split('.').last.toLowerCase();
  switch (ext) {
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'gif':
      return 'image/gif';
    case 'bmp':
      return 'image/bmp';
    case 'heic':
      return 'image/heic';
    case 'heif':
      return 'image/heif';
    case 'jpg':
    case 'jpeg':
    default:
      return 'image/jpeg';
  }
}

class WorkOrderService {
  WorkOrderService._({OdooSessionManager? odoo, IsarService? isar})
      : _odoo = odoo ?? OdooSessionManager.instance,
        _isar = isar ?? IsarService.instance;
  static final WorkOrderService instance = WorkOrderService._();

  final OdooSessionManager _odoo;
  final IsarService _isar;

  /// Lấy thông tin đơn (FsmOrder)
  Future<FsmOrder?> getOrder(int orderOdooId) async {
    return _isar.db.fsmOrders.getByOdooId(orderOdooId);
  }

  /// Lấy hoặc tạo mới báo cáo cho đơn.
  Future<WorkReport> getOrCreateReport(int orderOdooId) async {
    final currentUserId = _odoo.currentUserId;
    final existing = await _isar.db.workReports
        .filter()
        .orderOdooIdEqualTo(orderOdooId)
        .and()
        .localOwnerIdEqualTo(currentUserId)
        .findFirst();

    if (existing != null) return existing;

    final report = WorkReport.create(orderOdooId: orderOdooId);
    report.localOwnerId = currentUserId;
    await _isar.db.writeTxn(() async {
      await _isar.db.workReports.put(report);
    });
    return report;
  }

  /// Lưu nội dung báo cáo (local).
  Future<void> saveReport(WorkReport report, [int? currentUserId]) async {
    final ownerId = currentUserId ?? _odoo.currentUserId;
    if (ownerId == null) {
      throw const OdooAuthException('Không tìm thấy phiên làm việc hợp lệ.');
    }
    final existing = await _isar.db.workReports
        .filter()
        .orderOdooIdEqualTo(report.orderOdooId)
        .and()
        .localOwnerIdEqualTo(ownerId)
        .findFirst();

    report.localOwnerId = ownerId;
    if (existing != null) {
      report.id = existing.id;
      if (existing.workDone != report.workDone) {
        report.isResolutionSynced = false;
      }
      if (existing.customerSignaturePath != report.customerSignaturePath ||
          existing.customerName != report.customerName) {
        report.isSignatureSynced = false;
      }
      final currentPhotos = report.photoPaths;
      report.syncedPhotoPaths = report.syncedPhotoPaths
          .where((p) => currentPhotos.contains(p))
          .toList();
      report.syncedAttachmentEntries = report.syncedAttachmentEntries
          .where((e) => currentPhotos.contains(e.split('|').first))
          .toList();
    } else {
      report.isResolutionSynced = false;
      report.isSignatureSynced = false;
      report.syncedPhotoPaths = [];
      report.syncedAttachmentEntries = [];
    }

    report
      ..isPendingSync = true
      ..createdAt = DateTime.now();
    await _isar.db.writeTxn(() async {
      await _isar.db.workReports.put(report);
    });
  }

  /// Submit báo cáo lên Odoo (chỉ gọi khi online và có chữ ký).
  Future<void> submitReport(WorkReport report) async {
    try {
      // 1. Ghi resolution thay vì description nếu chưa sync
      if (!report.isResolutionSynced) {
        await _odoo.callKw(
          model: 'fsm.order',
          method: 'write',
          args: [
            [report.orderOdooId],
            {
              'resolution': report.workDone,
            },
          ],
        );
        report.isResolutionSynced = true;
        await _isar.db.writeTxn(() async {
          await _isar.db.workReports.put(report);
        });
      }

      // 2. Submit chữ ký bằng Wizard chuẩn của Odoo nếu chưa sync
      if (!report.isSignatureSynced &&
          report.customerSignaturePath != null &&
          report.customerName != null) {
        final sigFile = File(report.customerSignaturePath!);
        if (sigFile.existsSync()) {
          final bytes = await sigFile.readAsBytes();
          final base64Sig = base64Encode(bytes); // Không cần tiền tố data:image

          // Bước 1: Tạo Wizard
          final wizardId = await _odoo.callKw(
            model: 'fsm.order.sign.wizard',
            method: 'create',
            args: [
              {
                'order_id': report.orderOdooId,
                'signed_by': report.customerName,
                'signature': base64Sig,
              }
            ],
          ) as int;

          // Bước 2: Trigger action ký
          await _odoo.callKw(
            model: 'fsm.order.sign.wizard',
            method: 'action_sign',
            args: [
              [wizardId]
            ],
          );

          report.isSignatureSynced = true;
          await _isar.db.writeTxn(() async {
            await _isar.db.workReports.put(report);
          });
        } else {
          logger.w(
              'WorkOrderService.submitReport: Signature file not found at ${report.customerSignaturePath}, skipping upload');
        }
      }

      // 3. Upload ảnh đính kèm
      await uploadPhotos(report);

      // Kiểm tra xem tất cả các bước đã hoàn tất đồng bộ thực sự chưa
      final allPhotosSynced = report.photoPaths
          .every((path) => report.syncedPhotoPaths.contains(path));
      final needsSignature =
          report.customerSignaturePath != null && report.customerName != null;
      final signatureOk = !needsSignature || report.isSignatureSynced;

      if (report.isResolutionSynced && signatureOk && allPhotosSynced) {
        await _isar.db.writeTxn(() async {
          report.isPendingSync = false;
          await _isar.db.workReports.put(report);
        });
      }
    } on OdooApiException catch (e) {
      logger.e('WorkOrderService.submitReport', error: e);
      rethrow;
    }
  }

  /// Sync các báo cáo chưa push (isPendingSync = true) — SyncManager gọi khi online.
  Future<void> syncPending() async {
    final currentUserId = _odoo.currentUserId;
    if (currentUserId == null) return;
    final pending = await _isar.db.workReports
        .filter()
        .isPendingSyncEqualTo(true)
        .localOwnerIdEqualTo(currentUserId)
        .findAll();
    for (final report in pending) {
      try {
        await submitReport(report);
      } catch (e) {
        logger.w(
            'WorkOrderService.syncPending: failed for order ${report.orderOdooId}',
            error: e);
      }
    }
  }

  /// Đẩy tất cả ảnh đính kèm lên Odoo Chatter
  Future<void> uploadPhotos(WorkReport report) async {
    if (report.photoPaths.isEmpty) return;

    final updatedSyncedPaths = List<String>.from(report.syncedPhotoPaths);
    final updatedEntries = List<String>.from(report.syncedAttachmentEntries);

    // Build lookup: path &gt; attachmentId
    final attIdByPath = <String, int>{};
    for (final entry in updatedEntries) {
      final parts = entry.split('|');
      if (parts.length == 2) {
        final val = int.tryParse(parts[1]);
        if (val != null) {
          attIdByPath[parts[0]] = val;
        }
      }
    }

    for (final path in report.photoPaths) {
      if (updatedSyncedPaths.contains(path)) {
        continue; // Bỏ qua ảnh đã sync hoàn chỉnh
      }

      final file = File(path);
      if (!await file.exists()) continue;

      final filename = file.uri.pathSegments.last;

      // Wrap xử lý riêng từng tệp tin để tránh hỏng toàn bộ hàng đợi đẩy ảnh
      try {
        // Check nếu đã có attachment ID persisted từ lần retry trước
        int attId;
        if (attIdByPath.containsKey(path) && attIdByPath[path] != null) {
          attId = attIdByPath[path]!;
          logger.i(
              'WorkOrderService.uploadPhotos: reusing persisted attachment $attId for $filename');
        } else {
          // 1. Tạo attachment mới
          final base64String = await compute(_encodeBase64Isolate, path);
          attId = await _odoo.callKw(
            model: 'ir.attachment',
            method: 'create',
            args: [
              {
                'name': filename,
                'datas': base64String,
                'mimetype': _mimeFromExtension(path),
                'res_model': 'fsm.order',
                'res_id': report.orderOdooId,
              }
            ],
          ) as int;

          // Persist ngay "path|attId" &#8212; trước message_post để retry không tạo duplicate
          updatedEntries.add('$path|$attId');
          report.syncedAttachmentEntries = updatedEntries;
          await _isar.db.writeTxn(() async {
            await _isar.db.workReports.put(report);
          });
        }

        // 2. Post message link tới attachment
        await _odoo.callKw(
          model: 'fsm.order',
          method: 'message_post',
          args: [
            [report.orderOdooId]
          ],
          kwargs: {
            'body': 'Ảnh hiện trường: $filename',
            'message_type': 'comment',
            'subtype_xmlid': 'mail.mt_comment',
            'attachment_ids': [attId],
          },
        );

        // Cả attachment + message_post thành công &gt; mới cập nhật syncedPhotoPaths
        updatedSyncedPaths.add(path);
        report.syncedPhotoPaths = updatedSyncedPaths;
        await _isar.db.writeTxn(() async {
          await _isar.db.workReports.put(report);
        });
      } on OdooApiException catch (e) {
        logger.w('WorkOrderService.uploadPhotos: Lỗi Odoo API cho ảnh $path',
            error: e);
      } on IOException catch (e) {
        logger.w(
            'WorkOrderService.uploadPhotos: Lỗi đọc file hoặc mạng cho ảnh $path',
            error: e);
      } catch (e) {
        logger.e('WorkOrderService.uploadPhotos: Lỗi không xác định cho ảnh $path',
            error: e);
      }
    }
  }

  /// Upload 1 ảnh duy nhất lên Odoo Chatter (real-time, gọi từ UI).
  Future<void> uploadSinglePhoto(int orderOdooId, String path) async {
    final file = File(path);
    if (!await file.exists()) return;

    // ✅ Đẩy encode base64 sang background isolate — KHÔNG block UI thread
    final base64String = await compute(_encodeBase64Isolate, path);
    final filename = file.uri.pathSegments.last;

    // 1. Tạo attachment (datas nhận base64 đúng 1 lần — KHÔNG double)
    final attId = await _odoo.callKw(
      model: 'ir.attachment',
      method: 'create',
      args: [
        {
          'name': filename,
          'datas': base64String,
          'mimetype': _mimeFromExtension(path),
          'res_model': 'fsm.order',
          'res_id': orderOdooId,
        }
      ],
    ) as int;

    // 2. Post message link tới attachment (BỎ kwargs 'attachments')
    await _odoo.callKw(
      model: 'fsm.order',
      method: 'message_post',
      args: [
        [orderOdooId]
      ],
      kwargs: {
        'body': 'Ảnh hiện trường: $filename',
        'message_type': 'comment',
        'subtype_xmlid': 'mail.mt_comment',
        'attachment_ids': [attId],
      },
    );
  }

  /// Encode base64 trong isolate riêng — KHÔNG block UI thread.
  static Future<String> _encodeBase64Isolate(String path) async {
    final bytes = await File(path).readAsBytes();
    return base64Encode(bytes);
  }
}
