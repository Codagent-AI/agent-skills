---
description: Exercises an implemented change through its user and client flows, reports clear defects without fixing them, waits for current-head CI, and prepares concise evidence for human review when preparing a change for acceptance, gathering review evidence, performing human-style flow testing, or invoking codagent:prepare-acceptance.
---

## Prepare Acceptance

Prepare an implemented change for a separate human acceptance session. Exercise it as a human user or
real client would, report clear defects, wait for CI once no defects remain, and produce concise
evidence for the code currently checked out. Fixes and automated validation belong to separate
caller-managed steps when used. PR and commit identity establish final CI and handoff alignment; they
are not prerequisites for exercising the product.

### Required inputs

Resolve these from the caller before acting:

- approved requirements, scenarios, design, and task artifacts;
- caller-supplied implementation summary or completion evidence identifying delivered behavior;
- evidence output directory;
- unresolved-assumptions ledger path, when one exists;
- verification scope:
  - `full`;
  - `targeted`, naming the affected flows, directly dependent flows, a concise impact rationale, and
    prior full-pass evidence to retain; or
  - `evidence-only`, identifying prior flow evidence whose coverage revision exactly matches the
    current tracked contents.

Report missing source-of-truth artifacts or an unspecified evidence directory as findings that prevent
readiness. Do not infer product behavior from implementation alone. Use `full` when the caller does
not supply a scope or no trustworthy full-pass baseline exists. Use `evidence-only` only when no
tracked product contents changed after the recorded coverage revision; PR alignment, pushing the
already-tested commit, waiting for CI, or a Validator run that made no tracked change do not invalidate
flow evidence. When no assumptions-ledger path is supplied, use
`<evidence-directory>/acceptance-assumptions.md` and create it if needed. Keep this preparation
autonomous: preserve product, scope, or design ambiguity for the later human acceptance session
instead of asking the user here.

### Procedure

#### 1. Establish the test context

1. Read repository instructions, the approved artifacts, the unresolved-assumptions ledger, and the
   existing automated-validation evidence supplied by the caller.
2. Treat the code currently present in the checked-out worktree as the test target. Record local
   `HEAD` and tracked worktree status as context, but do not require a clean worktree or PR-head
   equality before exercising flows. Do not inspect or reconstruct a diff.
3. Use the project's normal setup, build, install, seed, and start commands when needed to expose the
   current worktree through its real public surface. These are test setup, not automated validation.
   Do not require an executable to embed a Git SHA, compare executable and commit timestamps, or infer
   source identity from a semantic version string.

#### 2. Exercise the product like a user

Derive a concise list of representative user or client flows from the approved artifacts and the
caller-supplied implementation evidence. Do not inspect a diff to discover behavior. A flow is a
meaningful journey or operation through a public surface, not an individual requirement scenario,
input permutation, internal branch, or automated-test case. Group equivalent variants and choose
typical data, configuration, and roles that demonstrate the delivered behavior.

- For `full` scope, exercise the representative flows that collectively cover the delivered user or
  client journeys and primary public surfaces. Do not turn every specification scenario into a
  separate manual case.
- For targeted scope, exercise only the affected flows and directly dependent flows named by the
  caller. Require an existing `<evidence-directory>/acceptance-flow-evidence.md` from a prior full
  pass, plus a rationale that bounds why flows outside the scope are unaffected; it may group them by
  surface or subsystem rather than enumerate them individually. Do not expand a targeted pass into a
  full pass merely because the revision changed. If the scope omits an obvious dependency or cannot
  be reconciled with the approved flow list, report the scope gap instead of silently guessing or
  rerunning everything.
- For `evidence-only` scope, do not exercise flows or replace screenshots. Require
  `acceptance-flow-evidence.md` to cover the representative flow inventory and identify a coverage revision whose
  tracked contents exactly match the current worktree. Continue directly to current-head CI and
  handoff collation. If contents changed or coverage is incomplete, reject evidence-only reuse and
  require a full or targeted scope from the caller.

Exercise the selected flows through the same public surface a real user or client would use.

- For a web, mobile, desktop, or terminal UI, navigate and operate it through its real interface.
- For an API, call it through its documented HTTP, SDK, or CLI surface as a client would. Record a
  sanitized request shape, response status and relevant response excerpt, plus observable side effects.
- For a CLI or library, invoke its public commands or API as a consumer would and retain representative
  input, output, and resulting state.
