---
name: simple-plan
description: >
  Lightweight planning for small, quick changes. Combines propose, spec, and (optionally) design
  into one conversational pass, then writes tasks.md so the change is ready for implementation.
  Activates when users ask for "simple plan", "quick plan", "plan this", or "planning mode" for
  a change that doesn't warrant the full propose/spec/design ceremony.
---

# Simple Plan

## Overview

Rapid, lightweight planning for small changes. One conversation produces a `proposal.md`, one or more spec files, an optional `design.md`, and a `tasks.md` placeholder so the change is ready for implementation.

> **Key principle — write for a different agent.**  The artifacts you produce will be handed to a *separate* implementing agent that has **zero shared context** from this conversation. Every decision, rationale, constraint, file path, naming convention, and behavioral detail must be captured in the written artifacts. If you discussed it but didn't write it down, the implementer won't know about it.

## Flow

1. **Understand** — Ask the user what the change is about (problem, desired behavior, scope) when not already explicit.
2. **Orient quickly** — Before asking questions, do a light survey so your questions are grounded:
   - **Related existing specs** — scan spec files in neighboring or overlapping capabilities for conflicts, dependencies, and naming conventions. For modified capabilities, locate the existing spec now.
   - **Code, when appropriate** — if the change touches existing code, skim the relevant files/modules to understand current behavior. Skip this for greenfield work, pure doc changes, or anything where reading code wouldn't change what you ask.
   Keep it light — this is a quick orientation, not the deep research pass from `propose` or `design`.
3. **Clarify** — Follow the `codagent:ask-questions` skill to gather information. Keep the conversation tight — a handful of questions total, not a full interview. Focus on:
   - Behaviors, boundaries, and error/edge cases (for the specs — this is the load-bearing part)
   - Scope boundaries (what's in, what's out)
   - Any architectural question that would actually change the specs — otherwise skip it
   Ask these as concrete discovery questions before presenting the plan or writing artifacts. A final "thumbs-up" confirmation is not a substitute for clarifying the behavior.
4. **Decide if a design doc is needed** — Default: **no**. Write `design.md` when:
   - There's a real architectural choice whose rationale needs to survive (e.g., a non-obvious trade-off future contributors would re-litigate), **or**
   - There are specific implementation details (algorithms, data-structure choices, integration points, migration steps, error-handling strategies, etc.) that came up in conversation but don't belong in behavioral specs. Because a different agent will implement the change, these details **must** be written down somewhere — `design.md` is that somewhere.
   
   A small code change, a config tweak, a straightforward CRUD addition, or anything where "the code is the design" does not need one. When in doubt, ask whether the implementer would have enough information without it.
5. **Confirm the plan** — Briefly restate: capabilities to spec, whether a design doc will be written, and output location. Get a quick thumbs-up before writing.
6. **Write all the docs in one pass** — `proposal.md`, one `specs/<capability>/spec.md` per capability, optionally `design.md`, and `tasks.md`.

## Output location

Follow the project's convention if one exists (e.g., AGENTS.md, a project config, or similar conventions). Otherwise default to `changes/<kebab-slug>/` and confirm with the user before writing.

## Specs — the load-bearing artifact

Specs outlive everything else in this skill — they become the living source of truth for the change. Get them right:

- Every requirement MUST have at least one scenario.
- Scenarios use `#### Scenario:` (exactly four hashtags) with WHEN/THEN.
- Use SHALL/MUST for normative language.
- Describe observable behavior — not file contents or internal structure.
- If a behavior genuinely depends on an architectural choice you haven't made, mark it `<!-- deferred-to-design: <reason> -->` — but for a simple plan, you should usually just decide and move on.

The proposal and (optional) design exist to scaffold the specs. The specs are what matter.

## tasks.md

Write a placeholder `tasks.md` — no actual task breakdown. This skill produces one-shot, self-contained plans; a **different agent** reads the files directly to implement the change.

Because the implementer has no context beyond these artifacts, the task entry must link to **every** artifact and the artifacts themselves must be fully self-contained. Before writing `tasks.md`, review your artifacts as a whole: if you realize there are discussed details missing from the specs and design, go back and add them now.

Format:

```markdown
- [ ] Implement the change described by these files:
  - [proposal.md](proposal.md)
  - [specs/<capability>/spec.md](specs/<capability>/spec.md)
  - [design.md](design.md)  <!-- only if written -->
```

Use relative paths from the change directory. Include every spec file. Include `design.md` only if it was written.

## Guardrails

- **Do NOT walk doc-by-doc, section-by-section.** Ask questions, then write everything.
- **Do NOT skip discovery questions.** Ask the behavior, boundary, error/edge-case, scope, and necessary architecture questions before confirming the plan or writing artifacts.
- **Do NOT cheerlead.** If you spot a real problem with the idea, say so — but don't run a full GO/NO-GO evaluation.
- **Do NOT pad with unused sections.** Omit sections of the templates that don't apply.
- **Do NOT write `design.md` by default.** The bar is "someone will re-litigate this later without a written rationale." If that's not true, skip it.
- **Follow `codagent:ask-questions`.** For tool choice and batching strategy whenever you need user input.

## Never

- Never present the consolidated plan or ask for thumbs-up before asking the appropriate discovery questions.
- Never write planning artifacts while behavior, scope, or edge-case questions remain unresolved.
- Never use the confirmation step as a substitute for clarifying what the system should do.

---

## Artifact Templates

Scale each section to the change. Omit sections that don't apply. Keep simple sections to a sentence or two.

### `proposal.md`

```markdown
## Why

<!-- 1-2 sentences on the problem or opportunity. -->

## What Changes

<!-- Bullet list of changes. Mark breaking changes with **BREAKING**. -->

## Capabilities

### New Capabilities
<!-- Each creates specs/<name>/spec.md -->
- `<name>`: <brief description>

### Modified Capabilities
<!-- Only list here if spec-level behavior changes. Leave empty if none. -->
- `<existing-name>`: <what's changing>

## Out of Scope

<!-- Explicit exclusions. -->

## Impact

<!-- Affected code, APIs, dependencies. -->
```

### `specs/<capability>/spec.md`

```markdown
## ADDED Requirements

### Requirement: <requirement name>
<requirement text using SHALL/MUST>

#### Scenario: <scenario name>
- **WHEN** <condition>
- **THEN** <expected outcome>

<!--
  For modified capabilities, use ## MODIFIED Requirements and copy the ENTIRE
  existing requirement block (all scenarios) before editing. Other delta headers:
  ## REMOVED Requirements (include **Reason** and **Migration**)
  ## RENAMED Requirements (use FROM:/TO:)
-->
```

### `design.md` (optional, discouraged unless necessary)

```markdown
## Context

<!-- Background and current state. -->

## Goals / Non-Goals

**Goals:**
<!-- What this design aims to achieve. -->

**Non-Goals:**
<!-- Explicitly out of scope. -->

## Approach

<!-- Components, interactions, data flow. Diagrams if they help. -->

## Decisions

<!-- Key decisions and rationale — the reason this doc exists. -->

## Risks / Trade-offs

<!-- Known risks. -->
```

### `tasks.md`

```markdown
- [ ] Implement the change described by these files:
  - [proposal.md](proposal.md)
  - [specs/<capability>/spec.md](specs/<capability>/spec.md)
```
