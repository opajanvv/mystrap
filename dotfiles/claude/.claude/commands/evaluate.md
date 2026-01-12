# Evaluate

Review the completed work and propose improvements to Claude Code instructions.

## Instructions

1. Review what was accomplished in this session by examining:
   - The todo list (if used)
   - Git commits made during this session
   - Files created or modified
   - Any challenges or friction encountered

2. Identify learnings and potential improvements:
   - What patterns emerged that could be codified?
   - What instructions would have helped avoid mistakes?
   - What context was missing that had to be discovered?
   - Were there repeated clarifications that could become defaults?

3. Present findings as a numbered list of specific, actionable suggestions:
   - Specify the target file (global `~/.claude/CLAUDE.md`, project `CLAUDE.md`, or folder-level)
   - Describe the change concisely
   - Explain why it would help

   Example format:
   ```
   1. [Global] Add rule to always check for existing tests before writing new ones
      - Had to ask twice about test conventions
   2. [Project] Document the frontmatter format for ideas/
      - Spent time figuring out required fields
   ```

4. Wait for Jan to choose which suggestions to implement (by number).

5. After implementing the chosen suggestions, remind Jan to run `/compact` to start fresh with the updated instructions.
