# Codagent Agent Skills

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![CodeRabbit](https://img.shields.io/coderabbit/prs/github/Codagent-AI/agent-skills)](https://coderabbit.ai)

## Overview

Codagent is a plugin for Claude Code and Cursor that provides a set of focused skills for spec driven development — from evaluating an idea to implementing with subagents to shepherding a PR through CI. Inspired by [obra/superpowers](https://github.com/obra/superpowers) and [OpenSpec](https://github.com/Fission-AI/OpenSpec).

## Features

- **Evaluate before building** — the agent critiques your idea, researches alternatives, and decides if it's worth pursuing
- **Interview-driven specs & design** — the agent grills you to flesh out requirements, edge cases, and architectural decisions
- **Right-sized tasks** — breaks work into self-contained task files, each scoped for a single subagent to implement
- **Multi-agent implementation** — dispatches tasks to be implemented via TDD by Claude Code subagents
- **Automated quality gates** — Agent Validator runs static checks and AI code reviews for each task before moving on
- **End-to-end PR lifecycle** — creates the PR, waits for CI, fixes failures, and addresses reviewer comments automatically

## Skills

Each skill is invoked with `/codagent:<skill-name>`.

- **`init`** — Initializes Codagent in your project. Checks that the Agent Validator CLI is installed and configured. Safe to re-run.
- **`propose`** — Evaluates whether an idea is worth building. Researches the codebase and web, delivers a GO / GO WITH CAVEATS / NO-GO verdict, and writes `proposal.md`.
- **`spec`** — Drives interactive requirement discovery. Walks through each capability from the proposal, asking about behaviors, boundaries, error conditions, and edge cases. Produces spec files with testable WHEN/THEN scenarios.
- **`design`** — Creates a technical design through collaborative brainstorming. Proposes 2-3 approaches with trade-offs, presents the design incrementally for approval, and writes `design.md`.
- **`review-spec`** — Reviews design artifacts (proposal, specs, design, tasks) for internal consistency, cross-artifact alignment, and gaps. Reports findings with exact citations.
- **`plan-tasks`** — Creates a structured task breakdown from the proposal, design, and specs. Each task file is self-contained with everything a subagent needs to implement it.
- **`implement-with-tdd`** — Enforces test-driven development: write a failing test, watch it fail, write minimal code to pass, refactor. No production code without a failing test first.
- **`implement-and-validate`** — Autonomous implementer that executes a single task end-to-end. Calls `implement-with-tdd` to build the code, performs self-review, runs the Agent Validator, and commits on success.
- **`push-pr`** — Commits changes, pushes to remote, and creates or updates a pull request. Runs the validator before committing if applicable.
- **`wait-ci`** — Polls CI status for the current branch's PR. Enriches failures with GitHub Actions logs, surfaces blocking reviews and unresolved PR comments.
- **`fix-pr`** — Fixes CI failures and review comments on the current branch's PR. Dispatches a fixer subagent, verifies with the validator, and pushes.
- **`finalize-pr`** — Orchestrates the full post-implementation loop: push PR, wait for CI, fix failures, repeat until green. Stops after 3 fix cycles or when the same failure persists.

## Getting Started

### 1. Install the Agent Validator CLI

Codagent requires the Agent Validator CLI for automated quality verification:

```bash
npm install -g agent-validator
agent-validator init
```

### 2. Install the plugin

#### Claude Code

```bash
claude plugin marketplace add Codagent-AI/agent-skills
claude plugin install codagent
```

#### Cursor

```bash
cursor plugins install Codagent-AI/agent-skills
```

### 3. Initialize

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
