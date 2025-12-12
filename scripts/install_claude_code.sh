#!/bin/sh
# install_claude_code.sh - Install Claude Code CLI using official installation method
# This script is idempotent and can be run multiple times safely

set -eu

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source helpers
. "$SCRIPT_DIR/helpers.sh"

CLAUDE_BIN="$HOME/.local/bin/claude"

# Check if Claude Code is already installed
if [ -f "$CLAUDE_BIN" ]; then
    log "Claude Code is already installed at $CLAUDE_BIN"

    # Get current version
    current_version=$("$CLAUDE_BIN" --version 2>/dev/null | head -n1 || echo "unknown")
    log "Current version: $current_version"

    # Note: The install script will handle updates if a newer version is available
    log "Running installation script to check for updates..."
else
    log "Claude Code not found, installing..."
fi

# Download and run the official installation script
# This script is idempotent and will update if needed
log "Downloading Claude Code installation script..."
curl -fsSL https://claude.ai/install.sh | bash

# Verify installation
if [ -f "$CLAUDE_BIN" ]; then
    new_version=$("$CLAUDE_BIN" --version 2>/dev/null | head -n1 || echo "unknown")
    log "Claude Code installed successfully: $new_version"
else
    die "Claude Code installation failed - binary not found at $CLAUDE_BIN"
fi
