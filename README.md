# Flokay

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![CodeRabbit](https://img.shields.io/coderabbit/prs/github/pacaplan/flokay)](https://coderabbit.ai)

A curated, spec-driven development workflow for Claude Code. Flokay guides you through a structured sequence — proposal, design, specs, tasks, review, implement — so every change is well-reasoned before code is written.

![Flokay Workflow](docs/images/workflow.png)

## Prerequisites

Flokay requires two external CLIs and their skills:

1. **OpenSpec CLI** — workflow engine that manages changes and artifacts
   - Install: `npm install -g @fission-ai/openspec`
   - Then run `openspec init` in your project to install OpenSpec skills

2. **Agent Gauntlet CLI** — automated quality verification
   - Install: `npm install -g @pacaplan/agent-gauntlet`
   - Then run `agent-gauntlet init` in your project to install Gauntlet skills

## Installation

In Claude Code, add the Flokay marketplace and install the plugin:

```
/plugin marketplace add pacaplan/flokay
/plugin install flokay
```

Then initialize Flokay in your project:

```
/flokay:init
```

## Quick Start

1. **Design**: `/opsx:explore` → `/opsx:new <name>` → `/opsx:continue`
2. **Plan**: `/opsx:ff` — generates specs, tasks, and review in one pass
3. **Develop**: `/opsx:apply` — implements, archives, and finalizes the PR

Each step uses a dedicated skill (`flokay:propose`, `flokay:design`, `flokay:plan-tasks`, etc.) that guides you through the process conversationally.

## Documentation

See [`docs/guide.md`](docs/guide.md) for the detailed user guide covering the full workflow, each artifact, and how to use the commands.

## License

MIT
