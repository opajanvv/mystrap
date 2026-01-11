#!/bin/sh
# Sync Claude Code config from mystrap to public claude-code repo
# Runs weekly via cron to keep the public reference updated

set -eu

SRC="$HOME/dev/mystrap/dotfiles/claude/.claude"
DEST="$HOME/dev/claude-code"

# Copy files
cp "$SRC/CLAUDE.md" "$DEST/CLAUDE.md"
cp "$SRC/commands/"*.md "$DEST/commands/"

# Generate commands list from file headers
commands_list=""
for f in "$DEST/commands/"*.md; do
  name=$(basename "$f")
  desc=$(head -1 "$f" | sed 's/^# //')
  commands_list="$commands_list  - \`$name\` - $desc\n"
done

# Update README: replace commands list between marker line and ## Setup
awk -v cmds="$commands_list" '
  /^- `commands\/` - Custom slash commands$/ {
    print
    printf "%s", cmds
    skip = 1
    next
  }
  /^## Setup$/ { print ""; skip = 0 }
  !skip { print }
' "$DEST/README.md" > "$DEST/README.md.tmp"
mv "$DEST/README.md.tmp" "$DEST/README.md"

# Commit and push if changes
cd "$DEST"
if ! git diff --quiet; then
  git add -A
  git commit -m "Sync from mystrap"
  git push
fi
