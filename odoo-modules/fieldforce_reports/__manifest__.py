{
    'name': 'Fieldforce Revenue Reports',
    'summary': 'Pivot/Graph views for FSM order revenue by service type, worker, and time',
    'version': '19.0.1.0.0',
    'category': 'Field Service',
    'author': 'Fieldforce',
    'depends': ['fieldservice', 'fieldforce_payment'],
    'data': [
        'security/ir.model.access.csv',
        'views/fsm_order_report_views.xml',
        'views/fsm_order_report_menu.xml',
    ],
    'installable': True,
    'application': False,
}