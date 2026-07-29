---
name: propose
description: >
  Evaluate whether a software idea is worth building, then write the proposal document.
  Use when the user wants to assess an idea, says "evaluate", "propose", "is this worth building",
  or "should we build". If the idea passes evaluation, write the proposal document using the provided template.
---

# Propose

Evaluate an idea honestly, then write `proposal.md` when it is worth pursuing. The proposal explains
the motivation deeply, bounds the change at a high level, and sketches only enough technical approach
to establish feasibility and expose structural risk. Detailed behavior belongs in specifications;
detailed architecture belongs in `design.md`.

## Process

### 1. Understand and research

Use `codagent:ask-questions` when the problem, audience, desired outcome, success criteria, constraints,
or scope boundaries are unclear. Do not draft from a rough idea when an answer would materially change
the proposal.

Ground the evaluation in available evidence:

- read related specifications and relevant code to understand current behavior, architecture, and
  existing patterns;
- investigate prior attempts, available tools, and credible alternatives;
- use web research when current external practices, products, or known pitfalls matter.

### 2. Evaluate

Assess the problem's significance, alternatives to building, opportunity cost, maintenance burden, and
fit with the existing system. Give a direct verdict: **go**, **go with caveats**, or **no-go**, with the
reasons and any condition that would change it. A no-go produces no proposal unless the user decides to
proceed after discussing the trade-offs.

### 3. Establish the high-level approach

For a viable idea, identify the minimum useful scope, affected capabilities, architecture fit, major
technical decisions, and material risks. When real alternatives exist, recommend one and explain the
important trade-off; ask the user only when the choice changes product scope or direction. Decide
low-risk implementation defaults from repository context.

Keep this intentionally lighter than design. Use a diagram or comparison only when it clarifies an
important relationship or decision.

### 4. Approve and write

Present the recommendation, scope, and approach for user approval before writing. Include any
consequential assumptions or defaults you selected so the user can correct them.

Use a caller-supplied or project-defined output path. Otherwise propose
`~/.agent-skills/changes/<kebab-slug>/proposal.md` and confirm it with the user.

Write the approved proposal with the structure below. Do not invoke another lifecycle skill.

## Artifact template

```markdown
## Why

<!-- Problem or opportunity, affected audience, and why it matters now. -->

## What Changes

<!-- High-level scope. Mark breaking changes with **BREAKING**. -->

## Capabilities

### New Capabilities
- `<kebab-name>`: <behavioral area that needs a new spec>

### Modified Capabilities
- `<existing-name>`: <existing requirements that change>

## Technical Approach

<!-- Overall architecture fit and key decisions; leave detailed design for design.md. -->

## Out of Scope

<!-- Explicit exclusions that prevent scope creep. -->

## Impact

<!-- Affected code, APIs, dependencies, systems, or users. -->
```
