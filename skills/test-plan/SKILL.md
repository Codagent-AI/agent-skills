---
description: Collaboratively creates a risk-based test plan for a defined software change using the automated test pyramid plus the envelope an exploratory acceptance pass runs under and exceptional human-only testing; use after specifications and design are complete, when asked to plan testing, define integration or end-to-end coverage, set testing authorizations, or create test-plan.md before implementation planning.
---

# Test Plan

Create `<change-dir>/test-plan.md` after the proposal, specifications, and design are complete. The
plan records important automated integration and end-to-end obligations, the envelope the later
exploratory acceptance pass runs under, and exceptional human-only checks. Specifications and
implementation-time TDD remain the source of unit-test requirements.

Do not write the plan until the user approves the proposed coverage. Use `codagent:ask-questions` for
consequential choices involving environments, external effects, cost, credentials, fidelity,
substitutes, or genuinely human-only judgment.

## Plan coverage by risk

Read the definition artifacts, relevant repository instructions, current test structure, and affected
public surfaces. Trace critical journeys and boundaries, then choose the lowest test layer that can
reliably detect each important failure:

- **Unit tests:** the broad base for isolated logic, validation, transformations, decisions, and edge
  cases. Do not inventory these in the test plan.
- **Integration tests (`INT-*`):** important boundaries where real components must work together, such
  as adapters, databases, filesystems, subprocesses, APIs, queues, or configuration-to-runtime wiring.
  Prefer controlled real dependencies or contract tests when they are more faithful than mocks.
- **Automated end-to-end tests (`E2E-*`):** a small set of critical journeys through a public entry
  point with realistic isolated setup and stable observable assertions.

Avoid fixed ratios, test-count quotas, duplicate assertions across layers, and E2E coverage for
behavior a cheaper layer proves adequately. It is valid to record that no new integration or E2E
obligation is warranted and explain why.

For each automated obligation, capture what it covers, the boundary or journey exercised, setup,
stable assertions, constraints, and where it runs.

## Define the testing envelope

Do not enumerate acceptance test cases. Acceptance is an exploratory pass sized to what actually
changed, and a pre-written flow list only tells it to re-walk the happy path. The plan's job is to say
what that pass is allowed to do, not what it must check.

Record the envelope:

- environments, sandboxes, and test accounts available;
- credentials and secrets that exist, and where;
- external effects that are authorized, their cost, and required cleanup;
- anything the pass must not touch, such as production data or irreversible operations;
- substitutes permitted when a real dependency is unavailable.

Note known risk areas, prior defect clusters, and anything the design treats as an accepted limitation.
These inform exploration without prescribing it.

Default human-only testing to `None.` Add an `HT-*` only for judgment or authority unavailable to an
agent with the product and tools—for example subjective preference, legal approval, physical
perception, unavailable personal credentials, or an irreversible user-authorized act. Visual and
interactive UI testing belongs to the exploratory pass. For each `HT-*`, state why an agent cannot
perform it, what prior testing must establish, concise user instructions, and the decision or
observation required.

## Approve and write

Present the proposed obligations, the envelope, meaningful omissions, and consequential testing
choices. After user approval, write the plan and a coverage map containing only requirements or
journeys with an additional `INT-*`, `E2E-*`, or `HT-*` obligation. Do not create tasks, write tests,
execute tests, or invoke another lifecycle phase.

## Artifact template

```markdown
## Coverage Strategy

Specifications remain the source of unit-test requirements. This plan records only additional
integration and end-to-end obligations, the acceptance testing envelope, and exceptional human-only
obligations.

## Integration Tests

### INT-001: <boundary behavior>
- Covers: <requirements or journey>
- Boundary: <real components and interaction>
- Setup: <controlled dependencies and data>
- Action: <operation>
- Assertions: <stable observable results>
- Execution: <test location or CI command/phase>

## End-to-End Tests

### E2E-001: <critical journey>
- Covers: <requirements or journey>
- Surface: <public entry point>
- Setup: <realistic isolated environment>
- Journey: <user/client actions>
- Assertions: <stable observable results>
- Execution: <test location or CI command/phase>

## Acceptance Testing Envelope

- Environments and sandboxes: <available targets>
- Credentials and secrets: <what exists and where>
- Authorized effects: <external effects, cost, and required cleanup>
- Off limits: <what must not be touched>
- Permitted substitutes: <substitute and condition, or None>
- Known risk areas: <prior defect clusters and accepted limitations>

## Human-Only Testing

None.

<!-- When needed:
### HT-001: <human judgment or authority>
- Reason: <why an agent cannot perform it>
- Prerequisites: <prior automated and acceptance evidence>
- Instructions: <concise user actions>
- Required decision or observation: <result needed>
-->

## Coverage Map

| Requirement or journey | INT | E2E | HT |
| --- | --- | --- | --- |
| <item> | <IDs or —> | <IDs or —> | <IDs or —> |
```
