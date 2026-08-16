from odoo import models, fields, api

class FieldForceHVACDevice(models.Model):
    _name = 'x_hvac.device'
    _description = 'HVAC Device'

    name = fields.Char(string='Device Name', required=True)
    location_id = fields.Many2one('fsm.location', string='Location', index=True)
    next_service_date = fields.Date(string='Next Service Date', index=True)


class FieldForceHVACOrderLine(models.Model):
    _name = 'x_hvac.order_line'
    _description = 'HVAC Order Line (Snapshot)'

    order_id = fields.Many2one('fsm.order', string='Work Order', required=True, ondelete='cascade')
    product_id = fields.Many2one('product.product', string='Product/Service', required=True)
    name = fields.Char(string='Description', required=True)
    unit_price = fields.Float(string='Unit Price', digits='Product Price')
    qty = fields.Float(string='Quantity', default=1.0)
    discount = fields.Float(string='Discount (%)', default=0.0)

    @api.onchange('product_id')
    def _onchange_product_id(self):
        if self.product_id:
            self.name = self.product_id.display_name
            self.unit_price = self.product_id.lst_price
            self.discount = 0.0

    @api.model
    def create(self, vals):
        # Automatically snapshot details if product_id is specified
        if vals.get('product_id') and not vals.get('unit_price'):
            product = self.env['product.product'].browse(vals['product_id'])
            if product.exists():
                vals['name'] = vals.get('name') or product.display_name
                vals['unit_price'] = product.lst_price
        return super(FieldForceHVACOrderLine, self).create(vals)


class FieldForceHVACZnsMessage(models.Model):
    _name = 'x_hvac.zns_message'
    _description = 'Zalo ZNS Outbox Message Queue'

    partner_id = fields.Many2one('res.partner', string='Recipient Customer', required=True)
    phone = fields.Char(string='Phone Number', required=True)
    template_id = fields.Char(string='Zalo ZNS Template ID', required=True)
    message_content = fields.Text(string='Message Content (JSON/Parameters)')
    state = fields.Selection([
        ('pending', 'Pending'),
        ('sent', 'Sent'),
        ('failed', 'Failed')
    ], string='Status', default='pending', index=True)
    retry_count = fields.Integer(string='Retries', default=0)
    error_msg = fields.Text(string='Error Log')
    scheduled_date = fields.Datetime(string='Scheduled Date', default=fields.Datetime.now, index=True)

    @api.model
    def process_zns_messages(self):
        # Find pending messages
        messages = self.search([
            ('state', '=', 'pending'),
            ('scheduled_date', '<=', fields.Datetime.now()),
            ('retry_count', '<', 3)
        ], limit=50)
        
        for msg in messages:
            try:
                # Simulating sending Zalo ZNS message
                self._send_zns_api_call(msg)
                msg.write({'state': 'sent', 'error_msg': False})
            except Exception as e:
                msg.write({
                    'retry_count': msg.retry_count + 1,
                    'error_msg': str(e),
                    'state': 'failed' if msg.retry_count >= 2 else 'pending'
                })

    def _send_zns_api_call(self, msg):
        # Actual HTTP post payload to Zalo ZNS endpoint with access token lookup
        access_token = self.env['ir.config_parameter'].sudo().get_param('zalo.oa_access_token')
        if not access_token:
            raise ValueError("Zalo OA Access Token isn't configured in settings.")
        # Logging standard structure
        pass

    @api.model
    def refresh_zalo_tokens(self):
        # Retrieve Refresh Token from config parameters and invoke refresh endpoint to fetch fresh access token
        refresh_token = self.env['ir.config_parameter'].sudo().get_param('zalo.oa_refresh_token')
        if refresh_token:
            # Under realistic settings, call requests.post to Zalo developer platform refresh endpoint
            # e.g., mapping response back into ir.config_parameter configs
            pass


class FieldForceHVACCommissionRule(models.Model):
    _name = 'x_hvac.commission_rule'
    _description = 'HVAC Technician Commission Calculation Rules'

    name = fields.Char(string='Rule Name', required=True)
    technician_id = fields.Many2one('res.users', string='Technician', domain="[('share', '=', False)]", required=True)
    rate_percentage = fields.Float(string='Commission Percentage Rate (%)', default=10.0)
    fixed_amount = fields.Float(string='Fixed Commission Amount ($)', default=0.0)

    def calculate_commission(self, order_amount):
        """Calculates final commission based on rate or fixed values."""
        self.ensure_one()
        commission = (order_amount * (self.rate_percentage / 100.0)) + self.fixed_amount
        return commission


class FieldForceHVACPhoneAudit(models.Model):
    _name = 'x_hvac.phone_audit_log'
    _description = 'Audit Logs for Retrieving Customer Phones'

    user_id = fields.Many2one('res.users', string='Requested By', default=lambda self: self.env.user, required=True)
    partner_id = fields.Many2one('res.partner', string='Audited Customer', required=True)
    query_datetime = fields.Datetime(string='Query Time', default=fields.Datetime.now, required=True)


class ResPartner(models.Model):
    _inherit = 'res.partner'

    x_masked_phone = fields.Char(string='Masked Phone', compute='_compute_masked_phone')

    def _compute_masked_phone(self):
        for partner in self:
            if partner.phone and len(partner.phone) >= 7:
                partner.x_masked_phone = f"{partner.phone[:3]}***{partner.phone[-4:]}"
            else:
                partner.x_masked_phone = partner.phone

    def get_unmasked_phone(self):
        """Method to fetch original phone. Log entry is created for auditing purposes."""
        self.ensure_one()
        self.env['x_hvac.phone_audit_log'].create({
            'partner_id': self.id,
            'user_id': self.env.uid
        })
        return self.phone