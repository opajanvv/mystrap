# JanStrap

**A simple, idempotent bootstrap system for Omarchy workstations.**

JanStrap automates the setup and maintenance of multiple workstations in a homelab environment. The goal is simple: painless installation and easy distribution of tools and settings across all machines.

> **Note:** This is a template repository. Use the "Use this template" button on GitHub to create your own independent copy.

## Credits

Inspired by and based on the YouTube video ["You installed Omarchy, Now What?"](https://www.youtube.com/watch?v=d23jFJmcaMI) by **typecraft**. Source: [typecraft-dev/omarchy-supplement](https://github.com/typecraft-dev/omarchy-supplement).

## Overview

JanStrap provides a single repository that can:
1. Bootstrap a workstation once
2. Re-apply updates any time (pull latest changes and reconcile)

The system is designed with strict idempotency: safe to re-run, no interactive prompts, and guarded edits.

## Features

- **Idempotent**: Safe to run multiple times without duplication or errors
- **Host-specific Hyprland config**: Per-machine monitor and workspace settings
- **Post-install scripts**: Optional per-package scripts for service enablement, etc.
- **GNU Stow**: Clean dotfile management with symlinks
- **yay-based**: Uses `yay` for all package management (official repos and AUR)
- **Auto-detection**: Automatically detects hostname
- **Git-aware**: Pulls updates automatically, exits early if no changes

## Repository Structure

```
janstrap/
├── install_all.sh          # Main entry point
├── packages.txt            # Packages to install
├── uninstall.txt           # Packages to remove
├── stow.txt                # Dotfiles to stow
├── dotfiles/               # Common dotfiles (identical everywhere)
│   └── waybar/
│       └── .config/waybar/
│           ├── config.jsonc
│           └── style.css
├── install/                # Post-install scripts (optional)
│   ├── cronie.sh           # Example: Enable cronie service
│   └── google-chrome.sh    # Example: Set Chrome as default browser
├── hosts/
│   ├── laptop1/
│   │   └── overrides.conf  # Hyprland overrides (monitors, etc.)
│   └── laptop2/
│       └── overrides.conf  # Hyprland overrides (monitors, etc.)
└── scripts/
    ├── helpers.sh          # Utility functions
    ├── uninstall_packages.sh
    ├── install_packages.sh
    ├── install_dotfiles.sh
    ├── install_overrides.sh
    ├── enable_auto_update.sh
    └── disable_auto_update.sh
```

## Requirements

JanStrap is designed for **Omarchy**, which comes with most requirements pre-installed:
- `yay` - Package manager for official repos and AUR (pre-installed)
- `git` - Repository cloning and updates (pre-installed)
- `stow` - Dotfile management with symlinks (add to packages.txt)

## Quick Start

**1. Use this template**

Click "Use this template" on GitHub to create your own repository.

**2. Clone your repository**

```bash
git clone <your-repo-url> janstrap
cd janstrap
```

**3. Customize**

- Edit `packages.txt` - Add your preferred packages
- Edit `dotfiles/` - Add your configuration files
- Edit `hosts/<hostname>/overrides.conf` - Set up monitor configuration

**4. Run the installer**

```bash
./install_all.sh
```

The installer will:
- Uninstall unwanted packages (from uninstall.txt)
- Install all packages (from packages.txt)
- Stow all dotfiles (from dotfiles/)
- Apply Hyprland overrides (host-specific monitor config)

## Configuration Files

### packages.txt

List of packages to install, one per line. Comments start with `#`.

```
# Common packages for all workstations
stow
cronie
google-chrome
waybar
```

### uninstall.txt

Packages to remove (e.g., replacing Chromium with Chrome):

```
# Replace Chromium with Chrome
omarchy-chromium
```

### stow.txt

Dotfile packages to stow (correspond to directories in `dotfiles/`):

```
waybar
```

### hosts/`<hostname>`/overrides.conf

Hyprland configuration overrides - monitors, workspaces, keybindings, etc.

**Example - laptop with external monitor:**
```
# Monitor configuration
env = GDK_SCALE,2
monitor=HDMI-A-1,1920x1080@60,-1920x0,1
monitor=eDP-1,1366x768@60,0x0,1
```

The override file is automatically sourced by Hyprland via `~/.config/hypr/hyprland.conf`:
```
source = ~/.config/hypr/overrides.conf
```

## Post-Install Scripts

Optional scripts that run after package installation. Use for enabling services, setting defaults, etc.

**Example: `install/cronie.sh`**

```bash
#!/bin/sh
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../scripts/helpers.sh"

# Check if we can use sudo without password
if ! sudo -n true 2>/dev/null; then
    warn "Cannot enable cronie.service without sudo access"
    exit 0
fi

# Enable and start cronie
if ! systemctl is-enabled cronie.service >/dev/null 2>&1; then
    sudo systemctl enable cronie.service
fi
if ! systemctl is-active cronie.service >/dev/null 2>&1; then
    sudo systemctl start cronie.service
fi
```

**Requirements:**
- Filename must match package name: `cronie.sh` for package `cronie`
- Must be executable: `chmod +x install/cronie.sh`
- Must be idempotent: Safe to run multiple times

## Re-Applying Updates

Run `install_all.sh` again to apply updates:

```bash
./install_all.sh
```

The installer will:
- Pull latest changes from git
- Reconcile package installations
- Update dotfile symlinks
- Re-apply overrides

If no updates are found, it exits early. Use `--force` to re-apply anyway:

```bash
./install_all.sh --force
```

## Automatic Updates

JanStrap can automatically check for and apply updates on a schedule.

**Prerequisite:** Requires `cronie` and passwordless sudo for full automation.

### Enable Auto-Updates

```bash
./scripts/enable_auto_update.sh
```

Choose a schedule (hourly, daily, etc.). Logs written to `~/.janstrap-auto-update.log`.

### Disable Auto-Updates

```bash
./scripts/disable_auto_update.sh
```

### Passwordless Sudo (Optional)

For full unattended automation, configure passwordless sudo:

```bash
sudo visudo -f /etc/sudoers.d/janstrap
```

Add (replace `yourusername`):
```
yourusername ALL=(ALL) NOPASSWD: /usr/bin/yay, /usr/bin/pacman, /usr/bin/systemctl enable *, /usr/bin/systemctl start *, /usr/bin/systemctl mask *
```

**Without this:** Auto-updates will fail at package installation. Manual runs will prompt for password.

## Omarchy-Specific Notes

After installing Omarchy:
1. Setup WiFi
2. Update system
3. Create snapshot: `sudo snapper -c root create --description "Fresh install, updated"`
4. Clone janstrap and run `./install_all.sh`
