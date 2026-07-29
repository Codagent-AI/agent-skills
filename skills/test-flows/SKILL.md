---
description: Exercises a small or branch-local software change through representative public user or client flows and reports concise observed evidence, defects, ambiguities, and limitations without fixing code, running automated suites, requiring a PR, or preparing formal acceptance; use for lightweight manual-style testing, smoke testing a completed change, or targeted verification after a small fix.
---

# Test Flows

Exercise the checked-out product as a user or real client would. This is a lightweight flow check, not
automated validation or formal acceptance preparation.

## Inputs

Read the caller-supplied:

- approved behavior or planning artifacts;
- concise implementation summary;
- verification scope: representative full pass or named targeted flows;
- evidence directory when the selected scope includes UI flows or durable evidence is requested.

If expected behavior is unavailable, report what is missing instead of inferring the contract from
implementation alone.
If a selected UI flow has no evidence directory, report the missing input instead of testing that
flow without its required screenshot.

## Select flows

For a representative full pass, identify the meaningful changed journeys and public surfaces that
collectively demonstrate the delivered behavior. When an approved test plan exists, exercise its
required and activated conditional `AT-*` flows. Otherwise keep the inventory proportional to the
small change rather than replaying every requirement scenario or input variation.

For targeted verification, exercise the named affected flows and obvious direct dependencies. Verify
the prior finding first. Do not start a new broad review or search unrelated surfaces for additional
issues.

Use typical data, configuration, and roles. Do not fuzz, try bizarre inputs, or build an exhaustive
edge-case matrix. Test an error or boundary state only when it belongs to a normal selected flow.

## Exercise the public surface

Use the project's normal setup, build, install, seed, and start commands needed to expose the current
worktree. Do not run automated unit, integration, or end-to-end suites, linters, Validator, or CI.

- Operate web, mobile, desktop, and terminal UIs through their real interface.
- Call APIs through their documented HTTP, SDK, or CLI surface as a client would.
- Invoke CLIs and libraries through their public commands or APIs.
- Trigger background behavior through its normal entry point and inspect the observable result.

For each selected flow, verify resulting state rather than trusting an agent assertion or successful
command exit. Continue through independently testable flows after finding a defect; stop only when the
problem makes remaining flows unreachable, unsafe, or untrustworthy.

For any tested UI flow, capture a meaningful stable screenshot under the caller's evidence directory.
Capture more than one only when multiple states are necessary to understand the flow. Record what the
reviewer should notice and a concise text equivalent. For non-visual surfaces, retain a sanitized
request/output excerpt or comparable client-visible evidence.

## Report

Return a concise report containing:

- checked-out `HEAD` as context;
- each selected flow, action, expected result, observed result, and evidence;
- clear defects with reproduction steps and affected flows;
- product, scope, or design ambiguity separated from defects;
- untested or blocked flows and practical limitations.

Write the same report to a caller-specified path when requested. Do not create status markers or
machine-control files.

Do not fix defects, modify approved artifacts, commit, push, wait for CI, inspect PR state, or claim
human acceptance. The caller decides how findings are handled and whether targeted verification is
needed after a fix.
