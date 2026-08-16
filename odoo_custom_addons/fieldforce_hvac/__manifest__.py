{
    'name': 'Fieldforce HVAC',
    'version': '1.0',
    'summary': 'Field Service Management for HVAC companies',
    'description': 'Manage recurring maintenance, work orders, and more for HVAC businesses.',
    'author': 'Your Company',
    'category': 'Services',
    'depends': ['base', 'fieldservice'],
    'data': [
        'security/security.xml',
        'security/ir.model.access.csv',
        'data/cron.xml',
    ],
    'installable': True,
    'application': True,
}