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

A context gap is a **major, avoidable hole** in the task file or project context that sent you down a fundamentally wrong path, caused you to build the wrong thing, or wasted significant effort that better upfront information would have prevented entirely.

The bar is high. Most sessions have zero context gaps. Fixing a linter warning is not a context gap. Searching for a convention is not a context gap. Iterating on validator feedback is not a context gap — it is the normal development loop.

**Examples of real context gaps:**
- The task said to extend module X, but module X was deleted last week and replaced by module Y — you built against a nonexistent target
- The task required integrating with service A but didn't mention that service A requires an auth token from a separate provisioning step — you couldn't have known this without tribal knowledge
- The task file pointed you to the wrong directory or package, wasting significant effort before you found the right one
- A critical requirement was completely absent from the task file and no automated check caught it — you only learned about it from the user after delivering

**Things that are NOT context gaps (do not report these):**
- Anything the validator caught (lint, security, permissions, test failures) — the validator's entire purpose is to catch what the task doesn't enumerate
- Quick searches for conventions, patterns, or existing code — that is normal development
- Iterative fix cycles of any kind — fixing things the first pass missed is expected, not a gap
- Learning something new about the codebase during implementation

For each genuine context gap:
- **What happened** — the concrete wasted effort or wrong direction
- **What was missing** — the specific information that, if present, would have prevented it entirely

## Output Format

```markdown
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
