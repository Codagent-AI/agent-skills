---
description: >
  Initializes Agent Skills in a project by checking prerequisites and verifying the validator
  configuration. Use when the user says "init", "set up agent-skills", or "initialize agent-skills".
---

# Init

Set up Agent Skills in the current project. This skill is idempotent — safe to re-run.

**Announce at start:** "Initializing Agent Skills in this project."

## Steps

### 1. Check Prerequisites

Check that the Agent Validator CLI is installed. If missing, tell the user what to install and stop.

- `agent-gauntlet` — run `agent-gauntlet --version`.
  - If not found: "Agent Validator CLI is required. Install with `npm install -g @pacaplan/agent-gauntlet`, then run `agent-gauntlet init` in your project, then re-run `/agent-skills:init`."
  - If found, extract the version number and verify it is **≥ 0.15**. If too old: "agent-gauntlet 0.15 or higher is required (found \<version\>). Upgrade from https://github.com/pacaplan/agent-gauntlet, then re-run `/agent-skills:init`."

Use this shell snippet to compare versions:
```bash
version_gte() { [ "$(printf '%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }
```
Example: `version_gte "$installed_version" "0.15"` returns true if `$installed_version` ≥ 0.15.

If the CLI is missing or out of date, stop. The user must resolve it first, then resume `/agent-skills:init`.

**Validator config (check after CLI passes):**
- `.gauntlet/config.yml` must exist. If not found: "Validator config not found. Run `agent-gauntlet init` in your project first, then re-run `/agent-skills:init`." Stop.

### 2. Update .gitignore

Ensure `.gauntlet/current-task-context.md` is listed in the consumer project's `.gitignore` (it is a transient working file that should never be committed).

Append it only if not already present:
```bash
grep -qxF '.gauntlet/current-task-context.md' .gitignore 2>/dev/null || echo '.gauntlet/current-task-context.md' >> .gitignore
```

### 3. Print Success

Print a summary:

```
Agent Skills initialized successfully.

Available skills:
- /agent-skills:propose — evaluate an idea and write a proposal
- /agent-skills:spec — interview-driven requirement discovery
- /agent-skills:design — brainstorm architecture and write a design doc
- /agent-skills:plan-tasks — break a change into scoped task files
- /agent-skills:implement-task — dispatch subagents to implement tasks
- /agent-skills:finalize-pr — push PR, wait for CI, fix failures
```

### 4. Commit

Invoke `/agent-validator:validator-commit skip` to commit any scaffolding changes. Checks are skipped because init only writes boilerplate.

## Guardrails

- Stop on missing or outdated prerequisites — tell user what to install/run and resume with `/agent-skills:init`
- Never overwrite `.gauntlet/config.yml` — only add/update entry points and reviews
- Use the hosting runtime's native mechanism to locate the plugin's root directory
