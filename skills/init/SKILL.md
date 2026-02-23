---
description: >
  Initializes Flokay in a project by checking prerequisites, copying the flokay schema, and writing
  openspec config. Use when the user says "init", "set up flokay", or "initialize flokay".
---

# Init

Set up the Flokay workflow in the current project. This skill is idempotent — safe to re-run.

**Announce at start:** "Initializing Flokay in this project."

## Steps

### 1. Check Prerequisites

Check that required CLIs and skills are available. Warn on missing items but do not fail.

**CLIs:**
- `openspec` — run `openspec --version`. If not found, warn: "openspec CLI not found. Install from https://github.com/fission-ai/OpenSpec"
- `agent-gauntlet` — run `agent-gauntlet --version`. If not found, warn: "agent-gauntlet CLI not found. Install from https://github.com/pacaplan/agent-gauntlet"

**Skills (check for directory existence):**
- `.claude/skills/openspec-*` — OpenSpec skills. If none found, warn: "OpenSpec skills not found. Run `openspec init` to install them."
- `.claude/skills/gauntlet-*` — Gauntlet skills. If none found, warn: "Gauntlet skills not found. Run `agent-gauntlet init` to install them."

### 2. Copy Schema

Copy the flokay schema from the plugin into the consumer's project.

**Source** (relative to plugin root): `openspec/schemas/flokay/`
**Destination**: `openspec/schemas/flokay/` in the consumer's project

This copies:
- `schema.yaml`
- `templates/proposal.md`
- `templates/design.md`
- `templates/spec.md`
- `templates/tasks.md`
- `templates/review.md` (if present)

Create the destination directories if they don't exist. Overwrite existing schema files — they are plugin-owned and updated on re-init.

Use `${CLAUDE_PLUGIN_ROOT}` to locate the plugin's files.

### 3. Write Config

Write `openspec/config.yaml` in the consumer's project:

```yaml
schema: flokay
```

**If `openspec/config.yaml` already exists**, do NOT overwrite it. Warn: "openspec/config.yaml already exists — not overwriting. Verify it contains `schema: flokay` if you want to use the Flokay workflow."

### 4. Print Success

Print a summary:

```
Flokay initialized successfully.

Schema installed at: openspec/schemas/flokay/
Config at: openspec/config.yaml

Next steps:
1. Start a new change: openspec new "my-change"
2. Continue the workflow: openspec continue
3. See the user guide: docs/guide.md (in the flokay plugin)
```

If there were warnings, list them again at the end so the user can address them.

## Guardrails

- Never fail on missing prerequisites — warn only
- Never overwrite `openspec/config.yaml` if it exists
- Always overwrite schema files (they're plugin-owned)
- Use `${CLAUDE_PLUGIN_ROOT}` to locate plugin files
