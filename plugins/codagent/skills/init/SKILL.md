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

- `agent-validator` — run `agent-validator --version`.
  - If not found: "Agent Validator CLI is required. Install with `npm install -g agent-validator`, then run `agent-validator init` in your project, then re-run `use the codagent:init skill`."
  - If found, extract the version number and verify it is **≥ 0.15**. If too old: "agent-validator 0.15 or higher is required (found \<version\>). Upgrade with `npm install -g agent-validator@latest`, then re-run `use the codagent:init skill`."

Use this shell snippet to compare versions:
```bash
version_gte() { [ "$(printf '%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }
```
Example: `version_gte "$installed_version" "0.15"` returns true if `$installed_version` ≥ 0.15.

If the CLI is missing or out of date, stop. The user must resolve it first, then resume `use the codagent:init skill`.

**Validator config (check after CLI passes):**
- `.validator/config.yml` must exist. If not found: "Validator config not found. Run `agent-validator init` in your project first, then re-run `use the codagent:init skill`." Stop.

### 2. Print Success

Print a summary:

```
Agent Skills initialized successfully.

Available skills:
- use the codagent:propose skill — evaluate an idea and write a proposal
- use the codagent:spec skill — interview-driven requirement discovery
- use the codagent:design skill — brainstorm architecture and write a design doc
- use the codagent:plan-tasks skill — break a change into scoped task files
- use the codagent:implement-and-validate skill — implement a single task and verify with the validator
- use the codagent:finalize-pr skill — push PR, wait for CI, fix failures
```

### 3. Commit

Invoke `/agent-validator:validator-commit skip` to commit any scaffolding changes. Checks are skipped because init only writes boilerplate.

## Guardrails

- Stop on missing or outdated prerequisites — tell user what to install/run and resume with `use the codagent:init skill`
- Never overwrite `.validator/config.yml` — only add/update entry points and reviews
- Use the hosting runtime's native mechanism to locate the plugin's root directory
