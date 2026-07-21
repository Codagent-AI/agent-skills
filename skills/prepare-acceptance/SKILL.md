---
description: Exercises an implemented change through its user and client flows, reports clear defects without fixing them, waits for current-head CI, and prepares concise evidence for human review when preparing a change for acceptance, gathering review evidence, performing human-style flow testing, or invoking codagent:prepare-acceptance.
---

## Prepare Acceptance

Prepare an implemented change for a separate human acceptance session. Exercise it as a human user or
real client would, report clear defects, wait for CI once no defects remain, and produce concise
evidence bound to the exact PR revision. Fixes and automated validation belong to separate
caller-managed steps when used.

### Required inputs

Resolve these from the caller before acting:

- approved requirements, scenarios, design, and task artifacts;
- caller-supplied implementation summary or completion evidence identifying delivered behavior;
- evidence output directory;
- unresolved-assumptions ledger path, when one exists.

Treat missing source-of-truth artifacts or an unspecified evidence directory as blockers. Do not infer
product behavior from implementation alone. When no assumptions-ledger path is supplied, use
`<evidence-directory>/acceptance-assumptions.md` and create it if needed. Keep this preparation
autonomous: preserve product, scope, or design ambiguity for the later human acceptance session
instead of asking the user here.

### Procedure

#### 1. Pin the tested revision

1. Read repository instructions, the approved artifacts, the unresolved-assumptions ledger, and the
   existing automated-validation evidence supplied by the caller.
2. Record local `HEAD` as the tested SHA and preserve it through the flow pass and CI wait. Read only
   the PR URL, current head SHA, and current PR state needed for the evidence record. Do not inspect or
   reconstruct a diff.
3. Require a clean tracked worktree and local `HEAD` equal to the PR head. If they do not match, stop
   for the caller to resolve; do not push or alter PR metadata in this skill.

#### 2. Exercise the product like a user

Derive a concise list of supported user or client flows only from the approved artifacts and the
caller-supplied implementation evidence. Do not inspect a diff to discover behavior. Exercise every
flow end to end through the same public surface a real user or client would use. A flow is a meaningful
journey or operation, not every input permutation.

- For a web, mobile, desktop, or terminal UI, navigate and operate it through its real interface.
- For an API, call it through its documented HTTP, SDK, or CLI surface as a client would. Record a
  sanitized request shape, response status and relevant response excerpt, plus observable side effects.
- For a CLI or library, invoke its public commands or API as a consumer would and retain representative
  input, output, and resulting state.
- For background behavior, trigger it through the normal entry point and inspect the user-visible or
  externally observable result.

Use typical representative data, configuration, and roles. Do not run automated unit, integration, or
end-to-end suites, linters, builds, or other automated validation commands; those belong to the caller.
Do not fuzz, try bizarre inputs, attempt to break the product, or build an exhaustive edge-case matrix.
Test an error, empty, boundary, or transient state only when it is an approved flow or necessary to
complete a normal flow.

For each flow, record the action, observed outcome, concise evidence, and any limitation. Verify the
resulting state instead of relying on task completion or agent assertions.

When one or more clear implementation defects appear, do not fix them. Continue through every
remaining flow that can still be exercised safely and independently; one finding alone is not a
reason to end the flow pass. Stop flow testing early only when a defect makes the remaining flows
unreachable, unsafe, or incapable of producing trustworthy evidence. Record every unexercised flow
and the defect that blocked it.

Write `<evidence-directory>/acceptance-findings.md` with the tested SHA and all clear defects found,
including each affected flow, expected and observed behavior, concise reproduction steps, and evidence
paths. Do not wait for CI or write final acceptance evidence in that invocation. Report the aggregated
findings clearly so the caller can run its fix and validation process.

Append product, scope, or design ambiguity to the unresolved-assumptions ledger with the decision
needed and likely impact; never silently choose an interpretation or report ambiguity as a clear
defect. Every invocation re-exercises all supported flows against the current committed `HEAD`; never
reuse results or screenshots from an earlier invocation.

#### 3. Capture visual evidence

For any UI—including web, mobile, desktop, and TUI—store screenshots under
`<evidence-directory>/acceptance-screenshots/` as the flows are exercised. Capture at least one
meaningful stable result for every UI flow, and more only when multiple states are needed to understand
that flow. Do not capture loading, empty, error, responsive, or before/after states unless they are part
of the flow being tested.

Record for every screenshot:

- flow demonstrated;
- expected behavior and what the reviewer should notice;
- route or command, representative input, and user role when relevant;
- tested head SHA;
- concise text equivalent.

Screenshots support the observed interaction; they are not proof on their own. For non-visual surfaces,
retain the corresponding client request/output evidence instead.

#### 4. Wait for current-head CI

Invoke `codagent:wait-ci` after a complete flow pass finds no clear defects and the final tested head is
pushed. After it returns, immediately re-read local `HEAD` and the PR `headRefOid`. Require the
preserved tested SHA, returned `head_sha`, current local `HEAD`, and current PR head to be identical;
otherwise stop and report the evidence as stale before writing acceptance-test or handoff evidence.

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
complete flow pass makes no tracked changes, and any automated-validation evidence supplied by the
caller applies to the current pushed head. Do not require automated-validation evidence when none was
supplied; explicitly record its absence instead. Include:

- exact tested local/PR head SHA;
- the supported flows exercised and their outcomes;
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
2. **Revision identity** — repository, PR URL, exact tested SHA, generation time, and tracked
   worktree status.
3. **Flow evidence** — each supported flow, what was done, the observed result, its evidence, and any
   limitation.
4. **Automated validation and CI** — concise status plus durable logs or links produced by separate
   validation and CI steps; explicitly say when automated-validation evidence was not supplied.
5. **Visual and client evidence** — screenshot metadata/text equivalents, API or CLI evidence, and
   practical human review instructions.
6. **Residual risk** — unavailable flows, environment limitations, warnings, and relevant omissions.
7. **Assumption handoff** — canonical ledger path plus a concise summary of every unresolved item.

#### 7. Verify readiness

Before reporting readiness:

1. Require a clean tracked worktree.
2. Require local `HEAD`, PR head, `acceptance-test.md`, and `acceptance-handoff.md` to name the same SHA.
3. Require CI evidence for that SHA to be passing, or explicitly record that no checks exist.
4. Verify every referenced evidence and screenshot path exists and every UI flow has visual evidence.
5. Ensure persisted evidence does not expose secrets, credentials, tokens, private data, or unrelated
   user content.
6. Record the current PR state for the caller without changing it.

Report the exact ready-for-acceptance SHA, PR URL, handoff path, unresolved-decision count, CI status,
and known limitations. Do not mark the PR ready or perform human acceptance. The caller owns any
machine-readable status file, terminal marker, or control-flow protocol.

### Out of scope

- Do not obtain human acceptance; leave that to the later human acceptance session.
- Do not fix implementation defects, modify repository files, commit, push, or alter PR metadata.
- Do not run automated test suites, linters, builds, other automated checks, or automated validation;
  the caller owns validation and reinvocation.
- Do not change approved requirements, product scope, or design to make tests pass.
- Do not archive the change, mark the PR ready, merge, or release.
- Do not perform fuzzing, adversarial testing, or exhaustive edge-case exploration.
- Do not treat successful task execution, agent summaries, or screenshots alone as proof of behavior.
