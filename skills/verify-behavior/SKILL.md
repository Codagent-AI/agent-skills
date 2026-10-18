---
description: >-
  Plans how to verify each behavior in a change's spec, then records evidence that each check
  passed. Use when asked to plan or record verification of a change's behavior, or to invoke
  codagent:verify-behavior.
---

# Verify Behavior

## Writing the checklist

Read the change's proposal, specs, design, and test plan, but not the code. For each behavior the
spec describes, including its error, failure, and cleanup cases, say how you will verify it: an
automated test (unit, integration, or end-to-end), a scripted command whose exit code or output
decides the result (such as a build, lint, or verify script), or inspection of the code or files.
Never plan a check in which an agent operates the product as a user would; that testing happens
once, in acceptance testing after implementation. Do not cite the test plan's acceptance (`AT-`) or
human-only (`HT-`) tests as a check, and add no rows for them. Several behaviors may share one
check. Choose the fastest check that would fail if the behavior broke: inspection or a unit or
component test where one can show it, and an integration or end-to-end test only where the
behavior exists only across processes, a real browser, or the built product. Plan no integration or
end-to-end tests beyond those the test plan names; cite a named test's ID for the behaviors that
need it, and add a row for any such test that no behavior covers. Write the checklist where
you were asked to, or else as `checklist.md` beside the change's spec, in one table:

| ID | Behavior | Spec reference | How to verify |
|---|---|---|---|
| 1 | An unknown route shows the not-found page | specs/routing.md, "Unknown route" | Router unit test |

## Recording evidence

After building, add the columns Code, Evidence, and Status.

- Run each check and save its output to a file in the evidence directory you were given, or else
  in `evidence/` beside the checklist: a test log, command output, or, for something that can only
  be inspected, a note of what you looked at.
- Put the evidence file names, in backticks, in the Evidence column. Status holds exactly one of
  `verified`, `failed`, or `not verified`, and nothing else. For `failed`, Evidence says what
  fails; for `not verified`, it says why you could not run the check.
- Never mark a behavior verified unless you ran its check.
- Mention no acceptance (`AT-`) or human-only (`HT-`) test ID anywhere in the checklist, not even to
  say a behavior is left to acceptance testing.
- Evidence can come from the one broader test run and from targeted runs of single tests; never
  rerun a whole suite only to refresh evidence.
- After any change to code or files a row depends on, rerun that row's check alone and update its
  Evidence, or set it to `not verified`. Evidence from before the change no longer counts for that
  row; other rows keep theirs, and a test you added or changed needs only its own run.
