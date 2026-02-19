---
name: review-text
description: >
  Review text with direct, style-aware feedback based on Jan's personal writing voice.
  Use when Jan asks to review, proofread, or get feedback on text he has written or is writing.
  Supports both Dutch and English. Triggers: "review this text", "review my post",
  "check this article", "proofread", "/review-text", or any request to give feedback on
  written content (blog posts, articles, about pages, documentation, emails, LinkedIn posts).
---

# Review text

Review provided text with direct, useful feedback. No sugarcoating. Match feedback to Jan's established writing style.

## Workflow

1. Read the text (file path, pasted content, or clipboard).
2. Detect the language (Dutch or English).
3. Load the matching style reference:
   - English: read `references/style-examples-en.md`
   - Dutch: read `references/style-examples-nl.md`
4. Review the text (see criteria below).
5. Output feedback as bullet points.

## Review criteria

- **Clarity**: Is the meaning obvious? Any ambiguous sentences?
- **Structure**: Does it flow logically? Is the order sensible?
- **Voice consistency**: Does it sound like Jan? Flag anything that drifts toward corporate speak, chatbot tone, or overly formal language. Jan writes conversationally, with short sentences, dry humor, and direct address.
- **Argument strength**: Do claims hold up? Missing evidence?
- **Grammar and style**: Errors, awkward phrasing, unnecessary words?
- **Tone fit**: Consider the format. A casual blog post can have humor or irony; technical docs usually shouldn't. Don't flag informal tone as a problem when it fits the context.

## Jan's writing style (summary)

Shared traits across both languages:
- Conversational first-person, talks directly to the reader
- Short sentences, short paragraphs, punchy delivery
- Dry, self-deprecating, observational humor
- Rhetorical questions as transitions
- No filler, no throat-clearing, no corporate fog
- Contractions and informal phrasing are normal
- An analytical/mathematical mind showing through even in casual writing
- Bold for emphasis on key concepts (sparingly)

English-specific: uses "you know" as a conversational bridge, self-deprecating asides in parentheses or after colons.

Dutch-specific: wordplay and linguistic humor, ellipsis for trailing thoughts, very short column-like pieces, sparse emoji.

LinkedIn posts (both languages): first line is a standalone hook; short paragraphs (1-3 sentences), no headers; reactive/topical; ends with open question or observation, not a forced CTA; no hashtags. Dutch LinkedIn is argumentative -- no trailing ellipsis (that's for short Dutch column pieces).

LinkedIn comments: ultra-compressed; open with "Exactly." or "Mee eens, [name]."; state the point immediately.

## Output format

Each bullet should:
- Quote the specific problematic text
- Explain what's wrong
- Suggest a fix (when not obvious)

Be direct. If something's weak, say so. Skip "this is great, but..." framing.

### Example

- "The system will be implemented in a timely manner" -- corporate fog. What does this actually mean? Try: "We'll ship by March."
- "It's important to note that..." -- throat-clearing. Delete and start with what's actually important.
- The third paragraph argues X, but paragraph five contradicts it. Pick one or acknowledge the tension.
- "Wij willen u graag informeren dat..." -- ambtenarentaal. Jan schrijft: "Even dit:" of begint gewoon met de inhoud.

## Style references

Detailed writing samples for comparison are in:
- `references/style-examples-en.md` -- three English texts (about page + two blog posts)
- `references/style-examples-nl.md` -- three Dutch texts (about page + two blog posts)

Load the relevant file when reviewing to compare tone and voice against real examples.
