import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:dotenv/dotenv.dart';

void main() {
  final dotenv = DotEnv()..load(File('.env').readAsLinesSync());
  test('Inspect Odoo account.analytic.line Fields and Data', () async {
    final client = OdooClient('https://demo002.crmhub.vn');
    try {
      print('Connecting to Odoo...');
      final session = await client.authenticate(
        'demo002.crmhub.vn',
        'admin',
        dotenv['ODOO_ADMIN_PASSWORD'] ?? '',
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
