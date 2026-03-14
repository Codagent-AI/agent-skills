## MODIFIED Requirements

### Requirement: Plugin skills have no name frontmatter
Plugin skill SKILL.md files SHALL NOT include a `name` field in their YAML frontmatter. Directory names determine skill identity for correct namespace resolution in both Claude Code and Cursor.

#### Scenario: Namespace prefix is preserved
- **WHEN** a plugin skill has no `name` field in frontmatter
- **THEN** both Claude Code and Cursor resolve it as `flokay:<directory-name>`

### Requirement: User-facing README
The plugin SHALL include a `README.md` at the repo root documenting: what Flokay is, prerequisites, installation steps for both Claude Code and Cursor, and a quick-start guide with a link to the detailed user guide.

#### Scenario: README covers essential information
- **WHEN** a new user reads README.md
- **THEN** they can understand what Flokay is, what they need to install, and how to get started with either Claude Code or Cursor

### Requirement: User guide
The plugin SHALL include a detailed user guide at `docs/guide.md` covering the full workflow, each artifact's purpose, and how to use the openspec commands. The guide SHALL note any runtime-specific differences between Claude Code and Cursor.

#### Scenario: Guide covers the full workflow
- **WHEN** a user reads docs/guide.md
- **THEN** they understand the full workflow and any differences between running in Claude Code vs Cursor
