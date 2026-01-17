---
description: How to organize slash commands between global and project-level
globs:
  - .claude/commands/**
  - commands/**
---

# Slash command organization

Commands live in two locations:

**Global** (`~/.claude/commands/`, symlinked from dotfiles):
- Generic workflows that work in any project
- Examples: commit-and-push, evaluate, plan, review-text, cleanup-downloads

**Project-level** (`.claude/commands/` in a repo):
- Commands that depend on project-specific structure
- Examples: task management, project workflows, vault-specific routines

When creating a new command, ask: "Does this need project-specific folders or conventions?" If yes, put it in the project. If it's generic, put it in global.

**Testing new commands**: After creating a new command in `.claude/commands/`, Jan will exit and run `claude -r` to restart and resume the conversation. Claude Code needs to restart to pick up new commands.
