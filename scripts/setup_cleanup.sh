#!/bin/sh
# setup_cleanup.sh - Install weekly cleanup cron job
#
# Usage: ./scripts/setup_cleanup.sh

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/helpers.sh"

CLEANUP_SCRIPT="$SCRIPT_DIR/cleanup.sh"
LOG_FILE="$HOME/.cache/cleanup.log"
CRON_PATTERN="cleanup.sh"

# Weekly on Sunday at 3am
CRON_ENTRY="0 3 * * 0 $CLEANUP_SCRIPT >> $LOG_FILE 2>&1"

if crontab -l 2>/dev/null | grep -qF "$CRON_PATTERN"; then
    log "Cleanup cron already installed"
else
    (crontab -l 2>/dev/null || true; echo "$CRON_ENTRY") | crontab -
    log "Installed weekly cleanup cron (Sundays 3am)"
fi
