---
description: Reviews proposal, specification, design, and task artifacts for internal consistency, testability, traceability, and cross-artifact alignment. Use when asked to review a spec, review artifacts, check design documents, check a change for consistency, or verify artifact quality before implementation.
---

# Review Spec

Review design artifacts for internal consistency, testability, traceability, and cross-artifact alignment. Accept requirements and design decisions as written. Flag conflicts and structural quality problems, not missing product behavior or alternative design choices.

## Flow

### 1. Discover and Classify

Read all `*.md` files recursively in the provided directory. Classify each by role using the following path-based heuristics (applied in order; first match wins):

1. `proposal.md` or `motivation.md` (anywhere in the path) → **Motivation / proposal**
2. `design.md` or `architecture.md` (anywhere in the path) → **Design / architecture**
3. `spec.md`, or any file matching `specs/**/spec*.md` → **Requirements / specs**
4. `tasks.md`, or any file matching `tasks/*.md` → **Tasks / plan**
5. Fallback: infer role from content (headings, structure). If ambiguous, assign the closest matching role and note the ambiguity.

An artifact may combine roles; assign the primary role first. Missing artifacts are not errors.

### 2. Review Checks

Skip any check that doesn't apply to the artifacts present. Every issue must cite the exact artifact, section, and text.

#### Cross-Artifact Consistency

Compare artifacts that discuss overlapping topics (e.g. proposal vs spec).

- **Contradictions** — one artifact asserts something another denies
- **Scope drift** — downstream artifact introduces work excluded upstream
- **Dropped items** — upstream artifact promises something no downstream artifact addresses
- **Terminology drift** — different names for the same concept across artifacts

#### Requirement Quality

For any artifact containing behavioral requirements or scenarios, check structural testability without assessing product intent or design choices:

- Every requirement has at least one testable scenario (i.e., a concrete WHEN/THEN or equivalent that can be verified by a test)
- Scenario outcomes are concrete enough to verify and faithfully express the behavior the requirement actually states
- No unresolved placeholder markers (TBD, TODO, etc.) that should have been filled in by the time a later artifact is already present

#### Task Quality

For any artifact breaking work into implementation tasks:

- Tasks are self-contained — a task may list other tasks as dependencies but must not require reading them to understand what to do
- References to other artifacts (e.g., design, spec) must include the file path and the specific section heading or requirement ID being referenced (line numbers are optional and may be omitted), not just the filename
- Acceptance criteria carried into tasks match the source faithfully
- Tasks describe what to build, not how to write each line — brief code or pseudocode for key points is fine, but the task should not spell out the full implementation
- No unresolved placeholders (`<path>`, `<your-service>`, etc.) — all values must be concrete
- No standalone infrastructure, test-only, or docs-only tasks with no independent behavioral value

#### Internal Coherence

Within each artifact: no self-contradictions, sections that reference each other are consistent, unresolved items are explicitly marked.

### 3. Present Findings

Report issues found directly to the user. Cite exact artifact paths and text for each issue.

When a finding leaves multiple consistency-preserving fixes, recommend the smallest safe fix. Do not use this review to ask the artifact owner to choose new product behavior, scope, or architecture; that belongs to an approach review.

## Guardrails

- **Do not critique requirements or design decisions** — only flag when written behavior is untestable, lacks a scenario, contains unresolved placeholders, or conflicts with another artifact.
- **Do not search for consequential behavioral or architectural gaps** — missing behavior, failure-mode decisions, tradeoffs, and alternatives belong to `review-approach`.
- **Do not rewrite artifacts** — point out issues, don't produce "improved" versions.
- **Do recommend fixes** — findings should be actionable without forcing the user to infer the next step.
- **Do not review code** — this reviews design artifacts, not implementation.
- **Do not invent missing artifacts** — skip checks that depend on absent artifacts.
