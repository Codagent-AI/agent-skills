---
description: >
  Lightweight planning for small, quick changes. Combines propose, spec, and (optionally) design
  into one conversational pass, then writes tasks.md so the change is ready for OpenSpec
  implementation. Activates when users ask for "simple plan", "quick plan", "plan this", or
  "planning mode" for a change that doesn't warrant the full propose/spec/design ceremony.
---

# Simple Plan

## Overview

Rapid, lightweight planning for small changes. One conversation produces a `proposal.md`, one or more spec files, an optional `design.md`, and a `tasks.md` placeholder so the change slots into the OpenSpec workflow.

## Flow

1. **Understand** — Ask the user what the change is about (problem, desired behavior, scope) when not already explicit.
2. **Orient quickly** — Before asking questions, do a light survey so your questions are grounded:
   - **Related existing specs** — scan spec files in neighboring or overlapping capabilities for conflicts, dependencies, and naming conventions. For modified capabilities, locate the existing spec now.
   - **Code, when appropriate** — if the change touches existing code, skim the relevant files/modules to understand current behavior. Skip this for greenfield work, pure doc changes, or anything where reading code wouldn't change what you ask.
   Keep it light — this is a quick orientation, not the deep research pass from `propose` or `design`.
3. **Clarify** — Ask clarifying questions **one at a time**. Prefer multiple-choice when it fits. Keep the conversation tight — a handful of questions, not a full interview. Focus on:
   - Behaviors, boundaries, and error/edge cases (for the specs — this is the load-bearing part)
   - Scope boundaries (what's in, what's out)
   - Any architectural question that would actually change the specs — otherwise skip it
4. **Decide if a design doc is needed** — Default: **no**. Only write `design.md` when there's a real architectural choice whose rationale needs to survive (e.g., a non-obvious trade-off future contributors would re-litigate). A small code change, a config tweak, a straightforward CRUD addition, or anything where "the code is the design" does not need one. When unsure, skip it.
5. **Confirm the plan** — Briefly restate: capabilities to spec, whether a design doc will be written, and output location. Get a quick thumbs-up before writing.
6. **Write all the docs in one pass** — `proposal.md`, one `specs/<capability>/spec.md` per capability, optionally `design.md`, and `tasks.md`.

## Output location

Follow the project's convention if one exists (AGENTS.md, OpenSpec config, etc.). Otherwise default to `openspec/changes/<kebab-slug>/` and confirm with the user before writing.

## Specs — the load-bearing artifact

Specs outlive everything else in this skill — they become the living source of truth via OpenSpec. Get them right:

- Every requirement MUST have at least one scenario.
- Scenarios use `#### Scenario:` (exactly four hashtags) with WHEN/THEN.
- Use SHALL/MUST for normative language.
- Describe observable behavior — not file contents or internal structure.
- If a behavior genuinely depends on an architectural choice you haven't made, mark it `<!-- deferred-to-design: <reason> -->` — but for a simple plan, you should usually just decide and move on.

The proposal and (optional) design exist to scaffold the specs. The specs are what matter.

## tasks.md

Write a placeholder `tasks.md` — no actual task breakdown. This skill produces one-shot, self-contained plans; the implementer reads the files directly.

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
- **Do NOT cheerlead.** If you spot a real problem with the idea, say so — but don't run a full GO/NO-GO evaluation.
- **Do NOT pad with unused sections.** Omit sections of the templates that don't apply.
- **Do NOT write `design.md` by default.** The bar is "someone will re-litigate this later without a written rationale." If that's not true, skip it.
- **Do ask one question at a time.** The only process discipline that matters here.

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
