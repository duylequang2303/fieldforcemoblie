import 'package:odoo_rpc/odoo_rpc.dart';

void main() async {
  final client = OdooClient('https://demo002.crmhub.vn');
  
  try {
    final dbName = 'demo002.crmhub.vn';
    print('Authenticating with database: $dbName');
    
    final session = await client.authenticate(dbName, 'admin', '<),9853\$6Ect');
    final userId = session.userId;
    print('Authenticated! User ID: $userId');
    
    print('Checking James (person_id = 4) in fsm.person...');
    final james = await client.callKw({
      'model': 'fsm.person',
      'method': 'search_read',
      'args': [[['id', '=', 4]]],
      'kwargs': {
        'fields': ['id', 'name', 'user_id', 'partner_id'],
        'limit': 1,
      },
    });
    print('James Record: $james');
    
    if ((james as List).isNotEmpty) {
      final partnerId = (james[0]['partner_id'] as List)[0];
      print('Checking partner_id = $partnerId in res.partner for user_ids...');
      final partner = await client.callKw({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [[['id', '=', partnerId]]],
        'kwargs': {
          'fields': ['id', 'name', 'user_ids'],
          'limit': 1,
        },
      });
      print('Partner Record: $partner');
    }

    print('Testing old domain: [[\'person_id.user_id\', \'=\', $userId]]');
    final ordersOld = await client.callKw({
      'model': 'fsm.order',
      'method': 'search_read',
      'args': [[['person_id.user_id', '=', userId]]],
      'kwargs': {
        'fields': ['id', 'name', 'person_id'],
        'limit': 5,
      },
    });
    print('Old Domain Result: $ordersOld');
    
  } catch (e) {
    print('Error: $e');
  }
}
