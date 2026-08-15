import 'package:odoo_rpc/odoo_rpc.dart';

const serverUrl = 'http://demo002.crmhub.vn:8069';
const database = 'demo002';
const username = 'admin';
const password = 'c)baL[0F0-qp]';
const workerEmail = 'worker1@gmail.com';

Future<void> main() async {
  final client = OdooClient(serverUrl);

  try {
    print('Authenticating...');
    final session = await client.authenticate(database, username, password);
    print('Authenticated as user_id=${session.userId}');

    // 1. Tìm worker theo email
    int? personId;
    String? personName;

    // Thử res.users
    try {
      final users = await client.callKw({
        'model': 'res.users',
        'method': 'search_read',
        'args': [
          [
            ['login', '=', workerEmail],
            ['active', '=', true],
          ]
        ],
        'kwargs': {'fields': ['id', 'name', 'login'], 'limit': 1},
      });
      if (users is List && users.isNotEmpty) {
        personId = users.first['id'] as int;
        personName = users.first['name'] as String?;
        print('Found res.users: id=$personId, name=$personName');
      }
    } catch (e) {
      print('res.users search failed: $e');
    }

    // Thử res.partner
    if (personId == null) {
      try {
        final partners = await client.callKw({
          'model': 'res.partner',
          'method': 'search_read',
          'args': [
            [
              ['email', '=', workerEmail],
              ['active', '=', true],
            ]
          ],
          'kwargs': {'fields': ['id', 'name'], 'limit': 1},
        });
        if (partners is List && partners.isNotEmpty) {
          personId = partners.first['id'] as int;
          personName = partners.first['name'] as String?;
          print('Found res.partner: id=$personId, name=$personName');
        }
      } catch (e) {
        print('res.partner search failed: $e');
      }
    }

    // Thử hr.employee
    if (personId == null) {
      try {
        final employees = await client.callKw({
          'model': 'hr.employee',
          'method': 'search_read',
          'args': [
            [
              ['work_email', '=', workerEmail],
              ['active', '=', true],
            ]
          ],
          'kwargs': {'fields': ['id', 'name'], 'limit': 1},
        });
        if (employees is List && employees.isNotEmpty) {
          personId = employees.first['id'] as int;
          personName = employees.first['name'] as String?;
          print('Found hr.employee: id=$personId, name=$personName');
        }
      } catch (e) {
        print('hr.employee search failed: $e');
      }
    }

    // Thử fsm.person
    if (personId == null) {
      try {
        final persons = await client.callKw({
          'model': 'fsm.person',
          'method': 'search_read',
          'args': [
            [
              ['email', '=', workerEmail],
              ['active', '=', true],
            ]
          ],
          'kwargs': {'fields': ['id', 'name'], 'limit': 1},
        });
        if (persons is List && persons.isNotEmpty) {
          personId = persons.first['id'] as int;
          personName = persons.first['name'] as String?;
          print('Found fsm.person: id=$personId, name=$personName');
        }
      } catch (e) {
        print('fsm.person search failed: $e');
      }
    }

    if (personId == null) {
    print('ERROR: Cannot find worker with email $workerEmail');
    client.close();
    return;
    }

    // 2. Tìm location mẫu
    int? locationId;
    try {
      final locations = await client.callKw({
        'model': 'fsm.location',
        'method': 'search_read',
        'args': [
          ['&', ['active', '=', true], '|', ['partner_id', '!=', false], ['name', 'ilike', 'test']]
        ],
        'kwargs': {'fields': ['id', 'name', 'partner_id'], 'limit': 1},
      });
      if (locations is List && locations.isNotEmpty) {
        locationId = locations.first['id'] as int;
        print('Using location: id=$locationId, name=${locations.first['name']}');
      }
    } catch (e) {
      print('fsm.location search failed: $e');
    }

    if (locationId == null) {
      print('WARNING: No fsm.location found, creating order without location');
    }

    // 3. Lấy stage_id mặc định (draft)
    int? stageId;
    try {
      final stages = await client.callKw({
        'model': 'fsm.stage',
        'method': 'search_read',
        'args': [
          [['name', '=', 'Draft']]
        ],
        'kwargs': {'fields': ['id', 'name'], 'limit': 1},
      });
      if (stages is List && stages.isNotEmpty) {
        stageId = stages.first['id'] as int;
        print('Using stage: id=$stageId, name=${stages.first['name']}');
      }
    } catch (e) {
      print('fsm.stage search failed: $e');
    }

    // 4. Tạo order
    final now = DateTime.now();
    final scheduledStart = now.add(const Duration(days: 1));
    final scheduledEnd = scheduledStart.add(const Duration(hours: 2));

    final orderData = <String, dynamic>{
      'name': 'TEST ORDER - Worker Assignment - ${now.toIso8601String().split('T').first}',
      'description': 'Đơn hàng test để gán cho worker $workerEmail',
      'scheduled_date_start': scheduledStart.toUtc().toIso8601String(),
      'scheduled_date_end': scheduledEnd.toUtc().toIso8601String(),
      'priority': '0',
      'person_id': personId,
    };

    if (stageId != null) {
      orderData['stage_id'] = stageId;
    }
    if (locationId != null) {
      orderData['location_id'] = locationId;
    }

    print('Creating order...');
    final orderId = await client.callKw({
      'model': 'fsm.order',
      'method': 'create',
      'args': [orderData],
    });

    print('SUCCESS: Created fsm.order id=$orderId');
    print('Assigned to: $personName (id=$personId)');

    client.close();
  } catch (e) {
    print('ERROR: $e');
    client.close();
  }
}
