# Codagent

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![CodeRabbit](https://img.shields.io/coderabbit/prs/github/Codagent-AI/agent-skills)](https://coderabbit.ai)

## Overview

Codagent is a plugin for Claude Code and Cursor that provides a set of focused skills for each stage of software development — from evaluating an idea to implementing with subagents to shepherding a PR through CI. Inspired by [obra/superpowers](https://github.com/obra/superpowers).

![Codagent demo](docs/images/demo2.gif)

## Features

- **Evaluate before building** — the agent critiques your idea, researches alternatives, and decides if it's worth pursuing
- **Interview-driven specs & design** — the agent grills you to flesh out requirements, edge cases, and architectural decisions
- **Right-sized tasks** — breaks work into self-contained task files, each scoped for a single subagent to implement
- **Multi-agent implementation** — dispatches tasks to be implemented via TDD by Claude Code subagents
- **Automated quality gates** — Agent Validator runs static checks and AI code reviews for each task before moving on
- **End-to-end PR lifecycle** — creates the PR, waits for CI, fixes failures, and addresses reviewer comments automatically

## Prerequisites

Codagent requires the Agent Validator CLI for automated quality verification:

- **Agent Validator CLI** — install: `npm install -g agent-validator`
- Then run `agent-validator init` in your project to configure the validator

## Installation

### Claude Code

Add the codagent marketplace and install the plugin:

```bash
claude plugin marketplace add Codagent-AI/agent-skills
claude plugin install codagent
```

### Cursor

Install the plugin using `/add-plugin` in chat or the CLI:

```bash
cursor plugins install Codagent-AI/agent-skills
```

### Initialize

After installing with either runtime, initialize Codagent in your project:

```text
/codagent:init
```

## Updating

```bash
claude plugin marketplace update codagent
claude plugin update codagent@codagent
```

Then run to get the latest skills:
```text
/codagent:init
```

## License

MIT
