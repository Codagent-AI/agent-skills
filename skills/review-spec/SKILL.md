---
description: Reviews proposal, specification, design, and task artifacts for internal consistency, testability, traceability, and cross-artifact alignment. Use when asked to review a spec, review artifacts, check design documents, check a change for consistency, or verify artifact quality before implementation.
---

# Review Spec

Review the supplied planning artifacts for internal coherence, structural testability, traceability,
and cross-artifact consistency. Accept product and design choices as written; consequential gaps,
alternatives, and weak decisions belong to an approach review.

Read all relevant markdown artifacts and infer their roles from path and content. Missing artifact
types are not findings.

Check applicable concerns:

- contradictions, scope drift, dropped commitments, or terminology drift across artifacts;
- behavioral requirements without a concrete testable scenario, scenarios that do not express their
  requirement, or unresolved placeholders;
- tasks that are not self-contained, lack exact source citations, alter source acceptance criteria,
  over-prescribe implementation, retain placeholders, or separate ordinary infrastructure, tests, or
  docs from the behavior they support; and
- contradictions or unresolved references within an artifact.

Every finding must cite the exact path and section. Recommend the smallest consistency-preserving fix
when more than one is possible.

Do not critique product intent or architecture, search for missing behavior or failure-mode decisions,
review implementation code, invent missing artifacts, or rewrite the artifacts.

```markdown
## Findings

### [high|medium|low] <title>
- Artifact: <path and section>
- Issue: <consistency, testability, traceability, or coherence defect>
- Fix: <smallest safe correction>

## Assessment
<Artifact readiness, or "No findings.">
```
