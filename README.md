# Codagent Agent Skills

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![CodeRabbit](https://img.shields.io/coderabbit/prs/github/Codagent-AI/agent-skills)](https://coderabbit.ai)

Codagent Agent Skills is a portable skill bundle for guiding AI agents through software-development work. The skills turn open-ended requests into a repeatable flow: evaluate the idea, write requirements, design the approach, break work into tasks, test the result, and finalize the pull request.

The repository ships the same core skills through host-specific plugin manifests:

- `.claude-plugin/plugin.json` for Claude Code
- `.codex-plugin/plugin.json` for Codex
- `.cursor-plugin/plugin.json` for Cursor

## What It Includes

The core skills cover five parts of the development lifecycle:

- Planning: `propose`, `proposal-review`, `spec`, `design`, `test-plan`, `review-approach`, `plan-tasks`, `review-tasks`, `review-spec`, and `simple-plan`
- Implementation: `orchestrate-change`
- Testing: `test-flows` and `prepare-acceptance`
- Pull requests: `push-pr`, `wait-ci`, `fix-pr`, and `finalize-pr`
- Support and review: `init`, `ask-questions`, `handoff`, `session-report`, `review-assumptions`, and `task-compliance`

The repository also includes a separate release skill under `.agents/skills/release` and `.claude/skills/release`. That release skill is for maintainers of this repository, not part of the installed user-facing Codagent workflow.

## Intended Workflow

Codagent works best when the agent has explicit artifacts to hand off between phases. A typical larger change moves through:

```text
propose -> proposal-review -> spec -> design -> test-plan -> review-approach -> plan-tasks -> review-tasks -> (implement) -> finalize-pr
```

For smaller changes, `simple-plan` compresses planning into one lightweight pass and `test-flows`
provides a proportional branch-local user-flow check without requiring PR finalization.

## When To Use It

Use Codagent skills when the work benefits from written intent, reviewable requirements, or an agent-to-agent handoff. The full planning flow is useful for feature work, cross-cutting changes, or changes with unclear requirements. The smaller `simple-plan` path is better for quick, bounded changes that still need a written trail.

For one-off questions, debugging conversations, or manual editing where no lifecycle is needed, invoking a skill is optional.

## Documentation

- [Quickstart](docs/quickstart.md) - install, initialize, and run the first workflow
- [Workflow Guide](docs/workflow-guide.md) - how the planning, testing, and PR skills fit together
- [Skills Reference](docs/skills-reference.md) - concise reference for every bundled skill

## Install

### Claude Code

```bash
claude plugin marketplace add Codagent-AI/agent-skills
claude plugin install codagent
```

Then initialize a project:

```text
/codagent:init
```

### Codex

```bash
codex plugin marketplace add Codagent-AI/agent-skills
```

Restart Codex, open `/plugins`, select the Codagent marketplace, and enable the `codagent` plugin.

Then initialize a project:

```text
use the codagent:init skill
```

### Cursor

```bash
cursor plugins install Codagent-AI/agent-skills
```

Then initialize a project from the Cursor plugin environment:

```text
use the codagent:init skill
```

## Requirements

Codagent skills expect Agent Validator to be installed and initialized in projects where validation should run:

```bash
npm install -g agent-validator
agent-validator init
```

The `init` skill verifies that `agent-validator` is available, that it is version `0.15` or newer, and that `.validator/config.yml` exists in the target project.

## Updating

```bash
claude plugin marketplace update codagent
claude plugin update codagent@codagent
```

After updating, run the init skill again in each project to verify the local setup.

## License

MIT
