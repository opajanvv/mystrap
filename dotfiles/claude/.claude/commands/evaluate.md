# Evaluate

Review the completed work and propose improvements to Claude Code instructions.

## Instructions

### Step 1: Summarize the session

Review what was accomplished by examining:
- The todo list (if used)
- Key decisions made
- Any challenges or friction encountered
- Clarifications that were needed

Create a brief summary with:
- Working directory
- Work completed (bullet points)
- Friction points encountered

### Step 2: Invoke Session Reviewer sub-agent

Use the Task tool to analyze the session:

```
Task(
  description: "Analyze session for improvements",
  subagent_type: "Bash",
  prompt: """
Analyze this Claude Code session and suggest instruction improvements.

Gather evidence by running:
- git log --oneline -20
- git diff HEAD~N (where N = number of commits in this session, estimate from log)
- git log --format="%s%n%b" -N for full commit messages

Analyze for:
- Mistakes requiring correction (fix commits, reverts, multiple attempts)
- Information discovered that could be documented
- Patterns that emerged (new conventions established)
- Friction points: [insert from step 1]

Return suggestions in this format:

SUGGESTIONS_START
---
target: global | project
file: ~/.claude/CLAUDE.md | ./CLAUDE.md
section: "Section name to add/modify"
action: add | modify
priority: high | medium | low
suggestion: |
  Description of the change
rationale: |
  Why this helps (cite specific evidence from git history)
---
SUGGESTIONS_END

If no improvements are warranted, return:
SUGGESTIONS_START
none
SUGGESTIONS_END

Session context:
- Working directory: [insert cwd]
- Work completed: [insert from step 1]
- Friction points: [insert from step 1]
"""
)
```

### Step 3: Parse and present suggestions

Extract suggestions from the sub-agent response and present as numbered list:

```
1. [Global/Project] Section name - Brief summary
   Priority: high/medium/low
   Evidence: Rationale from sub-agent
```

If no suggestions, acknowledge that the session went smoothly.

### Step 4: Wait for selection

Ask Jan which suggestions to implement:
- By number (e.g., "1 and 3")
- "all" to implement everything
- "none" to skip

### Step 5: Implement selected suggestions

For each selected suggestion:
- Read the target CLAUDE.md file
- Make the specified change following existing style
- Confirm the edit

### Step 6: Wrap up

After implementing changes, remind Jan to run `/compact` to reload with updated instructions.
