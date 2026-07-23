import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/core/api/odoo_session_manager.dart';

void main() {
  Map<String, String> loadEnv() {
    final env = <String, String>{};
    final file = File('.env');
    if (file.existsSync()) {
      final lines = file.readAsLinesSync();
      for (final line in lines) {
        if (line.trim().isEmpty || line.startsWith('#')) continue;
        final parts = line.split('=');
        if (parts.length >= 2) {
          env[parts[0].trim()] = parts.sublist(1).join('=').trim();
        }
      }
    }
    return env;
  }

  group('Odoo API Access Rights Analysis', () {
    final env = loadEnv();
    final url = env['ODOO_URL'] ?? 'https://demo002.crmhub.vn';
    final db = env['ODOO_DB'] ?? 'demo002.crmhub.vn';
    final workerUser = env['ODOO_TEST_USER'] ?? 'worker1@gmail.com';
    final workerPassword = env['ODOO_TEST_PASSWORD'] ?? '123';
    
    const adminUser = 'admin';
    const adminPassword = r'<),9853$6Ect';

    final sessionManager = OdooSessionManager.instance;

    Future<Map<String, bool>> checkAccessForUser(String username, String password) async {
      final results = <String, bool>{};
      
      try {
        await sessionManager.authenticate(
          serverUrl: url,
          database: db,
          username: username,
          password: password,
        );
      } catch (e) {
        print('Không thể đăng nhập tài khoản $username: $e');
        return results;
      }

      final modelsToCheck = {
        'fsm.order': ['id', 'name'],
        'product.product': ['id', 'name'],
        'hr.expense': ['name', 'total_amount'],
        'account.analytic.line': ['name', 'date'],
        'stock.move': ['product_id'],
      };

      for (final entry in modelsToCheck.entries) {
        final model = entry.key;
        final fields = entry.value;
        try {
          // Thử gọi fields_get - nếu thành công tức là model tồn tại và User có quyền truy cập thông tin trường
          await sessionManager.callKw(
            model: model,
            method: 'fields_get',
            args: [fields],
            kwargs: {'attributes': ['type']},
          );
          results[model] = true;
        } catch (e) {
          // Báo false nếu lỗi phân quyền (AccessError) hoặc model không tồn tại (KeyError/404)
          results[model] = false;
        }
      }

      await sessionManager.logout();
      return results;
    }

    test('Analyze permissions differences between ADMIN and WORKER', () async {
      print('\n=============================================================');
      print('BẮT ĐẦU PHÂN TÍCH QUYỀN TRUY CẬP HỆ THỐNG ODOO');
      print('=============================================================');

      print('\n[1/2] Kiểm tra quyền với tài khoản ADMIN...');
      final adminRights = await checkAccessForUser(adminUser, adminPassword);
      
      print('\n[2/2] Kiểm tra quyền với tài khoản WORKER ($workerUser)...');
      final workerRights = await checkAccessForUser(workerUser, workerPassword);

      print('\n=============================================================');
      print('KẾT QUẢ SO SÁNH QUYỀN TRUY CẬP (ACCESS RIGHTS):');
      print('=============================================================');
      
      final allModels = {
        'fsm.order': 'Đơn dịch vụ (Field Service Order)',
        'product.product': 'Sản phẩm/Vật tư (Product Product)',
        'hr.expense': 'Chi phí phát sinh (Expense)',
        'account.analytic.line': 'Bảng chấm công giờ (Timesheet)',
        'stock.move': 'Dịch chuyển kho (Stock Move)',
      };

      allModels.forEach((model, description) {
        final hasAdmin = adminRights[model] ?? false;
        final hasWorker = workerRights[model] ?? false;

        print('\n* Model: $model ($description)');
        if (!hasAdmin) {
          print('  -> TRẠNG THÁI: CHƯA CÀI ĐẶT MODULE trên Odoo server.');
          print('     (Cả Admin và Worker đều báo lỗi 404/KeyError)');
        } else {
          print('  -> TRẠNG THÁI: Đã cài đặt trên Odoo.');
          print('     - Admin:  [OK] Có quyền truy cập.');
          if (hasWorker) {
            print('     - Worker: [OK] Có quyền truy cập.');
          } else {
            print('     - Worker: [LỖI] KHÔNG CÓ QUYỀN TRUY CẬP (Access Denied / 404).');
            print('       ==> Cần gán thêm Access Group (Nhóm quyền) cho user này trên Odoo Web.');
          }
        }
      });
      print('\n=============================================================');
    });
  });
}
