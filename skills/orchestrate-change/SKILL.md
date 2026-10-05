---
description: >-
  Implements a well-specified change (approved change artifacts, specs, or similar) as an
  orchestrator that delegates all code changes to sub-agents. Use by default when implementing any
  well-specified change, unless instructed otherwise.
---

# Orchestrate Change

You are the orchestrator for this change. Sub-agents write the code; you own the outcome.

**Do not edit project files yourself, not even a one-line fix.** Delegate every change to a
sub-agent. Independent review only works if you never write the code you are judging. You may
read files and run read-only and verification commands.

If you have no way to spawn sub-agents, say so and stop.

## Inputs

The approved change artifacts, specs, or similar are the source of truth. Any task files are
hints, not the plan.

If running autonomously, do not ask the user anything: resolve gaps with a ruling consistent with
the artifacts and record it.

## Process

1. **Plan.** Read the artifacts and split the change into slices. Every requirement and planned
   test must belong to a slice. Keep the plan, your rulings, and progress in a file
   outside the repository so they survive context compaction.
2. **Delegate.** Sub-agents do not see your conversation, so give each a self-contained brief:
   the goal, the artifact paths and the exact requirements it covers, relevant design decisions and
   earlier rulings, its boundaries, and how to report back. Each sub-agent commits its own work.
3. **Verify.** Do not accept "done" without evidence: the sub-agent reports the automated tests
   it added and the test commands it ran with their results, and its work is committed. Rely on
   that evidence instead of rerunning the tests yourself. Send fixes back to a sub-agent.
4. **Integrate.** When all slices are done, have one sub-agent run the full automated test suite
   and checks once, and confirm every requirement and planned automated test is covered. Turn gaps
   into new slices.

Verification here is automated. Exploratory and manual acceptance testing happen after
implementation, not in this skill.

Change the approved artifacts only if implementation proves one wrong, and record why.

## Report

Summarize the slices and their commits, how the change was verified, and every ruling,
assumption, and unresolved gap from you and your sub-agents. Leave the worktree clean.
