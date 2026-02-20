#!/bin/sh
# install_cron.sh - Install cron job to run install_all.sh every 6 hours

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

. "$SCRIPT_DIR/helpers.sh"

CRON_COMMAND="$REPO_ROOT/install_all.sh"
CRON_ENTRY="0 */6 * * * $CRON_COMMAND"

if crontab -l 2>/dev/null | grep -qF "$CRON_COMMAND"; then
    log "Cron job already exists"
    exit 0
fi

(crontab -l 2>/dev/null || true; echo "$CRON_ENTRY") | crontab -
log "Installed cron job: $CRON_ENTRY"

BG_COMMAND="$HOME/.local/bin/mystrap-bg-next"
BG_ENTRY="0 0,12 * * * WAYLAND_DISPLAY=wayland-1 XDG_RUNTIME_DIR=/run/user/1000 $BG_COMMAND"

if crontab -l 2>/dev/null | grep -qF "$BG_COMMAND"; then
    log "Wallpaper cron job already exists"
    exit 0
fi

(crontab -l 2>/dev/null || true; echo "$BG_ENTRY") | crontab -
log "Installed cron job: $BG_ENTRY"
