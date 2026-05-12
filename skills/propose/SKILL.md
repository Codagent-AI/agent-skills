---
name: propose
description: >
  Evaluate whether a software idea is worth building, then write the proposal document.
  Use when the user wants to assess an idea, says "evaluate", "propose", "is this worth building",
  or "should we build". If the idea passes evaluation, write the proposal document using the provided template.
---

# Propose

Evaluate whether an idea is worth formalizing, and if so, write the proposal document. This sits between optional freeform exploration and the formal design artifact.

**The proposal is a "why + high-level what + high-level how" document.** Deeply understand and articulate the motivation — the problem, the opportunity, and why it matters now. Scope "what" at a high level — enough to bound the change and identify capabilities, but leave detailed behavioral requirements for specs. Sketch the high-level technical approach and architecture — enough to ground the change in reality and surface structural risks early — but leave detailed design for design.md.

## Principles

- **Conversational evaluation, documentary proposal** — The evaluation phase is a conversation. The proposal phase produces `proposal.md`. Keep these phases distinct.
- **Research-informed** — Before opining, investigate the codebase and web resources to ground advice in reality.
- **Honest assessment** — If an idea has problems, say so directly. "Not worth building" is a valid and valuable outcome. A brainstorm that only cheerleads is useless.
- **Visual** — Use ASCII diagrams liberally when they'd help clarify thinking: architecture maps, comparison tables, flow sketches.
- **Why-first, then lightly** — The proposal establishes motivation first, then scopes the change at a high level, then sketches the high-level technical approach. Dig into the problem deeply. Scope "what" enough to bound capabilities and identify what needs specs — but leave detailed behavioral requirements for specs. Capture enough architecture and key technical decisions to ground the proposal in reality — but leave detailed design, component internals, and implementation specifics for design.md.

## Flow

### 1. Understand

First understand the idea. If the user's invocation didn't include enough context, follow the `codagent:ask-questions` skill to gather:
- What is the idea? What does it do from the user's perspective?
- What problem does it solve? Who has this problem?
- What triggered this? (bug report, user request, personal itch, competitive pressure)
- What would make this successful? What is explicitly out of scope?

Focus on purpose, constraints, success criteria, audience, and scope boundaries. Do not proceed until you have a concrete understanding of the idea. If the prompt is rough, ask specific discovery questions before evaluating or drafting — do not jump straight to a proposal-shaped artifact.

### 2. Research

Investigate before forming opinions. Do this proactively.

**Spec research** (when requirement specs exist):
- Review existing specs to understand current system behavior
- Identify if the idea conflicts with or extends existing capabilities

**Codebase research** (when a relevant codebase exists):
- Explore existing architecture to understand how this idea would fit
- Look for existing patterns, infrastructure, or prior attempts
- Identify areas that would be affected

**Web research** (when applicable):
- How others have solved similar problems
- Existing libraries, tools, or services that could help
- Known pitfalls or anti-patterns

When sharing findings, use diagrams to show architecture fits, data flows, or option comparisons rather than just prose.

### 3. Evaluate Worth

This is the decision point. Before going further into "how", assess whether this is worth doing:

- **Problem significance** — Is the problem real and meaningful? How many users/systems are affected?
- **Alternatives to building** — Could the goal be achieved with configuration, an existing tool, or a third-party service?
- **Opportunity cost** — What else could be built with the same effort? Is this the highest-value use of time?
- **Maintenance burden** — What ongoing cost does this introduce?

Be direct about the verdict:

```text
VERDICT
════════════════════════════════════════════

  GO          Worth pursuing.
              → Explore the approach, then write the proposal

  GO WITH     Worth pursuing, but with
  CAVEATS     scope or approach adjustments.
              → Discuss adjustments first

  NO-GO       Not worth building.
              → State why directly.
```

A "no-go" requires explanation: what specifically makes this not worth pursuing, and whether anything could change that assessment. If the user disagrees, engage with their reasoning — but ultimately it's their decision.

### 4. Explore the Approach (lightly)

Only reached on GO or GO WITH CAVEATS. Sketch the high-level technical approach — enough to ground the proposal in architectural reality and surface structural risks. This is NOT the design phase; you're establishing the approach, not detailing component internals.

