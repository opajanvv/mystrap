#!/bin/sh
# install_claude_code.sh - Install Claude Code CLI using official installation method

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/helpers.sh"

CLAUDE_BIN="$HOME/.local/bin/claude"

# Claude Code auto-updates itself, so only install if not present
if [ -f "$CLAUDE_BIN" ]; then
    log "Claude Code already installed"
    exit 0
fi

log "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash

if [ ! -f "$CLAUDE_BIN" ]; then
    die "Claude Code installation failed"
fi

log "Claude Code installed successfully"
