#!/bin/sh
# disable_auto_update.sh - Disable automatic updates

set -eu

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source helpers
. "$SCRIPT_DIR/helpers.sh"

# Check if cron is available
if ! has_cmd crontab; then
    die "crontab not found."
fi

# Check if auto-update is enabled
if ! crontab -l 2>/dev/null | grep -q "janstrap.*install_all.sh"; then
    log "Auto-update is not currently enabled."
    exit 0
fi

log "Disabling JanStrap auto-update..."

# Remove JanStrap entries from crontab
crontab -l 2>/dev/null | grep -v "janstrap.*install_all.sh" | grep -v "# JanStrap automatic updates" | crontab - || crontab -r 2>/dev/null || true

log "Auto-update disabled successfully!"
echo ""
echo "To re-enable: ./scripts/enable_auto_update.sh"
