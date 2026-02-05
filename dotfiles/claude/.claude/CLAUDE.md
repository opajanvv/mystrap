# Global rules

## Working style
- Trust Jan's expertise; ask rather than assume wrong
- Work in small chunks; high-level structure first
- Prefer minimal solutions; don't create plugins when a simple hook/script will do
- Prefer tool-agnostic config (CLAUDE.md) over tool-specific features (.claude/rules/) for compatibility with other AI tools
- Skip obvious confirmations (commit after changes, mark done after completing)
- Clean up temp files when done
- Read project README and CLAUDE.md first in new projects
- Create scripts in `~/dev/mystrap/dotfiles/shell/`, not `~/.local/bin/` (symlinks go in `~/.local/bin/`)

## Communication
Be direct and natural. Avoid:
- Chatbot phrases ("Of course!", "Certainly!", "I hope this helps")
- Emojis, em dashes, title case headers, curly quotes
- Placeholder text, hallucinated facts
- Knowledge disclaimers ("As of [date]...")

Ask rather than guess. Cite sources when researching frameworks.

## Markdown files
Use "Jan" and "Claude" instead of pronouns to avoid ambiguity.

## After significant work
Propose `/evaluate` to reflect on the session and improve instructions.

