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

1. Understand the problem, desired behavior, success criteria, and scope. Lightly inspect related
   specifications and relevant code so questions and artifacts reflect the existing system.
2. Use `codagent:ask-questions` to resolve the decisions behind the proposal, specs, and any design:
   - **Proposal:** the problem, desired outcome, success criteria, scope boundaries, and any choice
     between real alternatives that changes product scope or direction.
   - **Specs:** observable behavior, boundaries, errors, and edge cases that affect behavior or scope.
   - **Design:** consequential architectural choices that repository context cannot safely resolve.

   Recommend a default when useful, decide low-risk implementation details from repository context,
   and do not use a generic approval question as discovery.
3. Decide whether `design.md` is necessary. Default to no; write one only for a consequential
   architectural choice, non-obvious rationale, migration, integration strategy, or implementation
   constraint that the implementer otherwise would not know.
4. Present the proposed capability set, key requirements, design-doc decision, output location, and
   the consequential assumptions or defaults you selected, so the user can correct them. Wait for
   approval before writing.
5. Write all artifacts in one pass, then check them together for missing decisions or contradictions.
   Return to the user for any new behavioral or scope decision instead of inventing one.

Follow a project-defined location. Otherwise propose `~/.agent-skills/changes/<kebab-slug>/` at the
approval step. Do not run separate proposal, spec, and design phases, and do not write a detailed task
breakdown.

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
