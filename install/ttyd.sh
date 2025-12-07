#!/bin/sh
# Post-install script for ttyd
# Sets up ttyd as a systemd user service running on port 4711

set -eu

# Source helpers for logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../scripts/helpers.sh" 2>/dev/null || . "$(dirname "$SCRIPT_DIR")/scripts/helpers.sh"

# Get current user (the one running the installer)
CURRENT_USER="${SUDO_USER:-${USER}}"

# Create/update systemd user service file
USER_SERVICE_DIR="/home/$CURRENT_USER/.config/systemd/user"
SERVICE_FILE="$USER_SERVICE_DIR/ttyd.service"

# Ensure user service directory exists
if [ ! -d "$USER_SERVICE_DIR" ]; then
    log "Creating user systemd directory..."
    mkdir -p "$USER_SERVICE_DIR"
fi

SERVICE_CONTENT='[Unit]
Description=ttyd - Share your terminal over the web
Documentation=https://github.com/tsl0922/ttyd
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/ttyd -p 4711 -W /bin/bash
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=default.target'

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
    echo "$SERVICE_CONTENT" | tee "$SERVICE_FILE" >/dev/null
fi

# Reload systemd user daemon
log "Reloading systemd user daemon..."
systemctl --user daemon-reload

# Enable linger for user (allows user services to run without login)
if ! loginctl show-user "$CURRENT_USER" | grep -q "Linger=yes"; then
    log "Enabling linger for user $CURRENT_USER..."
    sudo loginctl enable-linger "$CURRENT_USER"
fi

# Enable service if not already enabled
if ! systemctl --user is-enabled ttyd.service >/dev/null 2>&1; then
    log "Enabling ttyd.service..."
    systemctl --user enable ttyd.service
else
    log "ttyd.service already enabled"
fi

# Start or restart service
if [ "$NEEDS_UPDATE" = "true" ] && systemctl --user is-active ttyd.service >/dev/null 2>&1; then
    log "Restarting ttyd.service..."
    systemctl --user restart ttyd.service
elif ! systemctl --user is-active ttyd.service >/dev/null 2>&1; then
    log "Starting ttyd.service..."
    systemctl --user start ttyd.service
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
