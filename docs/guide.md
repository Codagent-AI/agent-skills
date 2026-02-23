# Flokay User Guide

Flokay is a spec-driven development workflow for Claude Code. It structures every change as a sequence of artifacts — each one building on the last — so you think through what you're building before writing code.

## The Workflow

Every change follows this sequence:

```
proposal → design → specs → tasks → review → implement
```

Each artifact answers a different question:

| Artifact | Question | Skill |
|----------|----------|-------|
| **Proposal** | Why build this? | `flokay:propose` |
| **Design** | How should it work? | `flokay:design` |
| **Specs** | What exactly must it do? | (manual) |
| **Tasks** | What work items exist? | `flokay:plan-tasks` |
| **Review** | Does it all hold together? | `gauntlet-run` |
| **Implement** | Build it. | `flokay:implement-task` |

## Prerequisites Setup

### 1. OpenSpec CLI

OpenSpec provides the workflow engine — it tracks which artifacts exist, what's ready next, and enforces ordering.

```bash
npm install -g @fission-ai/openspec
```

In your project, install the OpenSpec skills:

```bash
openspec init
```

This adds `openspec-*` skills to `.claude/skills/` that drive the CLI commands.

### 2. Agent Gauntlet CLI

Agent Gauntlet provides automated quality checks — it reviews your artifacts for consistency and completeness.

```bash
npm install -g @pacaplan/agent-gauntlet
```

In your project, install the Gauntlet skills:

```bash
agent-gauntlet init
```

This adds `gauntlet-*` skills to `.claude/skills/`.

### 3. Flokay Plugin

Install the plugin:

```bash
claude plugin install pacaplan/flokay
```

Initialize Flokay in your project:

```
/flokay:init
```

This copies the Flokay schema into `openspec/schemas/flokay/` and creates `openspec/config.yaml`.

## Working with Changes

### Starting a Change

```
/openspec-new-change "my-feature"
```

This creates a change directory at `openspec/changes/my-feature/`.

### Stepping Through Artifacts

```
/openspec-continue-change
```

This checks what artifacts exist and what's ready next, invoking the appropriate Flokay skill for each step. See the [OpenSpec docs](https://github.com/fission-ai/OpenSpec) for more details on change management.

### The Artifacts in Detail

#### Proposal (`proposal.md`)

The proposal establishes **why** this change matters. The `flokay:propose` skill guides you through an evaluation: understand the idea, research alternatives, assess whether it's worth building. Only if the verdict is GO does it write the proposal.

#### Design (`design.md`)

The design answers **how** the change should work. The `flokay:design` skill brainstorms approaches with you, proposes 2-3 options with trade-offs, and writes the design after you approve.

#### Specs (`specs/**/*.md`)

Specs define **what** the system must do — one spec file per capability from the proposal. Each spec contains requirements with behavioral scenarios (WHEN/THEN) that become acceptance criteria. These are written manually or with Claude's help.

#### Tasks (`tasks.md` + `tasks/*.md`)

The `flokay:plan-tasks` skill reads the proposal, design, and specs, then creates a task breakdown. Each task is a self-contained file with everything a subagent needs: goal, background, relevant spec scenarios, and done criteria.

#### Review (`review.md`)

The `gauntlet-run` skill runs automated quality checks across all artifacts — verifying consistency between proposal, design, specs, and tasks. The review report summarizes findings and their resolution.

### Implementing

```
/openspec-apply-change
```

The `flokay:implement-task` skill dispatches one fresh subagent per task. Each subagent reads its task file, follows TDD methodology (via `flokay:test-driven-development`), and runs the gauntlet before reporting back.

### Archiving

```
/openspec-archive-change
```

Once all tasks are complete, archive the change to move it to history.

## Project Structure After Init

```
your-project/
├── openspec/
│   ├── config.yaml              # schema: flokay
│   ├── schemas/
│   │   └── flokay/
│   │       ├── schema.yaml      # the workflow definition
│   │       └── templates/       # artifact templates
│   └── changes/                 # active changes live here
│       └── my-feature/
│           ├── proposal.md
│           ├── design.md
│           ├── specs/
│           ├── tasks.md
│           ├── tasks/
│           └── review.md
├── .claude/
│   └── skills/                  # OpenSpec + Gauntlet skills
│       ├── openspec-*/
│       └── gauntlet-*/
└── ...
```

## Tips

- **Don't skip artifacts.** The sequence exists because later artifacts depend on earlier ones. A design without a proposal lacks motivation; tasks without specs lack acceptance criteria.
- **Re-run init after plugin updates.** `/flokay:init` is idempotent — it refreshes the schema files without touching your config.
- **One change at a time is typical**, but OpenSpec supports multiple parallel changes if needed.
- **The review step catches problems early.** It's tempting to skip straight to implementation, but the gauntlet review frequently catches inconsistencies that would waste implementation time.
