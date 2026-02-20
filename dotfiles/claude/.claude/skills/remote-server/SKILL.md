---
name: remote-server
description: >
  Execute commands on Jan's remote Proxmox server via SSH. Use for ANY task that
  needs to run on the homelab server: Proxmox operations (pct, qm, pvesm),
  Docker management, systemctl, file operations, package management, checking
  logs, or any other remote command. Triggers: server commands, Proxmox, LXC
  containers, VMs, remote Docker, homelab operations, "run on server", "check
  on server", container status, server logs.
---

# Remote server

Execute commands on Jan's Proxmox homelab server via SSH.

## Connection

```
ssh jan@server "command"
```

The `server` alias is configured in `~/.ssh/config`.

## Execution patterns

**Single command:**
```bash
ssh jan@server "sudo pct list"
```

**Multi-command or complex logic:** write a temporary script, pipe it, then clean up:
```bash
ssh jan@server 'bash -s' < /tmp/remote-task.sh
rm /tmp/remote-task.sh
```

Important: a piped script runs as `jan`, not root. Every command that needs elevated privileges must use `sudo` explicitly — there is no ambient root context. Don't skip sudo assuming the script runs as root.

**Commands requiring sudo:** Proxmox commands (pct, qm, pvesm) require sudo. Always use `sudo` for these. Other commands (docker, systemctl) typically don't need sudo:
```bash
ssh jan@server "sudo systemctl restart docker"
```

**Follow these patterns:** when this skill is loaded, use its execution patterns. Don't bypass them with ad-hoc inline Bash — the patterns exist to ensure consistent sudo usage, cleanup, and risk classification.

## Risk categories

Classify every command before running:

**Safe (run without asking):**
- Status/list: `pct list`, `qm list`, `pct status <ID>`, `qm status <ID>`
- Logs: `journalctl`, `docker logs`, `cat`
- Info: `df`, `free`, `uptime`, `ip addr`, `docker ps`, `systemctl status`
- Listing files, reading configs

**Needs confirmation (ask Jan first):**
- Start/stop/restart containers or VMs: `pct start/stop/restart`, `qm start/stop/restart`
- Docker operations: `docker compose up/down`, `docker restart`
- Service management: `systemctl start/stop/restart/enable/disable`
- File modifications, writing files, creating directories
- Package operations: `pacman -S`, `pacman -Syu`
- Config changes: `pct set`, `qm set`
- Network changes

**Dangerous (warn explicitly about consequences):**
- Destroying containers/VMs: `pct destroy`, `qm destroy`
- Removing data: `rm -rf`, deleting volumes
- ZFS pool/dataset modifications
- Rebooting the server

## Syncing configs

Source configs live in `~/dev/homelab-docker/` locally and are version-controlled with git. The Proxmox host repo at `/home/jan/homelab-docker` is bind-mounted into all LXCs at `/opt/homelab-docker`.

To deploy config changes:

```bash
# 1. Push from local
cd ~/dev/homelab-docker && git push

# 2. Pull on server
ssh jan@server "cd /home/jan/homelab-docker && git pull"

# 3. Restart affected service
ssh jan@server "sudo pct exec <CT_ID> -- bash -c 'cd /opt/homelab-docker/<service> && docker compose up -d'"
```

Changes are visible in all LXCs immediately after the pull (bind mount, no per-container sync needed).

All LXCs are unprivileged (`unprivileged: 1`), so root inside maps to uid 100000 on the host. Bind-mounted files must be world-readable. The server repo has `core.sharedRepository=world` to ensure `git pull` creates readable files.

Always edit configs locally first, then push. Never edit directly on the server.

## Troubleshooting

**`curl: (23) client returned ERROR on write of N bytes` in a piped script**
This means the destination path is not writable — it's a permissions error, not a network error. Add `sudo` to the curl command writing to a system path (e.g. `/usr/local/bin/`).

## Homelab context

Read these as needed for context on specific operations:
- `~/Cloud/janvv/life/docs/homelab/infrastructure/proxmox.md` - Proxmox commands, LXC setup
- `~/Cloud/janvv/life/docs/homelab/services/all-services.md` - Service overview
- `~/Cloud/janvv/life/docs/homelab/infrastructure/network.md` - IP assignments
- `~/dev/homelab-docker/` - Docker Compose source configs
