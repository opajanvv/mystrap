---
name: plan
description: This skill should be used when the user says "/plan", "plan this", "let's plan", wants to start any new work (feature, script, article, project, refactor, system change), or when an idea needs to be broken down before starting. Provides a structured spec-plan-do workflow that scales from tiny actions to large projects.
---

# Plan

Structured approach to turning any idea into action. Applies to everything: code, writing, system changes, projects. Scale the process to match the idea's size.

## Scaling guide

Assess the idea's size first. This determines how much process to apply.

| Size | Spec phase | Plan phase | Do phase |
|------|-----------|------------|----------|
| Tiny (fix a typo, rename a file) | Skip or one confirming question | Single step | Just do it |
| Small (write a script, short article) | 2-3 questions | 3-5 steps | Sequential |
| Medium (new feature, blog post, config overhaul) | Full interview | Sectioned plan | Phase by phase |
| Large (new project, website, system redesign) | Thorough interview | Multi-phase blueprint with milestones | Phase by phase with checkpoints |

For tiny ideas, skip straight to doing. For everything else, follow the three phases below.

## Phase 1: Spec (understand the idea)

Interview Jan to develop a clear specification. Build understanding iteratively.

**Rules:**
- Ask one question at a time. Each question builds on previous answers.
- Keep the scope tight. Push toward V1 (simple and focused). Resist feature creep.
- Dig into every relevant detail before moving on.
- The interview will come to a natural conclusion. Don't force it.

**Domain-specific angles:**
- Code: architecture choices, data handling, error handling, testing strategy
- Writing: audience, angle, key points, tone, structure, length
- System/infra: current state, constraints, rollback plan, verification
- Any domain: goals, constraints, success criteria, what "done" looks like

When the interview wraps up, compile findings into a specification. For projects with a working directory, save as `spec.md`. For conversational ideas, present inline.

## Phase 2: Plan (break it down)

Turn the spec into an actionable blueprint.

**Process:**
1. Draft a high-level step-by-step plan.
2. Break each step into small, iterative chunks that build on each other.
3. Review and adjust. Each chunk should be:
   - Small enough to complete and verify safely
   - Big enough to move the project forward
   - Ending with something working or testable
   - Building on the previous chunk (no orphaned work)

**Domain-specific outputs:**
- Code: series of implementation steps, each with context. Prioritize early testing, incremental complexity, real data over mocks. Each step ends with wiring things together (no hanging code).
- Writing: outline with section order, key points per section, research needs.
- System/infra: ordered checklist of actions with verification after each step.
- Any domain: ordered checklist of concrete actions.

Save the plan as `todo.md` using checkbox format. For conversational ideas, present inline. For tiny ideas, this might be a single checkbox.

**Verify factual claims against source docs.** If the plan includes claims about existing processes, workflows, or system behavior, read the relevant source documentation before finalizing. Don't trust memory or context for domain-specific facts.

**Write specs and todos that a cheap LLM can execute.** These files may be handed to a less capable model. Be specific: include exact file paths, exact commands, exact file contents where possible. Avoid ambiguity, open questions, or reasoning in the files. Resolve all thinking before writing.

**Present the plan to Jan and wait for approval before proceeding.**

## Phase 3: Do (execute)

Work through the plan step by step. Check off items as they are completed.

- Code: write, test, self-correct. Each step should pass its tests before moving on.
- Writing: draft, review, revise section by section.
- System/infra: execute, verify, then proceed to next step.

Do not start this phase until Jan approves the plan.

## File outputs

| File | When | Content |
|------|------|---------|
| `spec.md` | Medium+ ideas with a working directory | Compiled specification from the interview |
| `todo.md` | Any idea needing more than one step | Actionable checklist with checkboxes |

For ideas without a working directory, present these inline instead of saving files.
