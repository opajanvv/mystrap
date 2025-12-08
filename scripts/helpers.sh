#!/bin/sh
# helpers.sh - Utility functions for Phoenix bootstrap scripts
# POSIX sh compatible utilities

set -eu

# Logging utilities
log() {
    echo "[$(date '+%Y-%m-%d %H:%M')] [INFO] $*"
}

warn() {
    echo "[$(date '+%Y-%m-%d %H:%M')] [WARN] $*" >&2
}

die() {
    echo "[$(date '+%Y-%m-%d %H:%M')] [ERROR] $*" >&2
    exit 1
}

cleanup_old_logs() {
    # Clean up log file by removing entries older than 24 hours
    # Usage: cleanup_old_logs [log_file]
    # Default log file: ~/.janstrap-auto-update.log
    log_file="${1:-$HOME/.janstrap-auto-update.log}"

    # Exit gracefully if log file doesn't exist
    if [ ! -f "$log_file" ]; then
        return 0
    fi

    # Exit if log file is empty
    if [ ! -s "$log_file" ]; then
        return 0
    fi

    # Calculate cutoff timestamp (24 hours ago)
    # Try GNU date format first, fallback to BSD format
    cutoff_timestamp=""
    if date -d '24 hours ago' '+%Y-%m-%d %H:%M' >/dev/null 2>&1; then
        # GNU date (Linux)
        cutoff_timestamp=$(date -d '24 hours ago' '+%Y-%m-%d %H:%M')
    elif date -v-24H '+%Y-%m-%d %H:%M' >/dev/null 2>&1; then
        # BSD date (macOS)
        cutoff_timestamp=$(date -v-24H '+%Y-%m-%d %H:%M')
    else
        # Fallback: cannot determine cutoff, skip cleanup
        warn "Cannot calculate 24-hour cutoff timestamp, skipping log cleanup"
        return 0
    fi

    # Create temp file for filtered logs
    temp_file="${log_file}.tmp.$$"

    # Filter log file: keep lines newer than 24 hours or without timestamps
    awk -v cutoff="$cutoff_timestamp" '
    {
        # Check if line starts with timestamp format [yyyy-mm-dd hh:mm]
        if (match($0, /^\[([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2})\]/, ts)) {
            # Extract timestamp (without brackets)
            line_ts = ts[1]
            # Compare timestamps lexicographically (works because ISO format)
            if (line_ts >= cutoff) {
                print $0
            }
        } else {
            # Keep lines without timestamps (backward compatibility)
            print $0
        }
    }
    ' "$log_file" > "$temp_file"

    # Atomically replace original file with filtered version
    if [ -f "$temp_file" ]; then
        mv "$temp_file" "$log_file"
    fi
}

has_cmd() {
    # Check if a command exists
    command -v "$1" >/dev/null 2>&1
}

get_hostname() {
    # Get hostname, preferring HOST environment variable, then hostname command
    if [ -n "${HOST:-}" ]; then
        echo "$HOST"
    elif has_cmd hostname; then
        hostname
    else
        # Fallback: read from /etc/hostname
        if [ -f /etc/hostname ]; then
            head -n1 /etc/hostname | tr -d '\n'
        else
            die "Cannot determine hostname"
        fi
    fi
}

append_if_absent() {
    # Append a line to a file if it doesn't already exist
    # Usage: append_if_absent <file> <line>
    file="$1"
    line="$2"
    
    if [ ! -f "$file" ]; then
        die "File does not exist: $file"
    fi
    
    if ! grep -qF "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
        log "Appended to $file: $line"
    else
        log "Line already present in $file, skipping"
    fi
}

install_packages() {
    # Install packages using yay (handles both official repos and AUR)
    # Usage: install_packages <packages>
    packages="$1"

    if [ -z "$packages" ]; then
        return 0
    fi

    if ! has_cmd yay; then
        die "yay not found. This script requires yay to be installed."
    fi

    log "Installing packages with yay: $packages"
    yay -S --needed --noconfirm $packages || die "Failed to install packages"
}

uninstall_packages() {
    # Uninstall packages using yay with their unused dependencies
    # Usage: uninstall_packages <packages>
    packages="$1"

    if [ -z "$packages" ]; then
        return 0
    fi

    if ! has_cmd yay; then
        die "yay not found. This script requires yay to be installed."
    fi

    log "Uninstalling packages with yay: $packages"
    yay -Rns --noconfirm $packages || die "Failed to uninstall packages"
}


