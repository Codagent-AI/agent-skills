---
title: Workflow Guide
group: Guides
order: 1
description: The standard and lightweight skill flows, support skills, and how to choose a path.
---

# Workflow Guide

Codagent skills are designed to preserve intent across phases. Each planning skill writes or checks an artifact that the next skill can consume, and each implementation skill verifies its work before handing off.

## Standard Flow

Use the standard flow for feature work, behavior changes, risky refactors, or anything that needs requirements before implementation.

```text
propose -> spec -> design -> review-approach -> plan-tasks -> review-spec -> implement-change -> finalize-pr
```

### 1. Propose

`propose` evaluates whether an idea is worth building. It researches the codebase and relevant outside context when needed, gives a GO / GO WITH CAVEATS / NO-GO verdict, and writes a proposal with motivation, high-level scope, capabilities, technical approach, exclusions, and impact.

Use `proposal-review` when you want a second pass that challenges the proposal before moving into requirements.

### 2. Spec

`spec` turns proposal capabilities into testable requirements. It asks behavior, boundary, error-condition, and edge-case questions before writing spec files. It does not make architecture decisions; architecture belongs in `design`.

Spec scenarios use requirement blocks and WHEN/THEN scenarios so implementation and review can trace behavior back to explicit requirements.

### 3. Design

`design` reads the specs first, explores the relevant code context, and focuses on architecture, patterns, trade-offs, components, data flow, error handling, and tests. It presents design sections for approval before writing `design.md`.

If the design phase discovers a spec implication, it applies the corresponding spec edits after approval.

### 4. Review The Approach

Use `review-approach` after the specification and design are complete. It challenges consequential behavioral gaps, architecture decisions, tradeoffs, failure modes, and alternatives without duplicating the later consistency and traceability review.

### 5. Plan Tasks

`plan-tasks` creates self-contained task files. Each task includes the relevant why, how, exact spec scenarios, and done criteria needed by a separate implementer that has no shared session context.

Tasks are ordered so dependent work stays sequential.

### 6. Review The Artifacts

`review-spec` checks proposal, spec, design, and task artifacts for conflicts, gaps, and cross-artifact drift. It treats requirements as written and reports inconsistencies rather than changing product decisions.

### 7. Implement

`implement-change` acts as the coordinating skill for a full change. It reads the tasks and context, dispatches one `implement-and-validate` subagent per task sequentially, runs Agent Validator, archives OpenSpec changes when applicable, and moves into PR finalization.

`implement-and-validate` executes one task end to end. It invokes `implement-with-tdd`, performs a self-review, runs Agent Validator when gates apply, and commits after successful validation.

`implement-with-tdd` enforces the red-green-refactor loop for new features, bug fixes, refactors, and behavior changes. It skips TDD only for the exceptions documented in the skill, such as generated code and configuration-only changes.

### 8. Finalize The PR

`push-pr` commits changes, pushes the branch, and creates or updates the PR after running validation when applicable.

`wait-ci` polls the current branch PR, reports CI status, gathers failed GitHub Actions logs, checks blocking reviews, and surfaces unresolved PR comments.

`prepare-acceptance` supports workflows that separate autonomous implementation from human acceptance. Starting from an implemented PR revision, it exercises every supported user or client flow through the real product surface, captures screenshots for UI flows or client-style evidence for APIs and CLIs, reports clear defects to the caller, waits for CI on a stable tested head, and produces a concise evidence package for the human review session. Fixes and any automated validation remain the caller's responsibility; the skill records their evidence or absence and the current PR state without changing it.

`fix-pr` addresses CI failures and review comments by dispatching a fixer subagent, verifying the fix, and pushing.

`finalize-pr` orchestrates the full loop: push PR, wait for CI, fix failures or comments, and repeat until the PR is green or the documented termination rules require a pause.

## Lightweight Flow

Use `simple-plan` for small, bounded changes that do not need the full proposal, spec, design, and task-planning ceremony.

`simple-plan` still produces durable artifacts: a proposal, one or more spec files, an optional design, and a `tasks.md` placeholder. That makes the change safe for another agent to implement even though planning was compressed.

Typical lightweight flow:

```text
simple-plan -> implement-change -> finalize-pr
```

## Support Skills

`ask-questions` is an internal helper used by other skills when they need user input. It defines when to use dedicated input tools, when to batch questions, and when to ask serially.

`handoff` summarizes a specific aspect of the current conversation so another agent can resume.

`session-report` audits assumptions and context gaps from a session.

`review-assumptions` reviews risky or notable assumptions from implementor reports, fixes high-confidence issues directly, and asks one clarifying question at a time for ambiguous findings.

`task-compliance` checks an implementation against task requirements, spec scenarios, and done criteria. It reports gaps but does not fix them.

## Choosing A Path

Use the full flow when the requirements are unsettled, the work touches multiple systems, or another agent will need exact context. Use `simple-plan` when the change is small but still benefits from written artifacts. Use `implement-with-tdd` directly only when the task is already clear enough that no planning artifact is needed.
