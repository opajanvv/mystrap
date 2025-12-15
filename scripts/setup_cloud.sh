#!/bin/sh
# setup_cloud.sh - Initialize rclone bisync for Google Drive
#
# Run this once on each new machine to:
# - Create ~/Cloud directories
# - Perform initial sync (remote → local)
# - Install bisync cron jobs
#
# Prerequisites:
# - rclone configured (run setup_rclone.sh first)
# - RCLONE_TEST file exists on each remote drive root
#
# Usage: ./scripts/setup_cloud.sh

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

. "$SCRIPT_DIR/helpers.sh"

CLOUD_DIR="$HOME/Cloud"
CACHE_DIR="$HOME/.cache/rclone"
BISYNC_STATE_DIR="$CACHE_DIR/bisync"
MARKER_DIR="$CACHE_DIR/cloud-init"

# Remotes to sync (must match rclone.conf)
REMOTES="janvv delichtbron penningmeester"

# Bisync options for cron jobs (ongoing sync)
BISYNC_OPTS="--check-access --fast-list --drive-skip-gdocs --resilient --recover --max-lock 10m --timeout 5m -MP"

# Options for initial sync (no --check-access since local is empty, more retries)
RESYNC_OPTS="--fast-list --drive-skip-gdocs --resilient --max-lock 10m --timeout 5m -MP --retries 5 --retries-sleep 30s --low-level-retries 10 -v"

# Check rclone is configured
if [ ! -f "$HOME/.config/rclone/rclone.conf" ]; then
    die "rclone not configured. Run setup_rclone.sh first."
fi

# Create directories
mkdir -p "$CLOUD_DIR"
mkdir -p "$CACHE_DIR"
mkdir -p "$MARKER_DIR"

# Initialize each remote
for remote in $REMOTES; do
    local_dir="$CLOUD_DIR/$remote"
    marker_file="$MARKER_DIR/$remote.done"
    state_pattern="$BISYNC_STATE_DIR/drive-${remote}_*path1.lst"

    # Check if already initialized
    if [ -f "$marker_file" ]; then
        log "[$remote] Already initialized (skipping)"
        continue
    fi

    # Safety check: state files exist but marker missing (cache partially cleared?)
    # shellcheck disable=SC2086
    if ls $state_pattern 1>/dev/null 2>&1; then
        warn "[$remote] State files exist but marker missing - recovering"
        touch "$marker_file"
        log "[$remote] Marker recreated (skipping resync)"
        continue
    fi

    log "[$remote] Creating directory..."
    mkdir -p "$local_dir"

    log "[$remote] Running initial sync (this may take a while)..."
    log "[$remote] Remote files will be downloaded to $local_dir"
    log "[$remote] If interrupted, re-run this script to resume."

    # shellcheck disable=SC2086
    if ! rclone bisync "drive-$remote:/" "$local_dir" --resync $RESYNC_OPTS; then
        warn "[$remote] Initial sync failed or interrupted."
        warn "[$remote] Re-run this script to retry."
        continue
    fi

    # Mark as successfully initialized
    touch "$marker_file"
    log "[$remote] Initial sync complete"
done

# Install cron jobs only for successfully initialized remotes
log "Installing bisync cron jobs..."

add_cron_if_missing() {
    entry="$1"
    pattern="$2"
    if crontab -l 2>/dev/null | grep -qF "$pattern"; then
        log "Cron already exists: $pattern"
    else
        (crontab -l 2>/dev/null || true; echo "$entry") | crontab -
        log "Added cron: $pattern"
    fi
}

# Only add cron for remotes that completed initial sync
if [ -f "$MARKER_DIR/janvv.done" ]; then
    add_cron_if_missing "0,30 * * * * /usr/bin/flock -n /tmp/janvv.lock rclone bisync drive-janvv:/ $CLOUD_DIR/janvv $BISYNC_OPTS >> $CACHE_DIR/bisync-janvv.log 2>&1" "bisync drive-janvv"
fi

if [ -f "$MARKER_DIR/delichtbron.done" ]; then
    add_cron_if_missing "10,40 * * * * /usr/bin/flock -n /tmp/delichtbron.lock rclone bisync drive-delichtbron:/ $CLOUD_DIR/delichtbron $BISYNC_OPTS >> $CACHE_DIR/bisync-delichtbron.log 2>&1" "bisync drive-delichtbron"
fi

if [ -f "$MARKER_DIR/penningmeester.done" ]; then
    add_cron_if_missing "20,50 * * * * /usr/bin/flock -n /tmp/penningmeester.lock rclone bisync drive-penningmeester:/ $CLOUD_DIR/penningmeester $BISYNC_OPTS >> $CACHE_DIR/bisync-penningmeester.log 2>&1" "bisync drive-penningmeester"
fi

# Summary
initialized=$(ls "$MARKER_DIR"/*.done 2>/dev/null | wc -l)
if [ "$initialized" -eq 3 ]; then
    log "Cloud sync setup complete! All 3 drives initialized."
    log "Bisync will run every 30 minutes for each drive."
elif [ "$initialized" -gt 0 ]; then
    log "Partial setup: $initialized/3 drives initialized."
    log "Re-run this script to complete remaining drives."
else
    warn "No drives were initialized. Check errors above."
fi
