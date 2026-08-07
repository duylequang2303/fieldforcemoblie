import 'dart:io';

Future<void> main() async {
  final issues = <String>[];

  final sessionManager = File('lib/core/api/odoo_session_manager.dart');
  final expenseService = File('lib/features/expense/services/expense_service.dart');
  final ordersService = File('lib/features/orders/services/orders_service.dart');
  final stockService = File('lib/features/stock/services/stock_service.dart');
  final workOrderService = File('lib/features/work_order/services/work_order_service.dart');

  // 1. Hardcoded serverVersion '19' (not in comments)
  if (await sessionManager.exists()) {
    final content = await sessionManager.readAsString();
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('//')) continue;
      if (trimmed.contains("serverVersion: '19'") ||
          trimmed.contains('serverVersion: "19"')) {
        issues.add('HARDCODED_VERSION: serverVersion is hardcoded to "19" in restoreSession');
        break;
      }
    }
  }

  // 2. Hardcoded product_id 1-5 as primary mapping (not fallback)
  if (await expenseService.exists()) {
    final content = await expenseService.readAsString();
    final hasDynamicFetch = content.contains('search_read') &&
        content.contains('product.product') &&
        content.contains('ilike');
    final hasHardcodedOnly = !hasDynamicFetch &&
        content.contains('return 1;') &&
        content.contains('return 2;') &&
        content.contains('return 3;') &&
        content.contains('return 4;') &&
        content.contains('return 5;');
    if (hasHardcodedOnly) {
      issues.add('HARDCODED_PRODUCT_IDS: expense_service.dart uses hardcoded product IDs 1-5 without dynamic fetch');
    }
  }

  // 3. Domain person_id.user_id
  if (await ordersService.exists()) {
    final content = await ordersService.readAsString();
    if (content.contains("'person_id.user_id'")) {
      issues.add('INVALID_DOMAIN: orders_service.dart contains invalid domain person_id.user_id');
    }
  }

  // 4. is_skipped in _fields
  if (await ordersService.exists()) {
    final content = await ordersService.readAsString();
    if (content.contains("'is_skipped',")) {
      issues.add('IS_SKIPPED_IN_FIELDS: _fields list contains is_skipped');
    }
  }

  // 5. quantity instead of product_uom_qty
  if (await stockService.exists()) {
    final content = await stockService.readAsString();
    if (content.contains("'quantity':") || content.contains('"quantity":')) {
      issues.add('WRONG_STOCK_FIELD: stock_service.dart uses quantity instead of product_uom_qty');
    }
  }

  // 6. Signature wizard result handling
  if (await workOrderService.exists()) {
    final content = await workOrderService.readAsString();
    if (!content.contains("result == true") && !content.contains("result is Map")) {
      issues.add('SIGNATURE_WIZARD: work_order_service.dart does not handle both True and dict results');
    }
  }

  if (issues.isEmpty) {
    stdout.writeln('[OK] App-side backend compatibility audit passed');
    exit(0);
  } else {
    stdout.writeln('[FAIL] App-side backend compatibility audit failed:');
    for (final issue in issues) {
      stdout.writeln('  - $issue');
    }
    exit(1);
  }
}
