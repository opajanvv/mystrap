#!/bin/sh
# install_dotfiles.sh - Install dotfiles using GNU Stow

set -eu

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source helpers
. "$SCRIPT_DIR/helpers.sh"

HOST=""

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --host)
            HOST="$2"
            shift 2
            ;;
        *)
            die "Unknown option: $1. Usage: $0 --host <hostname>"
            ;;
    esac
done

if [ -z "$HOST" ]; then
    die "Hostname not specified. Usage: $0 --host <hostname>"
fi

COMMON_STOW_FILE="$REPO_ROOT/stow.txt"
HOST_STOW_FILE="$REPO_ROOT/hosts/$HOST/stow.txt"
DOTFILES_DIR="$REPO_ROOT/dotfiles"
HOST_DOTFILES_DIR="$REPO_ROOT/hosts/$HOST/dotfiles"

# Create persistent merge directory for merging common and host-specific dotfiles
# This allows host-specific dotfiles to override individual files from common packages
# without requiring duplication of unchanged files
# Must be persistent (not /tmp) so symlinks remain valid after script exits
TEMP_DOTFILES_DIR="$HOME/.local/share/janstrap/merged-dotfiles"

# Verify stow is installed
if ! has_cmd stow; then
    die "stow not found. Please install it first (should be in common packages)."
fi

# Function to merge common and host-specific dotfiles for a package
# Implementation: For each package, we create a temporary merged directory that contains:
# 1. All files from dotfiles/<package>/ (common files)
# 2. Files from hosts/<host>/dotfiles/<package>/ (host-specific overrides)
# Host-specific files overwrite common files, allowing selective per-file overrides
# without requiring users to duplicate unchanged files in host directories
merge_package() {
    package="$1"
    temp_package_dir="$TEMP_DOTFILES_DIR/$package"
    common_package_dir="$DOTFILES_DIR/$package"
    host_package_dir="$HOST_DOTFILES_DIR/$package"

    # Create temp package directory
    mkdir -p "$temp_package_dir"

    # Copy common dotfiles if they exist
    if [ -d "$common_package_dir" ]; then
        cp -r "$common_package_dir"/* "$temp_package_dir/" 2>/dev/null || true
        cp -r "$common_package_dir"/.[!.]* "$temp_package_dir/" 2>/dev/null || true
    fi

    # Copy host-specific dotfiles (overwriting common ones)
    if [ -d "$host_package_dir" ]; then
        log "  Merging host-specific overrides for $package..."
        cp -r "$host_package_dir"/* "$temp_package_dir/" 2>/dev/null || true
        cp -r "$host_package_dir"/.[!.]* "$temp_package_dir/" 2>/dev/null || true
    fi
}

# Function to stow packages from a file
stow_from_file() {
    stow_file="$1"
    if [ ! -f "$stow_file" ]; then
        return 0
    fi

    while IFS= read -r package || [ -n "$package" ]; do
        # Skip comments and empty lines
        case "$package" in
            \#*|"") continue ;;
        esac

        # Check if package exists in either common or host-specific dotfiles
        common_package_dir="$DOTFILES_DIR/$package"
        host_package_dir="$HOST_DOTFILES_DIR/$package"

        if [ ! -d "$common_package_dir" ] && [ ! -d "$host_package_dir" ]; then
            warn "Package directory not found: $package (skipping)"
            continue
        fi

        log "Stowing $package..."

        # Merge common and host-specific dotfiles into temp directory
        merge_package "$package"

        # Try to stow - capture output to detect conflicts
        stow_output=$(stow -d "$TEMP_DOTFILES_DIR" -t "$HOME" --restow "$package" 2>&1) || stow_failed=true

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
            stow -d "$TEMP_DOTFILES_DIR" -t "$HOME" --restow "$package" || warn "Failed to stow $package"
            unset stow_failed
        fi
    done < "$stow_file"
}

# Create merge directory (persistent, so symlinks remain valid)
# Clean it first to ensure we have fresh merged dotfiles
if [ -d "$TEMP_DOTFILES_DIR" ]; then
    rm -rf "$TEMP_DOTFILES_DIR"
fi
mkdir -p "$TEMP_DOTFILES_DIR"

# Stow common dotfiles
if [ -f "$COMMON_STOW_FILE" ]; then
    log "Stowing common dotfiles..."
    stow_from_file "$COMMON_STOW_FILE"
fi

# Stow host-specific dotfiles
if [ -f "$HOST_STOW_FILE" ]; then
    log "Stowing host-specific dotfiles for $HOST..."
    stow_from_file "$HOST_STOW_FILE"
fi

log "Dotfiles installed successfully"