- For background behavior, trigger it through the normal entry point and inspect the user-visible or
  externally observable result.

Use typical representative data, configuration, and roles. Run only the setup and build commands
needed to expose the checked-out product for hands-on use. Do not run automated unit, integration, or
end-to-end suites, linters, or other automated validation commands; those belong to the caller. Do not
fuzz, try bizarre inputs, attempt to break the product, or build an exhaustive edge-case matrix. Test
an error, empty, boundary, or transient state only when it is an approved flow or necessary to complete
a normal flow.

For each selected flow, record the action, observed outcome, concise evidence, and any limitation. Verify the
resulting state instead of relying on task completion or agent assertions.

When one or more clear implementation defects appear, do not fix them. Continue through every
remaining in-scope flow that can still be exercised safely and independently; one finding alone is
not a reason to end the scoped pass. Stop early only when a defect makes the remaining in-scope flows
unreachable, unsafe, or incapable of producing trustworthy evidence. Record every unexercised
in-scope flow and the defect that blocked it.

After every pass, write or update `<evidence-directory>/acceptance-flow-evidence.md`. Record the
representative flow inventory, the current verification scope and rationale, and for each flow its most
recent tested SHA, outcome, evidence paths, and limitations. A full pass establishes the baseline. A
targeted pass replaces evidence for its selected flows and retains prior evidence for flows the caller
identified as unaffected, preserving the original SHA and provenance rather than relabeling it as
current-head evidence. Record the revision whose tracked contents this combined coverage supports.

Write `<evidence-directory>/acceptance-findings.md` with the tested SHA and all clear defects found,
including each affected flow, expected and observed behavior, concise reproduction steps, and evidence
paths. On a targeted pass, mark a prior finding resolved only when its affected flow is in scope and
the observed behavior now passes; retain other prior findings with their original status and SHA. Do
not wait for CI or write final acceptance evidence while a current finding remains. Report the
aggregated findings clearly so the caller can run its fix and validation process.

Append product, scope, or design ambiguity to the unresolved-assumptions ledger with the decision
needed and likely impact; never silently choose an interpretation or report ambiguity as a clear
defect. After a fix, require the caller to provide a new impact scope. Use a full pass only when the
change is broad, cross-cutting, or its impact cannot be bounded confidently.

#### 3. Capture visual evidence

For any UI—including web, mobile, desktop, and TUI—store screenshots under
`<evidence-directory>/acceptance-screenshots/` as the flows are exercised. Capture at least one
meaningful stable result for every in-scope UI flow, and more only when multiple states are needed to
understand that flow. Retain prior screenshots for out-of-scope flows with their original SHA and
provenance. Do not capture loading, empty, error, responsive, or before/after states unless they are
part of the flow being tested.

Record for every screenshot:

- flow demonstrated;
- expected behavior and what the reviewer should notice;
- route or command, representative input, and user role when relevant;
- tested head SHA;
- concise text equivalent.

Screenshots support the observed interaction; they are not proof on their own. For non-visual surfaces,
retain the corresponding client request/output evidence instead.

#### 4. Wait for current-head CI

Invoke `codagent:wait-ci` after the required full or targeted pass finds no clear defects, or after
evidence-only reuse is verified, and the tested worktree contents are clean, committed, and pushed.
This is the first point at which local `HEAD` and the PR head must match. After CI returns, immediately
re-read local `HEAD` and the PR `headRefOid`. Require the returned `head_sha`, current local `HEAD`,
and current PR head to be identical; otherwise report that final handoff evidence cannot yet be
produced. If tracked product contents change after flow testing, require a new caller-supplied impact
scope and run that verification before producing final evidence. A push that publishes already-tested
contents, PR alignment, or a no-change Validator run does not invalidate the pass.

- `passed`: continue.
- `failed` or `comments`: do not write final acceptance-test or handoff evidence or claim readiness.
  When the failure or comment is clearly attributable to the implementation and actionable in the
  repository, add it to `<evidence-directory>/acceptance-findings.md` with the tested SHA, failing
  check or comment, relevant log or link, and concise expected-versus-observed behavior. Report it as
  a clear defect so the caller can run its fix and validation process. Otherwise, report the external,
  environmental, or infrastructure blocker without classifying it as an implementation defect.
- `pending`: do not claim readiness. Report the pending checks and stop for the caller to resume or
  retry later.
- no configured checks: continue only after recording that CI coverage is absent.

