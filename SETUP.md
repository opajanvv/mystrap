# New Machine Setup

Checklist for bootstrapping a fresh Omarchy workstation.

## Prerequisites

- [ ] Omarchy installed
- [ ] WiFi configured (prompted on first boot)
- [ ] Omarchy updated (prompted on first boot)

## Steps

```sh
# 1. Create restore point
sudo snapper create -d "Fresh Omarchy install"

# 2. Clone mystrap
git clone https://github.com/opajanvv/mystrap
cd mystrap

# 3. Set up passwordless sudo
sudo ./scripts/setup_passwordless_sudo.sh

# 4. Run bootstrap
./install_all.sh --force

# 5. Set up SSH keys
./scripts/setup_ssh.sh

# 6. Set up rclone (decrypt config)
./scripts/setup_rclone.sh

# 7. Set up Google Drive sync (may take hours on first run)
./scripts/setup_cloud.sh
```

## Post-setup

- [ ] Add machine's public key to `server:~/.ssh/authorized_keys`
      (Tip: use Proxmox web UI shell at https://server:8006 to paste the key)
- [ ] Test SSH: `ssh server`
- [ ] Re-source shell: `source ~/.bashrc` (or restart terminal)

## First Machine Only

If this is the first machine (encrypted secrets don't exist in repo yet):

### SSH Keys
```sh
# Encrypt existing keys with your chosen passphrase
age -p -o dotfiles/ssh/.ssh/encrypted/github.age ~/.ssh/github
age -p -o dotfiles/ssh/.ssh/encrypted/gitlab.age ~/.ssh/gitlab

# Commit and push
git add dotfiles/ssh/.ssh/encrypted/
git commit -m "Add encrypted SSH keys"
git push
```

### Rclone Config
```sh
# Encrypt existing rclone config
age -p -o dotfiles/rclone/.config/rclone/rclone.conf.age ~/.config/rclone/rclone.conf

# Commit and push
git add dotfiles/rclone/.config/rclone/rclone.conf.age
git commit -m "Add encrypted rclone config"
git push
```

### Google Drive
Ensure each remote drive has a `RCLONE_TEST` file in its root (required by `--check-access`).
