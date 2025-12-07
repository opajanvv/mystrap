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

# Create or update ttyd user
if ! id ttyd >/dev/null 2>&1; then
    log "Creating ttyd user..."
    sudo useradd -r -s /bin/bash -m -d /home/ttyd -c "ttyd service user" ttyd
    # Lock the account - no password login
    sudo passwd -l ttyd
else
    log "User ttyd already exists, updating configuration..."
    # Update home directory and shell
    sudo usermod -d /home/ttyd -s /bin/bash ttyd
    # Ensure password is locked
    sudo passwd -l ttyd 2>/dev/null || true
fi

# Ensure home directory exists and has correct ownership
if [ ! -d /home/ttyd ]; then
    log "Creating home directory for ttyd user..."
    sudo mkdir -p /home/ttyd
    sudo chown ttyd:ttyd /home/ttyd
    sudo chmod 700 /home/ttyd
fi

# Create restricted .bashrc for ttyd user
TTYD_BASHRC="/home/ttyd/.bashrc"
if [ ! -f "$TTYD_BASHRC" ]; then
    log "Creating restricted .bashrc for ttyd user..."
    sudo tee "$TTYD_BASHRC" >/dev/null <<'EOF'
# Restricted shell for ttyd user
# Users must authenticate to gain access

echo "=========================================="
echo "ttyd Terminal - Restricted Access"
echo "=========================================="
echo ""
echo "This is a restricted shell with minimal permissions."
echo "To access your account, use: sudo -u <username> -i"
echo ""
echo "=========================================="

# Minimal PATH
export PATH=/usr/bin:/bin

# Remove dangerous commands from environment
unset HISTFILE
EOF
    sudo chown ttyd:ttyd "$TTYD_BASHRC"
else
    log "Restricted .bashrc already exists"
fi

# Create/update systemd service file
SERVICE_FILE="/etc/systemd/system/ttyd.service"
SERVICE_CONTENT='[Unit]
Description=ttyd - Share your terminal over the web
Documentation=https://github.com/tsl0922/ttyd
After=network.target

[Service]
Type=simple
User=ttyd
Group=ttyd
ExecStart=/usr/bin/ttyd -p 4711 -W /bin/bash
Restart=on-failure
RestartSec=5s

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/home/ttyd
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictRealtime=true
RestrictNamespaces=true
RestrictSUIDSGID=true

[Install]
WantedBy=multi-user.target'

# Check if service file needs updating
NEEDS_UPDATE=false
if [ ! -f "$SERVICE_FILE" ]; then
    NEEDS_UPDATE=true
    log "Creating systemd service file..."
elif ! echo "$SERVICE_CONTENT" | diff -q - "$SERVICE_FILE" >/dev/null 2>&1; then
    NEEDS_UPDATE=true
    log "Updating systemd service file..."
else
    log "Systemd service file is up to date"
fi

if [ "$NEEDS_UPDATE" = "true" ]; then
    echo "$SERVICE_CONTENT" | sudo tee "$SERVICE_FILE" >/dev/null
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

# Start or restart service
if [ "$NEEDS_UPDATE" = "true" ] && systemctl is-active ttyd.service >/dev/null 2>&1; then
    log "Restarting ttyd.service..."
    sudo systemctl restart ttyd.service
elif ! systemctl is-active ttyd.service >/dev/null 2>&1; then
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
