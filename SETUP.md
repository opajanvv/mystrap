# New Machine Setup

Checklist for bootstrapping a fresh Omarchy workstation.

## Prerequisites

- [ ] Omarchy installed
- [ ] Network connection
- [ ] User account created (username: `jan`)

## Steps

```sh
# 1. Clone mystrap
git clone https://github.com/<user>/mystrap.git ~/dev/mystrap
cd ~/dev/mystrap

# 2. Set up passwordless sudo
sudo ./scripts/setup_passwordless_sudo.sh

# 3. Run bootstrap
./install_all.sh --force

# 4. Set up SSH keys
./scripts/setup_ssh.sh
```

## Post-setup

- [ ] Add machine's public key to `server:~/.ssh/authorized_keys`
- [ ] Test SSH: `ssh server`
- [ ] Re-source shell: `source ~/.bashrc` (or restart terminal)

## First Machine Only

If this is the first machine (shared keys don't exist in repo yet):

```sh
# Encrypt existing keys with your chosen passphrase
age -p -o dotfiles/ssh/.ssh/encrypted/github.age ~/.ssh/github
age -p -o dotfiles/ssh/.ssh/encrypted/gitlab.age ~/.ssh/gitlab

# Commit and push
git add dotfiles/ssh/.ssh/encrypted/
git commit -m "Add encrypted SSH keys"
git push
```
