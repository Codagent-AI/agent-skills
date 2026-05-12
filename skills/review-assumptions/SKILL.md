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

The implementor(s) produced session report(s) (via `codagent:session-report`) listing `risky` / `notable` assumptions and context gaps. Assume the implementors did not have the plan's intent; audit the findings against that intent, act on confident fixes, and ask about ambiguous cases.

## Checklist

Work through these in order:

1. **Build the report map** — identify every session report, its iteration id, and the exact task file it belongs to.
2. **Extract findings** via a subagent — keep extraction noise off your context.
3. **Create a finding ledger** — every extracted finding gets one stable id and one final disposition.
4. **Classify and act on each finding** one at a time.
5. **Summarize** what was fixed, what the user decided, what was accepted as-is, and any remaining context gaps.

## Report map

Before extracting findings, map reports to tasks:

- Use the report filename's iteration marker (for example `implement-tasks_0`) only as an iteration id; do not infer the task name from order or memory.
- Cross-reference the matching `step_start` / `iteration_start` metadata when available to recover the `task_file` parameter.
- Record each report as `[iteration id | task file path | short task name]`.
- If a report cannot be mapped to a task, label it `task unknown` and treat that as an ambiguity to surface in the final summary.

Do not renumber tasks in the final summary. Use the mapped task file path or short task name. This prevents mixing up "task 0" and "task 1" when workflow iteration order differs from human-readable task order.

## Extracting findings

Dispatch a subagent with this task:

- From the session report(s), extract the `## Assumption Audit` (with `### Risky` / `### Notable` subsections) and `## Context Gaps` sections.
- Use the report map supplied by the parent agent. Preserve the iteration id and mapped task file for every finding.
- Return a compact markdown list: one line per finding with stable id, iteration id, task file, severity, finding title, and a tight verbatim quote or paraphrase of the bullet. No commentary.

If nothing turns up, report "no findings to review" and stop.

## Finding ledger

Create a ledger before acting:

```markdown
| id | iteration | task | severity | finding | disposition | evidence | action |
| --- | --- | --- | --- | --- | --- | --- | --- |
```

Allowed dispositions:

- `fixed` — high-confidence issue fixed in code/docs.
- `resolved-with-user` — ambiguous issue answered by the user, then acted on or left as-is.
- `accepted` — reviewed and intentionally left unchanged because it matches the plan or risk is acceptable.
- `deferred` — real issue or risk remains but is outside this review's authority/scope; include why and who should handle it.
- `context-gap` — only for findings originally reported under `## Context Gaps`, or for cases where the report itself cannot be mapped to a task.

Hard requirements:

- Every extracted assumption and context gap must appear in the ledger exactly once.
- Do not silently drop low-severity, notable, or "acceptable" findings.
- Do not reclassify an assumption as a context gap just to avoid fixing or asking about it. If it is acceptable, mark it `accepted`; if it needs product input, mark it ambiguous and ask.
- Before the final response, compare the number of extracted findings with the number of ledger rows. If they differ, stop and reconcile the missing item(s).

## Classifying and acting

For each finding, pick one bucket and act accordingly:

- **High-confidence fix** — a bug, obvious gap, or clear deviation from the plan. Fix it directly: edit (or dispatch an implementor subagent for nontrivial changes), then commit with a message citing the task and assumption. Don't ask permission.
  - Examples: implementor picked a default that contradicts a spec scenario; implementor skipped an error path the spec required; implementor left a TODO the plan explicitly required finishing.
- **Ambiguous** — product intent, scope, or UX preference only the user can weigh in on. Ask the user, then apply their answer.
  - Examples: which of two reasonable naming choices; whether to widen scope for an adjacent edge case; whether a near-miss matches the spec's original intent.
- **Acceptable** — fine against the plan. Note and move on.

If a finding makes a claim about code ("I fixed X", "already handles Y"), have a subagent spot-check before classifying — don't take the implementor's word for it.

When you make your own code-based claim in the final summary, verify it first:

- Cite the specific file/function or command output you checked in your private notes and summarize the evidence in the ledger.
- Distinguish verified facts from inference. If you only inferred the behavior, say so or treat it as ambiguous.
- If source evidence contradicts the intended disposition, revisit the classification instead of smoothing it over in prose.

If you're guessing, it's ambiguous. Calibrate your confidence bar honestly.

<HARD-GATE>
For ambiguous findings, ask **one question at a time** via the `codagent:ask-questions` skill. This skill intentionally overrides the default batching strategy: each finding must be fully resolved (including applying the user's answer) before raising the next.
</HARD-GATE>

Each clarifying question should:
- Quote the assumption (or a tight paraphrase) so the user has context.
- Cite the task and section it came from.
- Propose 2–4 concrete options when the option space is small. Include "leave as-is" when appropriate.
- Not presume the answer.

After the user answers, apply the change exactly like a high-confidence fix (edit, commit) before moving on. If the answer is "leave as-is", note it and move on.

## Context gaps

Context gaps are feedback on the plan itself — missing information that sent an implementor down a wrong path. **Do not try to fix them.** Collect verbatim and surface in the final summary so the user can update the plan, spec, or future task generation.

Do not move normal assumptions into this section unless the session report listed them as context gaps. For example, "implementation used a heuristic but could be stricter" is usually an assumption to accept, fix, defer, or ask about — not a context gap.

## Final summary

End with one message structured as:

```markdown
## Review Summary

### Fixed (high-confidence)
- [task X] — [assumption] → [what you changed, commit sha]

### Resolved with user
- [task X] — [assumption] → [user's choice] → [what you changed, or "left as-is"]

### Reviewed, no change
- [task X] — [assumption] → [accepted/deferred] — [evidence-backed rationale]

### Context gaps
- [task X] — [gap, verbatim] — Missing: [what was needed]
```

Omit any section with zero items.

Every non-context-gap finding must appear in exactly one of `Fixed`, `Resolved with user`, or `Reviewed, no change`. Context gaps must appear in `Context gaps`.

## Guardrails

- Scope is the flagged findings plus code spot-checks on claims — not a full re-review.
- Don't lower the confidence bar to avoid asking. Silent drift from product intent is the failure mode this step exists to prevent.
- Don't ask about findings you just fixed — fix first, then report what you fixed.
- Trust the plan when a finding disagrees with it absent contrary evidence.
- Keep review-step output separate from later workflow steps. If another step runs after this review, do not attribute its commits or changes to this review summary.
