# Flokay

A curated, spec-driven development workflow for Claude Code. Flokay guides you through a structured sequence — proposal, design, specs, tasks, review, implement — so every change is well-reasoned before code is written.

## Prerequisites

Flokay requires two external CLIs and their skills:

1. **OpenSpec CLI** — workflow engine that manages changes and artifacts
   - Install: `npm install -g @fission-ai/openspec`
   - Then run `openspec init` in your project to install OpenSpec skills

2. **Agent Gauntlet CLI** — automated quality verification
   - Install: `npm install -g @pacaplan/agent-gauntlet`
   - Then run `agent-gauntlet init` in your project to install Gauntlet skills

## Installation

```bash
claude plugin install pacaplan/flokay
```

Then initialize Flokay in your project:

```
/flokay:init
```

This copies the Flokay schema into your project and sets it as the default workflow.

## Quick Start

1. **Start a change**: `/openspec-new-change "my-feature"`
2. **Step through artifacts**: `/openspec-continue-change` — creates proposal, design, specs, tasks, and review in sequence
3. **Implement**: `/openspec-apply-change` — dispatches subagents to execute each task
4. **Archive**: `/openspec-archive-change` — moves the completed change to history

Each step uses a dedicated skill (`flokay:propose`, `flokay:design`, `flokay:plan-tasks`, etc.) that guides you through the process conversationally.

## Documentation

See [`docs/guide.md`](docs/guide.md) for the detailed user guide covering the full workflow, each artifact, and how to use the commands.

## License

MIT
