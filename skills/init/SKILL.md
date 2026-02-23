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

Check that required CLIs are installed. If any are missing, tell the user what to install and stop — do not continue with schema copy or config.

**CLIs:**
- `openspec` — run `openspec --version`. If not found: "openspec CLI is required. Install from https://github.com/fission-ai/OpenSpec, then re-run `/flokay:init`."
- `agent-gauntlet` — run `agent-gauntlet --version`. If not found: "agent-gauntlet CLI is required. Install from https://github.com/pacaplan/agent-gauntlet, then re-run `/flokay:init`."

If either CLI is missing, list all missing prerequisites and stop. The user must install them first, then resume `/flokay:init`.

**Skills (check for directory existence, after CLIs pass):**
- `.claude/skills/openspec-*` — OpenSpec skills. If none found: "OpenSpec skills not found. Run `openspec init` to install them, then re-run `/flokay:init`." Stop.
- `.claude/skills/gauntlet-*` — Gauntlet skills. If none found: "Gauntlet skills not found. Run `agent-gauntlet init` to install them, then re-run `/flokay:init`." Stop.

### 2. Copy Schema

Copy the flokay schema from the plugin into the consumer's project.

**Source** (relative to plugin root): `openspec/schemas/flokay/`
**Destination**: `openspec/schemas/flokay/` in the consumer's project

```bash
mkdir -p openspec/schemas/flokay/templates
cp "${CLAUDE_PLUGIN_ROOT}/openspec/schemas/flokay/schema.yaml" openspec/schemas/flokay/schema.yaml
cp "${CLAUDE_PLUGIN_ROOT}/openspec/schemas/flokay/templates/"*.md openspec/schemas/flokay/templates/
```

This copies `schema.yaml` and all template files (`proposal.md`, `design.md`, `spec.md`, `tasks.md`, `review.md`).

Overwrite existing schema files — they are plugin-owned and updated on re-init.

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
1. Start a new change: /openspec-new-change "my-change"
2. Continue the workflow: /openspec-continue-change
3. See the user guide: docs/guide.md (in the flokay plugin)
```

If there were warnings, list them again at the end so the user can address them.

## Guardrails

- Stop on missing prerequisites — tell user what to install and resume with `/flokay:init`
- Never overwrite `openspec/config.yaml` if it exists
- Always overwrite schema files (they're plugin-owned)
- Use `${CLAUDE_PLUGIN_ROOT}` to locate plugin files
