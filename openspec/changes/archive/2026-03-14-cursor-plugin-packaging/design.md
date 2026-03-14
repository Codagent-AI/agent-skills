## Context

Flokay is currently a Claude Code-only plugin. Cursor has adopted the same Agent Skills open spec and launched a plugin marketplace (Cursor 2.5). Both runtimes auto-discover skills from a `skills/` directory using `SKILL.md` files, making a single-codebase, dual-manifest approach viable.

The repo currently has:
- `.claude-plugin/plugin.json` — Claude Code manifest
- `skills/` — 11 skills, some with `allowed-tools` in frontmatter and Claude Code-specific tool/variable references in their body
- `openspec/schemas/flokay/` — bundled workflow schema
- `.gauntlet/` — quality gate config, reviews, and checks

## Goals / Non-Goals

**Goals:**
- Ship a single set of skill files that works in both Claude Code and Cursor
- Add a `.cursor-plugin/plugin.json` manifest alongside the existing Claude Code manifest
- Remove all Claude Code-specific tool names, variables, and dispatch mechanisms from skill prose
- Update docs to cover both runtimes

**Non-Goals:**
- Cursor marketplace submission (future follow-up — requires logo, manual review)
- Supporting runtimes beyond Claude Code and Cursor
- Adding Cursor-specific components (rules, agents, commands) not present in the Claude Code plugin
- Changing skill behavior or workflow logic — this is a portability change only

## Decisions

### 1. Dual manifests, no build step

Add `.cursor-plugin/plugin.json` alongside `.claude-plugin/plugin.json`. Both point to the same `skills/`, `openspec/`, and `.gauntlet/` directories via auto-discovery. No build or packaging tooling needed.

`.cursor-plugin/plugin.json` fields: `name` ("flokay"), `displayName`, `version` (must match Claude Code manifest), `description`, `author`, `license` ("MIT"), `keywords`.

### 2. Drop `allowed-tools` from all SKILL.md frontmatter

Four skills currently have `allowed-tools`: `finalize-pr`, `fix-pr`, `push-pr`, `wait-ci`. Remove the field entirely. Both runtimes will make all available tools accessible to skills.

### 3. Replace tool-name references with intent-based prose

Audit all SKILL.md bodies for Claude Code-specific tool names (`Agent`, `Bash`, `Read`, `Write`, `Edit`, `Grep`, `Glob`) and rewrite to intent language:

| Current | Replacement |
|---------|-------------|
| "Use the Agent tool to spawn..." | "Spawn a fresh subagent to..." |
| "Use the Bash tool to run..." | "Run the following shell command..." |
| `subagent_type: "general-purpose"` | (remove — let runtime choose) |

Affected skills: `implement-task`, `fix-pr`, `finalize-pr` (subagent dispatch), plus any that reference tool names inline.

### 4. Replace `${CLAUDE_PLUGIN_ROOT}` with generic prose

Three skills reference `${CLAUDE_PLUGIN_ROOT}`:

- **`init`** — Uses it to copy schema and gauntlet files. Replace `cp "${CLAUDE_PLUGIN_ROOT}/..."` commands with prose: "Copy the following files from the plugin's root directory to the consumer project." The runtime will resolve the plugin root using its native mechanism (`${CLAUDE_PLUGIN_ROOT}` for Claude Code, Cursor's equivalent).

- **`implement-task`** and **`fix-pr`** — Use it to read prompt files (`implementer-prompt.md`, `fixer-prompt.md`) that are in the *same skill directory*. Replace with: "Read the file `implementer-prompt.md` in this skill's directory." Both runtimes support skill-local file resolution.

### 5. No `name` field in SKILL.md frontmatter

Keep the current approach: omit `name` from all SKILL.md frontmatter. Both Claude Code and Cursor default to using the directory name. This preserves the `flokay:` namespace prefix in both runtimes (and avoids Claude Code bug #22063 which strips the prefix when `name` is present).

### 6. Version parity enforcement

Both manifests must declare the same semver version. This is a manual discipline enforced during the release process — no automation needed for now.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Cursor may not resolve skills without `name` in frontmatter | Test with Cursor after implementation; fall back to adding `name` if needed |
| Generic prose may be less precise than explicit tool calls | Skills already work as prompts — runtimes are good at interpreting intent |
| `allowed-tools` removal gives skills broader tool access | Acceptable — skills are trusted plugin code |
| Dual manifests could drift in version | Enforce during release checklist |

## Migration Plan

1. Add `.cursor-plugin/plugin.json`
2. Edit all 11 SKILL.md files: remove `allowed-tools`, replace tool-name references and `${CLAUDE_PLUGIN_ROOT}` with generic prose
3. Update `README.md` with Cursor install instructions
4. Update `docs/guide.md` with runtime-specific notes
5. Test in Claude Code to verify no regressions
6. Test in Cursor to verify discovery and invocation

No rollback needed — changes are additive (new manifest) and prose-only (skill edits don't change behavior).

## Open Questions

- Does Cursor correctly resolve skills without `name` in frontmatter? (Deferred from spec — verify during testing)
- What is Cursor's equivalent of `${CLAUDE_PLUGIN_ROOT}` for plugin root resolution? (Runtime will resolve generically — no action needed unless testing reveals issues)
