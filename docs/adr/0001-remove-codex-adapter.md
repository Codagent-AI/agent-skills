# ADR-0001: Remove Codex Adapter from Implement-Task

**Date:** 2026-03-12
**Status:** Accepted

## Context

In early March 2026, we added multi-adapter dispatch to the `implement-task` skill, allowing it to delegate implementation work to either a Claude Code subagent or an OpenAI Codex subagent. The feature included:

- An `invoke-codex.js` helper script using `@openai/codex-sdk`
- Adapter selection logic with configurable preferences (`.claude/flokay.local.md`)
- OpenSpec specs for adapter selection and the Codex adapter
- An adapter config step in the init skill
- Commit verification and unified token reporting across adapters

## Decision

We are removing the Codex adapter feature entirely and reverting `implement-task` to Claude-only subagent dispatch.

## Rationale

### Too many moving parts

The Codex adapter creates a chain of nested agent invocations that is fundamentally fragile:

1. **Claude (Opus)** orchestrates the implement-task skill
2. Which dispatches **Codex** as the implementer subagent
3. Which must run **agent-gauntlet** for quality verification
4. Which itself spawns **Claude or Codex** as AI reviewers

That's 3-4 layers of AI agent delegation. Each layer adds latency, failure modes, and context loss. When something goes wrong at layer 3, layer 2 must diagnose and recover — but it often can't because it doesn't have enough context about what happened.

### Gauntlet integration never worked reliably

Across every implement-task run we examined, subagents (both Claude and Codex) consistently failed to run gauntlet successfully. The root causes were:

- **Bun stdout/stderr dropping**: 26% of `agent-gauntlet run` invocations returned only an exit code with zero output. The subagent couldn't tell whether gauntlet found violations or failed to run.
- **Recovery path complexity**: The gauntlet-run skill's 8-step error recovery procedure (console log reading, sub-subagent spawning for log extraction, review JSON updates) was designed for a top-level Opus agent, not a Sonnet subagent with limited context.
- **Codex had no gauntlet-run skill at all**: The combined prompt included the TDD and commit skills but not gauntlet-run, so Codex had to improvise — and consistently got it wrong.
- **Lock file contention**: Failed subagents left lock files behind, blocking subsequent runs.

### Complexity budget

The adapter abstraction added significant complexity to three skills (implement-task, init, and the implementer prompt) and four OpenSpec specs, all to support a feature that wasn't working. The complexity was not justified by the value it provided.

## What was removed

- `skills/implement-task/scripts/` — invoke-codex.js, package.json, node_modules
- `skills/implement-task/SKILL.md` — reverted to pre-codex version (Claude-only dispatch)
- `.claude/flokay.local.md` — adapter preferences config file
- `openspec/specs/adapter-selection/` — adapter selection spec
- `openspec/specs/codex-adapter/` — codex adapter spec
- `openspec/specs/adapter-config-init/` — init adapter config spec
- `openspec/specs/implement-task/` — implement-task spec (created for this feature)
- `openspec/changes/archive/2026-03-04-external-agent-delegation/` — change artifacts
- `skills/init/SKILL.md` — removed adapter config step (step 5), renumbered subsequent steps
- `docs/example.md` — removed "Using adapter: claude" line from example output

## What was kept

- `skills/implement-task/implementer-prompt.md` — retained the improved gauntlet integration instructions (self-contained, with output file capture and explicit exit code documentation) since these improvements benefit the Claude subagent path too.
- Archived change artifacts in `openspec/changes/archive/2026-03-05-address-pr16-skill-review/` — historical records, left as-is.

## Consequences

- `implement-task` only supports Claude Code subagents. If we want external agent support in the future, it should be reconsidered with a simpler architecture that doesn't require nested agent-in-agent-in-agent chains.
- The `.claude/flokay.local.md` file and `implementation.preference` config are no longer recognized. Projects that had this file will see no effect (it's simply ignored).
