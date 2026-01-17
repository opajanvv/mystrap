#!/bin/sh
# Post-install script for plocate
# Excludes ~/Downloads from the locate database to preserve atime for cleanup

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../scripts/helpers.sh"

UPDATEDB_CONF="/etc/updatedb.conf"
EXCLUDE_PATH="/home/$USER/Downloads"

# Check if already excluded
if grep -q "$EXCLUDE_PATH" "$UPDATEDB_CONF" 2>/dev/null; then
    log "~/Downloads already excluded from plocate"
    exit 0
fi

# Check if we can use sudo
if ! sudo -n true 2>/dev/null; then
    warn "Cannot modify $UPDATEDB_CONF without sudo access"
    exit 0
fi

log "Adding ~/Downloads to plocate PRUNEPATHS..."
sudo sed -i "s|PRUNEPATHS = \"\(.*\)\"|PRUNEPATHS = \"\1 $EXCLUDE_PATH\"|" "$UPDATEDB_CONF"
log "Done"
