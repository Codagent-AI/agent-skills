---
description: >-
  Implements an approved change in one continuous session, with tiered test runs. Use when asked
  to implement a change from its approved definition, or to invoke codagent:implement-change.
---

# Implement Change

Implement the approved change (its proposal, specs, design, and test plan) in this session. Even if
it is a very large task, you must finish all of it yourself. Keep working until it is finished. Do
not use the codagent:orchestrate-change, codagent:plan-tasks, or codagent:simple-plan skills. You
may use sub-agents if they would help, but you are not required to.

## Building

- Get a working, integrated path through the main interacting deliverables early, before polishing
  any one of them.
- Work in increments you choose, writing each increment's code and tests together in whatever order
  suits it. Do not follow test-driven development as a method unless the project's instructions
  require it.
- Write automated tests for code only, never for prompts. Do not write a test that checks whether a
  prompt, such as a `SKILL.md`, contains certain text.

## Running tests

Use three tiers, each kept inside its time limit with a timeout (for example
`timeout 180 <command>`). The limits are defaults the user may change. A tool call may stop after
10 minutes, so start any run that may take longer detached, with its output going to a log file,
then wait for it and read the log. Never restart a run only because a call timed out, and reuse a result when
nothing relevant has changed since it ran.

1. Unit tests your change affects: run these while you work, as often as you need, within 3
   minutes. If a run times out, run a smaller set.
2. A broader run: the whole suite, or a subset you choose that includes the integration and
   end-to-end tests relevant to the change. Run it once, when the work is ready, within 15 minutes.
   If it times out, run a smaller set.
3. Anything beyond that is left to CI. Do not run it, even if project instructions ask for the full
   suite, and name the tests you left unrun.

## Before finishing

- Do a maintainability pass yourself, without a /simplify skill or reviewer sub-agents: remove
  duplication and logic at the wrong layer. Cleanups must preserve behavior exactly and must not
  grow the code; commit them separately.
- Commit following the project's commit message conventions.
