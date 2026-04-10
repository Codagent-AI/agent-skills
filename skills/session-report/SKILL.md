---
description: >
  Audits your session for assumptions and context gaps — things only a human can act on.
  Use when the user says "session report", "review assumptions", "what did you struggle with",
  "audit your session", or wants a retrospective on execution quality.
---

# Session Report

Audit your own session against the task file(s) you were given. Surface assumptions you made and context gaps that caused struggles. These are observations for the human — not things you can fix after the fact.

## Review Process

Work through each dimension in order. For every finding, cite specific evidence.

### Dimension 1: Assumption Audit

Identify every place you made a decision that was not dictated by the task file or spec. For each assumption:

- **Ambiguity** — what the spec didn't say
- **Choice** — what you decided
- **Impact classification**:
  - `benign` — reasonable default, no real consequence
  - `notable` — meaningful choice that could have gone differently
  - `risky` — could cause problems, warrants review

Surface all assumptions. Do not filter out benign ones.

### Dimension 2: Context Gaps

Identify moments where you struggled because the task file or project context (CLAUDE.md, AGENTS.md, etc.) was missing information it could have provided. Only report gaps that are **actionable** — information that was knowable upfront and should have been in the task file. Do not report things that are inherently only discoverable at runtime (e.g., iterative validator failures, unexpected test output).

Signs of an actionable context gap:
- You had to search for something the task file could have pointed you to
- You hit a constraint (naming convention, test pattern, linter rule) that was known but not documented in the task or project context
- You made repeated attempts because neither the task nor project context mentioned a prerequisite or dependency
- The task file or project context could have answered a question you had to figure out yourself

For each observation:
- **What happened** — the observable struggle
- **What context was missing** — what the task file or project context should have included

## Output Format

```
## Assumption Audit

| Ambiguity | Choice | Impact | Notes |
|-----------|--------|--------|-------|
| [What spec didn't say] | [What you chose] | benign/notable/risky | [Consequence or implication] |

## Context Gaps

- [What happened] — Missing context: [what was needed]
- [What happened] — Missing context: [what was needed]
```

## Guardrails

- **Do not suggest fixes for context gaps.** Report what needs attention; leave solutions to the human.
- **Do not conflate code quality issues with assumptions.** An assumption is a decision you made where the spec was silent — not a code style choice.
