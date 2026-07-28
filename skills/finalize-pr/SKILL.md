---
name: finalize-pr
description: >
  Orchestrates the full post-implementation loop: push PR → wait for CI → fix failures → repeat
  until CI passes or termination rules trigger a pause.
  This skill should be used when the user says "ship it", "finalize pr", "push and fix CI",
  "push pr and wait for CI", or invokes "codagent:finalize-pr".
---

# Finalize PR

Use the independently reusable PR skills to make the current branch review-ready:

1. Invoke `codagent:push-pr`.
2. Invoke `codagent:wait-ci`.
3. On `failed` or `comments`, invoke `codagent:fix-pr`, then return to waiting.
4. On `passed`, report success and the PR URL.

For `pending`, report what remains and ask whether to wait longer.

## Termination

Track each fix cycle's failure signature: the set of failing check names, or `comments-only` when only
review feedback remains.

Pause for user direction instead of fixing when:

- three fix cycles have already run; or
- the same signature remains after two consecutive fix attempts.

When pausing, include the current CI or review evidence and the attempted fixes. Do not archive changes;
archiving is a separate operation.
