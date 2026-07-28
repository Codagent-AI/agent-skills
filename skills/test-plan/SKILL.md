---
description: Collaboratively creates a risk-based test plan for a defined software change using the automated test pyramid plus agent acceptance and exceptional human-only testing. Use after specifications and design are complete, when asked to plan testing, define integration or end-to-end coverage, establish acceptance flows, or create test-plan.md before implementation planning.
---

# Test Plan

Create `<change-dir>/test-plan.md` after the proposal, specifications, and design are complete. The
plan records important automated integration and end-to-end obligations, authoritative agent
acceptance flows, and exceptional human-only checks. Specifications and implementation-time TDD remain
the source of unit-test requirements.

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

## Define acceptance flows

Create concise `AT-*` obligations for human-style verification through the delivered UI, mobile
interface, TUI, CLI, API, library, or other public surface. Acceptance complements automated tests; it
does not rerun suites, enumerate edge cases, or fuzz inputs.

Each flow should state:

- whether it is required or conditional, and the activation condition;
- actor, public surface, representative setup and data;
- actions and expected observable result;
- evidence, including meaningful screenshots for UI flows;
- authorized external effects, credentials, cost, cleanup, and any explicitly permitted substitute.

Applicable flows are authoritative. A later tester may group equivalent variants but may not omit a
flow, replace it with a dry run or mock, or call its absence a harmless limitation unless this plan
allows that substitute. If an applicable flow cannot run, acceptance testing is incomplete.

Default human-only testing to `None.` Add an `HT-*` only for judgment or authority unavailable to an
agent with the product and tools—for example subjective preference, legal approval, physical
perception, unavailable personal credentials, or an irreversible user-authorized act. Visual or
interactive UI testing normally belongs in agent acceptance. For each `HT-*`, state why an agent
cannot perform it, what prior testing must establish, concise user instructions, and the decision or
observation required.

## Approve and write

Present the proposed obligations, meaningful omissions, and consequential testing choices. After user
approval, write the plan and a coverage map containing only requirements or journeys with an
additional `INT-*`, `E2E-*`, `AT-*`, or `HT-*` obligation. Do not create tasks, write tests, execute
tests, or invoke another lifecycle phase.

## Artifact template

```markdown
## Coverage Strategy

Specifications remain the source of unit-test requirements. This plan records only additional
integration, end-to-end, agent-acceptance, and exceptional human-only obligations.

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

## Agent Acceptance Tests

### AT-001: <delivered flow>
- Classification: <Required | Conditional: condition>
- Covers: <requirements or journey>
- Actor and surface: <user/client and interface>
- Setup: <data, environment, and credentials>
- Steps: <human-style actions>
- Expected: <observable result>
- Evidence: <screenshots or client-visible evidence>
- Effects and cleanup: <authorized effects, cost, and cleanup>
- Permitted substitutes: <explicit substitute and condition, or None>

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

| Requirement or journey | INT | E2E | AT | HT |
| --- | --- | --- | --- | --- |
| <item> | <IDs or —> | <IDs or —> | <IDs or —> | <IDs or —> |
```
