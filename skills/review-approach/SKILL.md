---
description: Reviews a supposedly complete product specification and technical design for consequential behavioral gaps, missing design decisions, weak tradeoffs, failure modes, and better alternatives. Use when asked to review an approach, challenge design decisions, find gaps in completed specs or design, or provide a second opinion before task planning or implementation.
---

## Review Approach

Review whether a completed definition gives implementers the right behavioral and technical decisions,
not merely whether its documents are internally consistent. Be constructively skeptical and spend review
depth in proportion to the impact and reversibility of each decision.

### 1. Understand the intended change

Read the proposal, all specifications, the design, and relevant repository instructions. Inspect the
existing code and established patterns around the affected areas before judging the approach. Treat the
specification and design as complete enough to review: an omitted decision is a finding when an
implementer would otherwise have to invent consequential product behavior or architecture.

### 2. Review the substance

Trace the important user flows and system interactions end to end. Look for material concerns such as:

- behavioral gaps in normal flows, state transitions, boundaries, failure behavior, permissions, data
  lifecycle, compatibility, or migration that the specification should decide;
- architectural gaps in ownership, component boundaries, data flow, concurrency, failure recovery,
  security, operability, rollout, or observability that the design should decide;
- choices that conflict with established repository patterns or impose avoidable coupling, complexity,
  maintenance burden, or irreversible commitments;
- decisions presented without enough rationale, plausible alternatives that were not considered, and
  assumptions whose failure would materially change the approach.

Apply only the concerns relevant to this change. Do not manufacture findings to fill a checklist.

### 3. Report findings

For each consequential finding:

1. Cite the exact artifact section and relevant repository evidence.
2. State whether it is a missing decision or a challenge to an existing decision.
3. Explain the concrete implementation or product risk.
4. Recommend a resolution or a small set of real alternatives, including which one you prefer and why.

Rank findings by impact and end with a direct overall assessment. Say explicitly when the approach is
sound and no consequential gaps remain. Do not edit any artifacts.

### Guardrails

- Do not perform a mechanical completeness or consistency audit. Heading structure, scenario counts,
  terminology alignment, traceability, and artifact formatting belong to a specification-quality review
  unless they expose a substantive behavioral or architectural gap.
- Do not relitigate whether the approved feature should exist or broaden its approved scope. Challenge
  scope only when the chosen approach cannot satisfy it coherently.
- Do not invent requirements or optional features. Surface decisions the approved change actually needs.
- Do not review implementation code quality or create implementation tasks.
- Do not rewrite or modify the artifacts; the author and user own the resolution.
