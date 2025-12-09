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

# Local helper: stow a package with conflict resolution
stow_package() {
    stow_dir="$1"
    package="$2"

    log "Stowing $package..."

    # Try to stow - capture output to detect conflicts
    stow_output=$(stow -d "$stow_dir" -t "$HOME" --restow "$package" 2>&1) || stow_failed=true

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
        stow -d "$stow_dir" -t "$HOME" --restow "$package" || warn "Failed to stow $package"
        unset stow_failed
    fi
}

# Read and stow packages from stow.txt
while IFS= read -r package || [ -n "$package" ]; do
    # Skip comments and empty lines
    case "$package" in
        \#*|"") continue ;;
    esac

    stow_package "$DOTFILES_DIR" "$package"
done < "$STOW_FILE"

log "Common dotfiles installed successfully"

# Install host-specific dotfiles if they exist
HOST=$(hostname)
HOST_DOTFILES_DIR="$REPO_ROOT/hosts/$HOST/dotfiles"

if [ -d "$HOST_DOTFILES_DIR" ]; then
    log "Installing host-specific dotfiles for $HOST..."

    # Find all packages in host dotfiles directory
    for package_dir in "$HOST_DOTFILES_DIR"/*; do
        [ -d "$package_dir" ] || continue
        stow_package "$HOST_DOTFILES_DIR" "$(basename "$package_dir")"
    done

    log "Host-specific dotfiles installed successfully"
else
    log "No host-specific dotfiles found for $HOST (skipping)"
fi
