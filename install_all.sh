#!/bin/sh
# install_all.sh - Main entry point for Phoenix bootstrap system
# Orchestrates the installation process for workstation setup

set -eu

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

# Source helpers
. "$SCRIPTS_DIR/helpers.sh"

FORCE=false
OFFLINE=false
HOST=""

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -f|--force)
            FORCE=true
            shift
            ;;
        --offline)
            OFFLINE=true
            FORCE=true  # offline implies force (skip update check)
            shift
            ;;
        --host)
            HOST="$2"
            shift 2
            ;;
        *)
            die "Unknown option: $1. Usage: $0 [-f|--force] [--offline] [--host <hostname>]"
            ;;
    esac
done

# Detect hostname
if [ -z "$HOST" ]; then
    HOST=$(hostname)
fi

log "Detected hostname: $HOST"

# Sync with remote (unless offline mode)
HAS_UPDATES=false
cd "$SCRIPT_DIR"

if [ "$OFFLINE" = "true" ]; then
    log "Offline mode: skipping git sync"
else
    # Auto-commit local changes (dotfile edits from this machine)
    if ! git diff --quiet || ! git diff --cached --quiet; then
        log "Local changes detected, auto-committing..."
        git add -A
        git commit -m "Auto-sync dotfiles from $HOST"
    fi

    # Check for remote updates
    git fetch -q || true
    current_head=$(git rev-parse HEAD || echo "")
    remote_head=$(git rev-parse @{u} || echo "")

    if [ -n "$current_head" ] && [ -n "$remote_head" ] && [ "$current_head" != "$remote_head" ]; then
        HAS_UPDATES=true
        log "Syncing with remote..."
        git pull --rebase || warn "Failed to pull updates, continuing anyway"
    else
        log "Repository is already up to date"
    fi

    # Push local commits (including auto-commits)
    if git status | grep -q "Your branch is ahead"; then
        log "Pushing local changes..."
        git push || warn "Failed to push, will retry next run"
    fi
fi

# Exit early if no updates and not forced
if [ "$HAS_UPDATES" = "false" ] && [ "$FORCE" = "false" ]; then
    log "No updates found. Use -f or --force to re-apply everything anyway."
    exit 0
fi

# Run installation scripts in order
log "Starting installation process..."

# 1. Remove unwanted files
log "Step 1/8: Removing unwanted files..."
"$SCRIPTS_DIR/remove_files.sh" || die "File removal failed"

# 2. Uninstall packages
log "Step 2/8: Uninstalling packages..."
"$SCRIPTS_DIR/uninstall_packages.sh" || die "Packages uninstallation failed"

# 3. Install packages
log "Step 3/8: Installing packages..."
"$SCRIPTS_DIR/install_packages.sh" || die "Packages installation failed"

# 4. Install Claude Code
log "Step 4/8: Installing Claude Code..."
"$SCRIPTS_DIR/install_claude_code.sh" || die "Claude Code installation failed"

# 5. Install cron job
log "Step 5/8: Installing cron job..."
"$SCRIPTS_DIR/install_cron.sh" || die "Cron job installation failed"

# 6. Install dotfiles
log "Step 6/8: Installing dotfiles..."
"$SCRIPTS_DIR/install_dotfiles.sh" || die "Dotfiles installation failed"

# 7. Install SSH keys
log "Step 7/8: Installing SSH keys..."
"$SCRIPTS_DIR/install_ssh.sh" || die "SSH key installation failed"

# 8. Install Hyprland overrides (host-specific)
log "Step 8/8: Installing Hyprland overrides..."
"$SCRIPTS_DIR/install_overrides.sh" --host "$HOST" || die "Overrides installation failed"

log "Installation complete!"

