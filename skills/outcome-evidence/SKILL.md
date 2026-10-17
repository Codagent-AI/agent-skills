---
description: >-
  Writes and maintains a change's outcome record: the outcomes its definition requires, how each
  will be shown, and the evidence that it was. Use when asked to list required outcomes, merge
  outcome lists, or record verification evidence, or to invoke codagent:outcome-evidence.
---

# Outcome Evidence

## Listing outcomes

Read only the approved definition (proposal, specs, design, and test plan), not the
implementation or any other outcome list. List the outcomes the change must deliver: observable
outcomes and required integrations between deliverables (for example "the demo uses the kit's
public API"), not implementation tasks. Include the failure, error, and cleanup behavior the
definition requires, not only the main path. Use one Markdown table with the columns ID, Outcome,
Definition reference, and Verification.

## Merging two lists

Take the union, combine equivalent rows (keep one ID and cite the other), and mark each row's
provenance (which list it came from, or both). Never drop or weaken an obligation from either
list. Add the columns Implemented in, Evidence, and Status (`open`).

Make the Verification column the plan for showing each outcome: the definition's scenarios it
covers, including the failure, error, and cleanup ones, and the check that will exercise them (a
test, a command, or an interaction). Several rows may share one check.

## Recording evidence

- Keep each row's location current, and add a row, marked as added, for any obligation the list
  lacks.
- Verify each row as its Verification column plans, exercising the behavior, including its failure
  and cleanup scenarios. Save each check's output in an evidence directory: a test log, a command transcript, a screenshot, or, for an outcome that can only be inspected, a
  note of what you inspected. Record the commit each check ran against. Several rows may cite one
  file.
- Set each row's Status to `verified`, citing its evidence file in backticks (relative to the
  evidence directory) with the result; `failed`, with what fails; or `not verified`, with why the
  check could not be performed. Never mark a check you did not perform as verified.
- After a fix, refresh the affected rows and their evidence. Evidence from before a fix does not
  cover the code the fix changed.
