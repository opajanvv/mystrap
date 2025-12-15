#!/bin/sh
# setup_rclone.sh - Configure rclone remotes for Google Drive
#
# Run this on each new machine to set up Google Drive remotes.
# Each machine authenticates independently (tokens are not shared).
#
# Usage: ./scripts/setup_rclone.sh

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/helpers.sh"

CONFIG_DIR="$HOME/.config/rclone"
CONFIG_FILE="$CONFIG_DIR/rclone.conf"

# Remotes to configure (must match setup_cloud.sh)
REMOTES="janvv delichtbron penningmeester"

mkdir -p "$CONFIG_DIR"

# Check if remote exists in config
remote_exists() {
    remote="$1"
    [ -f "$CONFIG_FILE" ] && grep -q "^\[drive-$remote\]" "$CONFIG_FILE"
}

# Test if remote is working
remote_works() {
    remote="$1"
    rclone lsf "drive-$remote:/" --max-depth 1 >/dev/null 2>&1
}

for remote in $REMOTES; do
    log "[$remote] Checking remote..."

    if ! remote_exists "$remote"; then
        log "[$remote] Not configured. Creating remote..."
        log "[$remote] A browser window will open for Google authentication."
        rclone config create "drive-$remote" drive
    fi

    if remote_works "$remote"; then
        log "[$remote] OK"
    else
        warn "[$remote] Authentication failed or token expired."
        log "[$remote] Re-authenticating..."
        rclone config reconnect "drive-$remote:"
        if remote_works "$remote"; then
            log "[$remote] OK"
        else
            warn "[$remote] Still not working. Check manually with: rclone lsf drive-$remote:/"
        fi
    fi
done

log "Rclone setup complete."
