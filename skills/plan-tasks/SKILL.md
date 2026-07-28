---
description: Creates a structured implementation task breakdown for a structured change, synthesizing proposal, design, specs, and test-plan obligations into self-contained per-task files. Use when the tasks artifact is the next step in a change.
---

# Plan Tasks

Create a small set of self-contained delivery tasks from the proposal, specifications, design, test
plan, and relevant repository context. Each task goes to a skilled agent with no prior conversation;
include necessary decisions, paths, constraints, scenarios, and automated-test obligations without
dictating line-by-line implementation.

## Size before decomposing

Estimate the whole change from novelty, uncertainty, architectural reach, migration risk, integration
breadth, and verification burden. Do not equate file, requirement, scenario, provider, or UI counts
with task count.

| LOE | Typical tasks |
| --- | ---: |
| Small | 1 |
| Medium | 2 |
| Large | 3–4, preferably 3 |
| XL | 5+, starting at 5 |

Choose the smallest fitting band. Mechanical propagation across layers or adapters usually remains one
task. For Medium-or-larger changes, or unclear provider, migration, cutover, feasibility, or cleanup
boundaries, read [references/task-sizing.md](references/task-sizing.md).

## Form delivery units

A task is an independently meaningful outcome a generalist can implement, test, and review in one
focused session. Prefer vertical slices that include their schema, config, logic, interfaces, tests,
and documentation.

Split only for a distinct outcome, implementation risk, real dependency or release gate, or substantial
independently verifiable foundation. Merge boundaries that create broad unfinished plumbing, duplicate
edits, or a large implicit handoff. Fold ordinary scaffolding, migrations, refactors, test setup, and
documentation into the outcome they support.

Assign each `INT-*` and `E2E-*` obligation to the task that first makes its boundary or journey
executable; a cross-task E2E belongs to the final task completing that journey. Do not assign `AT-*` or
`HT-*` execution to implementors. Unit cases remain implementation-time TDD decisions.

Compare the result with the independent LOE estimate. Merge coupled candidates above the band; never
invent work to reach a count. Use repository context to resolve ordinary planning choices. Stop only
when approved source artifacts contradict each other enough that safe implementation cannot be
planned. Do not ask the user to approve the task count or grouping.

## Write the tasks

Write tasks under `<change-dir>/tasks/`. Use an unnumbered `<slug>.md` for one task or ordered
`<NN>-<slug>.md` files for multiple tasks. Use real repository paths and no placeholders.

For one task, exact references to the design, specs, and test plan may replace copied artifact text:

```markdown
# Task: <Title>

## Goal
<Outcome and reason>

## Background
You MUST read:
- `design.md` for <relevant decisions>
- `specs/<capability>/spec.md` for <requirements and scenarios>
- `test-plan.md` for <assigned INT/E2E obligations>

<Relevant paths, constraints, and context>

## Done When
<Concrete completion signals>
```

For multiple tasks, each file must stand alone and must not refer to another task:

```markdown
# Task: <Title>

## Goal
<Outcome and reason>

## Background
<Motivation, design decisions, exact paths/APIs, and constraints>

## Spec
<Relevant requirements and scenarios copied verbatim>

## Test Plan
<Assigned INT/E2E obligations and relevant strategy>

## Done When
<Scenarios and automated obligations pass, plus concrete delivery signals>
```

Keep all variants of one behavior together. If tasks genuinely share a scenario, copy it into each and
state that task's portion. A standalone refactor is justified only when it is independently risky and
reviewable; otherwise keep refactoring with the behavior it enables.

Order multiple tasks by real dependencies and use matching zero-padded prefixes. Write
`<change-dir>/tasks.md` with one linked checkbox per task:

```markdown
- [ ] <Task title> (`tasks/01-<slug>.md`)
- [ ] <Task title> (`tasks/02-<slug>.md`)
```

Report the task count, titles, and index path. Do not invoke another lifecycle skill.
