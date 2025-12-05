#!/bin/sh
# uninstall_packages.sh - Uninstall common and host-specific packages

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

COMMON_UNINSTALL_FILE="$REPO_ROOT/uninstall.txt"
HOST_UNINSTALL_FILE="$REPO_ROOT/hosts/$HOST/uninstall.txt"

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

# Read packages from both files
if [ -f "$COMMON_UNINSTALL_FILE" ]; then
    log "Reading packages to uninstall from $COMMON_UNINSTALL_FILE"
    common_packages=$(read_packages "$COMMON_UNINSTALL_FILE")
else
    log "Common uninstall file not found: $COMMON_UNINSTALL_FILE (skipping)"
    common_packages=""
fi

if [ -f "$HOST_UNINSTALL_FILE" ]; then
    log "Reading host-specific packages to uninstall from $HOST_UNINSTALL_FILE"
    host_packages=$(read_packages "$HOST_UNINSTALL_FILE")
else
    log "Host-specific uninstall file not found: $HOST_UNINSTALL_FILE (skipping)"
    host_packages=""
fi

# Combine and remove duplicates (using sort -u)
all_packages=$(printf "%s\n%s\n" "$common_packages" "$host_packages" | sort -u | tr '\n' ' ')

if [ -z "$all_packages" ]; then
    log "No packages to uninstall"
    exit 0
fi

# Uninstall packages (only if they're installed)
log "Checking which packages are installed..."
packages_to_remove=""

for package in $all_packages; do
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
