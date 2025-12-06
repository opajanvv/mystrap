# MyStrap

This is a copy of the JanStrap Github template.
This is the customized version for my own homelab, hence *My*Strap.
All JanStrap example source code is removed, and I am now building my own version using this framework.

#JanStrap

An idempotent bootstrap and configuration management system for Omarchy workstations.

JanStrap was developed to manage multiple Omarchy workstations in a homelab environment. The goal is simple: painless re-installation and easy distribution of common tools and settings across all machines.

> **Note:** This is a template repository. Use the "Use this template" button on GitHub to create your own independent copy.

## Credits

This repository is inspired by and based on the approach explained in the YouTube video ["You installed Omarchy, Now What?"](https://www.youtube.com/watch?v=d23jFJmcaMI) by **typecraft**. The source files for his approach can be found in the [typecraft-dev/omarchy-supplement](https://github.com/typecraft-dev/omarchy-supplement) repository.

## Overview

JanStrap provides a single repository that can:
1. Bootstrap a workstation once
2. Re-apply updates any time (pull latest dotfiles/config and reconcile)

The system is designed with strict idempotency: safe to re-run, no interactive prompts, and guarded edits.

## Features

- **Idempotent**: Safe to run multiple times without duplication or errors
- **Host-specific configuration**: Common packages/dotfiles + per-workstation customization
- **Post-install scripts**: Optional per-package scripts for service enablement, user groups, database initialization, etc.
- **GNU Stow**: Clean dotfile management with symlinks
- **yay-based**: Uses `yay` for all package management (official repos and AUR)
- **Auto-detection**: Automatically detects hostname, or specify with `--host` flag
- **Git-aware**: Pulls updates automatically, exits early if no changes (override with `--force`)

## Getting Started

**This repository is a template.** Use GitHub's "Use this template" button to create your own independent copy.

1. **Click "Use this template"** on GitHub to create your own repository
   - This creates a clean, independent copy (not a fork)
   - You can make it private for your homelab configurations
2. **Clone your new repository:**
   ```bash
   git clone <your-new-repo-url> janstrap
   cd janstrap
   ```
3. **Customize the configurations:**
   - Replace example configs in `dotfiles/` with your own
   - Update `packages.txt` with your preferred tools
   - Create `hosts/<your-hostname>/` directories for each machine in your homelab
   - Add your host-specific packages, dotfiles, and overrides
4. **Commit your changes** to your repository
5. **Deploy on your workstations** (see Quick Start below)

The generic examples in this repository are intentionally minimal - they show the pattern but need your personal configuration to be useful.

## Repository Structure

```
janstrap/
├── install_all.sh          # Main entry point
├── packages.txt            # Common packages for all workstations
├── uninstall.txt           # Packages to uninstall from all workstations
├── stow.txt                # Common dotfiles to stow
├── overrides.conf          # Common Hyprland overrides (optional)
├── install/                # Post-install scripts for packages (optional)
│   └── cronie.sh           # Example: Enable cronie service after install
├── scripts/
│   ├── helpers.sh          # Utility functions
│   ├── uninstall_packages.sh # Package uninstallation (common + host-specific)
│   ├── install_packages.sh # Package installation (common + host-specific)
│   ├── install_dotfiles.sh # Dotfile stowing
│   └── install_overrides.sh # Override application
├── hosts/
│   ├── laptop1/            # Host-specific configuration
│   │   ├── packages.txt    # Additional packages for laptop1
│   │   ├── uninstall.txt   # Additional packages to uninstall (optional)
│   │   ├── stow.txt        # Additional dotfiles (optional)
│   │   ├── overrides.conf  # Host-specific Hyprland overrides
│   │   ├── install/        # Host-specific post-install scripts (optional)
│   │   │   └── tlp.sh      # Example: Enable tlp service on laptop
│   │   └── dotfiles/       # Host-specific dotfile overrides (optional)
│   │       └── waybar/     # Override specific files from common waybar package
│   └── laptop2/            # Another workstation
│       ├── packages.txt
│       ├── uninstall.txt   # (optional)
│       ├── stow.txt
│       ├── overrides.conf
│       ├── install/        # Host-specific post-install scripts (optional)
│       └── dotfiles/       # Host-specific dotfile overrides (optional)
└── dotfiles/               # Dotfile packages for stow
    ├── nvim/
    ├── tmux/
    ├── shell/
    ├── starship/
    ├── hypr/
    └── waybar/
```

## Requirements

JanStrap is designed for **Omarchy**, which comes with most requirements pre-installed:
- `yay` - Package manager for official repos and AUR (pre-installed)
- `git` - Repository cloning and updates (pre-installed)
- `stow` - Dotfile management with symlinks (needs to be installed)
- `cronie` - Cron daemon for automatic updates (optional, only if using scheduled updates)

### Installing Prerequisites

Install stow using yay:
```bash
yay -S stow
```

If you plan to use automatic updates, install and enable cronie:
```bash
yay -S cronie
sudo systemctl enable --now cronie
```

## Quick Start

Once you've created your own repository from this template and customized it:

1. Install stow (if not already installed):
```bash
yay -S stow
```

2. Clone your repository:
```bash
git clone <your-repo-url> janstrap
cd janstrap
```

3. Run the installer:
```bash
./install_all.sh
```

The installer will auto-detect your hostname and:
- Uninstall unwanted packages (from uninstall.txt, if any)
- Install common packages
- Install host-specific packages (if any)
- Stow common dotfiles
- Stow host-specific dotfiles (if any)
- Apply Hyprland overrides (host-specific preferred, falls back to common)

You can also specify a hostname explicitly:
```bash
./install_all.sh --host laptop1
```

Or use an environment variable:
```bash
HOST=laptop1 ./install_all.sh
```

### Hostname Detection

JanStrap detects your hostname in this order:
1. `--host` command line flag
2. `$HOST` environment variable
3. `hostname` command output
4. `/etc/hostname` file contents

## Re-Applying Updates

JanStrap is designed to be re-run safely. To update your system:

```bash
./install_all.sh
```

The installer will:
- Pull latest changes from git
- Reconcile package installations (using `--needed` flag)
- Update dotfile symlinks via stow (using restow)
- Re-apply overrides (idempotently)

If no updates are found, the installer will exit early. Use `-f` or `--force` to re-apply everything anyway:

```bash
./install_all.sh --force
```

## Automatic Updates

JanStrap can automatically check for and apply updates on a schedule, keeping all your workstations in sync without manual intervention.

**Prerequisite:** This feature requires `cronie` to be installed and enabled. See the [Requirements](#requirements) section for installation instructions.

### How It Works

When enabled, JanStrap will:
- Run on your chosen schedule (hourly, daily, etc.)
- Pull latest changes from git
- Apply updates only if changes are found
- Log all activity for review

This is perfect for homelab setups where you want changes to propagate automatically across all machines.

### Enable Automatic Updates

```bash
./scripts/enable_auto_update.sh
```

You'll be prompted to choose an update schedule:
- Every hour (recommended for active development)
- Every 6 hours
- Every 12 hours
- Daily at 2 AM
- Custom cron schedule

Logs are written to `~/.janstrap-auto-update.log`

### Disable Automatic Updates

```bash
./scripts/disable_auto_update.sh
```

### Monitoring

View the auto-update log:
```bash
tail -f ~/.janstrap-auto-update.log
```

### Important Considerations

✅ **Benefits:**
- Push once, all machines update automatically
- Maintains consistency across your homelab
- Idempotent design makes it safe to run repeatedly

⚠️ **Trade-offs:**
- Changes apply without manual review
- Settings may change while you're working
- Consider testing changes on one machine before pushing to all

**Tip:** For critical changes, test on a single machine first, then push to let other machines auto-update.

### Sudo and Post-Install Scripts

Post-install scripts that enable systemd services require `sudo` access. When running manually, you'll be prompted for your password. **However, automated/scheduled runs cannot prompt for passwords.**

**Behavior:**
- **Manual runs**: Prompts for password → services enabled
- **Automated runs**: Skips service enablement → logs warning

**Solution for full automation** (optional):

If you want post-install scripts to enable services during automated runs, configure passwordless sudo for specific systemctl commands:

1. Create a sudoers file:
```bash
sudo visudo -f /etc/sudoers.d/janstrap
```

2. Add this content (replace `yourusername` with your actual username):
```
yourusername ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable *, /usr/bin/systemctl start *, /usr/bin/systemctl mask *
```

3. Save and exit (Ctrl+X, then Y, then Enter in nano)

**Important notes:**
- This is a **one-time manual setup** per machine
- Only needed if you want automated service enablement
- Services only need to be enabled **once** - subsequent updates don't re-enable them
- Most users can skip this and just enable services during the first manual run

## Configuration Files

### packages.txt

List of packages to install, one per line. Comments start with `#`.
All packages are installed via `yay`, which handles both official repository and AUR packages.

- Root `packages.txt`: Common packages for all workstations
- `hosts/<hostname>/packages.txt`: Additional packages for specific workstations

Packages are deduplicated automatically, so overlaps between common and host-specific lists are fine.

### uninstall.txt

List of packages to uninstall (remove), one per line. Comments start with `#`.
These packages will be removed if they are currently installed, using `yay -Rns` (removes package with unused dependencies).

- Root `uninstall.txt`: Packages to remove from all workstations
- `hosts/<hostname>/uninstall.txt`: Additional packages to remove from specific workstations (optional)

**When to use uninstall.txt:**
- Replacing one package with another (e.g., `omarchy-chromium` → `google-chrome`)
- Removing pre-installed packages you don't want
- Cleaning up packages that are no longer needed

**Example:**
```
# Replace Chromium with Chrome
omarchy-chromium
```

The uninstall step runs **before** package installation, so you can safely replace packages in one operation. Packages are deduplicated automatically, and only installed packages will be removed (idempotent).

### stow.txt

List of dotfile packages to stow, one per line. These correspond to directories in `dotfiles/`.

- Root `stow.txt`: Common dotfiles for all workstations
- `hosts/<hostname>/stow.txt`: Additional dotfiles for specific workstations (optional)

### overrides.conf

Hyprland configuration overrides. This file is automatically sourced by the Hyprland config.

- Root `overrides.conf`: Common overrides (optional)
- `hosts/<hostname>/overrides.conf`: Host-specific overrides (preferred if exists)

Host-specific overrides take precedence over common overrides. This is useful for different monitor setups per workstation.

The override file is sourced via a line appended to `~/.config/hypr/hyprland.conf`:
```
source = ~/.config/hypr/overrides.conf
```

### Post-Install Scripts

Some packages require additional configuration after installation, such as enabling services, adding users to groups, or initializing databases. JanStrap supports optional post-install scripts that run automatically after packages are installed.

**When to use post-install scripts:**
- Enabling and starting systemd services (e.g., `cronie`, `tlp`, `docker`)
- Adding users to groups (e.g., adding current user to `docker` group)
- Initializing databases or application data
- Any idempotent configuration that should happen after package installation

**When NOT to use post-install scripts:**
- Most packages work fine without post-install configuration
- Only create scripts for packages that actually need post-installation steps

#### Script Locations

- `install/<package>.sh`: Common post-install scripts (run on all workstations)
- `hosts/<hostname>/install/<package>.sh`: Host-specific post-install scripts

Both scripts will run if they exist (common first, then host-specific). This allows you to have base configuration in common scripts and extend it with host-specific customization.

#### Script Requirements

1. **Filename must match package name**: For a package named `cronie`, the script must be `cronie.sh`
2. **Must be executable**: `chmod +x install/cronie.sh`
3. **Must be idempotent**: Safe to run multiple times without errors

#### Example: Common Install Script

`install/cronie.sh` - Enable cronie service on all workstations:

```bash
#!/bin/sh
# Post-install script for cronie
# Enables and starts the cronie service (cron daemon)

set -eu

# Source helpers for logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../scripts/helpers.sh" 2>/dev/null || . "$(dirname "$SCRIPT_DIR")/scripts/helpers.sh"

# Check if we can use sudo without password
if ! sudo -n true 2>/dev/null; then
    warn "Cannot enable cronie.service without sudo access (run manually or configure passwordless sudo)"
    exit 0
fi

# Enable service if not already enabled
if ! systemctl is-enabled cronie.service >/dev/null 2>&1; then
    sudo systemctl enable cronie.service
fi

# Start service if not already running
if ! systemctl is-active cronie.service >/dev/null 2>&1; then
    sudo systemctl start cronie.service
fi
```

#### Example: Host-Specific Install Script

`hosts/laptop1/install/tlp.sh` - Enable tlp (power management) only on laptop1:

```bash
#!/bin/sh
# Post-install script for tlp (laptop power management)
# Enables and starts the tlp service

set -eu

# Source helpers for logging
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../../scripts/helpers.sh" 2>/dev/null || . "$(dirname "$(dirname "$SCRIPT_DIR")")/scripts/helpers.sh"

# Check if we can use sudo without password
if ! sudo -n true 2>/dev/null; then
    warn "Cannot enable tlp.service without sudo access (run manually or configure passwordless sudo)"
    exit 0
fi

# Enable service if not already enabled
if ! systemctl is-enabled tlp.service >/dev/null 2>&1; then
    sudo systemctl enable tlp.service
fi

# Start service if not already running
if ! systemctl is-active tlp.service >/dev/null 2>&1; then
    sudo systemctl start tlp.service
fi

# Mask conflicting rfkill services
if systemctl list-unit-files systemd-rfkill.service >/dev/null 2>&1; then
    if ! systemctl is-masked systemd-rfkill.service >/dev/null 2>&1; then
        sudo systemctl mask systemd-rfkill.service
    fi
fi

if systemctl list-unit-files systemd-rfkill.socket >/dev/null 2>&1; then
    if ! systemctl is-masked systemd-rfkill.socket >/dev/null 2>&1; then
        sudo systemctl mask systemd-rfkill.socket
    fi
fi
```

#### How It Works

1. Packages are installed from `packages.txt`
2. For each installed package, JanStrap checks if post-install scripts exist:
   - First runs `install/<package>.sh` if it exists (common configuration)
   - Then runs `hosts/<hostname>/install/<package>.sh` if it exists (host-specific configuration)
3. Scripts are executed with `--host` flag passed automatically
4. If a script fails, a warning is logged but installation continues

This hybrid approach keeps your repository clean: most packages are just listed in `packages.txt`, while the few that need post-installation steps get dedicated scripts.

## Adding a New Host

To add a new workstation to JanStrap:

1. Create a directory in `hosts/` matching your hostname: `hosts/<hostname>/`
2. Add the following files (see `hosts/laptop1/` for a working example):
   - `packages.txt` - Additional packages specific to this host (optional)
   - `stow.txt` - Additional dotfiles to stow for this host (optional)
   - `overrides.conf` - Hyprland overrides for this host, such as monitor configuration (optional)
   - `install/` - Host-specific post-install scripts (optional, see Post-Install Scripts section)
   - `dotfiles/` - Host-specific dotfile overrides (optional, see below)
3. Populate the files with host-specific configuration
4. Run `./install_all.sh` on that workstation

The installer will automatically detect the hostname and apply both common and host-specific configurations.

### Host-Specific Dotfile Overrides

You can override individual files from common dotfile packages without duplicating the entire package. For example, to use a different waybar config on laptop1:

1. Create `hosts/laptop1/dotfiles/waybar/.config/waybar/config` with your laptop1-specific config
2. The installer will use your host-specific `config` while keeping other waybar files (like `style.css`) from the common package

This allows per-file customization across hosts without maintaining duplicate copies of unchanged files.

## Adding New Dotfiles

To add new dotfiles to JanStrap:

1. Create a new directory in `dotfiles/`: `dotfiles/<package-name>/`
2. Structure your files as they should appear in your home directory (see `dotfiles/shell/` or `dotfiles/nvim/` for examples)
   - Files go directly in the package directory (e.g., `dotfiles/shell/.bashrc` → `~/.bashrc`)
   - Config files go in subdirectories (e.g., `dotfiles/nvim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`)
3. Add the package name to `stow.txt` (for all hosts) or `hosts/<hostname>/stow.txt` (for specific hosts)
4. Run `./install_all.sh` to test the installation

Stow will create symlinks from your home directory to the files in the JanStrap repository.

**Note:** You can override individual files on specific hosts by placing them in `hosts/<hostname>/dotfiles/<package-name>/`. See "Host-Specific Dotfile Overrides" above for details.

## Omarchy-Specific Notes

### First Omarchy Setup

After installing Omarchy from the ISO, you'll see two initial notifications:
- Setup WiFi
- Update system

Complete both steps, then create a snapshot to preserve this clean baseline state:
```bash
sudo snapper -c root create --description "Fresh install, updated, known good state"
```

This snapshot allows you to quickly revert to a known-good state if needed, without having to reinstall from scratch.
