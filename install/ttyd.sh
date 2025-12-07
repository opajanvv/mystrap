#!/bin/sh
# Post-install script for ttyd
# Sets up ttyd as a systemd service running on port 4711
# Creates ttyd user and configures firewall

set -eu

# Source helpers for logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../scripts/helpers.sh" 2>/dev/null || . "$(dirname "$SCRIPT_DIR")/scripts/helpers.sh"

# Check if we can use sudo without password
if ! sudo -n true 2>/dev/null; then
    warn "Cannot configure ttyd service without sudo access (run manually or configure passwordless sudo)"
    exit 0
fi

# Create ttyd user if it doesn't exist
if ! id ttyd >/dev/null 2>&1; then
    log "Creating ttyd user..."
    sudo useradd -r -s /usr/bin/nologin -d /nonexistent -c "ttyd service user" ttyd
else
    log "User ttyd already exists"
fi

# Create systemd service file
SERVICE_FILE="/etc/systemd/system/ttyd.service"
if [ ! -f "$SERVICE_FILE" ]; then
    log "Creating systemd service file..."
    sudo tee "$SERVICE_FILE" >/dev/null <<'EOF'
[Unit]
Description=ttyd - Share your terminal over the web
Documentation=https://github.com/tsl0922/ttyd
After=network.target

[Service]
Type=simple
User=ttyd
ExecStart=/usr/bin/ttyd -p 4711 -W /bin/bash
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
    log "Systemd service file created"
else
    log "Systemd service file already exists"
fi

# Reload systemd daemon
log "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable service if not already enabled
if ! systemctl is-enabled ttyd.service >/dev/null 2>&1; then
    log "Enabling ttyd.service..."
    sudo systemctl enable ttyd.service
else
    log "ttyd.service already enabled"
fi

# Start service if not already running
if ! systemctl is-active ttyd.service >/dev/null 2>&1; then
    log "Starting ttyd.service..."
    sudo systemctl start ttyd.service
else
    log "ttyd.service already running"
fi

# Configure firewall (if ufw is available)
if has_cmd ufw; then
    # Check if ufw is active
    if sudo ufw status | grep -q "Status: active"; then
        # Check if port is already open
        if ! sudo ufw status | grep -q "4711/tcp"; then
            log "Opening port 4711/tcp in firewall..."
            sudo ufw allow 4711/tcp
        else
            log "Port 4711/tcp already open in firewall"
        fi
    else
        log "ufw not active, skipping firewall configuration"
    fi
else
    log "ufw not installed, skipping firewall configuration"
fi

log "ttyd service setup complete"
log "Access ttyd at: http://localhost:4711"
