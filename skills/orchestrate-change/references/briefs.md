# Sub-agent brief templates

Sub-agents see only their brief and the project's instruction files (such as `CLAUDE.md` or
`AGENTS.md`), not your conversation. Fill every placeholder. A brief that leans on "as
discussed" or "the usual approach" fails.

## Implementer

```
You are implementing one slice of the change "<change name>".

Goal: <one or two sentences on the behavior this slice adds>

Source of truth (read these first):
- <proposal path>
- <spec paths>
- <design path>
- <test plan path>

Requirements and scenarios this slice must satisfy (quoted exactly):
<requirement and scenario text>

Test-plan items this slice owns:
<items>

Relevant design decisions:
<short list>

Decisions already made by earlier slices:
<short list, or "none">

Code pointers: <interfaces or contracts to honor, existing patterns to follow, file paths>

Boundaries:
- Expected files: <paths>. Touch others only when needed, and say why in your report.
- Out of scope: <what not to change>. Do not refactor unrelated code.
- Do not edit the change's proposal, specs, design, or test plan.

How to work:
- Follow the repository's development conventions, including test-driven development where
  they require it: write a failing test from each scenario first, then make it pass.
- Run: <targeted test command> and <lint or format command>.
- Commit only your own work when the tests pass, following the project's commit message
  conventions<, with the "<prefix>" prefix>. Leave unrelated files untouched.
- Do not ask the user questions. If you lack information, stop and report NEEDS_CONTEXT.
- Do not spawn sub-agents.

Report:
- Status: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED
- Commits: <shas>
- Files changed
- Commands run, with pass or fail results
- Assumptions made, and concerns or open questions
```

## Reviewer

```
You are independently reviewing one slice of the change "<change name>". Do not modify any
files.

Brief the implementer received:
<the implementer brief>

Changes to review: git diff <base>..<head>

Check, in this order:
1. Spec compliance: every quoted scenario and test-plan item is implemented and covered by a
   test that would fail without the change. Nothing out of scope was added.
2. Correctness: bugs, missed edge cases or failure modes from the design, broken existing
   behavior.
3. Fit: the code follows the repository's existing patterns and conventions.

Report only problems that affect correctness or the stated requirements. Do not report
stylistic preferences. For each finding, give the file and line, the problem, why it matters,
and a suggested fix. If there are none, say "No blocking findings."
```

## Final reviewer

```
You are doing the final verification of the change "<change name>". Do not modify any files.

Source of truth: <artifact paths>
Changes: git diff <start commit>..HEAD
Full check commands: <commands>

Run the full checks. Then build a matrix with one row per spec scenario and per test-plan item:

| Item | Verified by (test name, or command and output) | Result: pass, fail, or unverified |

Also report any integration problems between slices, behavior the artifacts do not ask for,
and existing behavior that broke. Report only problems that affect correctness or the
requirements.
```
