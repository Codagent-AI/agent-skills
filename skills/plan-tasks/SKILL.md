---
description: Creates a structured implementation task breakdown for a structured change, synthesizing proposal, design, specs, and any supplied test-plan obligations into self-contained per-task files; use when the tasks artifact is the next step in a change.
---

# Plan Tasks

Create a small set of self-contained delivery tasks from the proposal, specifications, design, any
supplied test plan, and relevant repository context. Each task goes to a skilled agent with no prior
conversation; include necessary decisions, paths, constraints, scenarios, and automated-test
obligations without dictating line-by-line implementation.

Read the proposal, design, specifications, and relevant repository context. When `test-plan.md` exists
or the caller supplies a test plan, read it and include its obligations; otherwise plan from the
available definition artifacts without requiring or inventing test-plan content.

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

When a test plan is supplied, assign each `INT-*` and `E2E-*` obligation to the task that first makes
its boundary or journey executable; a cross-task E2E belongs to the final task completing that journey.
Do not assign `AT-*` or `HT-*` execution to implementors. Unit cases remain implementation-time TDD
decisions.

Compare the result with the independent LOE estimate. Merge coupled candidates above the band; never
invent work to reach a count. Use repository context to resolve ordinary planning choices. Stop only
when approved source artifacts contradict each other enough that safe implementation cannot be
planned. Do not ask the user to approve the task count or grouping.

## Write the tasks

Write tasks under `<change-dir>/tasks/`. Use an unnumbered `<slug>.md` for one task or ordered
`<NN>-<slug>.md` files for multiple tasks. Use real repository paths and no placeholders.

For one task, exact references to the design and specs may replace copied artifact text. When a test
plan is supplied, also cite it for the assigned `INT-*` and `E2E-*` obligations:

```markdown
# Task: <Title>

## Goal
<Outcome and reason>

## Background
You MUST read:
- `design.md` for <relevant decisions>
- `specs/<capability>/spec.md` for <requirements and scenarios>

<Relevant paths, constraints, and context>

## Test Plan
- `<INT-* or E2E-*>`: <strategy and completion signal>

## Done When
<Concrete delivery signals, including the assigned automated obligations>
```

When a test plan is supplied, include `- test-plan.md for <assigned INT/E2E obligations>` under
`You MUST read` and the `## Test Plan` section shown above. Otherwise omit both and use ordinary
completion signals under `## Done When`.

For multiple tasks, each file must stand alone and must not refer to another task:

```markdown
# Task: <Title>

## Goal
<Outcome and reason>

## Background
<Motivation, design decisions, exact paths/APIs, and constraints>

## Spec
<Relevant requirements and scenarios copied verbatim>

## Done When
<Scenarios and automated obligations pass, plus concrete delivery signals>
```

When a test plan is supplied, add a `## Test Plan` section with the assigned `INT-*` and `E2E-*`
obligations and relevant strategy; otherwise omit that section and test-plan-specific completion
signals.

Keep all variants of one behavior together. If tasks genuinely share a scenario, copy it into each and
state that task's portion. A standalone refactor is justified only when it is independently risky and
reviewable; otherwise keep refactoring with the behavior it enables.

Order multiple tasks by real dependencies and use matching zero-padded prefixes. Write
`<change-dir>/tasks.md` with one linked checkbox per task:

```markdown
- [ ] [<Task title>](tasks/01-<slug>.md)
- [ ] [<Task title>](tasks/02-<slug>.md)
```

The task title MUST be an actual Markdown link. A path in an inline code span is not a link.

Report the task count, titles, and index path. Do not invoke another lifecycle skill.
