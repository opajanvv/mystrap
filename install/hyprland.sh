#!/bin/sh
# Post-install script for hyprland
# Creates initial workspace configuration symlink

set -eu

# Source helpers for logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../scripts/helpers.sh" 2>/dev/null || . "$(dirname "$SCRIPT_DIR")/scripts/helpers.sh"

log "Updating hyprpm..."
hyprpm update || warn "Failed to update hyprpm"

# Create initial workspaces-current.conf symlink (default to dual mode)
WS_CURRENT="$HOME/.config/hypr/workspaces-current.conf"
WS_DUAL="$HOME/.config/hypr/workspaces-dual.conf"

if [ ! -e "$WS_CURRENT" ]; then
    log "Creating initial workspace configuration symlink (dual mode)..."
    ln -sf "$WS_DUAL" "$WS_CURRENT"
else
    log "Workspace configuration symlink already exists"
fi

log "Hyprland plugin setup complete"
