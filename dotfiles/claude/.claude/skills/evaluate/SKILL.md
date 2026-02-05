---
name: evaluate
description: Reflect on completed work and improve instructions. Use when Jan asks for evaluation, reflection, lessons learned, retrospective, or what went well/wrong.
---

# Evaluate

Review a session's work, extract learnings, and propose improvements to instructions, commands, and skills.

## Workflow

### 1. Summarize the session

Review what happened by examining:
- The todo list (if used)
- Key decisions made
- Challenges or friction encountered
- Clarifications that were needed
- Cases where Claude searched llm-context files but didn't find needed information, or had to ask Jan for project/domain knowledge that could have been documented

Present a brief summary:
- Working directory
- Work completed (bullet points)
- Friction points

### 2. Analyze the work

If in a git repository, use a sub-agent to gather evidence:

```
Task(
  description: "Analyze session for improvements",
  subagent_type: "Bash",
  prompt: "Run git log --oneline -20 and git diff HEAD~N (estimate N from session commits). Look for: mistakes (fix commits, reverts, multiple attempts), patterns worth documenting, friction points: [insert friction from step 1]. Return a list of findings and suggested improvements with rationale."
)
```

If not in a git repository, analyze based on the session summary, conversation history, and any files changed.

### 3. Present findings

Share:
- What went well
- What caused friction or mistakes
- Suggested improvements (numbered list with target file, change, and rationale)

Improvement targets include:
- Global instructions (`~/.claude/CLAUDE.md`)
- Project instructions (`./CLAUDE.md`)
- Commands (`~/.claude/commands/` or project commands) that were used and had issues
- Skills (`~/.claude/skills/`) that were used and could work better
- LLM context files (`~/Cloud/janvv/life/llm-context/`) -- suggest additions when Claude lacked project/domain knowledge that should be documented

If nothing to improve, acknowledge the session went smoothly.

### 4. Implement selected suggestions

Ask Jan which suggestions to implement (by number, "all", or "none").

For each selected suggestion:
- Read the target CLAUDE.md file
- Make the change following existing style
- Confirm the edit
