# Filing rules

Decision tree for where documentation goes.

## Step 1: Existing topic?

Check `llm-context/index.md` trigger table and scan existing files in both `llm-context/` and `docs/`.

- **Yes, file exists** -> Add content to the existing file, wherever it lives. Done.
- **No** -> Continue to step 2.

## Step 2: Choose destination

Ask: "Is a single flat file (< 50 lines) enough to cover this topic?"

- **Yes** -> Create in `llm-context/`. Examples: API credentials, tool config, quick reference.
- **No** -> Create in `docs/` with appropriate subfolder. Add routing entry in `llm-context/`. Examples: service setup with multiple sections, how-to guides, anything with subsections or steps.

## Subfolder conventions for docs/

- `docs/homelab/services/` - Service-specific documentation (Docker, config, troubleshooting)
- `docs/homelab/how-to/` - Step-by-step procedures
- `docs/homelab/` - General homelab topics (networking, architecture)
- `docs/personal/` - Non-technical personal documentation

Create new subfolders only when none of the above fit.

## Examples

| Topic | Destination | Reason |
|-------|-------------|--------|
| OAuth credentials for a new API | `llm-context/` | Short, flat reference |
| Syncthing setup and troubleshooting | `docs/homelab/services/syncthing.md` | Multiple sections, service config |
| New keybinding cheatsheet | `llm-context/` | Quick reference, single file |
| Backup strategy with multiple tools | `docs/homelab/how-to/backups.md` | Step-by-step, needs depth |
| Facts about a person | `llm-context/personal.md` | Existing file, add to it |
