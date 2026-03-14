# agent-abstraction Specification

## Purpose
TBD - created by archiving change cursor-plugin-packaging. Update Purpose after archive.
## Requirements
### Requirement: Agent-neutral skill prose
All SKILL.md files SHALL use agent-neutral language for tool operations. Skills SHALL NOT reference runtime-specific tool names (e.g., `Agent`, `Bash`, `Read`) in their instruction body. Instead, skills SHALL describe the intent (e.g., "spawn a subagent", "run a shell command", "read the file").

#### Scenario: Skill is interpretable by an unfamiliar runtime
- **WHEN** a SKILL.md is loaded by an agent runtime that is not Claude Code
- **THEN** the runtime can interpret the skill's instructions using its native tool equivalents

### Requirement: No allowed-tools in frontmatter
SKILL.md files SHALL NOT include an `allowed-tools` field in their YAML frontmatter. Each runtime SHALL determine available tools based on its own capabilities.

#### Scenario: Runtime determines tool access independently
- **WHEN** a skill is loaded by any supported runtime
- **THEN** the runtime grants tool access based on its own capabilities without being constrained by a frontmatter field

### Requirement: Portable subagent dispatch
Skills that dispatch subagents (e.g., implement-task, fix-pr) SHALL describe subagent dispatch using generic language ("spawn a fresh subagent with the following prompt") without referencing runtime-specific dispatch mechanisms.

#### Scenario: Subagent skill works across runtimes
- **WHEN** a skill that dispatches subagents is loaded in Cursor
- **THEN** Cursor can interpret the dispatch instruction and spawn a subagent using its native mechanism

### Requirement: Portable plugin root resolution
Skills that reference files from other parts of the plugin (e.g., init copying schema files) SHALL describe file location using generic prose ("locate the plugin's root directory") without referencing runtime-specific variables.

#### Scenario: Init skill locates plugin files in either runtime
- **WHEN** the init skill runs in Cursor
- **THEN** it can resolve the plugin root directory using Cursor's native mechanism

### Requirement: Portable skill-local file resolution
Skills that reference files within their own skill directory (e.g., implementer-prompt.md, fixer-prompt.md) SHALL describe file location relative to the skill ("read the file `fixer-prompt.md` in this skill's directory") without referencing runtime-specific variables.

#### Scenario: Skill-local file access works across runtimes
- **WHEN** a skill references a file bundled in its own directory
- **THEN** both Claude Code and Cursor can resolve the file path using their native skill-directory mechanism

<!-- deferred-to-design: The exact generic phrasing and whether a portable variable convention emerges needs architectural investigation during design -->

