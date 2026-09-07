#!/bin/bash
set -euo pipefail

# Level 3 Deployment Script
APP_USER="l3app"
APP_ROOT="/var/www/level3-logistics"
PORT=5000

[ "${EUID}" -eq 0 ] || { echo "Run as root: sudo ./deploy.sh"; exit 1; }

apt-get update
apt-get install -y python3 python3-pip python3-venv curl

id "${APP_USER}" >/dev/null 2>&1 || useradd -m -s /bin/bash "${APP_USER}"

install -d -m 0755 -o root -g root "${APP_ROOT}"
install -d -m 0755 -o "${APP_USER}" -g "${APP_USER}" "${APP_ROOT}/uploads"
install -d -m 0777 -o "${APP_USER}" -g "${APP_USER}" "${APP_ROOT}/templates"

# Copy application files
cp -r webapp/* "${APP_ROOT}/"

# Set permissions
chown -R root:root "${APP_ROOT}"
# The templates directory needs to be writable by the app user to allow the SSTI overwrite
chown -R "${APP_USER}:${APP_USER}" "${APP_ROOT}/templates"
chown -R "${APP_USER}:${APP_USER}" "${APP_ROOT}/uploads"

# config.json contains FLAG3_03
echo '{"api_key": "FLAG3_03{c0nf1g_r34d_v14_lf1}"}' > "${APP_ROOT}/config.json"
chown root:root "${APP_ROOT}/config.json"
chmod 0644 "${APP_ROOT}/config.json" # Readable by app user

# Ensure test.txt is writable by the app user
touch "${APP_ROOT}/test.txt"
chown "${APP_USER}:${APP_USER}" "${APP_ROOT}/test.txt"
chmod 0644 "${APP_ROOT}/test.txt"

# Final flag in l3app's home directory
echo 'FLAG3_08{l0w_pr1v_sh3ll_4ch13v3d}' > "/home/${APP_USER}/flag.txt"
chown "${APP_USER}:${APP_USER}" "/home/${APP_USER}/flag.txt"
chmod 0600 "/home/${APP_USER}/flag.txt"

# Set up python venv
python3 -m venv "${APP_ROOT}/venv"
"${APP_ROOT}/venv/bin/pip" install -r "${APP_ROOT}/requirements.txt"

# Create systemd service
cat > /etc/systemd/system/level3-logistics.service <<EOF
[Unit]
Description=LPH Level 3 Logistics Portal
After=network.target

[Service]
User=${APP_USER}
Group=${APP_USER}
WorkingDirectory=${APP_ROOT}
Environment="PATH=${APP_ROOT}/venv/bin"
Environment="FLAG3_07=FLAG3_07{sst1_r3c0v3ry_v14_3nv}"
ExecStart=${APP_ROOT}/venv/bin/python app.py

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now level3-logistics.service

systemctl is-active --quiet level3-logistics.service || { systemctl status level3-logistics.service --no-pager; exit 1; }

echo "Level 3 deployment complete. Run: sudo ./verify_level3.sh"
