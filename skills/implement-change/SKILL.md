---
description: >-
  Implements an approved change in one continuous session, with tiered test runs and escalation
  rules. Use when asked to implement a change from its approved definition, or to invoke
  codagent:implement-change.
---

# Implement Change

Implement the approved change (its proposal, specs, design, and test plan) in this session. Even
if it is a very large task, finish all of it yourself. You may use sub-agents if they would help,
but you are not required to.

## Building

- Get a working, integrated path through the main interacting deliverables early, before
  polishing any one of them.
- Work in increments you choose, writing each increment's code and tests together in whatever
  order suits it. Do not follow test-driven development as a method unless the project's
  instructions require it.
- If an outcome record is in use, keep it current with `codagent:outcome-evidence`.
- A reproduced spec violation stays open until it is fixed and verified, or the escalation route
  rules it is not a violation. Disputing it does not close it.

## Running tests

Use three tiers, each kept inside its time limit with a timeout (for example
`timeout 180 <command>`). The limits are defaults; the user or the caller may set others. A tool
call may stop after 10 minutes, so start any run that may take longer detached, with its output
going to a log file, then wait for it and read the log. Never restart a run only because a call
timed out, and reuse a result when nothing relevant has changed since it ran.

1. Unit tests your change affects: run these while you work, as often as you need, within 3
   minutes. If a run times out, run a smaller set.
2. A broader run: the whole suite, or a subset you choose that includes the integration and
   end-to-end tests relevant to the change. Run it only when the caller tells you to (with no
   caller, once when the work is ready), within 15 minutes. If it times out, run a smaller set.
3. Anything beyond that is left to CI. Do not run it, even if project instructions ask for the
   full suite, and name the tests you left unrun.

## Escalation

- Ask the caller's escalation route, or the user if there is none, when plausible readings would
  give materially different behavior, scope, or integration, when requirements conflict, or when
  you propose departing from the approved definition. Decide ordinary questions yourself.
- Follow its rulings. When it records a proposed exception for the user, build the requirement as
  written.
- Blocked: if it rules that no compliant implementation is possible without the user, record the
  question, the ruling, and the decision needed where the caller says, and stop. Do not wait for
  an answer, work around it, or claim completion.

## Before finishing

- Do a maintainability pass yourself, without a /simplify skill or reviewer sub-agents: remove
  duplication and logic at the wrong layer. Cleanups must preserve behavior exactly and must not
  grow the code; commit them separately.
- Then run the broader test run if the caller asks for it at this point, and the repository's
  other required checks, such as lint and build.
- Commit following the project's commit message conventions.
