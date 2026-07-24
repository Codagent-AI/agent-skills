---
title: Quickstart
group: Getting Started
order: 2
description: Install the skill bundle for your agent host and run the first workflow.
---

# Quickstart

Install the plugin for your host, initialize the target project, then invoke the skill that matches the work.

## Prerequisites

Agent Validator is required for the implementation and PR workflows:

```bash
npm install -g agent-validator
agent-validate init
```

The `init` skill verifies:

- `agent-validator` is installed
- the installed validator version is `0.15` or newer
- `.validator/config.yml` exists in the target project

## Install In Claude Code

```bash
claude plugin marketplace add Codagent-AI/agent-skills
claude plugin install codagent
```

Initialize the current project:

```text
/codagent:init
```

Claude Code invokes skills with slash commands, such as:

```text
/codagent:propose
/codagent:implement-change
/codagent:finalize-pr
```

## Install In Codex

Add the marketplace:

```bash
codex plugin marketplace add Codagent-AI/agent-skills
```

Restart Codex, open `/plugins`, select the Codagent marketplace, and install or enable the `codagent` plugin.

Initialize the current project:

```text
use the codagent:init skill
```

Codex invokes skills by name in chat, for example:

```text
use the codagent:propose skill
use the codagent:implement-change skill
use the codagent:finalize-pr skill
```

## Install In Cursor

```bash
cursor plugins install Codagent-AI/agent-skills
```

After installation, initialize the project with the `init` skill from the Cursor plugin environment.

## First Workflow

For a larger change:

1. Use `codagent:propose` to evaluate the idea and write `proposal.md`.
2. Run `codagent:proposal-review` for an adversarial review before confirming the proposal.
3. Run `codagent:spec` to turn the proposal into testable requirements.
4. Ask `codagent:design` to settle architecture and implementation approach.
5. Run `codagent:review-approach` for the final consistency, gap, and decision review of the proposal, specs, and design.
6. Use `codagent:plan-tasks` to create task files for implementation.
7. Run `codagent:review-tasks` to verify the task plan against the approved definition.
8. Ask `codagent:implement-change` to run the implementation loop.
9. Use `codagent:finalize-pr` if the PR still needs CI polling or review-comment cleanup.

For a small change:

```text
use the codagent:simple-plan skill for this change
```

Then use `codagent:implement-change` when the plan is ready.

## Updating

For Claude Code:

```bash
claude plugin marketplace update codagent
claude plugin update codagent@codagent
```

After updating, run the init skill again in projects that use Codagent.
