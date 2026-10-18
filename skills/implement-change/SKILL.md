---
description: >-
  Implements an approved change as an orchestrator: builds the scaffolding itself, delegates
  independent pieces to sub-agents, and runs tiered tests. Use when asked to implement a change
  from its approved definition, or to invoke codagent:implement-change.
---

# Implement Change

Implement the approved change (its proposal, specs, design, and test plan) in this session, acting
mainly as orchestrator. Even if it is a very large task, you must see all of it finished. Keep
working until it is. Do not use the codagent:orchestrate-change, codagent:plan-tasks, or
codagent:simple-plan skills.

## Building

- First build the scaffolding yourself: the seams, interfaces, shared types, and a working
  integrated path through the main interacting deliverables, so the remaining work splits into
  independent pieces. Do not polish any one piece before that path works.
- Do the complex or cross-cutting pieces yourself, or give them to a sub-agent on your own model.
- Write each increment's code and tests together, in whatever order suits it. Do not follow
  test-driven development as a method unless the project's instructions require it.
- Write automated tests for code only, never for prompts. Do not write a test that checks whether a
  prompt, such as a `SKILL.md`, contains certain text.

## Delegating

- Give well-specified, independent pieces to sub-agents on the cheapest capable model your CLI
  offers (for example Haiku in Claude Code). Keep pieces substantial, not many tiny ones.
- Use your CLI's built-in sub-agent tool, not Agent Runner `call_agent`, which stays for
  any escalation your instructions describe.
- Run independent pieces in parallel. Never put two sub-agents on the same files.
- Never end your turn while a sub-agent is running: headless CLIs abort running sub-agents when
  your turn ends. Wait for every one to report.
- Brief each sub-agent with its files, the interfaces it must honor, the checklist or outcome rows
  it owns, any commit prefix or other rules your session was given, and these rules:
  - Write the code and its tests together. No test-driven development, and no test that checks
    prompt text.
  - Run only narrow targeted tests for its piece, within the tier 1 limit. No full suite.
  - No manual or exploratory testing, and no browser or app clicking.
  - Update only its own rows in the checklist or outcome list (location, evidence from its own
    targeted test, status). Do not edit other pieces' files or rows.
  - Commit only its own paths, following the project's commit message conventions.
  - Report what it did and anything left open.
- Do not review a sub-agent's code line by line or re-verify its rows; a later audit does that.
  Integrate the pieces and fix integration breakage yourself.

## Running tests

Use three tiers, each kept inside its time limit with a timeout (for example
`timeout 180 <command>`). The limits are defaults the user may change. A tool call may stop after
10 minutes, so start any run that may take longer detached, with its output going to a log file,
then wait for it and read the log. Never restart a run only because a call timed out, and reuse a result when
nothing relevant has changed since it ran.

1. Unit tests your change affects: run these while you work, as often as you need, within 3
   minutes. If a run times out, run a smaller set. Sub-agents run only this tier, for their piece.
2. A broader run: the whole suite, or a subset you choose that includes the integration and
   end-to-end tests relevant to the change. Run it once yourself, when all pieces are integrated,
   within 15 minutes. If it times out, run a smaller set.
3. Anything beyond that is left to CI. Do not run it, even if project instructions ask for the full
   suite, and name the tests you left unrun.

## Before finishing

- Do a maintainability pass over the whole change yourself, without a /simplify skill or reviewer
  sub-agents: remove duplication and logic at the wrong layer. Cleanups must preserve behavior
  exactly and must not grow the code; commit them separately.
- Commit following the project's commit message conventions.
