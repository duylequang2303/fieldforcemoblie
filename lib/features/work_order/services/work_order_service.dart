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
    final existing = await _isar.db.workReports
        .filter()
        .orderOdooIdEqualTo(orderOdooId)
        .findFirst();

    if (existing != null) return existing;

    final report = WorkReport.create(orderOdooId: orderOdooId);
    await _isar.db.writeTxn(() async {
      await _isar.db.workReports.put(report);
    });
    return report;
  }

  /// Lưu nội dung báo cáo (local).
  Future<void> saveReport(WorkReport report) async {
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
      // Ghi resolution thay vì description
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

      // Submit chữ ký bằng Wizard chuẩn của Odoo
      if (report.customerSignaturePath != null && report.customerName != null) {
        final sigFile = File(report.customerSignaturePath!);
        if (sigFile.existsSync()) {
          final bytes = await sigFile.readAsBytes();
          final base64Sig = base64Encode(bytes); // Không cần tiền tố data:image

          // Bước 1: Tạo Wizard
          final wizardId = await _odoo.callKw(
            model: 'fsm.order.sign.wizard',
            method: 'create',
            args: [{
              'order_id': report.orderOdooId,
              'signed_by': report.customerName,
              'signature': base64Sig,
            }],
          ) as int;

          // Bước 2: Trigger action ký
          await _odoo.callKw(
            model: 'fsm.order.sign.wizard',
            method: 'action_sign',
            args: [[wizardId]],
          );
        }
      }
      
      // Upload ảnh đính kèm
      await uploadPhotos(report);
      
      await _isar.db.writeTxn(() async {
        report.isPendingSync = false;
        await _isar.db.workReports.put(report);
      });
    } on OdooApiException catch (e) {
      logger.e('WorkOrderService.submitReport', error: e);
      rethrow;
    }
  }

  /// Sync các báo cáo chưa push (isPendingSync = true) — SyncManager gọi khi online.
  Future<void> syncPending() async {
    final pending = await _isar.db.workReports
        .filter()
        .isPendingSyncEqualTo(true)
        .findAll();
    for (final report in pending) {
      try {
        await submitReport(report);
      } catch (e) {
        logger.w('WorkOrderService.syncPending: failed for order ${report.orderOdooId}', error: e);
      }
    }
  }

  /// Đẩy tất cả ảnh đính kèm lên Odoo Chatter
  Future<void> uploadPhotos(WorkReport report) async {
    if (report.photoPaths.isEmpty) return;

    try {
      for (final path in report.photoPaths) {
        final file = File(path);
        if (await file.exists()) {
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
                'mimetype': 'image/jpeg',
                'res_model': 'fsm.order',
                'res_id': report.orderOdooId,
              }
            ],
          ) as int;

          // 2. Post message link tới attachment (BỎ kwargs 'attachments')
          await _odoo.callKw(
            model: 'fsm.order',
            method: 'message_post',
            args: [[report.orderOdooId]],
            kwargs: {
              'body': 'Ảnh hiện trường: $filename',
              'message_type': 'comment',
              'subtype_xmlid': 'mail.mt_comment',
              'attachment_ids': [attId],
            },
          );
        }
      }
    } catch (e) {
      // Bọc try-catch để không chặn luồng submit báo cáo nếu lỗi ảnh
      logger.w('WorkOrderService.uploadPhotos: Lỗi đẩy ảnh lên Odoo', error: e);
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
          'mimetype': 'image/jpeg',
          'res_model': 'fsm.order',
          'res_id': orderOdooId,
        }
      ],
    ) as int;

    // 2. Post message link tới attachment (BỎ kwargs 'attachments')
    await _odoo.callKw(
      model: 'fsm.order',
      method: 'message_post',
      args: [[orderOdooId]],
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

