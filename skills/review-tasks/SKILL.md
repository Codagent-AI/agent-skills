---
description: Reviews an implementation task plan against its approved proposal, specifications, design, and test plan, finding only defects that can be corrected in the task files; use when asked to review tasks, review an implementation plan, verify task and automated-test coverage, or check whether a task breakdown is ready for autonomous implementation.
---

# Review Tasks

Review whether the task index and detailed task files are a faithful, complete, executable translation
of the approved proposal, specifications, design, and test plan.

Read all definition and task artifacts before judging the plan. Inspect relevant repository structure
when needed to verify feasibility, paths, dependencies, test placement, or implementation boundaries.
The definition artifacts are immutable inputs, not review targets.

## Review focus

Check that the tasks:

- cover approved requirements, scenarios, design obligations, migration, deliverables, and assigned
  integration or E2E tests without adding scope;
- are self-contained for implementors with no hidden session context, including exact artifact
  citations, constraints, acceptance criteria, and done conditions;
- form meaningful, right-sized delivery units with workable dependencies and ordering;
- keep tests, ordinary documentation, setup, and refactoring with the behavior they support;
- identify relevant implementation surfaces without prescribing line-by-line code; and
- contain no duplicate, contradictory, orphaned, or unreachable work.

Do not ask for new product, scope, architecture, or testing-strategy decisions. If a concern requires
changing an approved artifact, it is outside this review and must not become a task finding. Do not
review implementation correctness or modify files.

## Report

Every finding must be correctable only in the task index or detailed task files. Cite the exact task
section and controlling artifact section, explain the implementation risk, and recommend the specific
task edit. Rank findings by impact and end with a readiness assessment; say explicitly when no
actionable task defect remains.

```markdown
## Findings

### [high|medium|low] <title>
- Task: <task file and section>
- Controlling artifact: <artifact and section>
- Risk: <implementation consequence>
- Correction: <specific task edit>

## Readiness Assessment
<Whether the task plan is ready and why.>
```
