# agent-skills

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

- Validator commit skill now uses exit code 2 from `agent-gauntlet detect` to determine whether gates would run, replacing fragile output text parsing.


## 0.3.0

### Minor Changes

- [#12](https://github.com/Codagent-AI/agent-skills/pull/12) Improve the implementor skill with better task dispatch and update the agent-gauntlet dependency.

