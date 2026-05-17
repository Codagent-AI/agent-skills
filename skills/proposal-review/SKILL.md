---
name: proposal-review
description: >
  Adversarial review of a proposal — challenges the why, what, and how, and suggests alternative approaches.
  Use when the user says "review proposal", "challenge this proposal", "adversarial review", "poke holes",
  "stress test the proposal", or wants a second opinion on a proposal before moving to specs/design.
---

# Proposal Review

Adversarial review of a proposal. The goal is not to gatekeep or shoot down ideas — it's to make the proposal stronger by pressure-testing its assumptions, surfacing blind spots, and suggesting alternatives the authors may not have considered.

You are a constructive adversary: skeptical but collaborative. Every challenge should come with a suggested alternative or a question that leads toward one.

## Principles

- **Willing to challenge any part, but don't manufacture objections** — No aspect of the proposal is off-limits — why, what, and how are all fair game. But only challenge where there's a real concern. Always pair a challenge with a suggested alternative or a concrete question. Never leave the author with just "this is wrong."
- **Steel-man before attacking** — Before challenging a decision, restate it in its strongest form. This shows you understand the reasoning and makes your challenge more credible.
- **Alternatives over objections** — "Have you considered X instead?" is more useful than "Y won't work." Lead with what could work differently.
- **Grounded in reality** — Research the codebase, existing patterns, and prior art before challenging. Uninformed skepticism is noise.
- **Proportional depth** — Spend more time on high-impact, hard-to-reverse decisions. Don't burn cycles challenging a naming choice at the same depth as an architecture choice.

## Flow

### 1. Read the Proposal

Read proposal from the location the user provides (or discover it in the current change directory). Read the full document before forming any opinions.

Also read any related context that exists:
- Existing specs in the same change directory
- Design docs if present
- The codebase areas mentioned in the proposal's Impact section

### 2. Research

Before challenging, understand the landscape:

- **Codebase** — Explore the areas the proposal touches. Understand existing patterns, constraints, and prior decisions that may have shaped the proposal.
- **Alternatives** — Search for other approaches: different libraries, architectures, patterns, or prior art. The goal is to have concrete alternatives ready, not vague "maybe something else."
- **Web** — Look for known pitfalls, post-mortems, or established wisdom related to the proposed approach.

### 3. Challenge

Work through the proposal systematically. For each section, decide whether there's something worth challenging. Skip sections where the proposal is solid — don't manufacture objections.

#### Challenging the Why

- Is the problem real? Is there evidence, or is it assumed?
- Is the problem significant enough to justify the effort?
- Is this the right time to solve it? What's the cost of waiting?
- Are there simpler ways to address the underlying need without building anything?

#### Challenging the What

- Is the scope right? Too broad (trying to solve too much at once) or too narrow (solving a symptom, not the cause)?
- Are the capabilities well-defined? Would two readers agree on what each capability means?
- Are the out-of-scope items actually out of scope, or is the proposal deferring something that will block delivery?
- Does the "what" actually address the "why"? Would delivering exactly this scope actually solve the stated problem?

#### Challenging the How (Technical Approach)

- Is the proposed architecture the simplest that could work?
- Are there existing patterns in the codebase that would solve this differently (and perhaps better)?
- What are the second-order effects? How does this change interact with the rest of the system?
- Are the key technical decisions well-reasoned, or are they defaults? (e.g., "we'll use X" without explaining why not Y)
- What are the failure modes? What happens when the happy path breaks?
- Is the approach reversible? If it turns out to be wrong, how expensive is it to change course?

#### Cross-cutting Concerns

- **Complexity budget** — Does the proposed change earn its complexity? Simple solutions that cover 80% of the need are often better than complete solutions that double the system's complexity.
- **Maintenance burden** — What ongoing cost does this introduce? Who will own it?
- **Migration and rollout** — If this changes existing behavior, how do users transition? Is there a credible rollout plan, or is it hand-waved?

### 4. Present the Review

Structure the review as a series of challenges, each with:

1. **What you're challenging** — cite the specific part of the proposal
2. **Steel-man** — the strongest version of the author's reasoning
3. **The challenge** — why this might not be the best approach
4. **Suggested alternative** — a concrete alternative, or a question that would resolve the concern

Group challenges by severity:

```text
CHALLENGE SEVERITY
════════════════════════════════════════════

  STRUCTURAL    Could change the fundamental approach.
                Worth resolving before moving to specs/design.

  SIGNIFICANT   Meaningful concern that should be addressed,
                but doesn't necessarily change the direction.

  MINOR         Worth noting. Can be addressed during
                design or implementation.
```

End with a brief overall assessment: is the proposal ready to move forward, or does it need revision? Be direct but constructive.

## Guardrails

- **Do not rewrite the proposal** — Challenge and suggest; don't produce a "fixed" version. The authors own the document.
- **Do not shoot down the idea** — The propose skill already evaluated whether the idea is worth building. Your job is to make the approach stronger, not to re-litigate the go/no-go decision.
- **Do not invent requirements** — Challenge what's written, don't add features the proposal didn't ask for.
- **Do not skip research** — Uninformed challenges waste everyone's time. Investigate before opining.
- **Do not manufacture objections** — If a section is solid, say so and move on. Not every section needs a challenge.
- **Do not flag missing downstream artifacts** — The proposal phase intentionally produces only proposal.md. Design docs, specs, and tasks are subsequent phases. Never report missing design.md, tasks.md, or spec files as a finding.
- **Do suggest alternatives** — Every challenge must come with a suggested alternative or a concrete question. "This is wrong" without direction is not helpful.
