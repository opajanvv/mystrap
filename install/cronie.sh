#!/bin/sh
# Post-install script for cronie
# Enables and starts the cronie service (cron daemon)

set -eu

# Source helpers for logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../scripts/helpers.sh" 2>/dev/null || . "$(dirname "$SCRIPT_DIR")/scripts/helpers.sh"

# Check if we can use sudo without password
if ! sudo -n true 2>/dev/null; then
    warn "Cannot enable cronie.service without sudo access (run manually or configure passwordless sudo)"
    exit 0
fi

# Enable service if not already enabled
if ! systemctl is-enabled cronie.service >/dev/null 2>&1; then
    sudo systemctl enable cronie.service
fi

# Start service if not already running
if ! systemctl is-active cronie.service >/dev/null 2>&1; then
    sudo systemctl start cronie.service
fi
