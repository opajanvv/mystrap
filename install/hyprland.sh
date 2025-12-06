#!/bin/sh
# Post-install script for hyprland
# Installs and enables split-monitor-workspaces plugin

set -eu

# Source helpers for logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../scripts/helpers.sh" 2>/dev/null || . "$(dirname "$SCRIPT_DIR")/scripts/helpers.sh"

# Check if hyprpm is available
if ! has_cmd hyprpm; then
    warn "hyprpm not found, skipping plugin installation"
    exit 0
fi

log "Updating hyprpm..."
hyprpm update || warn "Failed to update hyprpm"

# Check if plugin is already added
PLUGIN_URL="https://github.com/Duckonaut/split-monitor-workspaces"
if hyprpm list | grep -q "split-monitor-workspaces"; then
    log "Plugin already installed"
else
    log "Installing split-monitor-workspaces plugin..."
    hyprpm add "$PLUGIN_URL" || die "Failed to install plugin"
fi

# Enable plugin
log "Enabling split-monitor-workspaces plugin..."
hyprpm enable split-monitor-workspaces || warn "Failed to enable plugin"

log "Hyprland plugin setup complete"
