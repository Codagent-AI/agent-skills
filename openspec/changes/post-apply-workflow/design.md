## Context

The flokay workflow currently ends at task implementation. After all tasks in `tasks.md` are checked off, the `apply.instruction` tells the agent to archive. But in practice, the workflow continues: run quality gates, create a PR, wait for CI, fix failures and review comments, and iterate until the PR is green. These steps are handled by separate skills (`gauntlet-run`, user-level `/push-pr`, user-level `/address-pr`) that the user must invoke manually in sequence. The stop hook in agent-gauntlet enforces this reactively but doesn't drive the workflow forward.

The existing `gauntlet-push-pr` and `gauntlet-fix-pr` skills in the project are stubs (11-15 lines each, `disable-model-invocation: true`). The real implementations live at the user level (`~/.claude/skills/push-pr/`, `~/.claude/skills/address-pr/`). The `wait-ci` logic exists as a TypeScript command in agent-gauntlet (`src/commands/wait-ci.ts`) but isn't exposed as a skill.

## Goals / Non-Goals

**Goals:**
- A single `flokay:finalize-pr` skill that the agent invokes after implementation is done, driving the full verify → push → wait → fix loop
- Project-level skills (`push-pr`, `wait-ci`, `fix-pr`) in the flokay plugin so the workflow is self-contained
- The schema's `apply.instruction` references `flokay:finalize-pr` as the step after task completion
- Each sub-skill is independently invocable (user can call `/push-pr` or `/fix-pr` standalone)

**Non-Goals:**
- Forking OpenSpec or modifying the `openspec-apply-change` orchestrator
- Replacing or deprecating the user-level skills in `~/.claude/skills/`
- Modifying the agent-gauntlet stop hook or creating a dependency on it
- Automating PR merge — the loop ends when CI is green, merge is manual

## Decisions

### Decision 1: Skill placement — flokay plugin `skills/` directory

New skills go in `skills/` (alongside `implement-task`, `design`, etc.) rather than `.claude/skills/`. This follows the existing pattern where content skills live in `skills/` and get discovered by the plugin.

The existing `gauntlet-push-pr` and `gauntlet-fix-pr` stubs in `.claude/skills/` will be replaced by the new project-level skills. The new skills are fuller implementations that supersede the stubs.

### Decision 2: `finalize-pr` is an orchestrator, sub-skills do the work

`finalize-pr` follows the same pattern as `implement-task`: it's an orchestrator that calls other skills in sequence. It does not do PR creation or CI polling itself.

```
finalize-pr (orchestrator)
    │
    ├── gauntlet-run       (existing — verify quality)
    ├── push-pr            (new — commit, push, create/update PR)
    ├── wait-ci            (new — poll CI, return structured result)
    └── fix-pr             (new — fix failures, push, loop back)
```

### Decision 3: `wait-ci` is a skill, not a CLI command

The `wait-ci` logic in agent-gauntlet is a TypeScript CLI command with poll loops and structured JSON output. For the skill-based approach, we translate the same concepts into skill instructions that the agent follows using `gh` CLI commands directly. No TypeScript, no external dependency.

The skill instructs the agent to:
1. Run `gh pr checks --json name,state,link` in a loop with delays
2. On failure: fetch logs via `gh run view <run-id> --log-failed`
3. On blocking reviews: fetch via `gh api` for review comments
4. Return a structured summary (what passed, what failed, log excerpts, review comments)

The key concepts ported from `wait-ci.ts`:
- **Poll with backoff**: Check every 30s, up to a configurable timeout
- **Log enrichment**: Extract run IDs from check links, fetch `--log-failed` output
- **Review awareness**: Check for `CHANGES_REQUESTED` reviews, deduplicate to latest per author
- **Structured output**: The skill returns a clear summary the orchestrator can act on

### Decision 4: `fix-pr` combines CI fixes and review comment addressing

Rather than separate skills for CI failures vs. review comments, `fix-pr` handles both — they arrive at the same time and the fix flow is identical: read the failures/comments, make changes, commit, push.

This skill is based on the user-level `/address-pr` skill but adapted for the project context:
- No PR URL argument needed (operates on current branch's PR)
- Integrated with the finalize-pr loop (returns structured pass/fail, not just a summary)
- Lighter — skips the GraphQL thread resolution since the orchestrator will re-check CI anyway

### Decision 5: `push-pr` adapts the user-level skill

The user-level `/push-pr` handles commit, push, and PR create/update with description generation. The project-level version follows the same logic but:
- Uses `flokay:` namespace prefix
- Lives in `skills/push-pr/` in the plugin
- May be invoked standalone or by the finalize-pr orchestrator

### Decision 6: Schema instruction update — minimal change

The `apply.instruction` in `schema.yaml` gets one additional line:

```
Once ALL tasks are complete, invoke the `flokay:finalize-pr` skill to verify,
create the PR, and iterate until CI passes.
```

The existing instruction about `flokay:implement-task` and archiving stays. The finalize-pr skill handles the bridge between "tasks done" and "ready to archive."

### Decision 7: Loop termination and user control

The finalize-pr loop has explicit exit conditions:
- **CI passes, no blocking reviews** → success, suggest archive
- **Max iterations reached** (default: 3 fix cycles) → pause, show status, ask user
- **User interrupts** → pause, show status
- **Unfixable failure** (infrastructure issue, flaky test) → pause, explain, ask user

The agent does NOT loop forever. After each fix-pr cycle, it evaluates whether progress was made (new failures vs. same failures). If stuck on the same failure after 2 attempts, it pauses.

## Risks / Trade-offs

### Risk: CI polling timeout in a skill context

Skills run within the agent's turn. Polling CI for 5+ minutes means the agent is blocked. Mitigation: the wait-ci skill uses explicit `sleep` delays between polls (the agent calls `sleep 30` via Bash), keeping the turn alive. The timeout is configurable but defaults to 5 minutes. If CI hasn't completed, the skill returns "pending" and the orchestrator can decide to retry or pause.

### Risk: Skill files get large and complex

The finalize-pr orchestrator and fix-pr skill both have substantial logic. Mitigation: follow the implement-task pattern — keep the orchestrator focused on sequencing, delegate work to sub-skills. Each sub-skill has a single responsibility.

### Trade-off: Project-level skills duplicate user-level skills

The project-level `push-pr` and `fix-pr` overlap with user-level `/push-pr` and `/address-pr`. This is intentional — the project-level versions are tailored for the finalize-pr orchestration context and can evolve independently. The user-level skills remain available for ad-hoc use outside of OpenSpec workflows.

### Trade-off: No structured schema enforcement

Approach B means the post-implementation workflow is defined in skill instructions, not in the schema's type system. The schema only says "use finalize-pr" — it doesn't enforce that verify happens before push, or that CI must pass before archive. The enforcement lives in the skill's step-by-step instructions. This is acceptable for now and can be graduated to a schema-level definition (Approach A) later if needed.

## Migration Plan

1. **Add new skills**: Create `finalize-pr`, `push-pr`, `wait-ci`, `fix-pr` in `skills/`
2. **Replace stubs**: Remove `gauntlet-push-pr` and `gauntlet-fix-pr` from `.claude/skills/` (or replace their content with pointers to the new skills)
3. **Update schema**: Add `flokay:finalize-pr` reference to `apply.instruction` in `schema.yaml`
4. **No rollback needed**: Existing workflows unaffected — the new skills are additive. Users can still invoke individual skills manually.

## Open Questions

None — the exploration session resolved the key design questions (skill placement, orchestration pattern, fork vs. no-fork).
