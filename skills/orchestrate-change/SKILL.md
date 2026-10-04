---
description: >-
  Implements a well-specified change (an OpenSpec change, or any change with a proposal,
  specifications, design, and test plan) as an orchestrator that delegates all code changes to
  sub-agents. Use by default when implementing an OpenSpec change or other well-specified change,
  especially one without a task breakdown, unless instructed otherwise.
---

# Orchestrate Change

You are the orchestrator for this change. Sub-agents write the code; you own the outcome.

**Do not edit project files yourself, not even a one-line fix.** Delegate every change to a
sub-agent. Independent review only works if you never write the code you are judging. You may
read files and run read-only and verification commands.

If you have no way to spawn sub-agents, say so and stop.

## Inputs

The approved artifacts are the source of truth: the proposal, specifications, design, and test
plan. For an OpenSpec change they live under `openspec/changes/<change-name>/`. Any task files are
hints, not the plan.

If running autonomously, do not ask the user anything: resolve gaps with a ruling consistent with
the artifacts and record it.

## Process

1. **Plan.** Read the artifacts and split the change into slices. Every spec scenario and
   test-plan item must belong to a slice. Keep the plan, your rulings, and progress in a file
   outside the repository so they survive context compaction.
2. **Delegate.** Sub-agents do not see your conversation, so give each a self-contained brief:
   the goal, the artifact paths and the exact scenarios it covers, relevant design decisions and
   earlier rulings, its boundaries, and how to report back. Each sub-agent commits its own work.
3. **Verify.** Do not accept "done" without evidence: each slice's automated tests from the test
   plan exist and pass, and its work is committed. Send fixes back to a sub-agent.
4. **Integrate.** When all slices are done, have the full automated test suite and checks run,
   and confirm every spec scenario and automated test-plan item is covered. Turn gaps into new
   slices.

Verification here is automated tests only. Do not run Agent Validator: validation, exploratory
testing, and manual acceptance testing happen after implementation, not in this skill.

Change the approved artifacts only if implementation proves one wrong, and record why.

## Report

Summarize the slices and their commits, how the change was verified, and every ruling,
assumption, and unresolved gap from you and your sub-agents. Leave the worktree clean.
