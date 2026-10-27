---
name: design
description: >
  Creates design artifacts through collaborative brainstorming of approaches, architecture, and trade-offs.
  Use when the user says "design this", "create a design", "brainstorm approaches", or "write a design doc".
---

# Design

Turn approved specifications into an implementation-ready technical design. Requirements are already
settled; focus on architecture, component boundaries, interfaces, data flow, failure handling,
migration, testing, and meaningful trade-offs.

Do not implement, scaffold, or invoke an implementation skill before the user approves the design.

## Process

1. Read every specification, including deferred-to-design markers, and inspect the relevant code,
   interfaces, tests, and repository conventions.
2. Use `codagent:ask-questions` for consequential architectural choices that repository context cannot
   safely resolve. Evaluate options first, recommend a path, and decide low-risk implementation details
   yourself.
3. Compare plausible approaches when a real trade-off exists. Do not manufacture alternatives for an
   obvious, patterned solution.
4. Present a design scaled to the change's complexity. Cover the important components, interactions,
   decisions, risks, verification strategy, and any resulting specification implications; use diagrams
   when they clarify the design. When the change produces something people look at, also cover its
   visual design: the visual style, the quality it must reach, and how that will be checked, not only
   legibility limits such as minimum text size or overlap. Ask the user about visual style choices the
   proposal and specifications leave open.
5. After approval, write `design.md` and apply any specification changes revealed by the design,
   including completing deferred scenarios, only when those implications were presented with the
   approved design. Return to the user for a newly discovered behavioral or scope decision. Keep
   normative behavioral changes in specs and technical rationale in the design.

If design work exposes a product or scope decision rather than a technical implication, discuss it
with the user instead of silently inventing behavior. The written artifacts must be self-contained for
an implementing agent with no conversation history.

Do not invoke another lifecycle skill after writing.

## Artifact template

Omit sections that do not apply.

```markdown
## Context

<!-- Relevant current state and constraints. -->

## Goals / Non-Goals

**Goals:**
<!-- Outcomes this design enables. -->

**Non-Goals:**
<!-- Explicit exclusions. -->

## Approach

<!-- Components, interfaces, interactions, data flow, and failure behavior. -->

## Visual Design

<!-- For something people look at: visual style, quality bar, and how they are checked. -->

## Decisions

<!-- Consequential choices and rationale. -->

## Risks / Trade-offs

<!-- Material risks, mitigations, and alternatives considered. -->

## Migration Plan

<!-- Rollout and rollback when applicable. -->

## Open Questions

<!-- Only unresolved decisions that remain. -->
```
