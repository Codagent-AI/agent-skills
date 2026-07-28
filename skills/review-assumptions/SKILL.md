---
name: review-assumptions
description: >
  Reviews risky/notable assumptions and context gaps surfaced by implementor session reports,
  fixes high-confidence issues directly, and asks one clarifying question at a time for
  ambiguous findings.
  Use when the user says "review assumptions", "audit implementor assumptions", or when invoked
  by a workflow's assumption-review step.
---

# Review Assumptions

Audit assumptions and context gaps from implementor session reports against the approved plan. Fix
clear deviations, ask the user about product ambiguity, and preserve plan-quality gaps for the final
summary.

## Process

1. Find the session reports and map each to its workflow iteration and exact task file using available
   run metadata. Do not infer task identity from report order; label an unmappable report `task
   unknown`.
2. Extract each risky or notable assumption and each context gap. Give every finding a stable identity
   and ensure none is silently dropped.
3. Verify claims against the controlling artifacts and relevant source before choosing a disposition:
   - **Fix:** a clear defect, omission, or deviation from the approved plan. Make the focused change
     directly, or delegate nontrivial implementation when the caller permits it.
   - **Ask:** a product, scope, or UX decision that evidence cannot resolve. Use
     `codagent:ask-questions`, one finding at a time, with context, practical options, impact, and a
     recommendation. Apply the user's answer before moving on.
   - **Accept:** the implementation matches the plan or the stated risk is intentionally acceptable.
   - **Defer:** the issue is real but outside this review's authority; identify the owner or later
     decision needed.
   - **Context gap:** the report explicitly says the plan lacked information. Do not invent a
     resolution; surface what future planning needed to provide.
4. Before reporting, reconcile the dispositions with the extracted findings.

Treat implementor statements as claims, not evidence. Inspect the cited code or artifacts before
asserting that something is fixed or already handled. Do not turn an ordinary assumption into a
context gap merely to avoid resolving it.

Run relevant validation and commit applied changes using the project's conventions unless the caller
explicitly owns validation or commits. Do not create an empty commit.

## Report

Summarize only applicable sections:

```markdown
## Review Summary

### Fixed
- [task] — [finding] → [change and commit]

### Resolved with user
- [task] — [finding] → [decision and resulting action]

### Reviewed, no change
- [task] — [finding] → [accepted or deferred, with rationale]

### Context gaps
- [task] — [gap] — Missing: [information the plan needed]
```

Keep the review scoped to reported findings and the source checks needed to evaluate them. Do not
attribute work from later workflow phases to this review.
