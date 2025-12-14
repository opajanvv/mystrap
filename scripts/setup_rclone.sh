#!/bin/sh
# setup_rclone.sh - Decrypt rclone configuration
#
# Run this once on each new machine to decrypt the rclone config.
#
# Usage: ./scripts/setup_rclone.sh

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

. "$SCRIPT_DIR/helpers.sh"

ENCRYPTED="$REPO_ROOT/dotfiles/rclone/.config/rclone/rclone.conf.age"
TARGET="$HOME/.config/rclone/rclone.conf"

if [ ! -f "$ENCRYPTED" ]; then
    die "Encrypted config not found: $ENCRYPTED"
fi

if [ -f "$TARGET" ]; then
    log "Config already exists: $TARGET (skipping)"
    exit 0
fi

# Ensure target directory exists
mkdir -p "$(dirname "$TARGET")"

log "Decrypting rclone config (enter age encryption passphrase)..."
age -d -o "$TARGET" "$ENCRYPTED"
chmod 600 "$TARGET"

log "Rclone config decrypted to $TARGET"
