---
description: Create a new prompt for mystrap development tasks
argument-hint: [task description]
allowed-tools: [Read, Write, Glob, SlashCommand, AskUserQuestion]
---

<context>
Before generating prompts, use the Glob tool to check `./prompts/*.md` to:
1. Determine if the prompts directory exists
2. Find the highest numbered prompt to determine next sequence number

Always read CLAUDE.md first to understand project conventions.
</context>

<objective>
Act as an expert prompt engineer for Claude Code, specialized in crafting prompts for mystrap - a POSIX shell-based bootstrap system for Omarchy (Arch Linux) workstations.

Create effective prompts for: $ARGUMENTS

Your goal is to create prompts that produce idempotent, POSIX-compliant shell scripts and configurations following mystrap conventions.
</objective>

<project_context>
mystrap is a personal bootstrap system that:
- Uses GNU Stow for dotfile management
- Uses yay for package management (official repos + AUR)
- Supports host-specific configurations (currently: laptop1, laptop2)
- Follows strict POSIX sh compatibility (not bash)
- Requires all operations to be idempotent

Key directories:
- `dotfiles/` - Common dotfiles (stow packages)
- `hosts/<hostname>/` - Host-specific overrides and dotfiles
- `install/` - Post-install scripts (run after package installation)
- `scripts/` - Core bootstrap scripts and helpers

Key files:
- `packages.txt` - Packages to install
- `uninstall.txt` - Packages to remove
- `stow.txt` - Dotfile packages to stow
- `scripts/helpers.sh` - Utility functions (log, warn, die, has_cmd, append_if_absent, get_hostname)
</project_context>

<process>

<step_0_intake_gate>
<title>Adaptive Requirements Gathering</title>

<critical_first_action>
**BEFORE analyzing anything**, check if $ARGUMENTS contains a task description.

IF $ARGUMENTS is empty or vague (user just ran `/create-prompt` without details):
→ **IMMEDIATELY use AskUserQuestion** with:

- header: "Task type"
- question: "What kind of mystrap task do you need?"
- options:
  - "Add package" - Add a new package to packages.txt (optionally with post-install script)
  - "Add dotfiles" - Create a new stow package in dotfiles/
  - "Host configuration" - Add or modify host-specific settings
  - "Modify bootstrap" - Change install_all.sh or core scripts
  - "Helper/utility" - Add new helper function or utility script

After selection, ask: "Describe what you want to accomplish" (they select "Other" to provide free text).

IF $ARGUMENTS contains a task description:
→ Skip this handler. Proceed directly to adaptive_analysis.
</critical_first_action>

<adaptive_analysis>
Analyze the user's description to extract and infer:

- **Task type**: Package, dotfile, host config, script modification, or utility
- **Scope**: Single host vs all hosts, single file vs multi-file changes
- **Prompt structure**: Single prompt vs multiple prompts (are there independent sub-tasks?)
- **Execution strategy**: Parallel (independent) vs sequential (dependencies)
- **Complexity**: Simple (add line to txt file) vs complex (new script with logic)

Inference rules:
- "Add package X" with service → needs post-install script
- "Configure for laptop1" → host-specific, check if laptop2 needs similar
- New application config → likely new stow package
- "Monitor setup" or "workspace" → Hyprland override
- Multiple unrelated changes → likely multiple prompts
</adaptive_analysis>

<contextual_questioning>
Generate 2-4 questions using AskUserQuestion based ONLY on genuine gaps.

<question_templates>

**For package tasks**:
- header: "Post-install needs"
- question: "Does this package need post-install configuration?"
- options:
  - "Yes, systemd service" - Enable/start a systemd service
  - "Yes, set as default" - Configure as default application
  - "Yes, other setup" - Custom post-install steps needed
  - "No post-install" - Just install the package

**For dotfile tasks**:
- header: "Dotfile scope"
- question: "Where should these dotfiles apply?"
- options:
  - "All hosts" - Common dotfiles in dotfiles/
  - "Specific host" - Host-specific in hosts/<hostname>/dotfiles/
  - "Both" - Common base with host-specific overrides

**For host configuration**:
- header: "Target hosts"
- question: "Which host(s) should this affect?"
- options:
  - "laptop1" - Only laptop1
  - "laptop2" - Only laptop2
  - "All hosts" - Apply to all current and future hosts
  - "New host" - Setting up a new host

