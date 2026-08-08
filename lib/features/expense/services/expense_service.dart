import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:meta/meta.dart' show visibleForTesting;
import 'package:path_provider/path_provider.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/expense.dart';
import '../../../core/utils/formatters.dart';

/// Kết quả đồng bộ, dùng để thông báo người dùng.
class SyncResult {
  int syncedCount = 0;
  int failedCount = 0;
  int skippedCount = 0;
  final List<String> errors = [];

  bool get hasFailures => failedCount > 0 || errors.isNotEmpty;

  @override
  String toString() =>
      'SyncResult(synced: $syncedCount, failed: $failedCount, skipped: $skippedCount, errors: ${errors.length})';
}

String getMimeFromExtension(String path) {
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

class ExpenseService {
  ExpenseService._({OdooSessionManager? odoo, IsarService? isar})
      : _odoo = odoo ?? OdooSessionManager.instance,
        _isar = isar ?? IsarService.instance;
  static final ExpenseService instance = ExpenseService._();

  @visibleForTesting
  factory ExpenseService.testConstructor(
      OdooSessionManager odoo, IsarService isar) {
    return ExpenseService._(odoo: odoo, isar: isar);
  }

  final OdooSessionManager _odoo;
  final IsarService _isar;

  static const _maxRetries = 3;
  String? _lastProductCacheKey;
  static final Map<String, int?> _productIdCache = {};

  String _productCacheKey(String serverUrl, String database) =>
      '$serverUrl|$database';

  Future<List<Expense>> getExpensesForOrder(int orderOdooId) async {
    return _isar.db.expenses
        .filter()
        .orderOdooIdEqualTo(orderOdooId)
        .sortByDateDesc()
        .findAll();
  }

  Future<Expense> addExpense({
    required int orderOdooId,
    required String name,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
    String? receiptImagePath,
    String? note,
  }) async {
    final currentUserId = _odoo.currentUserId;
    final employeeId = _odoo.currentSession?.employeeId;

    // Persist receipt image to app directory if it exists and is a temp file
    String? persistedReceiptPath = receiptImagePath;
    if (receiptImagePath != null) {
      persistedReceiptPath = await _persistReceiptFile(receiptImagePath);
    }

    final expense = Expense.create(
      orderOdooId: orderOdooId,
      name: name,
      amount: amount,
      date: date,
      category: category,
      receiptImagePath: persistedReceiptPath,
      note: note,
    );
    expense.localOwnerId = currentUserId;

    await _isar.db.writeTxn(() async {
      await _isar.db.expenses.put(expense);
    });

    if (employeeId == null) {
      logger.w('ExpenseService.addExpense: no employeeId, staying offline');
      return expense;
    }

    final productId = await getProductIdForCategory(category);
    if (productId == null) {
      logger.w(
          'ExpenseService.addExpense: no product mapping for category $category');
      return expense;
    }

    try {
      final existingOdooId = await _findDuplicateOnOdoo(
        name: name,
        amount: amount,
        date: date,
        employeeId: employeeId,
        orderOdooId: orderOdooId,
      );

      var odooId = existingOdooId;
      if (existingOdooId != null) {
        logger.i(
            'ExpenseService.addExpense: Found existing duplicate expense on Odoo with id $existingOdooId. Linking local record.');
      } else {
        final result = await _odoo.callKw(
          model: 'hr.expense',
          method: 'create',
          args: [
            buildOdooPayload(
              name: name,
              amount: amount,
              date: date,
              employeeId: employeeId,
              productId: productId,
              orderOdooId: orderOdooId,
            ),
          ],
        );
        odooId = result as int?;
        logger.i(
            'ExpenseService.addExpense: Created expense on Odoo with id $odooId');
      }

      int? attachmentId;
      if (persistedReceiptPath != null &&
          expense.receiptAttachmentId == null &&
          odooId != null) {
        attachmentId = await _uploadReceipt(persistedReceiptPath, odooId);
      }

      await _isar.db.writeTxn(() async {
        expense.odooId = odooId;
        expense.receiptAttachmentId =
            attachmentId ?? expense.receiptAttachmentId;
        expense.isPendingSync = odooId == null;
        await _isar.db.expenses.put(expense);
      });
    } on OdooApiException catch (e) {
      logger.w('ExpenseService.addExpense: offline', error: e);
    }

    return expense;
  }

  /// Helper to copy temp files to app documents directory
  Future<String?> _persistReceiptFile(String tempPath) async {
    try {
      final tempFile = File(tempPath);
      if (!await tempFile.exists()) {
        logger.w(
            'ExpenseService._persistReceiptFile: temp file does not exist: $tempPath');
        return tempPath;
      }
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final persistedFile = await tempFile.copy('${appDir.path}/$fileName');
      logger.i(
          'ExpenseService._persistReceiptFile: Persisted receipt to ${persistedFile.path}');
      return persistedFile.path;
    } catch (e) {
      logger.e('ExpenseService._persistReceiptFile failed', error: e);
      return tempPath;
    }
  }

  /// Upload receipt image as ir.attachment linked to hr.expense.
  /// Returns the Odoo attachment ID, or null on failure.
  Future<int?> _uploadReceipt(String receiptPath, int expenseOdooId) async {
    final file = File(receiptPath);
    if (!await file.exists()) {
      logger.w(
          'ExpenseService._uploadReceipt: file does not exist: $receiptPath');
      return null;
    }

    final base64String = await compute(_encodeBase64Isolate, receiptPath);
    final filename = file.uri.pathSegments.last;

    try {
      final attId = await _odoo.callKw(
        model: 'ir.attachment',
        method: 'create',
        args: [
          {
            'name': filename,
            'datas': base64String,
            'mimetype': getMimeFromExtension(receiptPath),
            'res_model': 'hr.expense',
            'res_id': expenseOdooId,
          }
        ],
      ) as int?;
      logger.i(
          'ExpenseService._uploadReceipt: Uploaded receipt attachment $attId for expense $expenseOdooId');
      return attId;
    } on OdooApiException catch (e) {
      logger.w('ExpenseService._uploadReceipt: Odoo API error', error: e);
      return null;
    }
  }

  /// Encode file to base64 in a background isolate — không block UI thread.
  static Future<String> _encodeBase64Isolate(String path) async {
    final bytes = await File(path).readAsBytes();
    return base64Encode(bytes);
  }

  /// Check if a duplicate expense already exists on Odoo.
  Future<int?> _findDuplicateOnOdoo({
    required String name,
    required double amount,
    required DateTime date,
    required int employeeId,
    required int orderOdooId,
  }) async {
    try {
      final dateStr = AppDateFormat.odooDate(date);
      final trimmedName = name.trim();
      final results = await _odoo.callKw(
        model: 'hr.expense',
        method: 'search_read',
        args: [
          [
            ['name', '=', trimmedName],
            ['date', '=', dateStr],
            ['employee_id', '=', employeeId],
            ['fsm_order_id', '=', orderOdooId],
          ]
        ],
        kwargs: {
          'fields': ['id', 'name', 'total_amount'],
          'limit': 1,
        },
      );
      if (results is List && results.isNotEmpty) {
        final item = results.first as Map<String, dynamic>;
        final rawAmount = item['total_amount'];
        final odooAmount = rawAmount is num ? rawAmount.toDouble() : 0.0;
        final remoteName = (item['name'] as String?)?.trim();
        if (remoteName != null &&
            remoteName == trimmedName &&
            (odooAmount - amount).abs() < 0.01) {
          return item['id'] as int?;
        }
      }
    } on OdooApiException catch (e, _) {
      logger.w('ExpenseService._findDuplicateOnOdoo failed', error: e);
      rethrow;
    }
    return null;
  }

  /// Build Odoo payload for creating hr.expense.
  Map<String, dynamic> buildOdooPayload({
    required String name,
    required double amount,
    required DateTime date,
    required int employeeId,
    required int productId,
    required int orderOdooId,
  }) {
    return {
      'name': name,
      'total_amount': amount,
      'unit_amount': amount,
      'quantity': 1,
      'date': AppDateFormat.odooDate(date),
      'employee_id': employeeId,
      'product_id': productId,
      'fsm_order_id': orderOdooId,
    };
  }

  /// Map ExpenseCategory to Odoo product_id for hr.expense.
  /// Fetches dynamically from Odoo by product name, with hardcoded fallback.
  /// Cache is isolated by serverUrl+database so session changes do not leak IDs.
  Future<int?> getProductIdForCategory(ExpenseCategory category) async {
    final session = _odoo.currentSession;
    final cacheKey = session != null
        ? _productCacheKey(session.serverUrl, session.database)
        : null;

    if (cacheKey != null && _lastProductCacheKey == cacheKey) {
      final cached = _productIdCache['$cacheKey|$category'];
      if (cached != null) return cached;
    } else {
      _productIdCache.clear();
      _lastProductCacheKey = cacheKey;
    }

    final label = categoryLabelFor(category);
    int? productId;

    try {
      final results = await _odoo.callKw(
        model: 'product.product',
        method: 'search_read',
        args: [
          [
            ['name', 'ilike', label]
          ]
        ],
        kwargs: {
          'fields': ['id', 'name'],
          'limit': 1,
        },
      ) as List<dynamic>;

      if (results.isNotEmpty) {
        productId = results.first['id'] as int?;
      }
    } on OdooApiException catch (e) {
      logger.w('ExpenseService.getProductIdForCategory: failed to fetch product for $label',
          error: e);
    } catch (e) {
      logger.w('ExpenseService.getProductIdForCategory: unexpected error for $label',
          error: e);
    }

    productId ??= _hardcodedProductIdForCategory(category);
    if (cacheKey != null) {
      _productIdCache['$cacheKey|$category'] = productId;
    }
    return productId;
  }

  /// Hardcoded fallback mapping when dynamic fetch fails.
  int? _hardcodedProductIdForCategory(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.fuel:
        return 1;
      case ExpenseCategory.meal:
        return 2;
      case ExpenseCategory.transport:
        return 3;
      case ExpenseCategory.material:
        return 4;
      case ExpenseCategory.other:
        return 5;
    }
  }

  String categoryLabelFor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.fuel:
        return 'Nhiên liệu';
      case ExpenseCategory.meal:
        return 'Ăn uống';
      case ExpenseCategory.transport:
        return 'Vận chuyển';
      case ExpenseCategory.material:
        return 'Vật liệu';
      case ExpenseCategory.other:
        return 'Khác';
    }
  }

  /// Sync pending expenses. Called by SyncManager on network change / periodic.
  /// Returns a [SyncResult] with failure details so UI can notify the user.
  Future<SyncResult?> syncPendingWithResult() async {
    final currentUserId = _odoo.currentUserId;
    final employeeId = _odoo.currentSession?.employeeId;
    if (currentUserId == null || employeeId == null) return null;

    final pending = await _isar.db.expenses
        .filter()
        .isPendingSyncEqualTo(true)
        .localOwnerIdEqualTo(currentUserId)
        .findAll();

    if (pending.isEmpty) return SyncResult();

    final result = SyncResult();
    final updates = <Expense, _SyncUpdate>{};

    for (final expense in pending) {
      if (expense.odooId != null) {
        updates[expense] = const _SyncUpdate(markSynced: true);
        result.skippedCount++;
        continue;
      }

      final productId = await getProductIdForCategory(expense.category);
      if (productId == null) {
        result.skippedCount++;
        result.errors
            .add('Chi phí "${expense.name}" bỏ qua: không có product mapping');
        logger.w(
            'ExpenseService.syncPending: no product mapping for category ${expense.category}');
        continue;
      }

      Object? error;
      int? existingOdooId;
      int? createdOdooId;
      int? attachmentId;

      for (int attempt = 1; attempt <= _maxRetries; attempt++) {
        error = null;
        try {
          existingOdooId = await _findDuplicateOnOdoo(
            name: expense.name,
            amount: expense.amount,
            date: expense.date,
            employeeId: employeeId,
            orderOdooId: expense.orderOdooId,
          );

          if (existingOdooId != null) {
            logger.i(
                'ExpenseService.syncPending: Found existing duplicate expense on Odoo with id $existingOdooId. Linking local record.');
            break;
          }

          createdOdooId = await _odoo.callKw(
            model: 'hr.expense',
            method: 'create',
            args: [
              buildOdooPayload(
                name: expense.name,
                amount: expense.amount,
                date: expense.date,
                employeeId: employeeId,
                productId: productId,
                orderOdooId: expense.orderOdooId,
              ),
            ],
          ) as int?;

          if (expense.receiptImagePath != null &&
              expense.receiptAttachmentId == null &&
              createdOdooId != null) {
            attachmentId =
                await _uploadReceipt(expense.receiptImagePath!, createdOdooId);
          }

          break;
        } on OdooApiException catch (e) {
          error = e;
          if (attempt < _maxRetries) {
            final backoff = Duration(seconds: 1 << (attempt - 1));
            logger.w(
                'ExpenseService.syncPending: attempt $attempt failed for expense ${expense.id}, retrying in ${backoff.inSeconds}s',
                error: e);
            await Future<void>.delayed(backoff);
          }
        } catch (e) {
          error = e;
          break;
        }
      }

      if (error != null) {
        result.failedCount++;
        result.errors.add('Chi phí "${expense.name}" chưa đồng bộ: $error');
        logger.w(
            'ExpenseService.syncPending: failed after $_maxRetries attempts for expense ${expense.id}',
            error: error);
      } else {
        result.syncedCount++;
        final odooId = existingOdooId ?? createdOdooId;
        updates[expense] = _SyncUpdate(
          odooId: odooId,
          attachmentId: attachmentId,
        );
      }
    }

    // Apply all DB updates in a single transaction (EXP-SYNC-003: batch write)
    if (updates.isNotEmpty) {
      await _isar.db.writeTxn(() async {
        for (final entry in updates.entries) {
          final expense = entry.key;
          final update = entry.value;
          if (update.markSynced == true) {
            expense.isPendingSync = false;
          } else {
            expense.odooId = update.odooId;
            expense.receiptAttachmentId =
                update.attachmentId ?? expense.receiptAttachmentId;
            expense.isPendingSync = update.odooId == null;
          }
          await _isar.db.expenses.put(expense);
        }
      });
    }

    return result;
  }

  /// SyncManager-compatible wrapper that discards the result.
  Future<void> syncPending() => syncPendingWithResult();
}

/// Internal holder for pending DB updates during sync.
class _SyncUpdate {
  final int? odooId;
  final int? attachmentId;
  final bool? markSynced;

  const _SyncUpdate({this.odooId, this.attachmentId, this.markSynced});
}
