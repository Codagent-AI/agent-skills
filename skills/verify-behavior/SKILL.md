---
description: >-
  Plans how to verify each behavior in a change's spec, then records evidence that each check
  passed. Use when asked to plan or record verification of a change's behavior, or to invoke
  codagent:verify-behavior.
---

# Verify Behavior

## Writing the checklist

Read the change's proposal, specs, design, and test plan, but not the code. For each behavior the
spec describes, including its error, failure, and cleanup cases, say how you will verify it: a
test, a command, or a manual check. Several behaviors may share one check. Write the checklist
where you were asked to, or else as `checklist.md` beside the change's spec, in one table:

| ID | Behavior | Spec reference | How to verify |
|---|---|---|---|
| 1 | An unknown route shows the not-found page | specs/routing.md, "Unknown route" | Router unit test |

## Recording evidence

After building, add the columns Code, Evidence, and Status.

- Run each check and save its output to a file in the evidence directory you were given, or else
  in `evidence/` beside the checklist: a test log, command output, a screenshot, or, for something
  that can only be inspected, a note of what you looked at.
- Set Status to `verified` with the evidence file name in backticks, `failed` with what fails, or
  `not verified` with why you could not run the check. Never mark a behavior verified unless you
  ran its check.
- After a fix, rerun the affected checks. Evidence from before the fix no longer counts.
