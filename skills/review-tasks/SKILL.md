---
description: Reviews an implementation task plan against its approved proposal, specifications, and design, finding only defects that can be corrected in the task files. Use when asked to review tasks, review an implementation plan, verify task coverage, or check whether a task breakdown is ready for autonomous implementation.
---

# Review Tasks

Review whether an implementation task plan is a faithful, complete, and executable translation of its
approved definition. The proposal, specifications, and design are required source material, but they are
not review targets in this skill.

## 1. Read the complete planning context

Read the proposal, every specification, the design, the task index, every detailed task file, and relevant
repository instructions. You MUST access the proposal, specifications, and design before judging the
tasks. Inspect relevant code or repository structure when needed to verify task feasibility, paths,
dependencies, or established implementation boundaries.

Treat the proposal, specifications, and design as immutable, approved inputs. If they appear ambiguous,
incomplete, inconsistent, or poorly designed, do not turn that concern into a task-review finding. That
belongs to an approach or definition review.

## 2. Review the task plan

Check whether the task files:

- cover every approved requirement, scenario, design obligation, migration, and required deliverable;
- preserve the exact behavior and boundaries established by the approved artifacts without adding scope;
- give each implementer enough context, artifact citations, acceptance criteria, and done conditions to
  complete the task without relying on hidden session knowledge;
- use task boundaries that are independently valuable, appropriately sized, and coherent rather than
  splitting infrastructure, tests, or documentation away from the behavior they support;
- state workable dependencies and appear in an order that respects those dependencies;
- identify the relevant implementation surfaces precisely enough to act on while leaving line-by-line
  implementation choices to the implementer; and
- form a complete execution contract when read together, with no duplicate, contradictory, orphaned, or
  unreachable work.

Apply only checks relevant to the plan. Do not manufacture findings to fill a checklist.

## 3. Report bounded findings

Every finding MUST be correctable by editing only the task index or detailed task files. For each finding:

1. Cite the exact task file and section.
2. Cite the controlling proposal, specification, or design section.
3. Explain the concrete implementation risk or missing execution contract.
4. Recommend the specific task-plan correction.

Rank findings by implementation impact. Say explicitly when the task plan is ready and no actionable
task-plan defects remain. Do not edit any files.

Use this output structure:

```markdown
## Findings

### [high|medium|low] <concise title>
- Task: <exact task file and section>
- Controlling artifact: <exact proposal, specification, or design section>
- Risk: <concrete implementation consequence or missing execution contract>
- Correction: <specific task-plan edit>

## Readiness Assessment
<Whether the task plan is ready for implementation and why.>
```

When there are no findings, write `None.` under Findings and still provide the readiness assessment.

## Guardrails

- Do not review the proposal, specifications, or design for gaps, consistency, completeness, product
  choices, architecture, or tradeoffs. `review-approach` owns that final definition review.
- Do not report an issue whose resolution requires changing an approved source artifact, inventing
  behavior, or asking the user to make a product, scope, or design decision.
- Do not treat an upstream ambiguity as a task-plan blocker or encode a guessed resolution into a task.
- Do not review implementation code quality or implementation correctness.
- Do not rewrite or modify the task artifacts; the caller owns correction.
