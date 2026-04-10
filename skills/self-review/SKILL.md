---
description: >
  Self-review your work against task file requirements. Checks every spec scenario and Done When criterion,
  identifies gaps, and fixes them.
  Use when the user says "self-review", "check your work against the task", "review what you did",
  or at the end of a task implementation session to verify completeness.
---

# Self-Review

Review your own work against the task file(s) you were given. Extract every spec scenario (WHEN/THEN) and every Done When criterion, then verify you addressed each one. Fix anything you missed.

## Review Process

### 1. Extract Checklist

From each task file, extract every:
- Spec scenario (WHEN/THEN)
- Done When criterion
- Explicit instruction in the Background or Goal sections

This is your checklist. Every item must be accounted for.

### 2. Check Compliance

For each checklist item, check whether you addressed it.

Classify each item:
- **Addressed** — you implemented this
- **Missed** — no evidence you addressed this
- **Partially addressed** — you attempted it but it's incomplete or incorrect

**When you're unsure** whether you addressed a scenario, read the actual code in the repository to verify before classifying. Do not mark something as missed without checking the code first.

### 3. Fix Gaps

For every item classified as **Missed** or **Partially addressed**:
1. Implement or complete it now
2. Verify the fix (run tests, check the code)
3. Update the classification to **Fixed**

### 4. Report

Present your findings:

```
## Self-Review

### Addressed
- [Scenario/criterion] — [evidence]

### Fixed (was missed/partial)
- [Scenario/criterion] — [what was missing, what you fixed]

```

## Guardrails

- **Do not mark a scenario as missed without checking the code first.** You may have implemented it without explicitly narrating it.
- **Do not expand scope while fixing gaps.** Implement exactly what the task requires — no refactoring, no improvements beyond what was specified.
