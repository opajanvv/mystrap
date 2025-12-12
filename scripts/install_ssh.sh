#!/bin/sh
# install_ssh.sh - Decrypt and sync shared SSH keys
#
# Called by install_all.sh to keep shared keys in sync.
# Requires setup_ssh.sh to have been run first.

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

. "$SCRIPT_DIR/helpers.sh"

PASSPHRASE_FILE="$HOME/.config/mystrap/age-passphrase"
ENCRYPTED_DIR="$REPO_ROOT/dotfiles/ssh/.ssh/encrypted"

# Skip if setup_ssh.sh hasn't been run
if [ ! -f "$PASSPHRASE_FILE" ]; then
    log "Age passphrase not configured (run setup_ssh.sh first)"
    exit 0
fi

# Decrypt shared keys if needed
for key in github gitlab; do
    encrypted="$ENCRYPTED_DIR/$key.age"
    target="$HOME/.ssh/$key"

    if [ ! -f "$encrypted" ]; then
        continue
    fi

    # Decrypt if target missing or encrypted is newer
    if [ ! -f "$target" ] || [ "$encrypted" -nt "$target" ]; then
        log "Decrypting $key..."
        age -d -i "$PASSPHRASE_FILE" -o "$target" "$encrypted" 2>/dev/null || \
            age -d -o "$target" "$encrypted" < "$PASSPHRASE_FILE"
        chmod 600 "$target"
    fi
done

log "SSH keys synced"
