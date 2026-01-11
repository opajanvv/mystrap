#!/bin/sh
# Sync Claude Code config from mystrap to public claude-code repo
# Runs weekly via cron to keep the public reference updated

set -eu

SRC="$HOME/dev/mystrap/dotfiles/claude/.claude"
DEST="$HOME/dev/claude-code"

# Copy files
cp "$SRC/CLAUDE.md" "$DEST/CLAUDE.md"
cp "$SRC/commands/"*.md "$DEST/commands/"

# Commit and push if changes
cd "$DEST"
if ! git diff --quiet; then
  git add -A
  git commit -m "Sync from mystrap"
  git push
fi
