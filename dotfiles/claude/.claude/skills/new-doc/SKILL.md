---
name: new-doc
description: File new documentation into the correct location (docs/ or llm-context/). Use when Jan wants to add documentation, says "document this", "new doc", "add to docs", or has content that belongs in the vault's documentation structure. Handles creating files, updating routing entries, and keeping the index in sync.
---

# New doc

Add documentation to Jan's vault, auto-filing to the right location.

## Key paths

- Vault root: `~/Cloud/janvv/life/`
- LLM context: `~/Cloud/janvv/life/llm-context/`
- Docs: `~/Cloud/janvv/life/docs/`
- Index: `~/Cloud/janvv/life/llm-context/index.md`

## Workflow

1. Take the content description from Jan (topic, notes, any source material)
2. Read `~/Cloud/janvv/life/llm-context/index.md` to understand existing topics
3. Decide destination using the filing rules in [references/filing-rules.md](references/filing-rules.md)
4. Create or update the file
5. Update routing and index as needed (see below)
6. Report where content was filed -- no confirmation step, just do it

## Updating the index

When creating a new file (in either location), check whether the trigger table in `llm-context/index.md` already covers the topic.

- **Topic already in trigger table**: No index change needed. If adding to an existing llm-context file that routes to docs/, just update the routing file.
- **New topic**: Add a row to the trigger table with relevant triggers and the file reference.

## Routing entries

When a topic lives in `docs/` but should be discoverable via llm-context:

- Create or update a routing file in `llm-context/` that points to the docs location
- Format: brief topic summary (2-3 lines max) followed by "For details, read `docs/path/to/file.md`"
- Existing routing files (like `llm-context/homelab.md`) show the pattern
