---
description: >
  Reviews design artifacts (proposal, specs, design, tasks) for internal consistency, gaps, and cross-artifact alignment.
  Use when the user says "review spec", "review artifacts", "review the design docs", "review the change",
  or wants a quality check on proposal, spec, design, or task files before implementation.
---

# Review Spec

Review design artifacts for internal consistency, cross-artifact alignment, and obvious gaps. Accept requirements as written — flag conflicts between artifacts, not disagreements with product decisions.

## Flow

### 1. Discover and Classify

Read all `*.md` files recursively in the provided directory. Classify each by role:

- **Motivation / proposal** — the "why" and scope
- **Requirements / specs** — behaviors, scenarios, acceptance criteria
- **Design / architecture** — approach, decisions, trade-offs
- **Tasks / plan** — implementation breakdown

Artifacts may combine roles. Missing artifacts are not errors.

### 2. Review Checks

Skip any check that doesn't apply to the artifacts present. Every issue must cite the exact artifact, section, and text.

#### Cross-Artifact Consistency

Compare artifacts that discuss overlapping topics (e.g. proposal vs spec).

- **Contradictions** — one artifact asserts something another denies
- **Scope drift** — downstream artifact introduces work excluded upstream
- **Dropped items** — upstream artifact promises something no downstream artifact addresses
- **Terminology drift** — different names for the same concept across artifacts

#### Requirement Quality

For any artifact containing behavioral requirements or scenarios:

- Every requirement has at least one testable scenario
- Placeholder markers (TBD, TODO, etc.) that should have been resolved by a later artifact already present

#### Task Quality

For any artifact breaking work into implementation tasks:

- Tasks are self-contained — no cross-task references
- Acceptance criteria carried into tasks match the source faithfully
- No standalone infrastructure, test-only, or docs-only tasks with no independent behavioral value

#### Internal Coherence

Within each artifact: no self-contradictions, sections that reference each other are consistent, unresolved items are explicitly marked.

### 3. Present Findings

Report issues found directly to the user. Cite exact artifact paths and text for each issue.

## Guardrails

- **Do not critique requirements** — only flag when they conflict with each other or other artifacts.
- **Do not rewrite artifacts** — point out issues, don't produce "improved" versions.
- **Do not review code** — this reviews design artifacts, not implementation.
- **Do not invent missing artifacts** — skip checks that depend on absent artifacts.
