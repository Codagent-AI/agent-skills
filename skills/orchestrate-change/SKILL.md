---
description: >-
  Implements a well-specified change (an OpenSpec change, or any change with a proposal,
  specifications, design, and test plan) as an orchestrator that never writes code itself: it
  decomposes the approved artifacts into slices, delegates every code change to sub-agents,
  reviews their work independently, and verifies the result against every spec scenario and
  test-plan item. Use by default when implementing an OpenSpec change or other well-specified
  change, especially one without a task breakdown, unless instructed otherwise. Requires an agent
  with a sub-agent or task-delegation tool.
---

# Orchestrate Change

You are the orchestrator for this change. Sub-agents write all of the code. You understand the
change, split it into slices, brief sub-agents, check their work, and own the outcome.

**You MUST NOT edit source code, tests, configuration, documentation, or any other project file
yourself, not even a one-line fix or a reviewer's finding.** Send every change, however small,
to a sub-agent. Independent review only works when the orchestrator never writes the code it is
judging, and your context stays clear for coordination. You may read files, write your own slice
ledger outside the repository, and run read-only or verification commands (`git status`,
`git diff`, `git log`, test, lint, and build commands).

Use your agent's sub-agent or task-delegation tool (for example the Agent/Task tool in Claude
Code, `spawn_agent` in Codex, or the task tool in Copilot CLI and OpenCode), and spawn
sub-agents explicitly. Assume one level of delegation: sub-agents do not spawn their own
sub-agents. If you have no delegation tool, say so plainly and stop. Never pretend to delegate.

## Inputs

The change is defined by its approved artifacts: a proposal, one or more specifications with
requirements and scenarios, a design, and a test plan. For an OpenSpec change these live under
`openspec/changes/<change-name>/`. The caller may name another directory. Treat the artifacts
as the source of truth. A `tasks.md` or task files, if present, are optional hints, not the plan.

When the caller runs you autonomously, do not ask the user anything. Resolve gaps with a ruling
consistent with the artifacts and record it. In an interactive session, ask before starting
only when a gap would change the product behavior; otherwise make a ruling and keep going.

## Checklist

Copy this checklist into your ledger and keep it current:

```
- [ ] 1. Read the artifacts and map the code
- [ ] 2. Write the slice ledger
- [ ] 3. Implement, check, and review each slice in order
- [ ] 4. Run the integration check
- [ ] 5. Report
```

### 1. Read the artifacts and map the code

Read every artifact once, in full. To learn the relevant code without filling your own context,
send a read-only exploration sub-agent. Ask it for a short map: the modules, interfaces, and
existing patterns the change touches, and the project's test, lint, and build commands.

### 2. Write the slice ledger

Write a ledger file **outside the repository** (a scratch or session directory the caller gives
you, or a temporary directory). Never commit it. The ledger keeps your plan and decisions safe
if your context is compacted. Use the format in [references/ledger.md](references/ledger.md).

Split the change into slices. Each slice is a coherent piece of behavior that can be checked on
its own: a few substantial slices beat many tiny ones. For each slice, record:

- the requirements and scenarios it satisfies
- the test-plan items it owns
- the files or packages it expects to touch
- the slices it depends on

Order the slices by dependency: shared types and interfaces first, then the behavior built on
them, then wiring and integration. Every scenario and test-plan item must belong to a slice. If
one cannot be mapped, that is a gap in the spec: make a ruling and record it in the ledger.

### 3. Implement, check, and review each slice

Run slices **one at a time** by default. Coding work rarely splits cleanly, and parallel writers
conflict. Run two implementer slices in parallel only when they touch disjoint files and depend
only on interfaces that are already committed. Read-only work (exploration, review) can run in
parallel freely.

For each slice:

1. **Brief an implementer.** Sub-agents start with no memory of your conversation. Write a
   self-contained brief using the implementer template in
   [references/briefs.md](references/briefs.md). Pass artifact paths and quote the exact
   requirements and scenarios rather than pasting whole documents. Include the decisions earlier
   slices made, as a short list, not the history. Note the commit before the slice starts.
2. **Check the evidence yourself.** When the implementer reports, run the slice's targeted tests
   and look at `git log` and `git diff --stat` for its commit range. Do not accept "done" without
   evidence.
3. **Get an independent review.** For any non-trivial slice, send a fresh review sub-agent with
   the reviewer template: the brief, the commit range, and the scenarios. It checks spec
   compliance first, then code quality. It reports only problems that affect correctness or the
   stated requirements, not stylistic preferences.
4. **Fix through sub-agents.** Send each confirmed finding back to an implementer, resuming the
   original one if your tool supports it. Fixes go in new commits, not amends, so a re-review can
   see what changed. Re-reviews look only at the findings being fixed.
5. **Update the ledger** with the commit range, the outcome, and any decisions or assumptions.

Handle implementer statuses as follows:

- **NEEDS_CONTEXT:** answer from the artifacts or make a ruling, then resume or re-brief.
- **BLOCKED:** split the slice, re-brief it with what was missing, or fix the prerequisite
  through another slice.
- **Repeated failure:** after two rounds of corrections on the same problem, stop correcting.
  Start a fresh implementer with a better brief that states what went wrong. If it still
  cannot be done, record the blocker and move on to slices that do not depend on it.

### 4. Run the integration check

When every slice is done:

1. Have a sub-agent run the project's full test, lint, format, and build checks and fix any
   failures.
2. Send one fresh final reviewer over the whole change range with the final-review template. It
   fills a matrix with one row per spec scenario and test-plan item: how it was verified (a test
   name, or a command and its output) and whether it passes.
3. Turn every failing or unverified row into a new fix slice, then repeat this check.

Do not change the approved artifacts unless implementation proves one is wrong. In that case,
have a sub-agent make the smallest correction, commit it, and record why in the ledger.

### 5. Report

Report with evidence, not assertions:

- the slices, their commit ranges, and their outcomes
- the final verification matrix, or its failing rows
- every ruling, assumption, and unresolved gap from you and your sub-agents
- anything left blocked and why

Leave the worktree clean: everything related to the change is committed, and nothing else is.
