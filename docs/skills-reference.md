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

### `plan-tasks`

Creates a structured implementation task breakdown. Each task file includes the relevant motivation, design context, exact spec scenarios, and done criteria needed by a separate implementer.

### `review-spec`

Reviews proposal, spec, design, and task artifacts for internal consistency, cross-artifact alignment, missing scenarios, and gaps. It reports findings with artifact citations.

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

Commits local changes, pushes the branch, and creates or updates the current branch PR. It detects whether validator gates apply before committing.

### `wait-ci`

Polls CI for the current branch PR. It reports pass, fail, pending, or comments status; fetches failed GitHub Actions logs; checks blocking reviews; and surfaces unresolved PR comments.

### `prepare-acceptance`

Prepares a draft PR for human acceptance. It exercises every supported user or client flow through the real product surface, reports clear defects to the caller, captures screenshots for every UI flow or client-style evidence for non-UI flows, waits for current-head CI once stable, and writes revision-bound acceptance-test and handoff artifacts. Fixes and automated validation are handled by the caller.

### `fix-pr`

Fixes CI failures and review comments for the current branch PR. It gathers failure context, dispatches a fixer subagent, verifies the fix with Agent Validator, pushes, and resolves addressed review threads when possible.

### `finalize-pr`

Runs the full push, wait, fix, retry loop. It stops when CI and comments are clear, when checks remain pending after the polling limit, after three fix cycles, or when the same failure persists across consecutive fix attempts.

## Support And Review

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
