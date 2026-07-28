---
name: spec
description: >
  Drives interactive requirement discovery to produce spec files.
  Use when the user says "spec this", "write specs", "create specs", or "run the spec skill".
---

# Spec

Turn the proposal's capabilities into testable behavioral requirements through collaborative
discovery. Specifications define observable behavior, not architecture or implementation.

Do not write a capability's spec until you have presented its proposed requirements and scenarios and
the user has approved them.

## Process

1. Read the proposal and related existing specifications. Use the proposal's capability names to
   determine the new or modified spec files. For modified capabilities, locate the current requirement
   blocks before drafting the delta.
2. Work through capabilities one at a time. Use `codagent:ask-questions` to resolve material behavior,
   boundaries, errors, and edge cases. Ask only questions that affect observable behavior or scope,
   recommend a default when useful, and do not use a generic approval question as discovery.
3. Present the complete proposed requirements and scenarios for that capability, including
   consequential assumptions or defaults inferred from context.
4. After approval, write the spec file using the format below. Continue until each proposal capability
   has a corresponding spec.

If behavior depends on an unresolved architectural choice, specify as much as is currently knowable and
add `<!-- deferred-to-design: <reason> -->` to the affected scenario. The design phase will complete or
revise it. Do not ask architecture or implementation questions during specification.

Report the relative paths created. Do not invoke another lifecycle skill.

## OpenSpec format

- Use one file per capability: `specs/<capability>/spec.md`.
- Write normative requirements with SHALL or MUST.
- Use `### Requirement: <name>` and at least one `#### Scenario: <name>` per requirement.
- Scenarios describe observable WHEN/THEN behavior. Exactly four hashes on scenario headings are
  required by the parser.
- Avoid scenarios about file contents, configuration structure, or skill text unless those are the
  actual public contract.

Use delta sections as applicable:

- `## ADDED Requirements` for new behavior.
- `## MODIFIED Requirements` for changed behavior. Copy the entire existing requirement block and all
  scenarios before editing it.
- `## REMOVED Requirements` with **Reason** and **Migration**.
- `## RENAMED Requirements` with FROM and TO.

```markdown
## ADDED Requirements

### Requirement: <name>
<normative behavior>

#### Scenario: <name>
- **WHEN** <condition>
- **THEN** <observable result>
```
