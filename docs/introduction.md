# Introduction

Codagent Agent Skills is a portable skill bundle for guiding AI agents through software-development work. The skills turn open-ended requests into a repeatable flow: evaluate the idea, write requirements, design the approach, break work into tasks, implement with validation, and finalize the pull request.

The bundle is distributed for Claude Code, Codex, and Cursor from the same repository. The host-specific manifests point at the shared `skills/` directory so the core workflow stays consistent across agents.

## What It Includes

The core skills cover four parts of the development lifecycle:

- Planning: `propose`, `proposal-review`, `spec`, `design`, `plan-tasks`, `review-spec`, and `simple-plan`
- Implementation: `implement-with-tdd`, `implement-and-validate`, and `implement-change`
- Pull requests: `push-pr`, `wait-ci`, `fix-pr`, and `finalize-pr`
- Support and review: `init`, `ask-questions`, `handoff`, `session-report`, `review-assumptions`, and `task-compliance`

The repository also includes a separate release skill under `.agents/skills/release` and `.claude/skills/release`. That release skill is for maintainers of this repository, not part of the installed user-facing Codagent workflow.

## Intended Workflow

Codagent works best when the agent has explicit artifacts to hand off between phases. A typical larger change moves through:

```text
propose -> spec -> design -> plan-tasks -> review-spec -> implement-change -> finalize-pr
```

For smaller changes, `simple-plan` compresses the planning phase into one lightweight pass while still writing enough artifacts for another agent to continue safely.

## Relationship To Agent Validator

Agent Validator is the verification engine used by the implementation and PR skills. The `init` skill checks for the validator CLI, requires version `0.15` or newer, and stops if `.validator/config.yml` is missing.

Implementation skills use Agent Validator before committing or shipping changes. PR skills use the validator locally, then use GitHub and CI status to complete the PR loop.

## When To Use It

Use Codagent skills when the work benefits from written intent, reviewable requirements, or an agent-to-agent handoff. The full planning flow is useful for feature work, cross-cutting changes, or changes with unclear requirements. The smaller `simple-plan` path is better for quick, bounded changes that still need a written trail.

For one-off questions, debugging conversations, or manual editing where no lifecycle is needed, invoking a skill is optional.
