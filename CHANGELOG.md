# agent-skills

## 0.8.0

### Minor Changes

- [#44](https://github.com/Codagent-AI/agent-skills/pull/44) Add reusable human-style acceptance testing, revision-bound review evidence, and caller-owned correction and control-flow integration.

## 0.7.6

### Patch Changes

- [#42](https://github.com/Codagent-AI/agent-skills/pull/42) Restructure the documentation into focused introduction, quickstart, workflow, and skill-reference guides, with an automated docs sync workflow.
- [#43](https://github.com/Codagent-AI/agent-skills/pull/43) Calibrate autonomous task planning with LOE-based task-count budgets and dense grouping rules that prevent systematic over-splitting.

## 0.7.5

### Patch Changes

- [9669478](https://github.com/Codagent-AI/agent-skills/commit/9669478) Preserved task execution order in planning artifacts so generated task lists keep dependency ordering intact.
- [7ae0245](https://github.com/Codagent-AI/agent-skills/commit/7ae0245) Improved planning-related skills so agents recommend before asking, decide low-risk details, and surface inferred decisions during approval.

## 0.7.4

### Patch Changes

- [#38](https://github.com/Codagent-AI/agent-skills/pull/38) Added a release skill workflow for automating version bumps and changelogs, and improved guidance for how skills ask users questions interactively
- [#39](https://github.com/Codagent-AI/agent-skills/pull/39) Added name fields to skill frontmatter for Vercel platform compatibility
- Removed OpenSpec-specific language from generic skills (simple-plan, proposal-review) so they work in any workflow

## 0.7.3

### Patch Changes

- [#36](https://github.com/Codagent-AI/agent-skills/pull/36) Added the proposal-review skill and refined proposal guidance to cover high-level what and how evaluation.

## 0.7.2

### Patch Changes

- [#35](https://github.com/Codagent-AI/agent-skills/pull/35) Add Codex plugin packaging with manifest, entry point, and release script support
- [#36](https://github.com/Codagent-AI/agent-skills/pull/36) Add proposal-review skill for adversarial review of proposals, and update propose skill to include high-level technical approach and architecture

## 0.7.1

### Patch Changes

- [#32](https://github.com/Codagent-AI/agent-skills/pull/32) Add `handoff` and `review-assumptions` skills for summarizing session context for another agent and auditing implementor assumptions, and update `session-report` with improved output
- [#33](https://github.com/Codagent-AI/agent-skills/pull/33) Add `ask-questions` skill for structured user interaction, and include `handoff` and `review-assumptions` skills with guidance for writing context handoffs to other agents

## 0.7.0

### Minor Changes

- [#27](https://github.com/Codagent-AI/agent-skills/pull/27) Adds the `implement-change` skill, which autonomously dispatches subagents to implement a full change end-to-end.
- [#29](https://github.com/Codagent-AI/agent-skills/pull/29) Adds the `session-report` and `task-compliance` (formerly self-review) skills for auditing session assumptions and verifying implementation against task requirements.
- [#30](https://github.com/Codagent-AI/agent-skills/pull/30) Adds the `simple-plan` skill, a lightweight planning tool for small changes that combines propose, spec, and design into a single step.

### Patch Changes

- [#28](https://github.com/Codagent-AI/agent-skills/pull/28) Renames all internal references from "gauntlet" to "validator" for consistency with the updated tool naming.

## 0.6.1

### Patch Changes

- [#25](https://github.com/Codagent-AI/agent-skills/pull/25) Align skill authoring style to imperative/third-person conventions and address review comments across multiple skills

## 0.6.0

### Minor Changes

- [#21](https://github.com/Codagent-AI/agent-skills/pull/21) Added Cursor IDE plugin support with portable skills that work across editor environments.
- [#23](https://github.com/Codagent-AI/agent-skills/pull/23) Renamed the plugin to `codagent` and embedded artifact templates directly into the plugin for self-contained distribution.

### Patch Changes

- [#20](https://github.com/Codagent-AI/agent-skills/pull/20) Reverted the removal of the codex adapter from `implement-task` to restore previous behavior.
- [#22](https://github.com/Codagent-AI/agent-skills/pull/22) Renamed the project and removed outdated items to reflect the new `codagent` branding.

## 0.5.0

### Minor Changes

- [#16](https://github.com/Codagent-AI/agent-skills/pull/16) Added multi-adapter dispatch to the implement-task skill, enabling external agent delegation via a new Codex adapter alongside the existing Claude subagent.

- [#17](https://github.com/Codagent-AI/agent-skills/pull/17) Added an adapter configuration step to the init skill so projects can choose their preferred implementation adapter (Claude or Codex) during setup.

### Patch Changes

- [#18](https://github.com/Codagent-AI/agent-skills/pull/18) Updated workflow documentation to a two-stage model, removed obsolete OPSX command files, fixed Codex adapter defaults (sandbox mode and approval policy), and documented the 30-minute timeout constant.


## 0.4.0

### Minor Changes

- Schema improvements to the apply workflow steps and finalize-pr skill notes for clarity and correctness.

- Validator commit skill now uses exit code 2 from `agent-validator detect` to determine whether gates would run, replacing fragile output text parsing.


## 0.3.0

### Minor Changes

- [#12](https://github.com/Codagent-AI/agent-skills/pull/12) Improve the implementor skill with better task dispatch and update the agent-validator dependency.

