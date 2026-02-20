#!/bin/sh
# cleanup.sh - Weekly maintenance cleanup
#
# - Removes broken symlinks in $HOME
# - Removes files in ~/Downloads not accessed for 7+ days
#
# Usage: ./scripts/cleanup.sh [--dry-run]

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/helpers.sh"

DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=true
    log "Dry run mode - no files will be deleted"
fi

# Clean broken symlinks in $HOME and .config (excluding .cache, .local)
log "Checking for broken symlinks..."
broken_count=0
find "$HOME" "$HOME/.config" -maxdepth 3 -xtype l \
    -not -path "$HOME/.cache/*" \
    -not -path "$HOME/.local/*" \
    -not -path "$HOME/.cargo/*" \
    -not -path "$HOME/.rustup/*" \
    2>/dev/null | while read -r link; do
    if [ "$DRY_RUN" = true ]; then
        log "Would remove broken symlink: $link"
    else
        log "Removing broken symlink: $link"
        rm "$link"
    fi
    broken_count=$((broken_count + 1))
done

# Clean old downloads (files not accessed in 7+ days)
DOWNLOADS="$HOME/Downloads"
if [ -d "$DOWNLOADS" ]; then
    log "Checking for old files in $DOWNLOADS..."
    find "$DOWNLOADS" -type f -atime +7 2>/dev/null | while read -r file; do
        if [ "$DRY_RUN" = true ]; then
            log "Would remove old download: $file"
        else
            log "Removing old download: $file"
            rm "$file"
        fi
    done

    # Remove empty directories left behind
    if [ "$DRY_RUN" = false ]; then
        find "$DOWNLOADS" -mindepth 1 -type d -empty -delete 2>/dev/null || true
    fi
fi

log "Cleanup complete."
