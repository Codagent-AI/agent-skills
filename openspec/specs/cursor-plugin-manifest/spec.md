# cursor-plugin-manifest Specification

## Purpose
TBD - created by archiving change cursor-plugin-packaging. Update Purpose after archive.
## Requirements
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

