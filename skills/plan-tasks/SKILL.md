---
description: Creates a structured implementation task breakdown for a structured change, synthesizing proposal, design, and specs into self-contained per-task files. Use when the tasks artifact is the next step in a change.
---

# Plan Tasks

## Overview

Write a structured task breakdown for a structured change. Each task gets its own self-contained file containing everything a subagent needs — the relevant "why" from the proposal, the relevant "how" from the design, and the exact spec scenario(s) copied in verbatim.

Assume the implementing subagent is a skilled developer with zero context about this codebase, this decision history, or this feature — they won't know which files to touch, what conventions we've settled on, or why a particular approach was chosen unless you tell them. Give them everything they need — and only what they need — for their specific task. DRY. YAGNI. No line-by-line implementation instructions; describe what to build and the constraints that matter, not how to write each line.

**Announce at start:** "I'm using the plan-tasks skill to create the task breakdown."

---

## 1. Read Your Inputs

The following are provided:
- The change directory where all output goes (e.g. `changes/<name>/`)
- Completed artifact files — `proposal.md`, `design.md`, and all `specs/**/*.md`

Read all artifact files before proceeding. Skip any you wrote earlier in this session — you already have that context.

---

## 2. Research the Codebase

Skip areas you already explored in earlier steps of this session. Focus on what's new or what you need to look at more closely for task planning. You need to understand:
- Which specific files and modules will be touched by the change (use the design's Approach section to guide where to look)
- Current structure, interfaces, and conventions in those files that the implementation must follow
- Whether any of the affected code is tangled or poorly abstracted enough that the new work would be significantly harder to implement as-is
- Whether any existing documentation (README, guides, config references, etc.) covering the affected areas will need updating

---

## 3. Plan the Task Breakdown

Decide the change's overall implementation effort first, then identify the delivery units that fit that size. Do not derive task count from the number of requirements, scenarios, design sections, affected files, or architectural layers.

### Estimate whole-change LOE

Estimate the change independently before drafting or counting candidate task boundaries. Base the estimate on the amount of novel implementation, uncertainty, architectural reach, platform or provider breadth, migration and cutover risk, and verification burden. Discount repeated or mechanical propagation through files, UI surfaces, adapters, docs, and tests. Do not use a preliminary outcome count to choose the size; that makes the task-count cross-check circular.

Use this t-shirt scale as a task-count budget:

| LOE | Preferred task count | Calibration |
| --- | ---: | --- |
| Small | exactly 1 | A routine, cohesive change using established patterns with limited uncertainty, even when it propagates through many surfaces or files. |
| Medium | exactly 2 | A substantial feature or refactor with a meaningful contract change, migration, or second implementation-sized risk cluster. |
| Large | 3–4 | A major subsystem change with high novelty or uncertainty, platform/provider integration breadth, a production transition, or extensive verification. Prefer 3 unless the fourth boundary is strong. |
| XL | 5+ | A program-scale change spanning multiple major subsystems or product capabilities, each with substantial implementation and verification. A difficult replacement of one subsystem is usually Large, not XL. Start at 5; every task beyond 5 needs its own clear boundary. |

Choose the smallest size whose implementation-risk profile fits, without looking ahead to the task count you want. The preferred granularity is deliberately dense. A change touching many files and several specs can still be Small when the work is patterned and low-risk. Conversely, one cohesive architectural outcome can be Large when it replaces a core subsystem or carries substantial platform, integration, cutover, and verification risk. Treat XL as exceptional, not as a synonym for a difficult Large change.

Only after completing this unbiased implementation-effort estimate and selecting the size band, decide whether any restructuring identified in Step 2 warrants a standalone refactoring task. Prepend one in Step 5 only when implementation would otherwise require working around serious structural obstacles. Use it to restructure existing code without changing behavior so the feature work lands cleanly. When in doubt, skip it; the implementing subagent can refactor inline. Treat necessary restructuring effort as part of the whole-change LOE, but do not let a preliminary refactoring-task decision influence size selection. If a standalone refactoring task is warranted, allocate it within the selected size band and task-count budget; never add it later as an unbudgeted extra task.

For a Medium, Large, or XL estimate—or whenever provider, migration, feasibility, cutover, or cleanup boundaries are ambiguous—read [references/task-sizing.md](references/task-sizing.md) before drafting task boundaries. Apply its calibration and boundary rules as required guidance, not optional examples.

### Form delivery units within the budget

**1 task = 1 meaningful outcome a skilled agent can implement, test, and review in one focused session.** A focused session may cover a broad repo-wide vertical slice when the task points to the design and specs. It is not a TDD micro-step, one architectural layer, one spec requirement, one UI surface, one adapter, or one file group.

Apply these rules:

1. **Group by delivered outcome** — include all layers needed to make one capability work. Keep config with its consumer, schema with the behavior that needs it, UI with its backing logic, and tests with implementation.
2. **Split on outcome and risk boundaries, not surface area** — use a separate task only when the work has independently meaningful value, a distinct risk or cutover point, or a genuine sequencing boundary. Multiple UI screens, providers, or files increase LOE but do not automatically create tasks.
3. **Assume a generalist implementer** — crossing backend, frontend, config, CLI, docs, or tests is not itself a reason to split. Split for genuinely different work, not different file types.
4. **Fold enabling work forward** — scaffolding, refactors, dependency changes, and infrastructure belong in the task that first exercises them unless they are independently risky and review-worthy.
5. **Run the merge test** — if two candidates would normally land in one PR, neither is useful without the other, or one merely prepares for the next, merge them.

Keep all plumbing for one capability together. In particular, do not split:

- a setting's persistence and validation from the runtime behavior it controls;
- editor and setup surfaces from the setting they expose or from the runtime routing/enforcement that makes the setting effective;
- adapter-specific implementations of the same behavior from their shared contract;
- tests, docs, migrations, or refactors from the outcome that requires them.

### Cross-check the count

After drafting candidate boundaries, compare the count with the independent LOE budget:

1. If the count is above the band, merge the most coupled candidates until it fits.
2. If a task contains multiple cohesive outcomes, split it and raise the whole-change LOE if necessary. Do not split merely because one outcome is broad.
3. If the count is below the band's minimum, re-check the LOE; do not manufacture a task merely to satisfy an inflated estimate.
4. Within a range, choose the lower count unless an additional boundary is concrete and implementation-significant.
5. For every task after the first, state internally why it cannot be folded into another task. If the answer is only "different requirement," "different layer," "different UI," "many adapters," "cleaner organization," "a lot of work," or "easier to track," merge it.

Once the cross-check passes, proceed autonomously to writing the task files. Do not present the breakdown for approval, ask the user to choose a count, or pause for confirmation. Resolve ordinary grouping uncertainty with best judgment; stop only if the source artifacts contain a contradiction that makes the implementation itself unsafe to plan.

### Task Splitting Examples and Anti-patterns

The following examples elaborate on how to apply these rules to avoid inappropriate splitting (particularly concerning infrastructure and vertical slices):

Good examples (proper delivery units):
- "Add CSV export: ExportService, POST /exports endpoint, permission checks, and size limits"
- "Add rate limiting and audit logging to the export endpoint"
- "Add user notification preferences: API, persistence, and application to outgoing notifications"

Bad examples (same feature, split too finely):
- "Set up the database schema and middleware that the export endpoint will need later" (infrastructure without testable behavioral value; fold it into the endpoint task)
- "Add the ExportService class" (part of a delivery unit that also includes the endpoint and permissions)
- "Wire the new export endpoint into the router with auth middleware" (one step inside a larger delivery unit)
- "Write integration tests covering the Successful Export and Permission Denied scenarios" (tests ship with the feature, not as a separate task)

For small changes, a single task is fine. Don't manufacture fake granularity.

**Anti-pattern: "Laying the groundwork"**. Infrastructure that exists purely to enable another task (e.g., "Set up the validator infra that Task 2 needs," "Add the module skeleton") should be folded into that dependent task. If a task produces no testable behavioral value of its own, it is a sign it should be merged into the task that actually exercises it. The exception is database migrations or dependency changes risky enough to review on their own.

**Anti-pattern: Separate doc-update tasks.** Don't create standalone tasks for documentation updates (README, guides, license files, etc.) when the docs are part of the same change as code or config. Update docs in the same task that introduces the related functionality. Only split docs into their own task when the documentation work is substantial and independent of any code change (e.g., a docs-only change).

**Litmus test for infrastructure/config-only changes:** If all files being created/modified are prompt files, config files, skill definitions, or other non-compiled artifacts (no application code with runtime behavior), the entire change is likely one task. Prompt/config changes don't have the layer boundaries that justify splitting — they're all "infrastructure" in the same sense. Only split when tasks produce independently valuable, releasable functionality.

## 4. Write Task Files

For each task you identified, write a self-contained task file in `tasks/`. Write them all before moving on to ordering.

**Filename format**:
- Single-task changes: use `<slug>.md`, where `slug` is a 2–4 word kebab-case summary (e.g., `package-as-plugin`).
- Multi-task changes: use a temporary descriptive filename while drafting if needed, but after Step 5 every task file MUST be named `<NN>-<slug>.md`, where `NN` is a zero-padded execution-order prefix (`01`, `02`, ...). The runner executes task files by sorted glob order, so these prefixes are what make execution match `tasks.md`.

**slug**: 2–4 word kebab-case summary (e.g., `export-service-endpoint`, `rate-limiting-audit-log`). Do not choose slugs whose alphabetical order is meant to imply execution order; the numeric prefix is the ordering mechanism.

### Single-task changes

When the entire change is one task, reference the design and spec docs by path rather than duplicating them. No `## Spec` section needed. The task file needs **Goal**, **Background**, and **Done When**.

In Background, list every file the implementer MUST read using exact relative paths. Do NOT use globs or vague references like "See `specs/`" — if a file isn't listed, it won't be read.

**Example:**
```markdown
# Task: Package as Plugin

## Goal

Restructure the repository as a Claude Code plugin with skills, schema, init scaffolding, and documentation.

## Background

You MUST read these files before starting:
- `design.md` for full design details
- `specs/plugin-packaging/spec.md` for plugin structure and init skill acceptance criteria
- `specs/skill-decoupling/spec.md` for skill decoupling acceptance criteria

The proposal motivation is <brief "why" context if helpful>.

## Done When

All spec scenarios pass review. The plugin installs and skills are invocable.
```

### Multi-task file format

```markdown
# Task: <Title>

## Goal

<1–3 sentences. What does this task accomplish, and why does it exist?>

## Background

<What the implementing agent needs to know to make good decisions. Pull from
proposal.md and design.md — quote or paraphrase the relevant parts. Include:
- The specific design decisions that govern this task (state the decision itself, never use arbitrary numbering like "Decision 4")
- Key files, modules, or APIs involved
- Constraints or conventions to follow
- Anything that would surprise a skilled engineer unfamiliar with the codebase>

**Strictly self-contained:** Do NOT reference other tasks (e.g., "built in Task 2" or "required by Task 5"). Tasks operate in total isolation; the agent executing this task won't know those exist.

Do NOT include background that doesn't affect this task.

## Spec

<Copy the relevant spec requirement(s) and scenario(s) verbatim from the spec files.
These are the acceptance criteria. Every scenario is a test case.>

### Requirement: <name>
<requirement text>

#### Scenario: <name>
- **WHEN** <condition>
- **THEN** <expected outcome>

#### Scenario: <name>
- **WHEN** <condition>
- **THEN** <expected outcome>

<!-- Add as many scenarios as the requirement has -->

## Done When

<Completion criterion — one or two sentences. Usually: "Tests covering the above
scenarios pass" plus any concrete signal (e.g., "the CLI command works end-to-end").>
```

### How spec scenarios map to tasks

Spec scenarios describe *behavior from the outside*. Tasks describe *work from the inside*. The mapping is rarely 1:1.

**Multiple scenarios → one task (most common).** Scenarios that are variations on the same behavioral unit — happy path, edge cases, error cases — belong in one task. Copy all of them into the task's `## Spec` section.

**One scenario → multiple tasks (cross-layer, uncommon).** A single scenario can span multiple tasks (backend service task + API task + frontend task). Include the full scenario in every task that contributes to it, with a note:

> Note: This task covers the backend portion. These scenarios become fully verifiable end-to-end once the frontend task is also complete.

**No spec section (pure infrastructure, very uncommon).** A task may omit `## Spec` only if the work is invisible to end-users and untestable at the behavioral level (e.g., a database migration). If you're tempted to write a task with no scenarios, ask: *is this genuinely infrastructure, or did I fail to identify which scenario it serves?* The latter is a decomposition mistake.

---

## 5. Order Tasks

Now that all task files exist, decide their sequence.

Order tasks so each one is ready to start when the previous finishes. A task is ready when everything it depends on already exists. Don't invent ordering to make the list feel structured — if two tasks have no dependency on each other, order doesn't matter; put the one that unblocks more work first.

For multi-task changes, rename every task file now so its filename starts with its execution-order prefix: `01-<slug>.md`, `02-<slug>.md`, and so on. If there are 10 or more tasks, keep all prefixes the same width (`01` through `10`, or `001` through `100`) so lexical sort order remains execution order.

**If you decided during the Step 3 LOE flow that refactoring is needed**, prepend it as the first task now. Write its task file (`01-refactor-<slug>.md` for multi-task changes, or `refactor-<slug>.md` for a single-task change) using the same format, describing what structural changes are needed and why, with a `## Done When` stating the code is restructured and all existing tests still pass. Renumber the remaining multi-task files after prepending it.

---

## 6. Write tasks.md

With ordering settled, write the task index at `<change-dir>/tasks.md` (i.e., in the change directory from Step 1) using the Artifact Template below.

## Artifact Template

```markdown
- [ ] <Task title> (`tasks/01-<slug>.md`)
- [ ] <Task title> (`tasks/02-<slug>.md`)
```

One checkbox line per task, in execution order. The parenthesized path links to the detailed task file. The applying agent marks tasks complete by changing `[ ]` to `[x]`.

---

## 7. Report and Exit

Exit cleanly. Do not ask about execution mode. Do not invoke other skills. This skill does not invoke other skills or manage sequencing.

Show a brief summary:
- How many task files were created and their titles
- The path to tasks.md
- What's now unlocked

---

## Example: Decomposing a Feature into Tasks

This example shows how 5 spec requirements map to 2 tasks — not 5.

### The specs (summary)

The CSV export feature has 5 requirements:

- **User can export their data** — 3 scenarios: successful export, empty dataset, field selection
- **Export respects permissions** — 3 scenarios: own data allowed, other user's data 403, admin bypass
- **Export enforces size limits** — 2 scenarios: within limit proceeds, oversized request rejected with 400
- **Export is rate-limited** — 2 scenarios: within rate limit proceeds, exceeded returns 429
- **Export is audit-logged** — 2 scenarios: successful export logged with user + timestamp, denied attempt logged

### The decomposition

Requirements 1–3 (export logic, permissions, size limits) all live in the `ExportService` class and the `POST /exports` endpoint. They're tightly coupled: permissions are checked at service entry, size limits validated before the query runs, and the streaming response is one code path. Shipping these three together delivers a working, permission-aware, size-bounded export API that is independently releasable.

Requirements 4–5 (rate limiting, audit logging) are cross-cutting concerns layered on top: rate limiting via middleware wrapping the endpoint, audit logging via a separate write to the audit log table. They touch different parts of the codebase, are independently review-worthy, and can ship after the core is stable.

**Result: 2 tasks.**

### tasks.md

```markdown
- [ ] ExportService + POST /exports endpoint (`tasks/01-export-service-endpoint.md`)
- [ ] Rate limiting and audit logging (`tasks/02-rate-limiting-audit-log.md`)
```

### Task 1 file

```markdown
# Task: ExportService + POST /exports endpoint

## Goal

Implement the ExportService class and the POST /exports API endpoint. This delivers the
core of the export feature: querying a user's data, serializing it as CSV, streaming the
response, enforcing permissions, and rejecting oversized requests.

## Background

ExportService is a standalone class (not middleware) that takes a `userId` and
`ExportOptions`, queries through `UserRepository`, and returns a `ReadableStream<string>`.
It must stream — do not buffer the full dataset in memory.

The POST /exports endpoint is a new Express route in `src/routes/exports.ts`. It
authenticates via the existing `requireAuth` middleware, calls ExportService, and pipes
the stream to the response with `Content-Type: text/csv`.

**Key files:**
- `src/services/ExportService.ts` — create here, following the pattern in UserService.ts
- `src/repositories/UserRepository.ts` — query through this; do not bypass
- `src/routes/exports.ts` — create new route file, register in src/routes/index.ts
- `src/types/export.ts` — create ExportOptions type here

**Constraints:**
- CSV serialization: use `csv-stringify` (already in package.json, not a new dependency)
- Null/undefined field values: emit empty string, not the string "null"
- Column order: match the order defined in ExportOptions.fields
- Permissions: ExportService enforces them — the route does not need separate checks
- Size limit: reject before running the query (use COUNT first, return 400 if > 100k rows)

## Spec

### Requirement: User can export their data
The system SHALL allow users to export their personal data in CSV format.

#### Scenario: Successful export
- **WHEN** user requests an export with valid options
- **THEN** system returns a 200 response with Content-Type text/csv, a header row, and one data row per record

#### Scenario: Empty dataset
- **WHEN** user has no data records
- **THEN** system returns a 200 response with a CSV containing only the header row (no error)

#### Scenario: Field selection
- **WHEN** user specifies a subset of fields in ExportOptions.fields
- **THEN** CSV contains only the selected columns in the specified order

### Requirement: Export respects permissions
The system SHALL enforce that users can only export their own data, with an exception for admins.

#### Scenario: User exports own data
- **WHEN** the authenticated user requests an export for their own userId
- **THEN** the export proceeds normally

#### Scenario: User requests another user's data
- **WHEN** the authenticated user requests an export for a different userId
- **THEN** the system returns 403 Forbidden without running the query

#### Scenario: Admin exports any user's data
- **WHEN** an authenticated admin requests an export for any userId
- **THEN** the export proceeds normally

### Requirement: Export enforces size limits
The system SHALL reject export requests that would return more than 100,000 rows.

#### Scenario: Export within row limit
- **WHEN** the user's dataset has 100,000 rows or fewer
- **THEN** the export proceeds normally

#### Scenario: Export exceeds row limit
- **WHEN** the user's dataset has more than 100,000 rows
- **THEN** the system returns 400 with a message indicating the row count and the limit

## Done When

All eight scenarios above are covered by tests and passing. The POST /exports route is
registered and reachable. ExportService can be instantiated and called in isolation.
```

### Task 2 file

```markdown
# Task: Rate limiting and audit logging

## Goal

Add rate limiting to the POST /exports endpoint and write an audit log entry for every
export attempt (successful or denied).

## Background

Rate limiting is a per-user limit: 10 export requests per hour. Use the `express-rate-limit`
package already in package.json. Configure it as middleware on the exports router, keyed
by `req.user.id`. Do not use the default IP-based keying.

Audit logging records export attempts to the existing `audit_log` table via `AuditService`.
Log both successful exports and 403 denials — not 400 size errors (those are client mistakes,
not security events). The log entry must include: userId (requester), targetUserId, outcome
(allowed/denied), timestamp, and ExportOptions.fields.

**Key files:**
- `src/routes/exports.ts` — add rate limiting middleware to the existing route
- `src/services/ExportService.ts` — add audit log write at permission enforcement point
- `src/services/AuditService.ts` — existing service, use the `log(entry)` method
- `src/db/schema.ts` — `audit_log` table schema is already defined, no migration needed

**Constraints:**
- Rate limit response: 429 with `Retry-After` header set to the window reset time
- Audit log writes are fire-and-forget — do not await them on the request path
- Do not audit 400 size rejections (those happen before permission checks)

## Spec

### Requirement: Export is rate-limited
The system SHALL limit each user to 10 export requests per hour.

#### Scenario: Request within rate limit
- **WHEN** the user has made fewer than 10 export requests in the past hour
- **THEN** the request proceeds normally

#### Scenario: Rate limit exceeded
- **WHEN** the user has made 10 or more export requests in the past hour
- **THEN** the system returns 429 Too Many Requests with a Retry-After header

### Requirement: Export attempts are audit-logged
The system SHALL record an audit log entry for every export attempt that reaches the
permission check, regardless of outcome.

#### Scenario: Successful export logged
- **WHEN** an export request is permitted and the export runs
- **THEN** an audit log entry is written with outcome=allowed, requester userId, target userId, fields, and timestamp

#### Scenario: Denied export logged
- **WHEN** an export request is rejected with 403
- **THEN** an audit log entry is written with outcome=denied, requester userId, target userId, and timestamp

## Done When

All four scenarios above are covered by tests and passing. Rate limiting is active on the
POST /exports endpoint and keyed per user. Audit log entries are written for permitted and
denied requests but not for 400 or 429 responses.
```

---

## Key Principles

- **Copy spec scenarios verbatim** — don't paraphrase; copy them exactly so they serve directly as test cases
- **Exact file paths** — always use real paths from the codebase, not placeholders like `src/your-service.ts`
- **No unresolved placeholders** — if the design document contains instructional placeholders (e.g., `<path to the task file>`), do not copy them verbatim. You must resolve them to their actual values or describe them in prose. Never leak `<...>` placeholder syntax into the task file.
- **Estimate LOE before task count** — use implementation effort to choose the size band, then fit outcome-based delivery units within it
- **Autonomous tasking** — make grouping and sequencing decisions from the artifacts and codebase, write the files, and report the result without an approval gate
- **Task filenames preserve order** — multi-task filenames must have numeric prefixes so sorted glob execution follows the same order as `tasks.md`

## Never

- Never ask the user to approve, split, or combine the task breakdown before writing it.
- Never equate requirements, scenarios, design sections, layers, or file groups with tasks.
- Never add a task solely for tests, docs, scaffolding, plumbing, or "laying the groundwork" when that work belongs to a delivered outcome.
