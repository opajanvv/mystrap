#!/bin/sh
# install_dotfiles.sh - Install dotfiles using GNU Stow

set -eu

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source helpers
. "$SCRIPT_DIR/helpers.sh"

STOW_FILE="$REPO_ROOT/stow.txt"
DOTFILES_DIR="$REPO_ROOT/dotfiles"

# Verify stow is installed
if ! has_cmd stow; then
    die "stow not found. Please install it first (should be in packages.txt)."
fi

# Check if stow.txt exists
if [ ! -f "$STOW_FILE" ]; then
    warn "stow.txt not found, skipping dotfiles"
    exit 0
fi

# Read and stow packages from stow.txt
while IFS= read -r package || [ -n "$package" ]; do
    # Skip comments and empty lines
    case "$package" in
        \#*|"") continue ;;
    esac

    # Check if package directory exists
    if [ ! -d "$DOTFILES_DIR/$package" ]; then
        warn "Package directory not found: $package (skipping)"
        continue
    fi

    log "Stowing $package..."

    # Try to stow - capture output to detect conflicts
    stow_output=$(stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$package" 2>&1) || stow_failed=true

    # If stow failed, check for conflicts and handle them
    if [ "${stow_failed:-false}" = "true" ]; then
        # Parse conflict errors and remove non-symlink files
        echo "$stow_output" | grep "existing target" | while IFS= read -r line; do
            # Extract the target path (format: "...existing target PATH since...")
            target=$(echo "$line" | sed -n 's/.*existing target \(.*\) since.*/\1/p')
            if [ -n "$target" ]; then
                target_path="$HOME/$target"
                # Only remove if it's a regular file (not a symlink or directory)
                if [ -f "$target_path" ] && [ ! -L "$target_path" ]; then
                    log "  Removing conflicting file: $target"
                    rm "$target_path"
                fi
            fi
        done

        # Retry stow after removing conflicts
        log "  Retrying stow for $package..."
        stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$package" || warn "Failed to stow $package"
        unset stow_failed
    fi
done < "$STOW_FILE"

log "Dotfiles installed successfully"
