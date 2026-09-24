---
description: Explores an implemented change to find defects its green test suite missed, sizes the pass to what actually changed, reports findings without fixing them, waits for current-head CI, and prepares evidence for human review when preparing a change for acceptance, gathering review evidence, performing exploratory or human-style testing, or invoking codagent:prepare-acceptance.
---

# Prepare Acceptance

Explore an implemented change for defects its green test suite missed. Produce concise evidence, the
findings, and an honest list of what was not exercised, then hand all of it to a human acceptance
session.

Target what is true of the running system but asserted nowhere. The suite already covers what someone
thought to assert, so re-running its scenarios by hand proves nothing. The failure mode to avoid is not
missing a bug; it is producing a long plan that re-walks the happy path and finds nothing, because
thoroughness is the easy thing to simulate.

## Targeting versus oracle

Read the implementation, the diff, and the tests to decide **where to look**. Never use them to decide
**what correct means**. Code is self-consistent, so an oracle drawn from it declares every defect
correct. Draw expected behavior from the approved artifacts and from what a user would reasonably
expect.

## Inputs

Resolve from the caller: approved artifacts, the testing envelope naming authorized effects,
credentials, sandboxes, cost, cleanup, and any `HT-*` obligations reserved for humans; an
implementation summary; and an evidence directory. If approved artifacts or the evidence directory are
missing, report that and stop.

Carry `HT-*` obligations forward as human-review instructions. Never execute them or claim evidence for
them.

## Size the pass

Size from seams moved, not lines changed. A change that only rearranges code inside one function
rarely earns a hand-run. A change that moves a seam almost always does, because seams are where
automated tests stop being able to see.

| Kind of move | What it puts at risk |
| --- | --- |
| Process boundary | Load paths, environment inheritance, working directory, how failures surface |
| Error surface | Which failures are now silent, and which rescue is too narrow |
| Control-flow source | Whether the new source can express every state the old one could |
| Data source | Shapes the fixture never contained |
| Identity or ownership | Two writers, or none |

Budget roughly one step per distinct seam, with a floor of one and a ceiling of eight. Write the
budget and its rationale to `<evidence-directory>/exploration-plan.md` before testing. Do not expand it
silently later.

Regardless of budget, always run one end-to-end pass through the change's primary public surface.
Whether the headline behavior works at all is the one thing never skipped.

## Step 0: establish what the suite already owns

Read the tests covering the changed surface, not the whole suite. Answer three questions:

1. **What does each assertion prove, as opposed to appear to prove?** When one input feeds two outputs
   and the test asserts the cheap one, the expensive one is uncovered. Names, ids, counts, and "returned
   without raising" are the usual cheap ones.
2. **What is structurally unreachable under the fixture strategy?** Look for a mismatch between what the
   code reads and what the fixture is. Code that reads from git needs fixtures that exist in git.
   Unreachable is fine; unreachable and undocumented means someone assumes it is covered.
3. **Which behavior is newest, and does anything cover it?** A fix landing late in review is the likeliest
   thing in the change to have no test at all.

## Where candidates come from

In rough yield order:

- **Seams the change moved**, per the table above.
- **Accepted gaps and known limitations.** Watching a specified-but-odd behavior actually happen is often
  the highest-value step in a pass, and it is where a limitation turns out worse than documented.
- **Interaction of two independently-correct changes.** Ask which two accepted behaviors have never been
  exercised in the same run. Each was reviewed alone, so no test owns the pair.
- **Negative space.** For each guard added, test the configuration where it cannot fire at all, not only
  the value it rejects.
- **Representation.** Live systems echo data in shapes fixtures never contained: floats for integers, a
  bare value for a one-element collection, an explicit null for an omitted key.
- **The environment.** Which secrets, refs, and versions actually exist where this runs, as opposed to
  which ones the config names. These findings need no test run at all.

## What earns a run

Keep a candidate only if it clears all three:

1. **No automated test owns it**, established in Step 0 rather than assumed.
2. **A mock could not settle it.** If reading the code answers the question, read it and report a
   code-reading finding. That is cheaper and more certain than a run.
3. **Being wrong has a consequence someone would care about.** "Writes to the wrong project" qualifies.
   "Logs an odd string" does not.

Drop everything else.

## Run order

Order steps so each introduces exactly one new source of reality. When a step fails, the newest
dependency is the suspect.

1. Pure logic against saved fixtures, no network or credentials.
2. The failure path, with the dependency deliberately absent.
3. A real read against a sandbox.
4. A real write against a sandbox.
5. The same operation twice.
6. The real runner or CI, which adds checkout, credentials, and environment.

Step 5 is disproportionately productive. A large share of real defects are second-run defects:
duplicated records, moved timestamps, replaced identity.

## Two habits that find things

