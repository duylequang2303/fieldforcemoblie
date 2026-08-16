import 'package:flutter_test/flutter_test.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:dotenv/dotenv.dart';

void main() {
  final dotenv = DotEnv()..load();
  final odooUrl = dotenv['ODOO_URL'] ?? 'https://demo002.crmhub.vn';
  final odooDb = dotenv['ODOO_DB'] ?? 'demo002';
  final odooUser = dotenv['ODOO_TEST_USER'] ?? dotenv['ODOO_USER'] ?? 'admin';
  final odooPassword =
      dotenv['ODOO_TEST_PASSWORD'] ?? dotenv['ODOO_ADMIN_PASSWORD'] ?? '';

  test('Inspect Odoo account.analytic.line Fields and Data', () async {
    if (odooPassword.isEmpty) {
      print('SKIP: ODOO_TEST_PASSWORD/ODOO_ADMIN_PASSWORD not set in .env');
      return;
    }
    final client = OdooClient(odooUrl);
    try {
      print('Connecting to Odoo...');
      final session = await client.authenticate(
        odooDb,
        odooUser,
        odooPassword,
      );
      print('Authenticated. Session ID: ${session.id}');

      // 1. Query danh sách các Project trên Odoo
      final projects = (await client.callKw({
        'model': 'project.project',
        'method': 'search_read',
        'args': <List<dynamic>>[<dynamic>[]],
        'kwargs': {
          'fields': ['id', 'name'],
        },
      }));
      final List<dynamic> projectsList = projects is List ? projects : [];
      print('--- PROJECT LIST IN ODOO ---');
      for (var p in projectsList) {
        print('  - Project: "${p['name']}" (ID: ${p['id']})');
      }

      // 2. Query 5 Tasks trên Odoo
      final tasks = (await client.callKw({
        'model': 'project.task',
        'method': 'search_read',
        'args': <List<dynamic>>[<dynamic>[]],
        'kwargs': {
          'limit': 5,
          'fields': ['id', 'name', 'project_id'],
        },
      }));
      final List<dynamic> tasksList = tasks is List ? tasks : [];
      print('--- TASK LIST IN ODOO ---');
      for (var t in tasksList) {
        print(
            '  - Task: "${t['name']}" (ID: ${t['id']}), Project: ${t['project_id']}');
      }
    } catch (e, stack) {
      print('ERROR: $e');
      print(stack);
    } finally {
      client.close();
    }
  });
}
