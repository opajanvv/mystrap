---
name: review-docs
description: Review documentation health across docs/ and llm-context/. Use when Jan asks to review docs, check documentation health, audit the docs structure, or for periodic documentation maintenance. Finds orphaned references, missing index entries, overgrown files, and duplicates.
---

# Review docs

Audit the documentation structure across `docs/` and `llm-context/` for health issues.

## Key paths

- LLM context: `~/Cloud/janvv/life/llm-context/`
- Docs: `~/Cloud/janvv/life/docs/`
- Index: `~/Cloud/janvv/life/llm-context/index.md`

## Workflow

1. Read `~/Cloud/janvv/life/llm-context/index.md`
2. List all files in `llm-context/` and `docs/` (recursive)
3. For each llm-context file that references docs/ paths, verify the target exists
4. Run all checks below
5. Present findings grouped by severity (errors first, then warnings, then suggestions)
6. For each issue, propose a concrete fix. Ask Jan which to apply.

## Checks

### Errors (broken references)

- **Orphaned routing**: llm-context file points to a docs/ path that doesn't exist
- **Broken index entries**: trigger table references a file that doesn't exist

### Warnings (structural issues)

- **Missing from index**: Files in llm-context/ or docs/ not reachable from the trigger table (check both direct references and routing files)
- **Overgrown llm-context files**: Files in llm-context/ over 50 lines -- consider moving content to docs/ with a routing entry
- **Duplicate coverage**: Same topic documented in both llm-context/ and docs/ without clear routing relationship

### Suggestions (maintenance)

- **Stale content**: Files with modification date older than 6 months -- flag for review, don't auto-fix
- **Empty or near-empty files**: Files under 5 lines of content (excluding frontmatter)

## Output format

```
## Documentation health report

### Errors
- [description] -> [proposed fix]

### Warnings
- [description] -> [proposed fix]

### Suggestions
- [description]

### Summary
X errors, Y warnings, Z suggestions
```

If no issues found, say so -- don't invent problems.