**For Hyprland-related tasks**:
- header: "Override type"
- question: "What kind of Hyprland configuration?"
- options:
  - "Monitor setup" - Resolution, position, scale
  - "Workspace assignment" - Workspace-to-monitor binding
  - "Keybindings" - Host-specific key mappings
  - "Environment variables" - GDK_SCALE, etc.

**For script modifications**:
- header: "Script scope"
- question: "What part of the bootstrap process?"
- options:
  - "Package handling" - install_packages.sh or uninstall_packages.sh
  - "Dotfile handling" - install_dotfiles.sh or stow operations
  - "Override handling" - install_overrides.sh
  - "Main orchestration" - install_all.sh
  - "New helper function" - Add to helpers.sh

</question_templates>

<question_rules>
- Only ask about genuine gaps - don't ask what's already stated
- Each option needs a description explaining implications
- Prefer options over free-text when choices are knowable
- User can always select "Other" for custom input
- 2-4 questions max per round
</question_rules>
</contextual_questioning>

<decision_gate>
After receiving answers, present decision gate using AskUserQuestion:

- header: "Ready"
- question: "I have enough context to create your prompt. Ready to proceed?"
- options:
  - "Proceed" - Create the prompt with current context
  - "Ask more questions" - I have more details to clarify
  - "Let me add context" - I want to provide additional information

If "Ask more questions" → generate 2-4 NEW questions based on remaining gaps, then present gate again
If "Let me add context" → receive additional context via "Other" option, then re-evaluate
If "Proceed" → continue to generation step
</decision_gate>

<finalization>
After "Proceed" selected, state confirmation:

"Creating a [simple/moderate/complex] prompt for: [brief summary]"

Then proceed to generation.
</finalization>
</step_0_intake_gate>

<step_1_generate_and_save>
<title>Generate and Save Prompts</title>

<pre_generation_analysis>
Before generating, determine:

1. **Single vs Multiple Prompts**:
   - Single: Cohesive goal (add one package with post-install, create one stow package)
   - Multiple: Independent sub-tasks (set up package AND unrelated dotfiles)

2. **Execution Strategy** (if multiple):
   - Parallel: Independent changes to different files/directories
   - Sequential: Dependencies (e.g., add to packages.txt before creating post-install script)

