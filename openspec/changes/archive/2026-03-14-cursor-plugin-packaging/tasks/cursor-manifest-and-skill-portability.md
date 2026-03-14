# Task: Add Cursor plugin manifest, portabilize skills, and update docs

## Goal

Add a `.cursor-plugin/plugin.json` manifest, make all 11 SKILL.md files runtime-agnostic, and update documentation to cover both Claude Code and Cursor.

## Background

You MUST read these files before starting:
- `design.md` in this change directory for full design details
- `specs/cursor-plugin-manifest/spec.md` for manifest requirements
- `specs/agent-abstraction/spec.md` for portability requirements
- `specs/init-gauntlet-setup/spec.md` for init skill changes
- `specs/plugin-packaging/spec.md` for documentation requirements

Key context for the implementer:

**Cursor manifest**: Create `.cursor-plugin/plugin.json` with fields: `name` ("flokay"), `displayName` ("Flokay"), `version` (must match `.claude-plugin/plugin.json`), `description`, `author`, `license` ("MIT"), `keywords`. Both manifests auto-discover the same `skills/`, `openspec/`, and `.gauntlet/` directories.

**Remove `allowed-tools` from frontmatter** in `finalize-pr`, `fix-pr`, `push-pr`, and `wait-ci` SKILL.md files.

**Replace Claude Code-specific tool/variable references in skill body**:
- In `implement-task/SKILL.md`, replace the `${CLAUDE_PLUGIN_ROOT}` path to `implementer-prompt.md` with skill-relative prose ("Read the file `implementer-prompt.md` in this skill's directory"). Remove `subagent_type` parameters — use generic "spawn a fresh subagent" prose.
- In `fix-pr/SKILL.md`, replace the `${CLAUDE_PLUGIN_ROOT}` path to `fixer-prompt.md` with skill-relative prose. Remove `subagent_type` parameters.
- In `init/SKILL.md`, replace all `${CLAUDE_PLUGIN_ROOT}` cp commands with generic prose: "Copy the following files from the plugin's root directory to the consumer project." Remove the `${CLAUDE_PLUGIN_ROOT}` reference from guardrails.

**Audit all SKILL.md files** for any remaining references to Claude Code-specific tool names (`Agent`, `Bash`, `Read`, `Write`, `Edit`, `Grep`, `Glob`) and rewrite to intent-based language.

**Documentation**:
- `README.md`: Add Cursor installation instructions alongside Claude Code (via `/add-plugin` or `cursor plugins install`). Same prerequisites apply.
- `docs/guide.md`: Add a section noting that skills are invoked identically in both runtimes (`/flokay:propose`, etc.) and document any runtime-specific differences.

## Spec

### Requirement: Cursor plugin manifest
The plugin SHALL have a `.cursor-plugin/plugin.json` file containing the plugin name (`flokay`), version (semver matching `.claude-plugin/plugin.json`), description, author, license (`MIT`), and keywords.

#### Scenario: Cursor discovers the plugin
- **WHEN** a user runs `/add-plugin` or `cursor plugins install` pointing to this repo
- **THEN** Cursor recognizes it as a valid plugin and installs it

#### Scenario: Version parity across manifests
- **WHEN** the plugin is released
- **THEN** `.cursor-plugin/plugin.json` version matches `.claude-plugin/plugin.json` version

### Requirement: Cursor skill discovery
The Cursor plugin SHALL rely on auto-discovery from the shared `skills/` directory. SKILL.md files SHALL NOT include a `name` field in frontmatter, relying on directory names for identity in both runtimes.

#### Scenario: All workflow skills are available after Cursor install
- **WHEN** a user installs the flokay plugin in Cursor
- **THEN** the skills `flokay:propose`, `flokay:design`, `flokay:plan-tasks`, `flokay:test-driven-development`, `flokay:implement-task`, `flokay:init`, `flokay:push-pr`, `flokay:wait-ci`, `flokay:fix-pr`, `flokay:finalize-pr`, and `flokay:spec` are all available

#### Scenario: Internal skills are not shipped to Cursor
- **WHEN** a user installs the flokay plugin in Cursor
- **THEN** no openspec-*, gauntlet-*, discover-skills, or pull-skills skills are included

