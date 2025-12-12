# SSH Configuration

SSH keys and config are managed through mystrap with encryption for shared keys.

## Key Types

| Key | Purpose | Storage |
|-----|---------|---------|
| `github` | GitHub access | Encrypted in repo, shared across machines |
| `gitlab` | GitLab access | Encrypted in repo, shared across machines |
| `<hostname>` | Server access | Generated locally, unique per machine |

## Files

```
dotfiles/ssh/.ssh/
  config              # SSH config (stowed)
  github.pub          # Public keys (stowed)
  gitlab.pub
  encrypted/
    github.age        # Encrypted private keys
    gitlab.age

~/.config/mystrap/
  age-passphrase      # Local decryption passphrase

~/.ssh/
  <hostname>          # Machine-specific key (generated locally)
  <hostname>.pub
```

## New Machine Setup

```sh
./install_all.sh            # Stows config and public keys
./scripts/setup_ssh.sh      # Generates machine key, decrypts shared keys
```

Then manually add the machine's public key to `server:~/.ssh/authorized_keys`.

## Encrypting Shared Keys

One-time setup (from a machine that has the keys):

```sh
age -p -o dotfiles/ssh/.ssh/encrypted/github.age ~/.ssh/github
age -p -o dotfiles/ssh/.ssh/encrypted/gitlab.age ~/.ssh/gitlab
```

Use the same passphrase for all keys. Commit the `.age` files to the repo.

## Rotating a Shared Key

1. Generate new key: `ssh-keygen -t ed25519 -f ~/.ssh/github`
2. Register with service (GitHub/GitLab)
3. Encrypt: `age -p -o dotfiles/ssh/.ssh/encrypted/github.age ~/.ssh/github`
4. Update public key: `cp ~/.ssh/github.pub dotfiles/ssh/.ssh/`
5. Commit and push

Next `install_all.sh` on other machines will decrypt the new key.

## Config

The SSH config uses `%L` (local hostname) for the default identity:

```
Host *
  IdentityFile ~/.ssh/%L
```

This automatically uses `~/.ssh/laptop1` on laptop1, `~/.ssh/laptop2` on laptop2, etc.
