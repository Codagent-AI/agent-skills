# Codagent Agent Skills

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![CodeRabbit](https://img.shields.io/coderabbit/prs/github/Codagent-AI/agent-skills)](https://coderabbit.ai)

Codagent Agent Skills is a portable skill bundle for Claude Code, Codex, and Cursor. It gives agents a structured software-development workflow: evaluate ideas, write requirements, design changes, plan tasks, implement with TDD, validate changes, and shepherd pull requests through CI.

The repository ships the same core skills through host-specific plugin manifests:

- `.claude-plugin/plugin.json` for Claude Code
- `.codex-plugin/plugin.json` for Codex
- `.cursor-plugin/plugin.json` for Cursor

## Documentation

- [Introduction](docs/introduction.md) - what the bundle includes and when to use it
- [Quickstart](docs/quickstart.md) - install, initialize, and run the first workflow
- [Workflow Guide](docs/workflow-guide.md) - how the planning, implementation, and PR skills fit together
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
