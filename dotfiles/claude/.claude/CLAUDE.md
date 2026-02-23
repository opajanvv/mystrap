# Global rules

## Working style
- When writing health checks or connectivity tests, verify the HTTP method matches what the endpoint expects (POST-only endpoints return 405 on GET)
- Trust Jan's expertise; ask rather than assume wrong
- Work in small chunks; high-level structure first
- Prefer minimal solutions; don't create plugins when a simple hook/script will do
- Prefer tool-agnostic config (CLAUDE.md) over tool-specific features (.claude/rules/) for compatibility with other AI tools
- Skip obvious confirmations (commit after changes, mark done after completing)
- Test proactively: when implementing changes, suggest or create test cases before declaring work done. For scripts, consider: test fixtures, mock data, or temporary test resources.
- Use task tracking for 5+ steps or complex dependencies; skip for straightforward sequential work
- Clean up temp files when done
- Read project README and CLAUDE.md first in new projects
- When creating files for other agents (specs, plans, todos), be specific and unambiguous. Resolve all thinking before writing. These files must be executable by a cheaper model.
- When implementing a plan that contains factual claims about existing workflows or processes, verify those claims against source documentation before writing content.
- Create scripts in `~/dev/mystrap/dotfiles/shell/.local/bin/`, not `~/.local/bin/` (symlinks go in `~/.local/bin/`)

## Communication
Be direct and natural. Avoid:
- Chatbot phrases ("Of course!", "Certainly!", "I hope this helps")
- Emojis, em dashes, title case headers, curly quotes
- Placeholder text, hallucinated facts
- Knowledge disclaimers ("As of [date]...")

Ask rather than guess. Cite sources when researching frameworks. When Jan drops an argument or direction, accept it — don't re-pitch it.

## Markdown files
Use "Jan" and "Claude" instead of pronouns to avoid ambiguity.

## Context on-demand
This CLAUDE.md is intentionally concise. For detailed knowledge:
- Read `~/Cloud/janvv/life/llm-context/index.md` to see available context
- Follow links only when relevant to the current task

## Vault structure
Most work happens in `~/Cloud/janvv/life/` with separate workspaces:
- **planning/** - Projects, tasks, ideas, daily overview (Claude Code root)
- **docs/** - Technical documentation, homelab (Claude Code root)
- **llm-context/** - Context summaries for Claude

Each subdirectory has its own CLAUDE.md with specific instructions. Work in the appropriate folder.

## External integrations
- **Mystrap**: `~/dev/mystrap` is the dotfiles repository. Uses stow, so scripts go in `dotfiles/shell/.local/bin/`. Skills live in `dotfiles/claude/.claude/skills/` and are tracked in this repo — commit skill changes via mystrap.
- **Vault scripts**: `~/.local/bin/vault-*` scripts for scanning, cleanup, creating tasks, and TODAY.md generation
- **Calendar**: `~/.local/bin/calendar-today` fetches Google Calendar events (see `llm-context/google-api.md`)
- **Homelab**: `~/dev/homelab-docker` contains Docker Compose files

## Server operations
- Use the `remote-server` skill for running commands on the Proxmox server via SSH
- Source configs in `~/dev/homelab-docker/` are deployed via git push + pull on server (bind-mounted into LXCs)
- Git pull on the server requires SSH agent forwarding (`ssh -A jan@server`) -- there is no GitHub SSH key on the server
- All LXCs are unprivileged -- bind-mounted files must be world-readable (`o+rX`)
- Never assume local edits apply automatically to remote servers
- Pi-hole (192.168.144.20) has no SSH access and no stored API credentials -- DNS records must be added manually via the web UI

## rclone operations
- `rclone move`/`rclone sync` fails on overlapping remotes (e.g. subdirectory → parent). Use `rclone copy --files-from` instead when source and destination share a common ancestor.
- Before running `rclone purge` or `rclone delete`, verify the destination file count matches expectations. Only purge after confirming the move/copy succeeded.
- Don't pipe rclone output inline (e.g. `rclone lsf ... | grep ...`). Write to a file first, then process separately — shell pipes mangle rclone's argument parsing.

## Git commits
- Never run git commit directly. Always use the auto-committer agent via the Task tool.
- Only commit when the user explicitly asks, or when "commit" is clearly part of the requested task.
- If no git repository exists in the current directory, do nothing and inform the user.

## After significant work
Propose `/evaluate` to reflect on the session and improve instructions.

