# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**mystrap** is a personal implementation of the JanStrap framework (from template repository `opajanvv/janstrap`). JanStrap is an idempotent bootstrap system for Omarchy (Arch Linux) workstations that automates package installation, dotfile management, and host-specific configurations.

This repository is in early development, being built incrementally and tested across two homelab machines: `laptop1` and `laptop2`. Additional machines may be added in the future.

## Core Commands

### Main Installation
```bash
./install_all.sh              # Run full bootstrap (auto-pulls git updates)
./install_all.sh --force      # Force re-apply even without updates
./install_all.sh --host <name> # Override hostname detection
```

### Individual Components
```bash
./scripts/uninstall_packages.sh  # Uninstall packages from uninstall.txt
./scripts/install_packages.sh    # Install packages from packages.txt
./scripts/install_dotfiles.sh    # Apply dotfiles via GNU Stow
./scripts/install_overrides.sh --host <name>  # Install Hyprland overrides
```

## Architecture

### Bootstrap Process Flow
The `install_all.sh` orchestrates four sequential steps:
1. **Uninstall packages** - Removes unwanted packages (from `uninstall.txt`)
2. **Install packages** - Installs all packages via `yay` (from `packages.txt`)
3. **Install dotfiles** - Applies dotfiles via GNU Stow (from `stow.txt`)
4. **Install overrides** - Applies host-specific Hyprland configs

### Configuration Files
- `packages.txt` - Packages to install (one per line, supports comments)
- `uninstall.txt` - Omarchy bloatware to remove on fresh install
- `stow.txt` - Dotfile packages to stow (corresponds to `dotfiles/` subdirs)

### Directory Structure
```
dotfiles/           # Common dotfiles (applied to all hosts via stow)
  hypr/             # Hyprland base configuration
  waybar/           # Waybar configuration
  shell/            # Shell configs

hosts/              # Host-specific configurations
  <hostname>/
    overrides.conf  # Hyprland overrides (monitors, workspaces, keybindings)
    dotfiles/       # Host-specific dotfiles (optional, applied via stow)

install/            # Post-install scripts (optional)
  <package>.sh      # Runs after <package> is installed
```

### Dotfile Management
- Uses **GNU Stow** to create symlinks from `dotfiles/` to `$HOME`
- Each subdirectory in `dotfiles/` is a "stow package"
- Example: `dotfiles/hypr/.config/hypr/hyprland.conf` → `~/.config/hypr/hyprland.conf`
- Supports both common dotfiles and host-specific overrides
- Host-specific dotfiles in `hosts/<hostname>/dotfiles/` override common ones

### Hyprland Override System
- `overrides.conf` is sourced by Hyprland's main config
- Each host has `hosts/<hostname>/overrides.conf` for machine-specific settings
- Used for monitor configurations, workspace assignments, and host-specific keybindings
- Falls back to `overrides.conf` (root level) if host-specific file doesn't exist
- The source line is automatically appended to `~/.config/hypr/hyprland.conf`

### Post-Install Scripts
- Optional scripts in `install/<package>.sh` run after package installation
- Must be executable and match package name exactly
- Must be idempotent (safe to run multiple times)
- Source `scripts/helpers.sh` for utility functions
- Example use cases: enabling systemd services, setting defaults

### Package Management
- Uses `yay` for all package operations (official repos + AUR)
- Install: `yay -S --needed --noconfirm` (in install_packages.sh)
- Uninstall: `yay -Rns --noconfirm` (in uninstall_packages.sh, removes with dependencies)

### Idempotency & Safety
- All scripts are POSIX sh compatible (use `#!/bin/sh`, not bash)
- Git-aware: automatically pulls updates, exits early if none found
- Stow conflict resolution: `stow_package()` removes non-symlink files blocking stow operations
- Post-install scripts should check state before making changes
- Minimal defensive checks - let commands fail naturally with clear errors

## Development Guidelines

### Philosophy
This codebase follows a **ruthless simplification** approach:
- **Trust the caller** - No defensive existence checks for required files/commands
- **Let commands fail naturally** - Clear error messages from tools are sufficient
- **Avoid abstraction** - Only create functions when eliminating substantial duplication
- **No meta-engineering** - Focus on solving actual problems, not building automation infrastructure
- **Keep it simple** - When in doubt, use direct commands over wrappers

### Shell Script Conventions
- Use POSIX sh for maximum compatibility (not bash-specific features)
- Always `set -eu` at the start of scripts
- Source `scripts/helpers.sh` for logging: `log()`, `warn()`, `die()`
- Trust the caller - let commands fail naturally with clear errors
- Use `hostname` command directly (no wrapper)

### Adding New Packages
1. Add package name to `packages.txt`
2. If needed, create executable `install/<package>.sh` for post-install tasks
3. Run `./install_all.sh --force` to test

### Adding New Dotfiles
1. Create directory structure under `dotfiles/<package>/`
2. Add package name to `stow.txt`
3. Test with `./scripts/install_dotfiles.sh`

### Host-Specific Configuration
- Create `hosts/<hostname>/overrides.conf` for Hyprland settings
- Create `hosts/<hostname>/dotfiles/` for host-specific dotfile packages
- Use `hostname` command to detect current host
- Currently configured hosts: `laptop1`, `laptop2`
