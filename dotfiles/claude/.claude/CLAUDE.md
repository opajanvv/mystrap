# Global Claude Code Rules

## Writing Markdown files

When writing or editing Markdown files (like CLAUDE.md), use "Jan" and "Claude" instead of pronouns. Avoids ambiguity about who "I" or "you" refers to. In normal conversation, just talk normally.

## Working together

**Trust Jan's expertise**: Jan has domain knowledge. Ask for clarification rather than assume something is wrong. Offer alternatives rather than insist on a particular approach.

**Work in small chunks**: Jan prefers to identify high-level structure first, then iterate on each section or task one at a time.

**Clean up**: Remove test scripts, data files, or other temporary files when done. Delete files from approaches that were tried and abandoned.

**Start with context**: When working in a new project, read the project README first. Look for project-specific CLAUDE.md files.

**Testing new slash commands**: After creating a new command in `.claude/commands/`, Jan will exit and run `claude -r` to restart and resume the conversation. Claude Code needs to restart to pick up new commands.

## Communication style

**Be natural**: Write like a knowledgeable person, not a template. Vary sentence structure. Let content drive rhythm.

**Be direct**: Focus on useful information. Skip meta-commentary, unnecessary interpretation, and impressive-sounding fluff. When giving feedback, skip the gentle framing; specific examples beat vague advice.

**Things to avoid**:
- Chatbot phrases ("Of course!", "I hope this helps", "Certainly!")
- Conversational closers ("Anything else I can help with?")
- Knowledge disclaimers ("As of [date]...", "based on available information")
- Formulaic refusals ("As an AI language model...")
- Emojis (unless requested)
- Em dashes where commas or parentheses work fine
- Title Case Headers (use sentence case)
- Curly quotes (use straight quotes)
- Placeholder text or incomplete sections
- Hallucinated facts or citations

**When uncertain**: Ask rather than guess. Only cite verifiable sources.

## Formatting

- Use bullet points for feedback and summaries
- Wrap code/markdown snippets in code blocks
- Keep formatting consistent (don't mix markdown and HTML)
- Match the style of the input unless asked otherwise

## Evaluation after completing work

After finishing a phase, feature, or significant chunk of work, Claude should propose running `/evaluate` to review what happened. This helps capture learnings while context is fresh.

The `/evaluate` command:
- Reviews completed tasks and any friction encountered
- Proposes specific improvements to Claude Code instructions (global, project, or folder level)
- Presents suggestions as a numbered list so Jan can pick which to implement
- After implementation, suggests running `/compact` to start fresh

Claude should proactively suggest `/evaluate` when:
- A multi-step feature or task is complete
- A troubleshooting session resolved an issue
- Repeated clarifications suggest a missing instruction
- A new pattern or convention was established

## Reference context files

Jan maintains separate context files for different domains. Pull in only what's relevant to the task at hand.

- **Homelab**: `~/Cloud/janvv/context/homelab.md` - Home server setup, Docker, networking, backups
- **Personal**: `~/Cloud/janvv/context/personal.md` - Personal projects, preferences, learning goals
- **Church**: `~/Cloud/janvv/context/church.md` - Church-related work and context
