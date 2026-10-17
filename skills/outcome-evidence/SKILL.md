---
description: >-
  Writes and maintains an outcome record for a change: the outcomes its definition requires, a plan
  for showing each, and the evidence each was shown. Use when asked to list required outcomes,
  merge outcome lists, record verification evidence, refresh evidence after a fix, or invoke
  codagent:outcome-evidence.
---

# Outcome Evidence

Maintain the outcome record for an approved change. Do only the operations the caller names:
list, merge, record, or refresh.

The caller may supply: the definition location, an ID prefix (for example `R-` or `I-`), whether
to write a file or respond with the table only, provenance source names, the evidence directory,
and an escalation route. Read the definition first.

## List

Use when producing an independent list. Work from the approved definition alone, not the
implementation or another list.

1. List the observable outcomes and the required integrations between deliverables (for example
   "the demo uses the kit's public API"). Do not list implementation tasks.
2. Include the failure, error, and cleanup behavior the definition requires, not only the main path.
3. Write one row per outcome with these columns:

   | ID | Outcome | Definition reference | Verification |
   | --- | --- | --- | --- |

   ID uses the caller's prefix if given. Definition reference points to the section or scenario.
   Verification names how the outcome could be shown.
4. Write a file or respond with the table only, as the caller says.

## Merge

Use when two lists exist (for example a reviewer's and an implementor's).

1. Take the union. Combine equivalent rows: keep one ID and cite the other in the row. Rows are
   equivalent when they require the same observable behavior from the same part of the definition;
   when unsure, keep both rows and send the question to the escalation route.
2. Mark each row's provenance with the caller's source names (for example `reviewer`,
   `implementor`, `both`) in a Provenance column.
3. Never drop or weaken an obligation from either list. Send disagreements to the escalation
   route.
4. Add the columns Implemented in, Evidence, and Status (`open`). The merged table, with one
   example row:

   | ID | Outcome | Definition reference | Provenance | Verification | Implemented in | Evidence | Status |
   | --- | --- | --- | --- | --- | --- | --- | --- |
   | R-2 | Cancelling an import leaves no partial files | specs/import.md, "Cancel" | both | Integration test `cancel import` | | | open |

5. Make Verification the plan for showing the outcome: which of the definition's scenarios it
   covers, including failure, error, and cleanup ones, and the check that will exercise them (a
   test, a command, or an interaction). Several rows may share one check.

## Record

1. Verify each row as its Verification column plans, exercising the behavior.
2. Save each check's output in the caller's evidence directory. With none, choose one outside
   tracked source (for example under the change directory) and say where. Evidence is a test log,
   a command transcript, a screenshot, or, for an outcome that can only be inspected, a note of
   what was inspected.
3. Record the commit each check ran against.
4. Set Status:
   - `verified`: cite at least one evidence file.
   - `failed`: say what fails.
   - `not verified`: say why the check could not be performed.
5. Never mark a check that was not performed as verified. Before leaving a check unperformed,
   use the escalation route if one exists.
6. Add a row, marked as added, for any obligation the list lacks. Keep each row's Implemented in
   current.
7. When `codagent:implement-change` is in use, run tests by its tiers.

## Refresh

Evidence from before a fix does not cover code the fix changed. After a fix, rerun the affected
checks, then update the rows, the commit, and the evidence files.

## Record format

A deterministic script checks the record. Follow this exactly.

- The record is the first Markdown table in the file that has both a Status and an Evidence
  column. An ID column is optional. The table ends at the first non-table line, so notes may
  follow it.
- Status is `verified`, `failed`, or `not verified`. Case, bold, and backticks are ignored.
  `open` is allowed only before recording.
- A `verified` row's Evidence cell cites at least one non-empty evidence file in backticks, as a
  path relative to the evidence directory or an absolute path inside it. Paths may contain
  spaces. A path with a `..` segment does not count.
- A `failed` or `not verified` row's Evidence cell says why.
- Escape a literal `|` inside a cell as `\|`.

After writing or updating the record, check it against these rules yourself and fix any
violation: every row has a valid Status, every `verified` row cites an existing non-empty file,
and every `failed` or `not verified` row says why.

Example row after recording:

```markdown
| ID | Outcome | Definition reference | Provenance | Verification | Implemented in | Evidence | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| R-3 | Invalid input is rejected and nothing is written | specs/import.md, "Rejects bad file" | both | Integration test `import rejects bad file` | `src/import.ts` | `tests/import.log` (commit a1b2c3d) | verified |
```

## Out of Scope

- Implementing the change (use `codagent:implement-change`).
- Editing the definition. Report a missing or contradictory obligation to the escalation route.
