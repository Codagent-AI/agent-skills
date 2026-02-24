## Why

Today the OpenSpec apply phase ends when all implementation tasks are checked off. But the real workflow continues: verify quality, create a PR, wait for CI, fix failures, and iterate until the PR is green and reviewed. This "last mile" is currently manual — the user has to remember to invoke `/gauntlet-run`, then `/push-pr`, then wait, then `/address-pr`, then push again. The pieces exist but there's no orchestration connecting them into a continuous flow.

The stop hook in agent-gauntlet solves this reactively (blocks the agent from stopping until the loop completes), but that requires opt-in configuration and only works as enforcement — it can't drive the workflow forward proactively. We need a skill that drives this workflow forward after implementation is done.

## What Changes

- Add a new `flokay:finalize-pr` skill that orchestrates the post-implementation loop: verify → push PR → wait for CI → fix issues → repeat until green
- Add supporting skills to the flokay plugin: `wait-ci` (polls CI status via `gh` CLI) and `fix-pr` (addresses CI failures and review comments)
- Bring the existing user-level `/push-pr` skill logic into the flokay plugin as a project-level skill
- Update `apply.instruction` in the schema to tell the agent to invoke `flokay:finalize-pr` after all tasks complete

## Capabilities

### New Capabilities
- `finalize-pr`: An orchestrator skill that drives the full post-implementation loop — runs gauntlet verification, creates/updates the PR, waits for CI, fixes failures and review comments, and repeats until the PR is green or the user intervenes
- `wait-ci-skill`: A skill that polls CI status via `gh` CLI and returns structured results (pass/fail/pending, failed check details with log output, blocking review comments)
- `fix-pr-skill`: A skill that addresses CI failures and review comments on the current PR (fix code, commit, push, resolve threads, reply to comments)

### Modified Capabilities
- `skill-decoupling`: The schema's `apply.instruction` will reference `flokay:finalize-pr` by name, following the same pattern established for `flokay:implement-task` and `flokay:test-driven-development`

## Impact

- **Skills added**: `finalize-pr`, `wait-ci`, `fix-pr`, `push-pr` in `.claude/skills/`
- **Schema**: `apply.instruction` in `openspec/schemas/flokay/schema.yaml` updated to reference `flokay:finalize-pr` after task completion
- **No changes to**: `openspec-apply-change` skill (remains generic OpenSpec orchestrator)
- **Dependencies**: Relies on `gh` CLI for PR and CI operations (already available)
- **Code reuse**: `wait-ci` logic modeled on `agent-gauntlet/src/commands/wait-ci.ts` concepts (polling, log enrichment, structured output) but implemented as a skill calling `gh` directly — no dependency on agent-gauntlet CLI
- **User-level skills**: `/push-pr` and `/address-pr` in `~/.claude/skills/` remain unchanged; project-level copies in the plugin may diverge over time
