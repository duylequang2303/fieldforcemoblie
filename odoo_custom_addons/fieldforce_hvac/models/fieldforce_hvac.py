import json
import logging
import requests
import uuid
from odoo import models, fields, api, _
from odoo.exceptions import AccessError

_logger = logging.getLogger(__name__)

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
        if vals.get('product_id') and 'unit_price' not in vals:
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
    tracking_id = fields.Char(string='Tracking ID', index=True, copy=False)
    provider_message_id = fields.Char(string='Provider Delivery ID', index=True, copy=False)
    last_attempt_date = fields.Datetime(string='Last Attempt')

    @api.model_create_multi
    def create(self, vals_list):
        # Stable outbound identifier for idempotent retries across queue runs
        for vals in vals_list:
            if not vals.get('tracking_id'):
                vals['tracking_id'] = 'hvac-zns-%s' % uuid.uuid4().hex
        return super(FieldForceHVACZnsMessage, self).create(vals_list)

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
                if self._reconcile_zns_message(msg):
                    msg.write({'state': 'sent', 'error_msg': False})
                    continue
                self._send_zns_api_call(msg)
                msg.write({'state': 'sent', 'error_msg': False})
            except Exception as e:
                msg.write({
                    'retry_count': msg.retry_count + 1,
                    'error_msg': str(e),
                    'last_attempt_date': fields.Datetime.now(),
                    'state': 'failed' if msg.retry_count >= 2 else 'pending'
                })

    def _reconcile_zns_message(self, msg):
        # Before retrying, check whether a prior indeterminate attempt was
        # actually delivered so a timeout must not trigger a duplicate send.
        if not msg.provider_message_id:
            return False
        access_token = self.env['ir.config_parameter'].sudo().get_param('zalo.oa_access_token')
        if not access_token:
            return False
        try:
            response = requests.get(
                'https://business.openapi.zalo.me/message/status',
                params={'message_id': msg.provider_message_id},
                headers={'access_token': access_token},
                timeout=15
            )
            response.raise_for_status()
            res_data = response.json()
            if res_data.get('error') != 0:
                _logger.error("Zalo status lookup error: %s", res_data.get('message'))
                return False
            status = res_data.get('data', {}).get('status')
            # Zalo status: 1 = delivered, 0 = pending, -1 = failed/sendable again
            return status == 1
        except Exception as e:
            _logger.error("Failed to reconcile ZNS delivery for %s: %s", msg.tracking_id, e)
            return False

    def _send_zns_api_call(self, msg):
        # Actual HTTP post payload to Zalo ZNS endpoint with access token lookup
        access_token = self.env['ir.config_parameter'].sudo().get_param('zalo.oa_access_token')
        if not access_token:
            raise ValueError("Zalo OA Access Token isn't configured in settings.")

        headers = {
            'Content-Type': 'application/json',
            'access_token': access_token,
        }

        template_data = {}
        if msg.message_content:
            try:
                template_data = json.loads(msg.message_content)
            except Exception:
                template_data = {'content': msg.message_content}

        payload = {
            'phone': msg.phone,
            'template_id': msg.template_id,
            'template_data': template_data,
            'tracking_id': msg.tracking_id,
        }

        try:
            response = requests.post(
                'https://business.openapi.zalo.me/message/template',
                headers=headers,
                json=payload,
                timeout=15
            )
            response.raise_for_status()
            res_data = response.json()
            if res_data.get('error') != 0:
                raise ValueError(f"Zalo ZNS API Error: {res_data.get('message')} (code: {res_data.get('error')})")
            msg.write({
                'provider_message_id': res_data.get('data', {}).get('message_id'),
                'last_attempt_date': fields.Datetime.now(),
            })
        except requests.exceptions.RequestException as e:
            raise ValueError(f"HTTP Connection to Zalo API failed: {e}") from e

    @api.model
    def refresh_zalo_tokens(self):
        # Retrieve Refresh Token from config parameters and invoke refresh endpoint to fetch fresh access token
        refresh_token = self.env['ir.config_parameter'].sudo().get_param('zalo.oa_refresh_token')
        app_id = self.env['ir.config_parameter'].sudo().get_param('zalo.app_id')
        secret_key = self.env['ir.config_parameter'].sudo().get_param('zalo.secret_key')
        
        if not refresh_token:
            return
            
        headers = {
            'Content-Type': 'application/x-www-form-urlencoded',
            'secret_key': secret_key or '',
        }
        data = {
            'refresh_token': refresh_token,
            'app_id': app_id or '',
            'grant_type': 'refresh_token',
        }
        
        try:
            response = requests.post(
                'https://oauth.zaloapp.com/v4/oa/access_token',
                headers=headers,
                data=data,
                timeout=15
            )
            response.raise_for_status()
            res_data = response.json()
            if 'access_token' in res_data:
                self.env['ir.config_parameter'].sudo().set_param('zalo.oa_access_token', res_data['access_token'])
                if 'refresh_token' in res_data:
                    self.env['ir.config_parameter'].sudo().set_param('zalo.oa_refresh_token', res_data['refresh_token'])
            else:
                _logger.error(f"Zalo OAuth token refresh response error: {res_data}")
                return False
        except Exception as e:
            _logger.error("Failed to refresh Zalo OA access token: %s", e)
            self.env['x_hvac.zns_message'].sudo().create({
                'partner_id': self.env.user.partner_id.id,
                'phone': '0000000000',
                'template_id': 'refresh_token_failure',
                'message_content': f"Error details: {str(e)}",
                'state': 'failed',
                'error_msg': f"Failed to refresh access token: {str(e)}"
            })
            return False


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

    @api.depends('phone')
    def _compute_masked_phone(self):
        for partner in self:
            if partner.phone:
                clean_phone = ''.join(c for c in partner.phone if c.isalnum() or c == '+')
                if len(clean_phone) >= 7:
                    mask_length = len(clean_phone) - 3
                    partner.x_masked_phone = f"{'*' * mask_length}{clean_phone[-3:]}"
                else:
                    partner.x_masked_phone = clean_phone
            else:
                partner.x_masked_phone = False

    def get_unmasked_phone(self):
        """Method to fetch original phone. Log entry is created for auditing purposes."""
        self.ensure_one()
        if not self.env.user.has_group('fieldforce_hvac.group_hvac_user'):
            raise AccessError(_("You do not have authorization to view customer phone numbers."))
        self.env['x_hvac.phone_audit_log'].sudo().create({
            'partner_id': self.id,
            'user_id': self.env.uid
        })
        return self.phone