- **Architecture fit** — How does this fit into the existing system? Align with current patterns or require new ones?
- **Key technical decisions** — The 2-3 big choices that will shape implementation (e.g., sync vs async, build vs buy, new service vs extending existing)
- **High-level approach** — What is the overall shape of the solution? Which layers/components are involved? What's the data flow?
- **Scope bounding** — What is the minimum viable version? What should be deferred?
- **Risk areas** — What parts are uncertain, complex, or likely to cause problems?

Present options when multiple approaches exist. Give a recommendation with reasoning, but let the user decide. Draw comparison tables and architecture sketches.

The findings from this phase feed directly into the proposal's Technical Approach section.

### 5. Write the Proposal

Once the idea has been evaluated and the approach has crystallized, determine where to write `proposal.md`, then write it using the Artifact Template below.

**Determining the output location:**

1. If the user has already specified a path, use it.
2. If a project configuration (e.g., AGENTS.md, openspec config, or similar conventions) specifies where proposals should live, use that.
3. Otherwise:
   - Generate a short kebab-case slug that captures what the change is about (e.g., `user-auth-improvements`, `rate-limit-api`).
   - Default path: `~/.agent-skills/changes/<slug>/proposal.md`
   - Use the appropriate tool for asking the user a question or requesting input to confirm the location. Offer exactly two choices: the default generated path, and "Somewhere else" (user specifies). Do not proceed until the user responds.

The proposal should be anchored in the "why" — the problem, the motivation, and the impact. Draw heavily from the Understand and Evaluate phases. The "what changes" section should scope the work at a high level — enough to bound capabilities, not to detail requirements. The "technical approach" section should capture the high-level architecture and key decisions from the Explore phase.

## Guardrails

- **Do not skip the evaluation** — Even for "obvious" ideas, the evaluation surfaces risks and shapes scope. Speed through it, but don't skip it.
- **Do not skip discovery questions** — If purpose, user impact, success criteria, or scope boundaries are ambiguous, ask targeted questions before presenting a verdict or proposal.
- **Do not cheerlead** — Honest assessment over enthusiasm. Every idea has trade-offs; name them.
- **Do not go deep on what or how** — The proposal answers "why" deeply, scopes "what" at a high level, and sketches the high-level "how". Detailed behavioral requirements belong in specs. Detailed design — component internals, algorithms, data structures, interface contracts — belongs in design.md. Capture enough to bound the change and ground it architecturally, then stop.
- **Do not auto-transition** — Follow `codagent:ask-questions` to confirm before writing the proposal. A "no-go" verdict means no proposal.
- **Do visualize** — Diagrams help clarify thinking. Use them for architecture, comparisons, and flows.
- **Follow the template** — Use the Artifact Template section below for proposal structure.

## Never

- Never present or write the proposal artifact before asking the appropriate purpose, scope, success-criteria, and constraint questions.
- Never use "does this proposal look right?" as a substitute for understanding why the change matters and what outcome the user wants.
- Never invent capability boundaries from a rough idea when a user answer would materially change the proposal.

## Artifact Template

Use this structure when writing `proposal.md`. Replace comments with actual content.

```markdown
## Why

<!-- 1-2 sentences on the problem or opportunity. What problem does this solve? Why now? -->

## What Changes

<!-- High-level bullet list of what's changing. Enough to bound scope and identify capabilities,
     not detailed requirements. Mark breaking changes with **BREAKING**. -->

## Capabilities

<!-- This section is critical. It creates the contract between the proposal and specs phases.
     Research existing specs before filling this in. Each capability listed here will need a
     corresponding spec file. -->

### New Capabilities
<!-- Capabilities being introduced. Replace <name> with kebab-case identifier
     (e.g., user-auth, data-export, api-rate-limiting). Each creates specs/<name>/spec.md -->
- `<name>`: <brief description of what this capability covers>

### Modified Capabilities
<!-- Existing capabilities whose REQUIREMENTS are changing (not just implementation).
     Only list here if spec-level behavior changes. Each needs a delta spec file.
     Leave empty if no requirement changes. -->
- `<existing-name>`: <what requirement is changing>

## Technical Approach

<!-- High-level architecture and key technical decisions. NOT detailed design —
     just enough to ground the proposal in reality.
     - Overall shape of the solution: which layers/components are involved
     - Key technical decisions and why (e.g., sync vs async, build vs buy)
     - How this fits into the existing architecture
     - Use ASCII diagrams for architecture sketches and data flows -->

## Out of Scope

<!-- What is explicitly out of scope for this change. Be specific — vague exclusions
     don't prevent scope creep. -->

## Impact

<!-- Affected code, APIs, dependencies, systems -->
```
