#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/helpers.sh"

log "Removing unwanted files..."

while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines and comments
    case "$line" in
        ''|'#'*) continue ;;
    esac

    # Expand ~ to $HOME
    file="${line#\~}"
    [ "$file" != "$line" ] && file="$HOME$file"

    rm -f "$file"
done < "$SCRIPT_DIR/../remove_files.txt"

log "File removal complete"