Treat skipped, neutral, cancelled, stale, and timed-out checks as explicit evidence states, never as
proof that associated behavior passed.

#### 5. Write acceptance-test evidence

Write `acceptance-test.md` in the evidence directory only after CI passes or is explicitly absent, the
required verification makes no tracked changes, `acceptance-flow-evidence.md` covers the current
tracked contents, every representative flow has evidence from either the full baseline or a subsequent
targeted pass, and any automated-validation evidence supplied by the caller applies to the current
pushed head. Do not require automated-validation evidence when none was supplied; explicitly record
its absence instead. Include:

- exact current local/PR head SHA;
- the representative flows, their outcomes, most recent tested SHA, and whether evidence came from the
  full baseline or a targeted post-fix pass;
- the caller-supplied impact scope and rationale for retaining unaffected-flow evidence;
- clear-defect status and any prior fix evidence supplied by the caller;
- existing automated-validation and CI status without rerunning either, explicitly noting when
  automated-validation evidence was not supplied;
- screenshot metadata and text equivalents for every UI flow;
- representative API, CLI, library, or background-operation evidence for non-UI flows;
- unavailable flows, environment limitations, warnings, and residual risks;
- new unresolved assumptions added to the canonical ledger.

Prefer concise conclusions with durable log paths over raw log dumps.

#### 6. Prepare the human handoff

Collate existing implementation, acceptance-test, available automated-validation, and CI evidence. Do
not run new acceptance tests, capture replacement screenshots, or fix issues during collation. If
required evidence is missing or stale, stop and require the producing phase to run again. The explicit
absence of caller-supplied automated-validation evidence is not missing evidence.

Write `acceptance-handoff.md` in the evidence directory with:

1. **Decision brief** — unresolved decisions, delivered behavior, overall validation status, known
   limitations, and suggested human review path.
2. **Revision identity** — repository, PR URL, current head SHA, generation time, tracked worktree
   status, full-baseline SHA, and subsequent targeted-pass SHAs.
3. **Flow evidence** — each supported flow, what was done, the observed result, its evidence, most
   recent tested SHA, baseline or targeted provenance, and any limitation.
4. **Automated validation and CI** — concise status plus durable logs or links produced by separate
   validation and CI steps; explicitly say when automated-validation evidence was not supplied.
5. **Visual and client evidence** — screenshot metadata/text equivalents, API or CLI evidence, and
   practical human review instructions.
6. **Residual risk** — unavailable flows, environment limitations, warnings, and relevant omissions.
7. **Assumption handoff** — canonical ledger path plus a concise summary of every unresolved item.

#### 7. Verify readiness

Before reporting readiness:

1. Require a clean tracked worktree.
2. Require local `HEAD`, PR head, `acceptance-test.md`, and `acceptance-handoff.md` to name the same
   current revision. Require `acceptance-flow-evidence.md` to account for the representative flow inventory and
   preserve the actual SHA of every retained or refreshed observation.
3. Require CI evidence for that SHA to be passing, or explicitly record that no checks exist.
4. Verify every referenced evidence and screenshot path exists and every UI flow has visual evidence
   from the baseline or an applicable targeted pass.
5. Ensure persisted evidence does not expose secrets, credentials, tokens, private data, or unrelated
   user content.
6. Record the current PR state for the caller without changing it.

Use revision identity only to show that final CI and handoff evidence describe the code that was
tested and will be reviewed. Do not require or inspect embedded executable revision metadata.

Report the exact ready-for-acceptance SHA, PR URL, handoff path, unresolved-decision count, CI status,
and known limitations. Do not mark the PR ready or perform human acceptance. The caller owns any
machine-readable status file, terminal marker, or control-flow protocol.

### Out of scope

- Do not obtain human acceptance; leave that to the later human acceptance session.
- Do not fix implementation defects, modify tracked source or approved artifacts, commit, push, or
  alter PR metadata. Disposable or ignored setup and build outputs are allowed.
- Do not run automated test suites, linters, other automated checks, or automated validation; the
  caller owns validation and reinvocation. Setup and builds needed to use the product are allowed.
- Do not change approved requirements, product scope, or design to make tests pass.
- Do not archive the change, mark the PR ready, merge, or release.
- Do not perform fuzzing, adversarial testing, or exhaustive edge-case exploration.
- Do not treat successful task execution, agent summaries, or screenshots alone as proof of behavior.
