# Agent Skills

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![CodeRabbit](https://img.shields.io/coderabbit/prs/github/pacaplan/flokay)](https://coderabbit.ai)

## Overview

Agent Skills is a plugin for Claude Code and Cursor that provides a set of focused skills for each stage of software development — from evaluating an idea to implementing with subagents to shepherding a PR through CI. Inspired by [obra/superpowers](https://github.com/obra/superpowers).

![Agent Skills demo](docs/images/demo2.gif)

## Features

- **Evaluate before building** — the agent critiques your idea, researches alternatives, and decides if it's worth pursuing
- **Interview-driven specs & design** — the agent grills you to flesh out requirements, edge cases, and architectural decisions
- **Right-sized tasks** — breaks work into self-contained task files, each scoped for a single subagent to implement
- **Multi-agent implementation** — dispatches tasks to be implemented via TDD by Claude Code subagents
- **Automated quality gates** — Agent Validator runs static checks and AI code reviews for each task before moving on
- **End-to-end PR lifecycle** — creates the PR, waits for CI, fixes failures, and addresses reviewer comments automatically

## Prerequisites

Agent Skills requires the Agent Validator CLI for automated quality verification:

- **Agent Validator CLI** — install: `npm install -g @pacaplan/agent-gauntlet`
- Then run `agent-gauntlet init` in your project to configure the validator

## Installation

### Claude Code

Add the Agent Skills marketplace and install the plugin:

```bash
claude plugin marketplace add pacaplan/flokay
claude plugin install agent-skills
```

### Cursor

Install the plugin using `/add-plugin` in chat or the CLI:

```bash
cursor plugins install pacaplan/flokay
```

### Initialize

After installing with either runtime, initialize Agent Skills in your project:

```text
/agent-skills:init
```

## Updating

```bash
claude plugin marketplace update agent-skills
claude plugin update agent-skills@agent-skills
```

Then run to get the latest skills:
```text
/agent-skills:init
```

## License

MIT
