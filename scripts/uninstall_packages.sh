#!/bin/sh
# uninstall_packages.sh - Uninstall packages from uninstall.txt

set -eu

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source helpers
. "$SCRIPT_DIR/helpers.sh"

UNINSTALL_FILE="$REPO_ROOT/uninstall.txt"

# Function to read packages from a file
read_packages() {
    file="$1"
    if [ ! -f "$file" ]; then
        return 0
    fi

    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        case "$line" in
            \#*|"") continue ;;
        esac
        echo "$line"
    done < "$file"
}

# Read packages to uninstall
if [ ! -f "$UNINSTALL_FILE" ]; then
    log "No uninstall.txt found (skipping)"
    exit 0
fi

log "Reading packages to uninstall from $UNINSTALL_FILE"
packages=$(read_packages "$UNINSTALL_FILE" | tr '\n' ' ')

if [ -z "$packages" ]; then
    log "No packages to uninstall"
    exit 0
fi

# Uninstall packages (only if they're installed)
log "Checking which packages are installed..."
packages_to_remove=""

for package in $packages; do
    if yay -Qi "$package" >/dev/null 2>&1; then
        packages_to_remove="$packages_to_remove $package"
    else
        log "Package not installed, skipping: $package"
    fi
done

if [ -z "$packages_to_remove" ]; then
    log "No packages to uninstall (none are currently installed)"
    exit 0
fi

# Remove packages with their unused dependencies
log "Uninstalling packages: $packages_to_remove"
uninstall_packages "$packages_to_remove"

log "Packages uninstalled successfully"
