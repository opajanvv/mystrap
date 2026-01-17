---
description: When and how to run the wrap-up workflow
---

# Wrap-up workflow

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
