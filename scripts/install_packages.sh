#!/bin/sh
# install_packages.sh - Install packages from packages.txt

set -eu

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source helpers
. "$SCRIPT_DIR/helpers.sh"

PACKAGES_FILE="$REPO_ROOT/packages.txt"

# Function to read packages from a file
read_packages() {
    file="$1"

    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        case "$line" in
            \#*|"") continue ;;
        esac
        echo "$line"
    done < "$file"
}

# Read packages
log "Reading packages from $PACKAGES_FILE"
packages=$(read_packages "$PACKAGES_FILE" | tr '\n' ' ')

# Install all packages
log "Installing packages with yay: $packages"
yay -S --needed --noconfirm $packages || die "Failed to install packages"

log "Packages installed successfully"

# Run post-install scripts for each package
log "Checking for post-install scripts..."

# Process each package for post-install scripts
for package in $packages; do
    script_path="$REPO_ROOT/install/${package}.sh"
    if [ -f "$script_path" ] && [ -x "$script_path" ]; then
        log "Running post-install script: $script_path"
        "$script_path" || warn "Post-install script failed: $script_path"
    fi
done

log "Post-install scripts completed"
