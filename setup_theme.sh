#!/bin/bash
# ==============================================================================
# Odoo 19 - Quick Theme Customization Script
# Author: DevOps & Odoo Expert
# Description: Automates creation and installation of the 'my_quick_theme' module.
# ==============================================================================

set -e

echo "================================================================="
echo "Starting Odoo Quick Theme Setup..."
echo "================================================================="

# 1. Locate odoo.conf and identify addons_path
echo "Step 1: Locating odoo.conf..."
ODOO_CONF=$(find / -name "odoo.conf" 2>/dev/null | head -n 1)

if [ -z "$ODOO_CONF" ]; then
    echo "ERROR: odoo.conf not found automatically on this system."
    echo "Searching in common locations..."
    COMMON_CONFS=(
        "/etc/odoo/odoo.conf"
        "/etc/odoo-server.conf"
        "/etc/odoo.conf"
        "/odoo/odoo-server.conf"
    )
    for conf in "${COMMON_CONFS[@]}"; do
        if [ -f "$conf" ]; then
            ODOO_CONF="$conf"
            break
        fi
    done
fi

if [ -z "$ODOO_CONF" ] || [ ! -f "$ODOO_CONF" ]; then
    echo "ERROR: Could not find odoo.conf. Please enter the path to odoo.conf manually,"
    echo "or ensure you run this script on the target production server."
    exit 1
fi

echo "Found odoo.conf at: $ODOO_CONF"

# Extract addons_path
ADDONS_PATH_LINE=$(grep -E "^addons_path" "$ODOO_CONF" | head -n 1)
if [ -z "$ADDONS_PATH_LINE" ]; then
    echo "ERROR: Could not find 'addons_path' inside $ODOO_CONF"
    exit 1
fi

echo "Found addons_path line: $ADDONS_PATH_LINE"

# Parse addons paths (comma separated)
# Normally we want to use the last path (usually the customaddons/custom folder)
IFS=',' read -ra ADDR <<< "${ADDONS_PATH_LINE#*=}"
CUSTOM_ADDONS_DIR=""

for path in "${ADDR[@]}"; do
    # Trim leading/trailing whitespace
    trimmed_path=$(echo "$path" | xargs)
    if [[ "$trimmed_path" == *"custom"* || "$trimmed_path" == *"extra"* ]]; then
        CUSTOM_ADDONS_DIR="$trimmed_path"
        break
    fi
done

# If no custom/extra folder identified, use the last one in the list
if [ -z "$CUSTOM_ADDONS_DIR" ] && [ ${#ADDR[@]} -gt 0 ]; then
    CUSTOM_ADDONS_DIR=$(echo "${ADDR[-1]}" | xargs)
fi

if [ -z "$CUSTOM_ADDONS_DIR" ] || [ ! -d "$CUSTOM_ADDONS_DIR" ]; then
    echo "Warning: Target custom addons directory parsed from config does not exist or is empty. Creating: $CUSTOM_ADDONS_DIR"
    mkdir -p "$CUSTOM_ADDONS_DIR"
fi

echo "Target Custom Addons Directory: $CUSTOM_ADDONS_DIR"

# 2. Create my_quick_theme module directory structure
MODULE_DIR="$CUSTOM_ADDONS_DIR/my_quick_theme"
echo "Step 2: Creating module directory structure at: $MODULE_DIR"
mkdir -p "$MODULE_DIR/static/src/css"
mkdir -p "$MODULE_DIR/views"

# 3. Create __manifest__.py
echo "Step 3: Creating __manifest__.py..."
cat << 'EOF' > "$MODULE_DIR/__manifest__.py"
# -*- coding: utf-8 -*-
{
    'name': 'My Quick Theme',
    'version': '1.0',
    'summary': 'Custom Green Header Theme for Odoo 19 Community',
    'category': 'Theme/Backend',
    'depends': ['web'],
    'data': [
        'views/assets.xml',
    ],
    'installable': True,
    'auto_install': False,
    'license': 'LGPL-3',
}
EOF

# 4. Create static/src/css/theme.css
echo "Step 4: Creating theme.css..."
cat << 'EOF' > "$MODULE_DIR/static/src/css/theme.css"
.o_main_navbar {
    background-color: #2ecc71 !important;
    border-bottom: 2px solid #27ae60 !important;
}
.btn-primary {
    background-color: #2ecc71 !important;
    border-color: #27ae60 !important;
}
EOF

# 5. Create views/assets.xml
echo "Step 5: Creating views/assets.xml..."
cat << 'EOF' > "$MODULE_DIR/views/assets.xml"
<?xml version="1.0" encoding="utf-8"?>
<odoo>
    <template id="assets_backend" inherit_id="web.assets_backend" name="My Quick Theme Assets">
        <xpath expr="." position="inside">
            <link rel="stylesheet" href="/my_quick_theme/static/src/css/theme.css"/>
        </xpath>
    </template>
</odoo>
EOF

# 6. Set correct ownership and permissions
echo "Step 6: Setting ownership & permissions..."
if id "odoo" &>/dev/null; then
    chown -R odoo:odoo "$MODULE_DIR"
    echo "Successfully set ownership to odoo:odoo."
else
    echo "User 'odoo' does not exist. Skipping chown..."
fi
chmod -R 755 "$MODULE_DIR"

# 7. Restart Odoo service
echo "Step 7: Restarting Odoo service..."
if systemctl list-units --type=service | grep -q "odoo"; then
    systemctl restart odoo
    echo "Odoo service restarted via systemctl."
elif service --status-all 2>/dev/null | grep -q "odoo"; then
    service odoo restart
    echo "Odoo service restarted via service command."
else
    echo "WARNING: Could not identify Odoo service name. Please restart Odoo manually."
fi

echo "================================================================="
echo "Setup script completed successfully!"
echo "Please proceed with the final steps on the Odoo Web Interface."
echo "================================================================="
