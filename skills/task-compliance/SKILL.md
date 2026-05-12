---
name: task-compliance
description: >
  Review an implementation against task file requirements. Checks every spec scenario and Done When criterion,
  identifies gaps, and reports them.
  Use when the user says "task compliance", "check compliance", "review against the task",
  or to verify implementation completeness before shipping.
---

# Task Compliance

Review the implementation against the task file(s). Extract every spec scenario (WHEN/THEN) and every Done When criterion, then verify each one was addressed. Report what's missing.

## Review Process

### 1. Extract Checklist

From each task file, extract every:
- Spec scenario (WHEN/THEN)
- Done When criterion
- Explicit instruction in the Background or Goal sections

This is your checklist. Every item must be accounted for.

### 2. Check Compliance

For each checklist item, check whether the implementation addresses it.

Classify each item:
- **Addressed** — the implementation covers this
- **Missed** — no evidence this was addressed
- **Partially addressed** — attempted but incomplete or incorrect

**When you're unsure**, read the actual code in the repository to verify before classifying. Do not mark something as missed without checking the code first.

### 3. Report

Present your findings:

```markdown
## Task Compliance

### Addressed
- [Scenario/criterion] — [evidence]

### Gaps
- [Scenario/criterion] — [what's missing or incomplete]
```

## Guardrails

- **Do not mark a scenario as missed without checking the code first.** It may have been implemented without being narrated in the conversation.
- **Report only.** Do not fix gaps — surface them for the human to decide how to proceed.
