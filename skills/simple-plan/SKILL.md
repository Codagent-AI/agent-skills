---
name: simple-plan
description: >
  Lightweight planning for small, quick changes. Combines propose, spec, and (optionally) design
  into one conversational pass, then writes tasks.md so the change is ready for implementation.
  Activates when users ask for "simple plan", "quick plan", "plan this", or "planning mode" for
  a change that doesn't warrant the full propose/spec/design ceremony.
---

# Simple Plan

Plan a small change in one focused conversation. Produce a concise `proposal.md`, one spec per
capability, an optional `design.md`, and a `tasks.md` handoff. The artifacts must be self-contained for
an implementing agent with no conversation history.

## Process

Be lightweight in ceremony, not in questions: produce every artifact in one pass, but never decide on
the user's behalf.

1. Understand the problem, desired behavior, success criteria, and scope. Lightly inspect related
   specifications and relevant code so the decisions and artifacts reflect the existing system.
2. Build a decision inventory before asking anything: list every decision the change requires and
   classify each as material or routine.
   - **Always material (ask):** anything that deletes, pushes, publishes, or creates external state;
     permissions or security boundaries; anything that narrows or widens what an automated agent may
     do; lifecycle and cleanup; scope boundaries; and any extension of the user's stated direction
     beyond what they literally said.
   - **Material when open (ask):** other user-visible or system behavior, and error, edge, and failure
     handling, whenever a reasonable user could want a different answer than the one the request,
     existing code, or established conventions imply.
   - **Routine (decide):** naming, file layout, internal helper structure, and choices settled by the
     request, existing code, specs, or established conventions.
   - When in doubt, treat it as material. Asking a question the user finds trivial costs seconds;
     silently deciding one they care about costs a rework.
3. Ask every material decision with `codagent:ask-questions`. There is no question budget: a small change
   can carry many material decisions. Keep routine details out of the questions so the real decisions
   stay visible. Follow the questioning rules below. When no user can answer (a headless session), stop
   here and return the open material decisions instead of writing artifacts that carry guessed answers.
4. Decide whether `design.md` is necessary. Default to no; write one only for a consequential
   architectural choice, non-obvious rationale, migration, integration strategy, or implementation
   constraint that the implementer otherwise would not know.
5. Present the approval gate: the proposed capability set, design-doc decision, output location, and a
   summary of the decisions the user already made, plus any genuinely routine defaults so they can
   correct them. The gate confirms; it never decides. A bundled "approve this plan?" is not consent to
   each item inside it, so a consequential assumption listed there is still a decision the user never
   made. If one surfaces, pull it out and ask it as its own question first.
   The capability set and design-doc decision are proposals the user may reject.
6. Draft all artifacts in one pass and run the self-check below on the drafts. Write them to the
   output location only once the self-check finds no unanswered material decisions.

Follow a project-defined location. Otherwise propose
`~/.agent-skills/changes/<kebab-slug>/` and confirm it before writing. Do not turn this into the full
propose/spec/design ceremony or write a detailed task breakdown.

## Questioning rules

These rules override `codagent:ask-questions`: ask serially, never in batches, and never list
consequential assumptions at the approval gate. Later questions often depend on earlier answers, and a
batch hides which choice the user is actually weighing.

- Ask one decision per question, wait for the answer, then ask the next. Re-derive the remaining
  inventory after each answer, since it can add, remove, or reshape decisions.
- Put the recommended option first with a one-line trade-off.
- Keep each option's label and description to that option's direct effect. An option that also bundles
  another consequence (for example "also apply this to X, and stop retrying") makes the user accept a
  second decision they never saw. Ask a consequence worth weighing on its own as a separate question.
- Read free-text answers literally and completely. An answer outside the options often redefines the
  decision or raises new material ones; follow what the user said, not the closest option, and ask
  follow-ups for what it opens up.

## Self-check before writing

Before writing the drafts to disk, re-read them against the decision inventory. Look for any material
decision the drafts make that the user did not explicitly answer: a behavior in a scenario, an
exclusion under Out of Scope, a cleanup step, a failure path, or an extension of what the user asked
for. Ask each one as a question under the rules above, update the drafts with the answers, and repeat
the check. Do not write the artifacts or declare the plan done while any remain, and do not list them
as "assumptions" for the user to notice; a reported decision is still one the user did not get to make.

When handing off, tell the user which answers the self-check added to the artifacts. In a headless
session, handle any decision it finds as step 3 does.

## Artifact requirements

### `proposal.md`

Keep the proposal brief: why, high-level changes, new and modified capabilities, out of scope, and
impact.

```markdown
## Why
<problem or opportunity>

## What Changes
- <high-level change>

## Capabilities

### New Capabilities
- `<name>`: <brief description>

### Modified Capabilities
- `<existing-name>`: <changed requirements>

## Out of Scope
<explicit exclusions>

## Impact
<affected code, APIs, dependencies, or users>
```

### `specs/<capability>/spec.md`

Specifications are the load-bearing artifact. Use SHALL or MUST, observable behavior, and at least one
`#### Scenario:` with WHEN/THEN per requirement. For a modified requirement, copy the complete existing
requirement and all scenarios under `## MODIFIED Requirements` before editing it. If behavior truly
depends on an unresolved architectural choice, mark the scenario
`<!-- deferred-to-design: <reason> -->` and resolve it in the design.

Use `## REMOVED Requirements` with **Reason** and **Migration**, and `## RENAMED Requirements` with
FROM and TO, when those delta operations apply.

```markdown
## ADDED Requirements

### Requirement: <name>
<normative behavior>

#### Scenario: <name>
- **WHEN** <condition>
- **THEN** <observable result>
```

### `design.md` when needed

Record only the context, approach, decisions and rationale, risks or trade-offs, and migration details
needed for implementation.

### `tasks.md`

Write one placeholder entry linking every artifact:

```markdown
- [ ] Implement the change described by these files:
  - [proposal.md](proposal.md)
  - [specs/<capability>/spec.md](specs/<capability>/spec.md)
  - [design.md](design.md) <!-- only when written -->
```