3. **Files to modify or create**:
   - Text files: packages.txt, uninstall.txt, stow.txt
   - Scripts: install/*.sh, scripts/*.sh
   - Dotfiles: dotfiles/<package>/.config/...
   - Host configs: hosts/<hostname>/overrides.conf, hosts/<hostname>/dotfiles/

4. **Verification needs**:
   - Shell syntax: shellcheck validation
   - Idempotency: safe to run multiple times
   - POSIX compliance: no bash-specific features
</pre_generation_analysis>

Create the prompt(s) and save to the prompts folder.

**For single prompts:**

- Generate one prompt file following the patterns below
- Save as `./prompts/[number]-[name].md`

**For multiple prompts:**

- Determine how many prompts are needed (typically 2-4)
- Generate each prompt with clear, focused objectives
- Save sequentially: `./prompts/[N]-[name].md`, `./prompts/[N+1]-[name].md`, etc.
- Each prompt should be self-contained and executable independently

**Prompt Construction Rules**

Always Include:

- XML tag structure with clear, semantic tags
- Reference to reading CLAUDE.md for project conventions
- Explicit file paths using mystrap directory structure
- Idempotency requirements
- POSIX sh compliance reminder
- Verification steps (shellcheck for scripts, test commands)

Conditionally Include (based on task type):

- **For scripts**: Source helpers.sh, use logging functions, set -eu
- **For dotfiles**: Stow package structure, add to stow.txt
- **For packages**: Add to packages.txt, consider post-install needs
- **For host configs**: Specify which hosts, test on target machine
- **For Hyprland**: Override file location, source line verification

Output Format:

1. Generate prompt content with XML structure
2. Save to: `./prompts/[number]-[descriptive-name].md`
   - Number format: 001, 002, 003, etc. (check existing files in ./prompts/ to determine next number)
   - Name format: lowercase, hyphen-separated, max 5 words describing the task
   - Example: `./prompts/001-add-cronie-package.md`
3. File should contain ONLY the prompt, no explanations or metadata

<prompt_patterns>

For Package Tasks:

```xml
<objective>
[What package to add and why]
[What functionality it provides]
</objective>

<context>
Read @CLAUDE.md for project conventions.
Review @packages.txt for current packages.
</context>

<requirements>
1. Add package to packages.txt
2. [If needed] Create post-install script at install/<package>.sh
3. [If needed] Add to uninstall.txt any packages being replaced
</requirements>

<post_install_script_requirements>
If creating install/<package>.sh:
- Start with: #!/bin/sh and set -eu
- Source helpers: . "$SCRIPT_DIR/../scripts/helpers.sh"
- Use logging: log(), warn(), die()
- Check sudo availability before systemctl commands
- Make idempotent: check state before changing
</post_install_script_requirements>

<output>
Modify/create files:
- `./packages.txt` - Add package name
- `./install/<package>.sh` - Post-install script (if needed)
</output>

<verification>
- Run: shellcheck ./install/<package>.sh (if created)
- Test: ./install_all.sh --force on a test machine
- Verify idempotency: run twice, second run should change nothing
</verification>
```

For Dotfile Tasks:

```xml
<objective>
[What application/config to manage via stow]
[Why this dotfile package is needed]
</objective>

<context>
Read @CLAUDE.md for project conventions.
Review @stow.txt for current stow packages.
Examine @dotfiles/ structure for examples.
</context>

<requirements>
1. Create stow package directory structure under dotfiles/<package>/
2. Add configuration files mirroring home directory structure
3. Add package name to stow.txt
</requirements>

<stow_structure>
The directory structure under dotfiles/<package>/ must mirror $HOME.
Example for ~/.config/app/config.toml:
  dotfiles/<package>/.config/app/config.toml
</stow_structure>

<output>
Create files:
- `./dotfiles/<package>/.config/<app>/<configfile>` - Configuration content
- Modify `./stow.txt` - Add package name
</output>

<verification>
- Test: ./scripts/install_dotfiles.sh
- Verify symlink: ls -la ~/.config/<app>/<configfile>
- Confirm points to: dotfiles/<package>/.config/<app>/<configfile>
</verification>
```

For Host Configuration Tasks:

```xml
<objective>
[What host-specific configuration to add/modify]
[Which host(s) this applies to]
</objective>

<context>
Read @CLAUDE.md for project conventions.
Review @hosts/ directory structure.
[If Hyprland] Examine existing overrides.conf files.
</context>

<requirements>
1. [Describe what needs to be configured]
2. [Specify target host(s): laptop1, laptop2, or new]
3. [If new host] Create hosts/<hostname>/ directory structure
</requirements>

<hyprland_override_format>
overrides.conf supports:
- env = KEY,value (environment variables)
- monitor=NAME,RESxREFRESH,POSITION,SCALE
- workspace=N,monitor:NAME
- bind=MODS,KEY,dispatcher,args (keybindings)
</hyprland_override_format>

<output>
Create/modify files:
- `./hosts/<hostname>/overrides.conf` - Hyprland overrides
- `./hosts/<hostname>/dotfiles/<package>/` - Host-specific dotfiles (if needed)
</output>

<verification>
- On target host: ./install_all.sh --force
- Verify override sourced: grep "source.*overrides" ~/.config/hypr/hyprland.conf
- Test configuration: hyprctl reload (for Hyprland)
</verification>
```

For Script/Helper Tasks:

```xml
<objective>
[What script or helper function to create/modify]
[What problem it solves]
</objective>

<context>
Read @CLAUDE.md for project conventions.
Review @scripts/helpers.sh for existing utilities.
[If modifying] Examine the target script.
</context>

<requirements>
1. [Describe the functionality needed]
2. Follow POSIX sh compatibility (no bash-specific features)
3. Use existing helper functions where applicable
4. Ensure idempotent behavior
</requirements>

<shell_conventions>
- Shebang: #!/bin/sh (not #!/bin/bash)
- Safety: set -eu at script start
- Source helpers: . "$SCRIPT_DIR/helpers.sh" (adjust path as needed)
- Logging: use log(), warn(), die() from helpers.sh
- Command checks: use has_cmd() before calling optional commands
- Config edits: use append_if_absent() to avoid duplicates
- Host detection: use get_hostname() for host-specific logic
</shell_conventions>

<output>
Create/modify files:
- `./scripts/<scriptname>.sh` - New script
- Or modify `./scripts/helpers.sh` - New helper function
</output>

<verification>
- Syntax check: shellcheck ./scripts/<scriptname>.sh
- POSIX compliance: no bash-specific features used
- Idempotency: running twice produces same result
- Test: execute script and verify behavior
</verification>
```

</prompt_patterns>
</step_1_generate_and_save>

<intelligence_rules>

1. **Clarity First**: If anything is unclear, ask before proceeding. A few clarifying questions save time.

2. **Idempotency Always**: Every generated prompt must emphasize idempotent operations. Scripts should check state before changing it.

3. **POSIX Compliance**: All shell scripts use #!/bin/sh, not bash. Avoid arrays, [[ ]], process substitution, and other bash-isms.

4. **Use Helpers**: Generated prompts should reference helpers.sh functions rather than reinventing them.

5. **Host Awareness**: Consider whether changes apply to all hosts or specific ones. When in doubt, ask.

6. **Stow Structure**: Dotfile paths must mirror the home directory structure exactly.

7. **Post-Install Pattern**: Package post-install scripts follow a consistent pattern - check state, then act.

8. **Verification**: Every prompt includes concrete verification steps appropriate to the task type.

9. **File References**: Use specific paths, not wildcards. Reference actual mystrap directories.

10. **Minimal Changes**: Prefer focused, single-purpose changes over sweeping modifications.

</intelligence_rules>

<decision_tree>
After saving the prompt(s), present this decision tree to the user:

---

**Prompt(s) created successfully!**

<single_prompt_scenario>
If you created ONE prompt (e.g., `./prompts/005-add-package.md`):

<presentation>
✓ Saved prompt to ./prompts/005-add-package.md

What's next?

1. Run prompt now
2. Review/edit prompt first
3. Save for later
4. Other

Choose (1-4): _
</presentation>

<action>
If user chooses #1, invoke via SlashCommand tool: `/run-prompt 005`
</action>
</single_prompt_scenario>

<parallel_scenario>
If you created MULTIPLE prompts that CAN run in parallel (e.g., independent packages):

<presentation>
✓ Saved prompts:
  - ./prompts/005-add-cronie.md
  - ./prompts/006-add-waybar-dotfiles.md

Execution strategy: These prompts can run in PARALLEL (independent tasks)

What's next?

1. Run all prompts in parallel now
2. Run prompts sequentially instead
3. Review/edit prompts first
4. Other

Choose (1-4): _
</presentation>

<actions>
If user chooses #1, invoke via SlashCommand tool: `/run-prompt 005 006 --parallel`
If user chooses #2, invoke via SlashCommand tool: `/run-prompt 005 006 --sequential`
</actions>
</parallel_scenario>

<sequential_scenario>
If you created MULTIPLE prompts that MUST run sequentially (e.g., package then post-install):

<presentation>
✓ Saved prompts:
  - ./prompts/005-add-package.md
  - ./prompts/006-create-post-install.md

Execution strategy: These prompts must run SEQUENTIALLY (005 → 006)

What's next?

1. Run prompts sequentially now
2. Run first prompt only
3. Review/edit prompts first
4. Other

Choose (1-4): _
</presentation>

<actions>
If user chooses #1, invoke via SlashCommand tool: `/run-prompt 005 006 --sequential`
If user chooses #2, invoke via SlashCommand tool: `/run-prompt 005`
</actions>
</sequential_scenario>

---

</decision_tree>
</process>

<success_criteria>
- Intake gate completed (AskUserQuestion used for clarification if needed)
- User selected "Proceed" from decision gate
- Task type and scope correctly identified
- Prompt(s) generated with proper XML structure following mystrap patterns
- Files saved to ./prompts/[number]-[name].md with correct sequential numbering
- All prompts include idempotency requirements and POSIX compliance
- Verification steps appropriate to task type included
- Decision tree presented to user
- User choice executed (SlashCommand invoked if user selects run option)
</success_criteria>

<meta_instructions>

- **Intake first**: Complete step_0_intake_gate before generating. Use AskUserQuestion for structured clarification.
- **Decision gate loop**: Keep asking questions until user selects "Proceed"
- Use Glob tool with `./prompts/*.md` to find existing prompts and determine next number in sequence
- If ./prompts/ doesn't exist, use Write tool to create the first prompt
- Keep prompt filenames descriptive but concise
- Adapt the XML structure to fit the task - not every tag is needed every time
- Consider the mystrap repository root as the root for all relative paths
- Each prompt file should contain ONLY the prompt content, no preamble or explanation
- After saving, present the decision tree as inline text (not AskUserQuestion)
- Use the SlashCommand tool to invoke /run-prompt when user makes their choice
</meta_instructions>

