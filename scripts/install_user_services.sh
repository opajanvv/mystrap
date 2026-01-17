#!/bin/sh
# Post-install script for systemd user services
# Enables user timers after dotfiles are stowed

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../scripts/helpers.sh"

# Enable cleanup-downloads timer
if systemctl --user is-enabled cleanup-downloads.timer >/dev/null 2>&1; then
    log "cleanup-downloads.timer already enabled"
else
    log "Enabling cleanup-downloads.timer..."
    systemctl --user daemon-reload
    systemctl --user enable --now cleanup-downloads.timer
fi
