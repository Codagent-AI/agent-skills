## Why

The flokay workflow's apply phase currently implements tasks inline in the main agent's context. This fills the context window quickly, provides no enforced TDD discipline, no per-task compliance review, and no automated quality gates. The per-task file structure (from writing-tasks) was designed for zero-context subagents, but nothing consumes it that way today. The infrastructure is built; the consumer is missing.

## What Changes

- New **implement-task** skill that delegates each task to a dedicated implementer subagent
- Implementer subagent follows TDD (red-green-refactor) using the superpowers TDD skill
- After implementation, subagent runs **agent-gauntlet** directly, which executes both a new **task-compliance review** (verifies implementation matches the task spec) and the existing **code-quality review** in parallel
- Subagent fixes gauntlet issues in a loop until all gates pass
- Main agent becomes a thin dispatcher: read task list, send one task to a subagent, mark complete on return, repeat
- Modify existing `/opsx:apply` skill to delegate to implement-task instead of implementing inline
- Pull **test-driven-development** skill from superpowers into the skill manifest

## Capabilities

### New Capabilities
- `implement-task`: Subagent-driven single-task implementation with TDD enforcement, structured self-review, and integrated gauntlet quality gates (task-compliance + code-quality reviews run in parallel)

### Modified Capabilities

(none — no existing specs to modify)

## Impact

- **Skills**: New `implement-task` skill (SKILL.md + implementer-prompt.md). Modified `opsx:apply` command to delegate.
- **Gauntlet config**: New `.gauntlet/reviews/task-compliance.md` review gate. Implementer writes `.gauntlet/current-task-context.md` before each gauntlet run so the task-compliance reviewer knows which task spec to check against.
- **Skill manifest**: Add `test-driven-development` from superpowers. Add `implement-task` as a local skill.
- **Dependencies**: Requires agent-gauntlet CLI (already installed and configured). Requires superpowers TDD skill (to be pulled).
- **Deferred**: Context sentinel for dynamic multi-task batching. Reviewer sub-subagent (gauntlet task-compliance review replaces this). Multi-task-per-subagent pattern.
