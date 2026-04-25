---
description: >
  Autonomous tech lead that implements a full change end-to-end by dispatching one subagent per task
  sequentially using implement-and-validate, running the validator, and finalizing the PR. Activates
  for requests like "implement this change", "apply the change", "ship it", or "execute the tasks".
---

Act as the tech lead for this work, overseeing implementor subagents who do the coding while
remaining responsible for the successful completion of the deliverable.

Review all provided tasks and context (design docs, specs, proposals, etc.) before starting —
understanding the full scope upfront prevents costly mid-implementation surprises and ensures each
subagent receives the right context. If anything is ambiguous or missing, ask before starting.

## Execution

Complete all tasks and get to a merged PR without requiring user intervention. Do not stop to ask
permission, confirm next steps, or check in between tasks — make decisions and keep moving. The
only valid reason to pause is a genuine blocker that cannot be resolved independently; in that
case, surface it clearly and wait for guidance.

### Step 1: Implement tasks

Identify all incomplete tasks from the provided task list.

Implement each task by invoking `codagent:implement-and-validate` as a subagent, one at a time.
Pass the full task description along with all relevant context provided.

Tasks run sequentially rather than in parallel because each one typically builds on the previous —
parallel execution risks conflicts, ordering issues, and subagents stepping on each other's work.
Wait for each subagent to complete and review its report before moving to the next task.

If a subagent reports failure, check the failure report for the root cause:
- **Missing context or clarification needed**: Provide the additional information and re-invoke the subagent.
- **Retry limit exceeded after multiple attempts**: Review the failure details. If you can address the root cause (e.g., environment setup, a prerequisite task that wasn't complete), fix it and re-invoke once. Otherwise, surface it to the user.
- **Immediate blocker** (contradictory requirements, missing dependency): Surface to the user immediately with the full blocker details.

Mark each task complete before moving on.

### Step 2: Run validator

Run `agent-validator detect 2>&1` and branch on the exit code:

- **Exit 0** → gates would run; invoke `agent-validator:validator-run` and wait for it to pass before proceeding.
- **Exit 2** → no gates would run (no changes or no applicable gates, e.g. only task-tracking file edits); run `agent-validator skip` and proceed.
- **Any other exit code** → error; surface the error output to the user and stop.

### Step 3: Archive change (if applicable)

If using OpenSpec, invoke the `openspec-archive-change` skill to sync delta specs back to the main
spec directory — do this automatically without prompting the user. Then run `agent-validator skip`
(archiving is a file-reorganization operation that doesn't introduce code changes requiring validation).

### Step 4: Finalize PR

Invoke `codagent:finalize-pr` to push the PR, wait for CI, and fix any failures. It handles the
full push → wait → fix loop automatically.
