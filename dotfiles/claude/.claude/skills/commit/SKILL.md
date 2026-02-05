---
name: commit
description: Stage, commit, and push git changes. Use when the user says "commit", "commit and push", "push changes", or invokes /commit. Handles splitting unrelated changes into separate focused commits.
---

# Commit

## Workflow

1. Run `git diff` and `git status` to review all staged and unstaged changes.

2. Check for unrelated changes that belong to earlier/separate work. Signs: different files touching different features, logically independent changes mixed together.

3. If unrelated changes exist:
   - Stage and commit those separately first with their own message.
   - Then commit the current work.

4. Keep each commit focused on one logical change.

5. Write concise, single-line commit messages. Use imperative mood ("add feature" not "added feature").

6. Push to the remote after committing.
