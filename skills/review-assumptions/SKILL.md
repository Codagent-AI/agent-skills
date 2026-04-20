---
description: >
  Review the risky/notable assumptions and context gaps surfaced by implementor session reports.
  Fix high-confidence issues directly; ask the user one clarifying question at a time for
  ambiguous ones.
  Use when the user says "review assumptions", "audit implementor assumptions", or when invoked
  by a workflow's assumption-review step.
---

# Review Assumptions

The implementor(s) produced session report(s) (via `codagent:session-report`) listing `risky` / `notable` assumptions and context gaps. They did not have the plan's intent — you do. Audit the findings, act on what you're confident about, ask the user about what you're not.

## Checklist

Work through these in order:

1. **Extract findings** via a subagent — keep extraction noise off your context.
2. **Classify and act on each finding** one at a time.
3. **Summarize** what was fixed, what the user decided, and any remaining context gaps.

## Extracting findings

Dispatch a subagent with this task:

- From the session report(s), extract the `## Assumption Audit` (with `### Risky` / `### Notable` subsections) and `## Context Gaps` sections, and, if applicable, identify which task the report came from.
- Return a compact markdown list: one line per finding with task, severity, and a verbatim quote of the bullet. No commentary.

If nothing turns up, report "no findings to review" and stop.

## Classifying and acting

For each finding, pick one bucket and act accordingly:

- **High-confidence fix** — a bug, obvious gap, or clear deviation from the plan. Fix it directly: edit (or dispatch an implementor subagent for nontrivial changes), then commit with a message citing the task and assumption. Don't ask permission.
  - Examples: implementor picked a default that contradicts a spec scenario; implementor skipped an error path the spec required; implementor left a TODO the plan explicitly required finishing.
- **Ambiguous** — product intent, scope, or UX preference only the user can weigh in on. Ask the user, then apply their answer.
  - Examples: which of two reasonable naming choices; whether to widen scope for an adjacent edge case; whether a near-miss matches the spec's original intent.
- **Acceptable** — fine against the plan. Note and move on.

If a finding makes a claim about code ("I fixed X", "already handles Y"), have a subagent spot-check before classifying — don't take the implementor's word for it.

If you're guessing, it's ambiguous. Calibrate your confidence bar honestly.

<HARD-GATE>
For ambiguous findings, ask **one question at a time** via the appropriate tool for requesting user input. Never batch. Finish one finding fully — including applying the user's answer — before raising the next.
</HARD-GATE>

Each clarifying question should:
- Quote the assumption (or a tight paraphrase) so the user has context.
- Cite the task and section it came from.
- Propose 2–4 concrete options when the option space is small. Include "leave as-is" when appropriate.
- Not presume the answer.

After the user answers, apply the change exactly like a high-confidence fix (edit, commit) before moving on. If the answer is "leave as-is", note it and move on.

## Context gaps

Context gaps are feedback on the plan itself — missing information that sent an implementor down a wrong path. **Do not try to fix them.** Collect verbatim and surface in the final summary so the user can update the plan, spec, or future task generation.

## Final summary

End with one message structured as:

```markdown
## Review Summary

### Fixed (high-confidence)
- [task X] — [assumption] → [what you changed, commit sha]

### Resolved with user
- [task X] — [assumption] → [user's choice] → [what you changed, or "left as-is"]

### Context gaps
- [task X] — [gap, verbatim] — Missing: [what was needed]
```

Omit any section with zero items.

## Guardrails

- Scope is the flagged findings plus code spot-checks on claims — not a full re-review.
- Don't lower the confidence bar to avoid asking. Silent drift from product intent is the failure mode this step exists to prevent.
- Don't ask about findings you just fixed — fix first, then report what you fixed.
- Trust the plan when a finding disagrees with it absent contrary evidence.
