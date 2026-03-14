## Why

Flokay is packaged only as a Claude Code plugin. Cursor has adopted the Agent Skills open spec (agentskills.io) and launched its own plugin marketplace (Cursor 2.5, Feb 2026), making cross-agent distribution tractable. Shipping a single set of skills that works in both Claude Code and Cursor doubles flokay's addressable user base without maintaining a fork.

## What Changes

- Introduce an agent-abstraction layer so skills reference portable capability names (e.g., "spawn subagent", "run shell command") instead of Claude Code-specific tool names (e.g., `Agent`, `Bash`)
- Add a Cursor plugin manifest alongside the existing Claude Code manifest
- Adapt all 11 skills to work in both runtimes with full parity — no Cursor-lite subset
- Update the init skill to use runtime-agnostic prose for locating plugin files
- Update README and user guide to cover Cursor installation and usage

## Capabilities

### New Capabilities
- `cursor-plugin-manifest`: Cursor-compatible plugin manifest and marketplace metadata for discovery and installation via Cursor's `/add-plugin` command
- `agent-abstraction`: Portable abstraction over agent-specific primitives (subagent dispatch, tool references, plugin root resolution) so a single set of SKILL.md files works in both Claude Code and Cursor

### Modified Capabilities
- `plugin-packaging`: Existing plugin-packaging spec needs to expand from Claude Code-only to multi-agent — manifest requirements, skill set requirements, and namespace resolution must account for both runtimes
- `init-gauntlet-setup`: Init skill must use runtime-agnostic prose for locating plugin files instead of Claude Code-specific variables

## Impact

- **Skills directory** (`skills/`): All 11 SKILL.md files — frontmatter `allowed-tools` and any inline tool references need to use portable names or conditional patterns
- **Subagent dispatch** (`implement-task`, `fix-pr`, `finalize-pr`): These skills call Claude Code's `Agent` tool directly — need to go through the abstraction layer
- **Plugin manifests**: New `.cursor-plugin/` plugin config alongside existing `.claude-plugin/`
- **Init skill**: Must use runtime-agnostic prose for plugin root path resolution
- **Docs**: README and guide need Cursor install instructions and any runtime-specific notes
- **OpenSpec schema**: `schema.yaml` skill references may need portable names if Cursor namespacing differs
