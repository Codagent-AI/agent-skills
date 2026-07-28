---
description: Collaboratively creates a risk-based test plan for a defined software change using the automated test pyramid plus agent acceptance and exceptional human-only testing. Use after specifications and design are complete, when asked to plan testing, define integration or end-to-end coverage, establish acceptance flows, or create test-plan.md before implementation planning.
---

# Test Plan

Create `<change-dir>/test-plan.md` after the proposal, specifications, and design are complete. The
artifact defines important automated integration and end-to-end obligations, authoritative agent
acceptance flows, and any unavoidable human-only checks. Unit-test details remain primarily owned by
TDD during implementation.

Do not write the artifact until you have presented the proposed plan and the user has approved it.
Use `codagent:ask-questions` for consequential choices about environments, external effects, cost,
credentials, fidelity, or genuinely human-only judgment.

## 1. Understand the change and its risks

Read the proposal, every specification, the design, relevant repository instructions, existing test
structure, and the public surfaces affected by the change. Trace the critical user journeys and
component boundaries. Identify failures that isolated logic tests would miss and flows whose completion
must be demonstrated through the real product surface.

Do not turn every scenario, code path, or input variation into a separately planned test. Concentrate
the artifact on cross-component risk, critical journeys, and acceptance evidence that implementers
would otherwise have to invent.

## 2. Apply the automated test pyramid

Use the pyramid as an economic and risk model, not a fixed ratio or test-count quota:

1. **Unit tests** form the broad base. Use them for isolated logic, validation, transformations,
   decisions, and edge cases. Specifications remain the source of unit-test requirements, and TDD
   determines the concrete cases during implementation; do not restate them in this plan.
2. **Integration tests** form the middle layer. Create an `INT-*` obligation for an important boundary
   whose behavior depends on real components working together, such as adapters, databases, filesystems,
   subprocesses, APIs, queues, configuration-to-runtime wiring, or workflow handoffs. Prefer controlled
   real dependencies or contract tests when they prove the boundary more faithfully than mocks.
3. **Automated end-to-end tests** form the narrow top. Create an `E2E-*` obligation only for a critical
   journey that must cross the complete application through a public entry point. Use realistic,
   isolated setup and stable observable assertions. Keep this set small because these tests are slower,
   costlier, and more fragile.

Prove behavior at the lowest layer that can adequately detect the relevant failure. Do not duplicate
the same assertion across layers merely for coverage. Do not use an E2E test for logic an integration
or unit test can prove, and do not mock the boundary an integration test exists to verify.

For each `INT-*` or `E2E-*` obligation, record:

- the requirements or critical journey covered;
- the boundary or public surface exercised;
- setup and controlled dependencies;
- the action and stable observable assertions;
- important external-system, data, isolation, cost, or CI constraints;
- where and how the automated test should run.

It is valid to record that no new integration or E2E obligation is warranted, with a concrete rationale.

## 3. Define agent acceptance testing

Create concise `AT-*` obligations for human-style verification through the real UI, mobile interface,
TUI, CLI, API, library, or other public surface. Agent acceptance complements the automated pyramid: it
checks that representative delivered flows work coherently and captures review evidence; it does not
rerun automated suites, enumerate edge cases, fuzz inputs, or replace deterministic regression tests.

For each `AT-*`, record:

- requirements or journey covered, whether it is **required** or **conditional**, and the activation
  condition when conditional;
- actor, public surface, setup, and representative data;
- actions and expected observable result;
- evidence to capture, including meaningful screenshots for any UI;
- authorized external effects, credentials, expected cost, and cleanup;
- any permitted substitute such as a sandbox or stub, and exactly when it is allowed.

A required `AT-*`, and a conditional `AT-*` whose activation condition holds, is authoritative. A later
tester may group equivalent variants within it, but may not omit it, replace it with a dry run or mock,
or relabel its absence as a harmless limitation unless this plan explicitly permits that substitute. If
an applicable flow cannot be exercised, acceptance testing has not completed.

## 4. Minimize human-only testing

Default the Human-Only Testing section to `None.` Create an `HT-*` obligation only when a human must
provide judgment or authority that an agent using the available product and tools cannot supply, such
as subjective preference, legal or organizational approval, physical perception, unavailable personal
credentials, or an irreversible act requiring the user.

A UI flow is not human-only merely because it is visual or interactive. Agent acceptance should test it
and capture screenshots when tools allow.

For each unavoidable `HT-*`, record the reason it cannot be delegated, prerequisites that automated and
agent testing must establish first, concise user instructions, and the decision or observation needed.
The ordinary discretionary human review conversation does not need to become a mandatory `HT-*`.

## 5. Check coverage and obtain approval

Build a coverage map only for the additional `INT-*`, `E2E-*`, `AT-*`, and `HT-*` obligations in this
plan, linking each to the requirements or critical journeys it covers. Do not add rows for requirements
that rely only on specification-driven unit coverage. Check that:

- important boundary risk has an integration obligation;
- only critical complete journeys use automated E2E coverage;
- agent acceptance covers the delivered public flows without duplicating automated edge-case testing;
- any permitted substitute is explicit;
- human-only testing is absent unless genuinely unavoidable; and
- the planned environment, side effects, credentials, cost, and cleanup are feasible and authorized.

Present the proposed obligations, meaningful omissions, and consequential testing choices to the user.
Revise until approved, then write `test-plan.md`. This skill does not create implementation tasks, write
tests, execute tests, or invoke another lifecycle phase.

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
- Classification: Required
- Covers: <requirements or journey>
- Actor and surface: <user/client and interface>
- Setup: <representative data, environment, and credentials>
- Steps: <human-style actions>
- Expected: <observable result>
- Evidence: <screenshots or client-visible evidence>
- Effects and cleanup: <authorized side effects, cost, and cleanup>
- Permitted substitutes: None

## Human-Only Testing

None.

## Coverage Map

Include only requirements or journeys with an additional obligation in this plan; do not inventory
specification-driven unit coverage.

| Requirement or journey | INT | E2E | AT | HT |
| --- | --- | --- | --- | --- |
| <item> | <IDs or —> | <IDs or —> | <IDs or —> | <IDs or —> |
```
