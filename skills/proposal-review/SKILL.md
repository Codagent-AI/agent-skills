---
name: proposal-review
description: >
  Adversarial review of a proposal — challenges the why, what, and how, and suggests concrete
  alternatives. Use when asked to review a proposal, challenge an idea, stress-test an approach,
  or provide a devil's advocate perspective before specs or design are written.
---

# Proposal Review

Give a constructive adversarial review of a completed proposal before specifications and design.
Strengthen the chosen direction by challenging its motivation, scope, and high-level approach—not by
manufacturing objections or writing a replacement proposal.

## Review

Read the full proposal, relevant existing specifications and code, and repository context. Research
credible alternatives and current external evidence when they materially affect the assessment.

Spend depth in proportion to impact and reversibility. Look for consequential concerns such as:

- a weakly evidenced problem, mistimed investment, or simpler non-build alternative;
- scope that is too broad, too narrow, internally unclear, or unlikely to solve the stated problem;
- capabilities that do not create a coherent contract for later specifications;
- a high-level architecture that conflicts with existing patterns, adds avoidable complexity, or
  ignores important failure, migration, rollout, maintenance, or second-order effects;
- major decisions made without rationale or without considering a plausible better alternative.

Do not re-run the propose skill's go/no-go exercise, invent requirements, or report missing downstream
specifications, design, test plans, or tasks. Those artifacts do not exist yet by design.

## Report

For each material challenge:

- cite the proposal section and relevant evidence;
- state the strongest case for the proposal's choice;
- explain the concrete concern;
- recommend an alternative or a load-bearing question, including your preferred answer.

Classify findings as **structural**, **significant**, or **minor**, then give a direct readiness
assessment. Say plainly when no consequential challenge remains. Do not edit the proposal.
