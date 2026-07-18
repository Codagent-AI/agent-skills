---
description: Creates a structured implementation task breakdown for a structured change, synthesizing proposal, design, and specs into self-contained per-task files. Use when the tasks artifact is the next step in a change.
---

# Plan Tasks

Create self-contained task files from a change's proposal, design, and specs. Assume each task goes to a skilled agent with no prior context. Include the decisions, paths, constraints, and verbatim scenarios that agent needs, but avoid line-by-line implementation instructions.

Announce: "I'm using the plan-tasks skill to create the task breakdown."

## 1. Read inputs and code

Read `proposal.md`, `design.md`, and every `specs/**/*.md` in the provided change directory. Skip material already read in this session.

Research only enough code to identify:

- affected files, interfaces, and conventions;
- structural obstacles that could make implementation significantly harder;
- documentation that must change with the behavior.

## 2. Size the whole change

Estimate implementation effort before drafting task boundaries. Consider novelty, uncertainty, architectural reach, provider or platform breadth, migration and cutover risk, and verification burden. Discount mechanical propagation across files, adapters, UI surfaces, docs, and tests. Never infer size from requirement, scenario, layer, or candidate-task counts.

Use the estimate as a task-count budget:

| LOE | Task count | Calibration |
| --- | ---: | --- |
| Small | 1 | Cohesive, patterned work with limited uncertainty, even across many files. |
| Medium | 2 | A substantial feature or refactor with a contract change, migration, or second implementation-sized risk cluster. |
| Large | 3–4 | A major subsystem change with high novelty, integration breadth, production transition, or extensive verification. Prefer 3. |
| XL | 5+ | Program-scale work spanning multiple major subsystems or capabilities. Start at 5; justify every additional task. |

Choose the smallest fitting size. A difficult replacement of one subsystem is usually Large, not XL.

For Medium or larger changes, or ambiguous provider, migration, feasibility, cutover, or cleanup boundaries, read [references/task-sizing.md](references/task-sizing.md) before decomposing.

Only after sizing, decide whether serious structural obstacles warrant a behavior-preserving refactor task. Prefer inline refactoring. If a standalone refactor is necessary, count it inside the selected budget.

## 3. Form delivery units

One task is one meaningful outcome a generalist agent can implement, test, and review in a focused session. A task may be a broad vertical slice; it is not a TDD step, requirement, scenario, layer, UI surface, adapter, or file group.

Apply these rules:

1. Group every layer needed for one outcome: schema, config, logic, UI, tests, and docs.
2. Split only for an independently meaningful outcome, distinct implementation risk, real sequencing or release gate, or substantial independently verifiable foundation.
3. Fold scaffolding, migrations, dependencies, and refactors into the outcome that first exercises them unless independently risky and review-worthy.
4. Prefer seams with narrow, stable handoffs. If the next task would inherit broad unfinished plumbing, overlapping edits, or many implicit assumptions, merge the candidates. A boundary should reduce context transfer, not create a large handoff surface.
5. Merge candidates that would normally land in one PR, are not useful separately, or exist only to prepare for the next task.

Do not create standalone tasks for tests, ordinary documentation, setup surfaces, adapter flags, or other plumbing belonging to an outcome. Prompt-, config-, or skill-only changes are usually one task unless they deliver independently releasable capabilities.

### Cross-check the count

Compare the candidate count with the independent LOE budget:

- Above the band: merge the most coupled candidates.
- Below the minimum: re-check the estimate; never invent work to satisfy it.
- Within a range: use the lower count unless another boundary is concrete and implementation-significant.
- Multiple cohesive outcomes in one task: split and raise the LOE if needed.
- For every task after the first, explain internally why it cannot be folded into another. "Different requirement/layer/UI," "many files/adapters," "cleaner," or "easier to track" are not sufficient.

Proceed autonomously once the cross-check passes. Do not ask for approval or count selection. Stop only for a source-artifact contradiction that makes implementation unsafe to plan.

## 4. Write task files

Write every task under `tasks/` before ordering:

- One task: `<2-4-word-slug>.md`
- Multiple tasks: eventually `<NN>-<2-4-word-slug>.md`, where the numeric prefix determines runner order

Use real repository paths and resolve all placeholders.

### Single-task format

Reference the design and every spec by exact relative path instead of duplicating them. Omit `## Spec`.

```markdown
# Task: <Title>

## Goal

<Outcome and reason>

## Background

You MUST read these files before starting:
- `design.md` for <relevant details>
- `specs/<capability>/spec.md` for <acceptance criteria>

<Brief motivation, key paths, decisions, and constraints>

## Done When

<Concrete completion signal covering all scenarios>
```

### Multi-task format

Each file must stand alone. Never reference another task; its agent will not see it. Include only background that affects this task.

```markdown
# Task: <Title>

## Goal

<Outcome and reason in 1–3 sentences>

## Background

<Relevant proposal motivation, design decisions, exact paths/APIs, and constraints>

## Spec

<Copy every relevant requirement and scenario verbatim from the specs>

## Done When

<Tests for the scenarios pass, plus any concrete end-to-end signal>
```

Scenarios map to behavior, not task count. Keep variations of one behavior together. When multiple tasks genuinely contribute to one scenario, copy the full scenario into each and identify that task's portion. Omit `## Spec` only for rare, purely internal work with no behavioral scenario.

## 5. Order and index tasks

Order tasks by real dependencies, placing the work that unblocks more first when independent. For multiple tasks, rename every file with zero-padded numeric prefixes matching execution order.

If Step 2 identified a necessary standalone refactor, prepend it now and renumber the remaining files. Its `Done When` must require the structural change and all existing tests to pass.

Write `<change-dir>/tasks.md`:

```markdown
- [ ] <Task title> (`tasks/01-<slug>.md`)
- [ ] <Task title> (`tasks/02-<slug>.md`)
```

Use one checkbox per task in execution order. For a single task, link its unnumbered filename.

## 6. Report

Exit without invoking another skill or asking about execution mode. Report:

- task count and titles;
- the `tasks.md` path;
- what is now unlocked.
