#!/usr/bin/env bash

# Copyright (c) 2021-2026 PhantomDave ORG
# Author: PhantomDave
# License: MIT | https://github.com/PhantomDave/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Doezer/Questarr

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y \
  git \
  curl \
  build-essential \
  python3
msg_ok "Installed Dependencies"

NODE_VERSION="20" setup_nodejs
PG_VERSION="16" setup_postgresql
export PG_DB_NAME="questarr"
export PG_DB_USER="questarr_user"
setup_postgresql_db
import_local_ip

msg_info "Cloning Questarr Repository"
cd /opt
$STD git clone --depth 1 https://github.com/Doezer/Questarr.git questarr
cd questarr
msg_ok "Cloned Questarr"

msg_info "Installing Questarr Dependencies"
$STD npm ci
msg_ok "Installed Dependencies"

msg_info "Configuring Questarr"
cat <<EOF >/opt/questarr/.env
# Database Configuration
DATABASE_URL=postgresql://$PG_DB_USER:$PG_DB_PASS@localhost:5432/$PG_DB_NAME

# PostgreSQL Configuration (fallback if DATABASE_URL not set)
POSTGRES_USER=$PG_DB_USER
POSTGRES_PASSWORD=$PG_DB_PASS
POSTGRES_DB=$PG_DB_NAME
POSTGRES_HOST=localhost
POSTGRES_PORT=5432

# Server Configuration
PORT=5000
HOST=0.0.0.0
NODE_ENV=production

# JWT Configuration (IMPORTANT: Change this in production!)
JWT_SECRET=$(openssl rand -base64 32)

# IGDB API Credentials (Required for game discovery)
# Get these from: https://dev.twitch.tv/console
IGDB_CLIENT_ID=
IGDB_CLIENT_SECRET=

# CORS Configuration (optional)
# ALLOWED_ORIGINS=http://localhost:5000

# Logging
LOG_LEVEL=info
EOF
chmod 600 /opt/questarr/.env
msg_ok "Configured Questarr"

msg_info "Building Questarr"
$STD npm run build
msg_ok "Built Questarr"

msg_info "Running Database Migrations"
export DATABASE_URL="postgresql://${PG_DB_USER}:${PG_DB_PASS}@localhost:5432/${PG_DB_NAME}"
$STD npm run db:migrate
msg_ok "Database Migrations Complete"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/questarr.service
[Unit]
Description=Questarr - Video Game Collection Manager
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/opt/questarr
Environment=NODE_ENV=production
EnvironmentFile=/opt/questarr/.env
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=questarr

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/questarr

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now questarr
msg_ok "Created Service"

msg_info "Setting up MOTD"
cat <<EOF >/etc/update-motd.d/99-questarr
#!/bin/bash
echo ""
echo "  ___                  _                   "
echo " / _ \ _   _  ___  ___| |_ __ _ _ __ _ __ "
echo "| | | | | | |/ _ \/ __| __/ _\` | '__| '__|"
echo "| |_| | |_| |  __/\__ \ || (_| | |  | |   "
echo " \__\_\\\\__,_|\___||___/\__\__,_|_|  |_|   "
echo ""
echo "Questarr - Video Game Collection Manager"
echo "----------------------------------------"
echo "Web Interface: http://${LOCAL_IP}:5000"
echo ""
echo "Configuration:"
echo "  Config file: /opt/questarr/.env"
echo "  Database: PostgreSQL ($PG_DB_NAME)"
echo ""
echo "Service Management:"
echo "  Start:   systemctl start questarr"
echo "  Stop:    systemctl stop questarr"
echo "  Status:  systemctl status questarr"
echo "  Logs:    journalctl -u questarr -f"
echo ""
echo "IMPORTANT: Configure IGDB API credentials in /opt/questarr/.env"
echo "Get credentials at: https://dev.twitch.tv/console"
echo ""
EOF
chmod +x /etc/update-motd.d/99-questarr

motd_ssh
customize
cleanup_lxc