### Requirement: Cursor plugin bundles schema and gauntlet config
The Cursor plugin SHALL include the same openspec schema (`openspec/schemas/flokay/`) and gauntlet review/check files (`.gauntlet/`) that the Claude Code plugin includes.

#### Scenario: Schema files are present in Cursor plugin
- **WHEN** the flokay plugin is installed in Cursor
- **THEN** the plugin contains `openspec/schemas/flokay/schema.yaml` and all template files

#### Scenario: Gauntlet config is present in Cursor plugin
- **WHEN** the flokay plugin is installed in Cursor
- **THEN** the plugin contains `.gauntlet/checks/` and `.gauntlet/reviews/` with the same files as the Claude Code plugin

### Requirement: Agent-neutral skill prose
All SKILL.md files SHALL use agent-neutral language for tool operations.

#### Scenario: Skill is interpretable by an unfamiliar runtime
- **WHEN** a SKILL.md is loaded by an agent runtime that is not Claude Code
- **THEN** the runtime can interpret the skill's instructions using its native tool equivalents

### Requirement: No allowed-tools in frontmatter
SKILL.md files SHALL NOT include an `allowed-tools` field in their YAML frontmatter.

#### Scenario: Runtime determines tool access independently
- **WHEN** a skill is loaded by any supported runtime
- **THEN** the runtime grants tool access based on its own capabilities without being constrained by a frontmatter field

### Requirement: Portable subagent dispatch
Skills that dispatch subagents SHALL describe subagent dispatch using generic language without referencing runtime-specific dispatch mechanisms.

#### Scenario: Subagent skill works across runtimes
- **WHEN** a skill that dispatches subagents is loaded in Cursor
- **THEN** Cursor can interpret the dispatch instruction and spawn a subagent using its native mechanism

### Requirement: Portable plugin root resolution
Skills that reference files from other parts of the plugin SHALL describe file location using generic prose without referencing runtime-specific variables.

#### Scenario: Init skill locates plugin files in either runtime
- **WHEN** the init skill runs in Cursor
- **THEN** it can resolve the plugin root directory using Cursor's native mechanism

### Requirement: Portable skill-local file resolution
Skills that reference files within their own skill directory SHALL describe file location relative to the skill without referencing runtime-specific variables.

#### Scenario: Skill-local file access works across runtimes
- **WHEN** a skill references a file bundled in its own directory
- **THEN** both Claude Code and Cursor can resolve the file path using their native skill-directory mechanism

### Requirement: Copy review and check files
The init skill SHALL locate plugin files using generic prose without referencing runtime-specific variables.

#### Scenario: Plugin file location is runtime-agnostic
- **WHEN** the init skill copies files from the plugin
- **THEN** it locates the plugin root using the hosting runtime's native mechanism, not a runtime-specific variable

### Requirement: User-facing README
The plugin SHALL include a `README.md` documenting installation steps for both Claude Code and Cursor.

#### Scenario: README covers essential information
- **WHEN** a new user reads README.md
- **THEN** they can understand what Flokay is, what they need to install, and how to get started with either Claude Code or Cursor

### Requirement: User guide
The plugin SHALL include a detailed user guide noting any runtime-specific differences between Claude Code and Cursor.

#### Scenario: Guide covers the full workflow
- **WHEN** a user reads docs/guide.md
- **THEN** they understand the full workflow and any differences between running in Claude Code vs Cursor

## Done When

- `.cursor-plugin/plugin.json` exists with correct fields and version matching `.claude-plugin/plugin.json`
- No SKILL.md file contains `allowed-tools` in frontmatter
- No SKILL.md file contains `${CLAUDE_PLUGIN_ROOT}`, `subagent_type`, or Claude Code-specific tool names in its body
- All subagent dispatch instructions use generic prose
- All file references use skill-relative or generic plugin-root prose
- `README.md` includes Cursor installation instructions alongside Claude Code
- `docs/guide.md` includes runtime-specific notes or confirms full parity
- Existing Claude Code functionality is preserved (prose changes only, no behavioral changes)
