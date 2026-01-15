# Global Claude Code Rules

## Writing Markdown files

When writing or editing Markdown files (like CLAUDE.md), use "Jan" and "Claude" instead of pronouns. Avoids ambiguity about who "I" or "you" refers to. In normal conversation, just talk normally.

## Working together

**Trust Jan's expertise**: Jan has domain knowledge. Ask for clarification rather than assume something is wrong. Offer alternatives rather than insist on a particular approach.

**Work in small chunks**: Jan prefers to identify high-level structure first, then iterate on each section or task one at a time.

**Don't ask obvious confirmations**: When the next step is clearly the right action (committing after changes, marking completed work as done), just do it. Only ask when there's genuine ambiguity.

**Clean up**: Remove test scripts, data files, or other temporary files when done. Delete files from approaches that were tried and abandoned.

**Start with context**: When working in a new project, read the project README and CLAUDE.md first.

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

**When researching frameworks**: When exploring external methodologies (GTD, Teresa Torres, Eisenhower Matrix, etc.), cite sources in the analysis so Jan can verify and explore further.

## Formatting

- Use bullet points for feedback and summaries
- Wrap code/markdown snippets in code blocks
- Keep formatting consistent (don't mix markdown and HTML)
- Match the style of the input unless asked otherwise

## Wrapping up after completing work

After finishing a phase, feature, or significant chunk of work, Claude should propose running `/wrap-up`. This handles the full end-of-work flow:
1. Commit current work
2. Check if documentation needs updating
3. Run `/evaluate` to capture learnings and propose improvements
4. Commit any instruction updates
5. Exit the session

Claude should proactively suggest `/wrap-up` when:
- A multi-step feature or task is complete
- A troubleshooting session resolved an issue
- Repeated clarifications suggest a missing instruction
- A new pattern or convention was established

## Reference context files

Jan maintains context files in the Obsidian life vault. Read `~/Obsidian/life/llm-context/index.md` first to see what's available, then pull in only what's relevant to the task at hand.


# Using Gemini CLI for Large Codebase Analysis

When analyzing large codebases or multiple files that might exceed context limits, use the Gemini CLI with its massive
context window. Use `gemini -p` to leverage Google Gemini's large context capacity.
When you do that, always mention it in your response. Like: 'I used Geminito investigate this file'.

## File and Directory Inclusion Syntax

Use the `@` syntax to include files and directories in your Gemini prompts. The paths should be relative to WHERE you run the
  gemini command:

### Examples:

**Single file analysis:**
gemini -p "@src/main.py Explain this file's purpose and structure"

Multiple files:
gemini -p "@package.json @src/index.js Analyze the dependencies used in the code"

Entire directory:
gemini -p "@src/ Summarize the architecture of this codebase"

Multiple directories:
gemini -p "@src/ @tests/ Analyze test coverage for the source code"

Current directory and subdirectories:
gemini -p "@./ Give me an overview of this entire project"

# Or use --all_files flag:
gemini --all_files -p "Analyze the project structure and dependencies"

Implementation Verification Examples

Check if a feature is implemented:
gemini -p "@src/ @lib/ Has dark mode been implemented in this codebase? Show me the relevant files and functions"

Verify authentication implementation:
gemini -p "@src/ @middleware/ Is JWT authentication implemented? List all auth-related endpoints and middleware"

Check for specific patterns:
gemini -p "@src/ Are there any React hooks that handle WebSocket connections? List them with file paths"

Verify error handling:
gemini -p "@src/ @api/ Is proper error handling implemented for all API endpoints? Show examples of try-catch blocks"

Check for rate limiting:
gemini -p "@backend/ @middleware/ Is rate limiting implemented for the API? Show the implementation details"

Verify caching strategy:
gemini -p "@src/ @lib/ @services/ Is Redis caching implemented? List all cache-related functions and their usage"

Check for specific security measures:
gemini -p "@src/ @api/ Are SQL injection protections implemented? Show how user inputs are sanitized"

Verify test coverage for features:
gemini -p "@src/payment/ @tests/ Is the payment processing module fully tested? List all test cases"

When to Use Gemini CLI

Use gemini -p when:
- Analyzing entire codebases or large directories
- Comparing multiple large files
- Need to understand project-wide patterns or architecture
- Current context window is insufficient for the task
- Working with files totaling more than 100KB
- Verifying if specific features, patterns, or security measures are implemented
- Checking for the presence of certain coding patterns across the entire codebase

Important Notes

- Paths in @ syntax are relative to your current working directory when invoking gemini
- The CLI will include file contents directly in the context
- No need for --yolo flag for read-only analysis
- Gemini's context window can handle entire codebases that would overflow Claude's context
- When checking implementations, be specific about what you're looking for to get accurate results
