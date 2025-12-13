#!/bin/sh
# install_ssh.sh - Ensure SSH directory permissions
#
# Called by install_all.sh after dotfiles are stowed.
# For key decryption, run setup_ssh.sh manually.

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/helpers.sh"

# Ensure correct permissions if .ssh exists
if [ -d "$HOME/.ssh" ]; then
    chmod 700 "$HOME/.ssh"
    find "$HOME/.ssh" -type f -name "*.pub" -exec chmod 644 {} \;
    find "$HOME/.ssh" -type f ! -name "*.pub" ! -name "known_hosts*" ! -name "config" -exec chmod 600 {} \; 2>/dev/null || true
    log "SSH permissions verified"
else
    log "SSH directory not found (run setup_ssh.sh after install)"
fi
