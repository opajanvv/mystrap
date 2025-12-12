#!/bin/sh
# setup_ssh.sh - One-time SSH setup for a new machine
#
# Run this once on each new machine to:
# - Generate machine-specific SSH key
# - Set up age passphrase for decrypting shared keys
# - Decrypt shared keys (github, gitlab)
#
# Usage: ./scripts/setup_ssh.sh

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

. "$SCRIPT_DIR/helpers.sh"

MACHINE_NAME=$(hostname)
MACHINE_KEY="$HOME/.ssh/$MACHINE_NAME"
PASSPHRASE_FILE="$HOME/.config/mystrap/age-passphrase"
ENCRYPTED_DIR="$REPO_ROOT/dotfiles/ssh/.ssh/encrypted"

# Generate machine-specific key if missing
if [ -f "$MACHINE_KEY" ]; then
    log "Machine key already exists: $MACHINE_KEY"
else
    log "Generating machine-specific SSH key..."
    ssh-keygen -t ed25519 -f "$MACHINE_KEY" -N "" -C "$MACHINE_NAME"
    log "Generated: $MACHINE_KEY"
fi

# Set up age passphrase
if [ -f "$PASSPHRASE_FILE" ]; then
    log "Age passphrase already configured"
else
    mkdir -p "$(dirname "$PASSPHRASE_FILE")"
    printf "Enter age passphrase for decrypting shared SSH keys: "
    stty -echo
    read -r passphrase
    stty echo
    printf "\n"

    echo "$passphrase" > "$PASSPHRASE_FILE"
    chmod 600 "$PASSPHRASE_FILE"
    log "Passphrase stored in: $PASSPHRASE_FILE"
fi

# Decrypt shared keys
for key in github gitlab; do
    encrypted="$ENCRYPTED_DIR/$key.age"
    target="$HOME/.ssh/$key"

    if [ ! -f "$encrypted" ]; then
        warn "Encrypted key not found: $encrypted (skipping)"
        continue
    fi

    if [ -f "$target" ]; then
        log "Key already exists: $target (skipping)"
        continue
    fi

    log "Decrypting $key..."
    age -d -i "$PASSPHRASE_FILE" -o "$target" "$encrypted" 2>/dev/null || \
        age -d -o "$target" "$encrypted" < "$PASSPHRASE_FILE"
    chmod 600 "$target"
    log "Decrypted: $target"
done

# Ensure correct permissions on all keys
chmod 700 "$HOME/.ssh"
find "$HOME/.ssh" -type f -name "*.pub" -exec chmod 644 {} \;
find "$HOME/.ssh" -type f ! -name "*.pub" ! -name "known_hosts*" ! -name "config" -exec chmod 600 {} \;

log "SSH setup complete!"
log ""
log "Machine public key (add this to server's ~/.ssh/authorized_keys):"
log "---"
cat "$MACHINE_KEY.pub"
log "---"
