# Review text

Review the provided text with direct, useful feedback. No sugarcoating.

## Instructions

1. Read the text the user provides (file path, pasted content, or clipboard).

2. Review for:
   - **Clarity**: Is the meaning obvious? Any ambiguous sentences?
   - **Structure**: Does it flow logically? Is the order sensible?
   - **Tone and voice**: Consistent? Appropriate for the audience?
   - **Argument strength**: Do claims hold up? Missing evidence?
   - **Grammar and style**: Errors, awkward phrasing, unnecessary words?

3. Output as bullet points. Each bullet should:
   - Quote the specific problematic text
   - Explain what's wrong
   - Suggest a fix (when not obvious)

4. Be direct. If something's weak, say so. Skip the "this is great, but..." framing.

5. Consider the format. A casual blog post can have humor or irony; technical docs usually shouldn't. Don't flag informal tone as a problem when it fits the context.

## Example output format

- "The system will be implemented in a timely manner" - corporate fog. What does this actually mean? Try: "We'll ship by March."
- "It's important to note that..." - throat-clearing. Delete and start with what's actually important.
- The third paragraph argues X, but paragraph five contradicts it. Pick one or acknowledge the tension.
- Passive voice throughout the intro makes it feel like a policy document. Who's doing these things?
