import xmlrpc.client

url = 'https://demo002.crmhub.vn'
db = 'demo002.crmhub.vn'
username = 'admin'
password = 'admin123'

common = xmlrpc.client.ServerProxy('{}/xmlrpc/2/common'.format(url))
uid = common.authenticate(db, username, password, {})
print('uid=', uid)

models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))

users = models.execute_kw(db, uid, password, 'res.users', 'search_read', [[['login', '=', 'worker1@gmail.com'], ['active', '=', True]]], {'fields': ['id', 'name'], 'limit': 1})
print('users=', users)

employees = models.execute_kw(db, uid, password, 'hr.employee', 'search_read', [[['work_email', '=', 'worker1@gmail.com'], ['active', '=', True]]], {'fields': ['id', 'name'], 'limit': 1})
print('employees=', employees)

stages = models.execute_kw(db, uid, password, 'fsm.stage', 'search_read', [[['name', '=', 'Draft']]], {'fields': ['id', 'name'], 'limit': 1})
print('stages=', stages)

locations = models.execute_kw(db, uid, password, 'fsm.location', 'search_read', [[]], {'fields': ['id', 'name'], 'limit': 5})
print('locations=', locations)

# Read an existing order to see actual fields and constraints
existing_orders = models.execute_kw(db, uid, password, 'fsm.order', 'search_read', [[]], {'fields': ['id', 'name', 'person_id', 'stage_id', 'location_id', 'scheduled_date_start', 'scheduled_date_end'], 'limit': 1})
print('existing_orders=', existing_orders)

# Create order
import datetime
now = datetime.datetime.now()
scheduled_start = now + datetime.timedelta(days=1)
scheduled_end = scheduled_start + datetime.timedelta(hours=2)

person_id = employees[0]['id'] if employees else users[0]['id'] if users else None
stage_id = stages[0]['id'] if stages else None
location_id = locations[0]['id'] if locations else None

order_data = {
    'name': 'TEST ORDER - Worker1 - {}'.format(now.strftime('%Y-%m-%d')),
    'description': 'Don hang test giao cho worker1@gmail.com',
    'scheduled_date_start': scheduled_start.strftime('%Y-%m-%d %H:%M:%S'),
    'scheduled_date_end': scheduled_end.strftime('%Y-%m-%d %H:%M:%S'),
    'priority': '0',
    'employee_id': person_id,
}

if stage_id:
    order_data['stage_id'] = stage_id
if location_id:
    order_data['location_id'] = location_id

print('Creating order with data:', order_data)
order_id = models.execute_kw(db, uid, password, 'fsm.order', 'create', [order_data])
print('Created order id=', order_id)
