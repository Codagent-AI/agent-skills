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
propose -> proposal-review -> spec -> design -> test-plan -> review-approach -> plan-tasks -> review-tasks -> implement-change -> finalize-pr
```

### 1. Propose

`propose` evaluates whether an idea is worth building. It researches the codebase and relevant outside context when needed, gives a GO / GO WITH CAVEATS / NO-GO verdict, and writes a proposal with motivation, high-level scope, capabilities, technical approach, exclusions, and impact.

`proposal-review` provides an adversarial second pass that challenges the proposal before the user confirms it and moves into requirements.

### 2. Spec

`spec` turns proposal capabilities into testable requirements. It asks behavior, boundary, error-condition, and edge-case questions before writing spec files. It does not make architecture decisions; architecture belongs in `design`.

Spec scenarios use requirement blocks and WHEN/THEN scenarios so implementation and review can trace behavior back to explicit requirements.

### 3. Design

`design` reads the specs first, explores the relevant code context, and focuses on architecture, patterns, trade-offs, components, data flow, error handling, and tests. It presents design sections for approval before writing `design.md`.

If the design phase discovers a spec implication, it applies the corresponding spec edits after approval.

### 4. Plan Testing

`test-plan` applies the automated test pyramid after requirements and design are settled. It keeps unit
testing broad and implementation-driven, records important integration boundaries as `INT-*`, reserves
`E2E-*` for critical complete journeys, defines authoritative human-style agent acceptance as `AT-*`,
and defaults genuinely human-only `HT-*` checks to none.

### 5. Review The Approach

Use `review-approach` after the proposal, specification, design, and test plan are complete. It is the
final review of those definition artifacts: it checks their consistency and testability, then challenges
consequential behavioral gaps, architecture and testing decisions, tradeoffs, failure modes, and
alternatives.

### 6. Plan Tasks

`plan-tasks` creates self-contained task files. Each task includes the relevant why, how, exact spec
scenarios, assigned `INT-*` and `E2E-*` obligations, and done criteria needed by a separate implementer
that has no shared session context. Automated tests stay with the task that delivers their behavior;
unit details are chosen through TDD, and acceptance execution is not assigned to implementers.

Tasks are ordered so dependent work stays sequential.

### 7. Review The Tasks

`review-tasks` must read the approved proposal, specifications, design, and test plan, but reviews only
the task plan. It checks requirement and automated-test coverage, fidelity, decomposition, dependencies,
ordering, self-contained context, and done criteria. Every finding must be correctable in the task files
without changing an approved definition artifact or asking the user for a new decision.

### 8. Implement

`implement-change` acts as the coordinating skill for a full change. It reads the tasks and context, dispatches one `implement-and-validate` subagent per task sequentially, runs Agent Validator, archives OpenSpec changes when applicable, and moves into PR finalization.

`implement-and-validate` executes one task end to end. It invokes `implement-with-tdd`, performs a self-review, runs Agent Validator when gates apply, and commits after successful validation.

`implement-with-tdd` enforces the red-green-refactor loop for new features, bug fixes, refactors, and behavior changes. It skips TDD only for the exceptions documented in the skill, such as generated code and configuration-only changes.

### 9. Test And Accept

`test-flows` exercises representative public flows for small or branch-local changes, captures
meaningful UI screenshots or client-visible evidence, and reports findings without requiring PR
alignment, CI, formal acceptance artifacts, or caller-managed status protocols.

`prepare-acceptance` supports workflows that separate autonomous implementation from formal human
acceptance. When an approved `test-plan.md` exists, its required and activated conditional `AT-*`
flows are authoritative and cannot be downgraded to limitations or replaced by unapproved
substitutes. Otherwise the skill derives a concise representative set of public flows. After a fix,
the caller attests to an impact scope so only affected and directly dependent flows are retested;
unaffected baseline evidence remains available as caller-scoped provenance. Publication, fixes, and
automated validation remain the caller's responsibility.

### 10. Finalize The PR

`push-pr` commits changes, pushes the branch, and creates or updates the open PR for the exact current
head branch after running validation when applicable. Merged or closed predecessors do not substitute
for the active PR.

`wait-ci` polls the current branch PR, reports CI status, gathers failed GitHub Actions logs, checks blocking reviews, and surfaces unresolved PR comments. When review automation is still running but actionable feedback already exists, it reports the feedback as actionable rather than hiding it behind a pending status.

`fix-pr` addresses CI failures and review comments by dispatching a fixer subagent, verifying the fix, and pushing.

`finalize-pr` orchestrates the full loop: push PR, wait for CI, fix failures or comments, and repeat until the PR is green or the documented termination rules require a pause.

## Lightweight Flow

Use `simple-plan` for small, bounded changes that do not need the full proposal, spec, design, and task-planning ceremony.

`simple-plan` still produces durable artifacts: a proposal, one or more spec files, an optional design, and a `tasks.md` placeholder. That makes the change safe for another agent to implement even though planning was compressed.

Typical lightweight flow:

```text
simple-plan -> implement-and-validate -> test-flows
```

A lead can present the tester's exact findings to the user, apply approved fixes, and request one
targeted verification of the affected flow when useful. The human decision to continue is the gate;
the lightweight flow does not need a formal acceptance-status protocol.

## Support Skills

`review-spec` is a generic artifact-quality review for standalone or legacy use. It checks whichever proposal, specification, design, and task artifacts are present for consistency, testability, traceability, and alignment, but it is not part of the standard v2 planning flow.

`call-agent` is the orchestration helper for workflow steps that explicitly receive Agent Runner's
`call_agent` tool. Proposal, approach, task-plan, and acceptance workflows use it to construct a
standalone bounded child prompt, make one safe profile or named-session call, preserve structured
failures, independently verify consequential findings, and report child findings separately from the
lead's assessment. Material findings remain visible even when the lead rejects or cannot verify them.
It does not provision the tool itself and never substitutes another delegation
mechanism when the tool is unavailable.

`ask-questions` is an internal helper used by other skills when they need user input. It defines when to use dedicated input tools, when to batch questions, and when to ask serially.

`handoff` summarizes a specific aspect of the current conversation so another agent can resume.

`session-report` audits assumptions and context gaps from a session.

`review-assumptions` reviews risky or notable assumptions from implementor reports, fixes high-confidence issues directly, and asks one clarifying question at a time for ambiguous findings.

`task-compliance` checks an implementation against task requirements, spec scenarios, and done criteria. It reports gaps but does not fix them.

## Choosing A Path

Use the full flow when the requirements are unsettled, the work touches multiple systems, or another agent will need exact context. Use `simple-plan` when the change is small but still benefits from written artifacts. Use `implement-with-tdd` directly only when the task is already clear enough that no planning artifact is needed.
