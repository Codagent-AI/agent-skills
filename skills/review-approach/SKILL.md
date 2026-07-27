---
description: Performs the final review of a completed proposal, product specification, and technical design for cross-artifact consistency, consequential gaps, missing decisions, weak tradeoffs, failure modes, and better alternatives. Use when asked to review an approach, challenge design decisions, find gaps in completed definition artifacts, or provide a second opinion before task planning or implementation.
---

## Review Approach

Review whether a completed definition is internally consistent and gives implementers the right
behavioral and technical decisions. This is the final review of the proposal, specifications, and design
before task planning. Be constructively skeptical and spend review depth in proportion to the impact and
reversibility of each decision.

### 1. Understand the intended change

Read the proposal, all specifications, the design, and relevant repository instructions. Inspect the
existing code and established patterns around the affected areas before judging the approach. Treat the
specification and design as complete enough to review: an omitted decision is a finding when an
implementer would otherwise have to invent consequential product behavior or architecture.

### 2. Review the substance

Trace the important user flows and system interactions end to end. Look for material concerns such as:

- contradictions, scope drift, dropped commitments, terminology drift, or incompatible assumptions
  across the proposal, specifications, and design;
- requirements without testable scenarios, scenarios that do not faithfully express their requirements,
  or unresolved placeholders that prevent the definition from being implementation-ready;
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
2. State whether it is a cross-artifact inconsistency, a missing decision, or a challenge to an existing
   decision.
3. Explain the concrete implementation or product risk.
4. Recommend a resolution or a small set of real alternatives, including which one you prefer and why.

Rank findings by impact and end with a direct overall assessment. Say explicitly when the approach is
sound and no consequential gaps remain. Do not edit any artifacts.

Use this output structure:

```markdown
## Findings

### [high|medium|low] <concise title>
- Artifacts: <exact sections and relevant repository evidence>
- Type: <cross-artifact inconsistency|missing decision|challenged decision>
- Risk: <concrete implementation or product consequence>
- Recommendation: <preferred resolution and material alternatives, if any>

## Open Questions
<Only unresolved questions needed to choose among real alternatives, or "None.">

## Overall Assessment
<Whether the definition is ready for task planning and why.>
```

When there are no findings, write `None.` under Findings and still provide the overall assessment.

### Guardrails

- Do not reduce the review to formatting or parser mechanics. Still check cross-artifact consistency,
  requirement testability, and whether the completed definition has the information implementation needs.
- Do not review implementation tasks. Task coverage, decomposition, ordering, dependencies, and task
  acceptance criteria belong to `review-tasks`.
- Do not relitigate whether the approved feature should exist or broaden its approved scope. Challenge
  scope only when the chosen approach cannot satisfy it coherently.
- Do not invent requirements or optional features. Surface decisions the approved change actually needs.
- Do not review implementation code quality or create implementation tasks.
- Do not rewrite or modify the artifacts; the author and user own the resolution.
