---
description: >-
  Implements an approved change (proposal, specs, design, test plan, or similar definition) in one
  continuous session, with tiered test runs, escalation rules, and a final maintainability pass. Use
  when asked to implement a change, build from approved artifacts, or invoke codagent:implement-change,
  directly or from a workflow step. This is the single-agent alternative to codagent:orchestrate-change,
  which delegates all edits to sub-agents.
---

# Implement Change

Implement the approved change in this session. The definition is the source of truth. Do not
report work done that was not done.

## Inputs

Read what the caller supplied. When an input is absent, apply the default.

| Input | When absent |
| --- | --- |
| Definition location (proposal, specs, design, test plan, or similar) | Find it in the repository (for example a change directory). If none exists, stop and report. |
| Outcome record to build against (see `codagent:outcome-evidence`) | Work from the definition alone. |
| Escalation route (for example a lead agent to ask) | Ask the user. |
| Blocked convention (how to signal a human-only decision) | Stop and report. |
| Test time limits | Use the defaults below. |
| When to run the broader tests (tier 2) | Run them once, when the work is ready. |
| Commit message prefix | Use the project's convention alone. |

The user, the caller, or the project's instructions may override any default here. Precedence:
the user, then the caller, then the project's instructions, then these defaults.

## Process

1. **Read first.** Read the whole definition, the outcome record if any, and the project's
   instructions. Find the project's test commands, commit conventions, lint and build checks, and
   existing test style.
2. **Integrate early.** Get a working path through the main interacting deliverables before
   polishing any one of them. Integration gaps found late are the costliest.
3. **Implement the behavior.** Do not use test-driven development (writing tests first) unless
   the project's instructions require it.
4. **Add tests.** Cover the behavior and every scenario in the definition, including failure,
   error, and cleanup scenarios, at the tier that fits (unit, integration, or end-to-end). Add
   them to the project's existing suites and match their style.
5. **Run tests** by tier (below) as the work proceeds.
6. **Escalate** when needed (below).
7. **Finish** with the maintainability pass, the tier 2 run, the project's other required checks,
   and the commit (below).

Use sub-agents when they help; never require them.

## Test tiers

| Tier | Tests | Limit per run | When |
| --- | --- | --- | --- |
| 1 | The unit tests the change affects | 3 minutes | As often as needed while working |
| 2 | The whole suite, or a subset you choose that includes the integration and end-to-end tests relevant to the change | 15 minutes | When the caller says to; with no instruction, once when the work is ready, and again only after a later change that could affect what it covers |
| 3 | Anything beyond the tier 2 limit | Not run | Left to CI |

- The limits are tunable defaults, sized to keep feedback fast and a run within one tool-call window.
- The caller decides when to run tier 2, never which tests. You choose the tests.
- If a run times out, run a smaller set.
- Do not run tier 3, even when project instructions ask for the full suite. Report which tests
  were left unrun.
- Enforce each limit with a timeout, for example `timeout 180 <command>`.
- A tool call can itself be cut off (in Claude Code headless runs, after 10 minutes, with
  background tasks disabled). Start any run that may take longer detached, with output going to
  a log file, for example `timeout 900 <command> > <log> 2>&1 &`. Then wait for it and read the
  log. Never restart a run only because a tool call timed out.
- Reuse a result when nothing relevant has changed since it ran.

## Escalation

Decide ordinary questions yourself and record the ruling.

Escalate when plausible readings would give materially different behavior, scope, or integration;
when requirements conflict; or before departing from the definition. Use the caller's escalation
route; with none, ask the user.

When blocked on a decision only a human can make, follow the caller's blocked convention, or stop
and report. Never work around the block or claim completion.

## Before finishing

1. **Maintainability pass.** Review your own diff without a separate simplify skill or reviewer
   sub-agents. Remove duplication and logic at the wrong layer. Each cleanup must preserve
   behavior exactly, must not grow the code, and is committed separately from the feature work.
2. **Tier 2 run**, when the caller asks for it at this point or by the default above.
3. **Other required checks**, such as lint, type checks, and build.
4. **Outcome record**, if one is in use: bring it current per `codagent:outcome-evidence`
   (record, refresh after fixes, keep Implemented in accurate).
5. **Commit** following the project's commit conventions, plus any caller prefix.

## Report

Return:

- what was built, by deliverable;
- tests run at each tier, with commands and results;
- tests left unrun, and why;
- deviations from the definition and open questions, including rulings you made.

## Out of Scope

- Writing or reviewing the definition (use `codagent:spec`, `codagent:design`, `codagent:test-plan`).
- Exploratory or acceptance testing (use `codagent:test-flows` or `codagent:prepare-acceptance`).
- Pushing, opening PRs, or waiting for CI (use `codagent:push-pr` or `codagent:finalize-pr`).
