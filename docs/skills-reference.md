---
title: Skills Reference
group: Reference
order: 1
description: The user-facing and support skills shipped from the bundle.
---

# Skills Reference

This page summarizes the user-facing and support skills shipped from `skills/`.

## Planning

### `init`

Initializes Codagent in the current project. It checks that Agent Validator is installed, requires validator version `0.15` or newer, verifies `.validator/config.yml`, prints the available core skills, and commits initialization scaffolding through the validator commit flow.

### `propose`

Evaluates whether an idea is worth building. It researches context, gives a GO / GO WITH CAVEATS / NO-GO verdict, and writes a proposal covering why, high-level scope, capabilities, technical approach, exclusions, and impact.

### `proposal-review`

Performs an adversarial review of a proposal. It challenges motivation, scope, technical approach, assumptions, and alternatives while recommending concrete resolutions.

### `spec`

Turns proposal capabilities into requirements. It asks behavior, boundary, error-condition, and edge-case questions, presents proposed requirements for approval, and writes spec files with requirement blocks and WHEN/THEN scenarios.

### `design`

Turns specs into a technical design. It reads all relevant specs first, explores code context, asks architecture and trade-off questions, proposes approaches, gets approval, writes `design.md`, and applies any spec edits discovered during design.

### `test-plan`

Creates an approved `test-plan.md` after design. It applies the automated test pyramid without fixed
ratios, records important integration (`INT-*`) and critical end-to-end (`E2E-*`) obligations, defines
authoritative agent acceptance flows (`AT-*`), minimizes human-only checks (`HT-*`), and maps them to
requirements and critical journeys.

### `review-approach`

Performs the final review of a completed proposal, specification, design, and test plan. It checks cross-artifact consistency and testability, then challenges consequential behavioral gaps, missing architectural or testing decisions, weak tradeoffs, failure modes, and better alternatives without editing the artifacts.

### `plan-tasks`

Creates a structured implementation task breakdown. Each task file includes the relevant motivation, design context, exact spec scenarios, assigned `INT-*` and `E2E-*` obligations, and done criteria needed by a separate implementer.

### `review-tasks`

Reviews an implementation task plan against the approved proposal, specifications, design, and test plan. It must read those source artifacts, but reports only task-plan defects that can be corrected in the task index or detailed task files.

### `review-spec`

Provides a generic artifact-quality review for any available proposal, spec, design, or task documents. It accepts product and design decisions as written and checks internal consistency, cross-artifact alignment, testability, and traceability. It remains available for standalone or legacy use but is not a stage in the standard v2 planning flow.

### `simple-plan`

Compresses planning for small changes into one lightweight flow. It writes a proposal, one or more spec files, an optional design, and a `tasks.md` placeholder so the change remains implementation-ready.

## Implementation

### `implement-with-tdd`

Enforces test-driven development. It requires a failing test before production code for features, bug fixes, refactors, and behavior changes, then follows red-green-refactor.

### `implement-and-validate`

Implements one task end to end. It uses `implement-with-tdd`, performs self-review, runs Agent Validator when gates apply, commits on success, and returns a structured report.

### `implement-change`

Coordinates a full change. It dispatches one `implement-and-validate` subagent per task sequentially, handles task failures, runs Agent Validator, archives OpenSpec changes when applicable, and invokes PR finalization.

## Pull Requests

### `push-pr`

Commits local changes, pushes the branch, and creates or updates the open PR for the exact current
head branch. It detects whether validator gates apply before committing and treats merged or closed
predecessors as history.

### `wait-ci`

Polls CI for the current branch PR. It reports pass, fail, pending, or comments status; fetches failed GitHub Actions logs; checks blocking reviews; and surfaces unresolved PR comments. Actionable feedback takes precedence over unfinished review automation so callers can address known findings instead of waiting indefinitely.

### `prepare-acceptance`

Prepares the currently checked-out implementation for human acceptance. When an approved test plan
exists, its applicable required `AT-*` flows, evidence, authorized effects, and permitted substitutes
are authoritative; otherwise the skill derives a concise representative flow set. It groups equivalent
variants within a flow instead of replaying every specification scenario or edge case. After a fix, the
caller can attest to an impact scope so the skill retests only affected and directly dependent flows
while preserving unaffected baseline evidence as caller-scoped provenance. It captures screenshots for
tested UI flows or client-style evidence for non-UI flows. Fixes and automated validation are handled
by the caller.

### `fix-pr`

Fixes CI failures and review comments for the current branch PR. It gathers failure context, dispatches a fixer subagent, verifies the fix with Agent Validator, pushes, and resolves addressed review threads when possible.

### `finalize-pr`

Runs the full push, wait, fix, retry loop. It stops when CI and comments are clear, when checks remain pending after the polling limit, after three fix cycles, or when the same failure persists across consecutive fix attempts.

## Support And Review

### `call-agent`

Safely invokes one Runner-owned child through a profile or declared named session. It builds a
standalone bounded prompt, preserves call budgets and structured failures, independently verifies
consequential findings, and reports each material child finding—including its rationale, evidence,
recommendation, lead disposition, and resulting action—even when the lead rejects or cannot verify it. It reports a
clear blocker when the enclosing Agent Runner step did not provision `call_agent` and never substitutes
another delegation mechanism.

### `ask-questions`

Defines how skills ask users for input. It prefers dedicated input tools when available, batches independent questions, asks serially for branching decisions, and stops rather than continuing past unresolved user decisions.

### `handoff`

Writes a focused handoff for a specific aspect of the current conversation. It captures objective, current state, decisions, open questions, next steps, and relevant files.

### `session-report`

Audits a session for risky or notable assumptions and context gaps. It is intended for human review rather than automatic fixes.

### `review-assumptions`

Reviews assumptions from implementor session reports. It builds a finding ledger, fixes high-confidence issues directly, asks for clarification on ambiguous findings, and summarizes final dispositions.

### `task-compliance`

Checks an implementation against task requirements, spec scenarios, and done criteria. It reports addressed items and gaps but does not modify the code.
