---
description: Performs the final review of a completed proposal, product specification, technical design, and test plan for cross-artifact consistency, consequential gaps, missing decisions, weak tradeoffs, failure modes, testing strategy, and better alternatives; use when asked to review an approach, challenge design or testing decisions, find gaps in completed definition artifacts, or provide a second opinion before task planning or implementation.
---

# Review Approach

Review the completed proposal, specifications, design, and test plan together before task planning.
Determine whether they form a coherent, implementation-ready definition with sound behavioral,
technical, and testing decisions.

Read every definition artifact and relevant repository instructions. Inspect affected code, tests, and
established patterns enough to judge feasibility and fit. Treat omissions as findings when an
implementer or tester would otherwise have to invent a consequential decision.

## Review focus

Trace important user flows and system interactions end to end. Look for material:

- contradictions, scope drift, dropped commitments, terminology drift, or incompatible assumptions;
- missing or untestable behavior, boundaries, state transitions, failure handling, permissions, data
  lifecycle, compatibility, or migration decisions;
- unclear ownership, component boundaries, data flow, concurrency, recovery, security, operability,
  rollout, or observability;
- testing strategy that conflicts with the definition, misses important integration or critical
  journeys, uses the wrong test layer, leaves acceptance substitutes ambiguous, or relies on unstated
  human judgment;
- avoidable coupling, complexity, maintenance burden, irreversible commitments, weak rationale, or
  overlooked alternatives.

Apply judgment rather than mechanically filling a checklist. Do not review task decomposition,
implementation code quality, formatting, or parser mechanics except where they prevent the definition
from being usable. Do not relitigate whether the approved feature should exist, broaden its scope, or
invent optional features.

## Report

For each consequential finding, cite the exact artifact section and repository evidence, classify it
as a cross-artifact inconsistency, missing decision, or challenged decision, explain the concrete risk,
and recommend a resolution or small set of real alternatives with a preferred choice.

Rank findings by impact and end with a direct readiness assessment. Say explicitly when the approach
is sound and no consequential gap remains. Do not edit artifacts.

```markdown
## Findings

### [high|medium|low] <title>
- Artifacts: <exact sections and repository evidence>
- Type: <inconsistency | missing decision | challenged decision>
- Risk: <concrete consequence>
- Recommendation: <preferred resolution and material alternatives>

## Open Questions
<Only decisions needed to resolve findings, or "None.">

## Overall Assessment
<Whether the definition is ready for task planning and why.>
```