**Predict before running.** Write the expected result first, in specifics: how many records, which
values, what exit status. Predict from the approved behavior and from the mechanism separately. Where
those two predictions differ, that difference is itself a candidate. A wrong prediction is the most
valuable event in a pass, because the model and the system disagree and one of them is a defect.

**Print values, not verdicts.** Emit the actual identifiers, timestamps, and objects rather than
pass or fail. A boolean can only answer the question already thought of. For a UI, read the API for
exact values and look at the interface for the mental model; some views are the only proof that a run
wrote nothing.

## When to stop

Stop when the remaining untested paths are enumerable and named, not when they are empty. End with a
sentence like: "Not exercised: the conflict path against live data, and behavior above the deletion
cap." That is a complete result. "Everything tested" is never true.

Signs the pass has drifted into theatre: steps that mirror requirement names, re-running a journey the
end-to-end suite already walks, hand-testing pure logic with no I/O, more than one step per seam, or a
step with no recorded prediction.

If every step passed and nothing surprised, re-read Step 0; the pass probably covered ground the suite
already owned. Never manufacture or escalate a finding to compensate. An honest empty pass is a better
result than an inflated one.

## Report

Record defects in `<evidence-directory>/acceptance-findings.md` with the tested SHA, affected behavior,
expected versus observed, concise reproduction, and evidence paths. Do not fix them, and continue
through the remaining independent steps after finding one. Stop early only when a defect makes the rest
unreachable or untrustworthy.

Append product, scope, or design ambiguity to the assumptions ledger, defaulting to
`<evidence-directory>/acceptance-assumptions.md`. Never report ambiguity as a defect or silently choose
an interpretation. Keep this pass autonomous and leave those decisions to the human acceptance session.

Write `<evidence-directory>/exploration-log.md`: the budget and rationale, each step with its
prediction, its observation, and the resulting finding or nothing, plus the named list of what was
deliberately not exercised and why.

After every pass, overwrite `<evidence-directory>/acceptance-tested-revision.txt` with the exact SHA
just tested. That file is the diff base for the next pass.

For any UI, store screenshots under `<evidence-directory>/acceptance-screenshots/` with the behavior
demonstrated, what the reviewer should notice, the tested SHA, and a concise text equivalent.
Screenshots support an observation; they are not proof on their own.

## After a fix

A fix is a change. Apply this same method to it: read `<evidence-directory>/acceptance-tested-revision.txt`,
diff the current worktree against that SHA, size the result by seams moved, and explore that. Do not
re-run the previous pass, and do not derive the new scope from what was tested before.

If that file is missing, or names a SHA that does not resolve in this repository, report it as an
impediment and explore the change as a whole rather than guessing a base.

Read the prior exploration log as history, meaning "this area already behaves this way," never as
coverage, meaning "this area is signed off." An empty diff sizes to zero steps.

## Wait for CI and hand off

Once no finding remains, require a clean tracked worktree, a pushed local `HEAD`, and a matching PR
head before invoking `codagent:wait-ci`. If any of those is missing, tell the caller to commit, push, or
align the PR; do not do it here. After CI returns, re-read local `HEAD` and the PR head and require both
to match the returned SHA.

On `failed` or `comments`, add anything clearly attributable to the implementation to the findings file
and report it; report anything external as a blocker rather than a defect. On `pending`, report and stop.
With no configured checks, continue after recording that CI coverage is absent. Treat skipped, neutral,
cancelled, and timed-out checks as evidence states, never as passes.

Then write `<evidence-directory>/acceptance-handoff.md`:

1. **Decision brief** — delivered behavior, unresolved decisions, overall status, suggested review path.
2. **Revision identity** — repository, PR URL, current head SHA, tracked worktree status.
3. **Exploration** — the budget and rationale, what was exercised, what was found, and the named list of
   what was not exercised.
4. **CI** — status and durable links. Say plainly when no automated-validation evidence was supplied.
5. **Visual and client evidence** — screenshot metadata, text equivalents, and practical review steps.
6. **Human-only obligations** — applicable `HT-*` items as instructions, with no execution outcome.
7. **Assumptions** — ledger path and a concise summary of each unresolved item.

Before reporting ready, confirm every referenced path exists and that no persisted evidence exposes
secrets, credentials, or private data. Report the ready SHA, PR URL, handoff path, unresolved-decision
count, CI status, and known limitations.

## Out of scope

- Do not fix defects, modify tracked source or approved artifacts, commit, push, or alter PR metadata.
  Disposable setup and build outputs are fine.
- Do not run automated suites, linters, or the Validator. Setup and builds needed to use the product are fine.
- Do not change approved requirements, scope, or design to make something pass.
- Do not obtain human acceptance, mark the PR ready, merge, archive, or release.
- Do not fuzz or build an exhaustive edge-case matrix. Exploration is targeted by risk, not by volume.
- Do not treat a successful command exit, an agent summary, or a screenshot alone as proof of behavior.
