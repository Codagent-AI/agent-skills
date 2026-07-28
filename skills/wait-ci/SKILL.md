---
name: wait-ci
description: >
  Polls CI check status for the current branch's pull request and reports pass/fail/pending/comments,
  surfacing PR review comments even when CI is green.
  Use when the user says "wait for CI", "check CI", "poll CI", or invokes "codagent:wait-ci".
---

# codagent:wait-ci

Poll CI check status for the current branch's PR and report the result, enriching failures with log output and checking for blocking reviews.

Use the bundled scripts for all API calls — they encode the correct field names, jq patterns, and GraphQL queries. Do not rewrite API calls inline.

> **NEVER pause to ask the user for permission to wait.** Always run the full polling duration silently. Asking mid-execution breaks automation and is never needed — the caller already decided to invoke this skill.

## How polling works

`check-ci.sh` is a **single-invocation** script. It polls every 10 seconds for up to 90 seconds, then exits. Claude calls it in a loop to cover the full max wait time. This keeps each Bash call bounded to ~2 minutes rather than blocking the agent for the full duration.

Each Bash call to `check-ci.sh` **must** use `timeout: 120000` (2 minutes).

## Steps

### 1. Run the polling loop

Compute `max_runs = ceil(max_minutes * 60 / 90)`, defaulting to `max_minutes = 15` → 10 runs.

The skill accepts an optional `--max-minutes N` argument; pass it through to adjust `max_runs`.

Track `ever_had_checks = false`, `run = 0`, and the overall deadline across iterations. The deadline is `max_minutes` after polling starts and also bounds any review-bot waiting in Step 3.

For each run:

```bash
bash skills/wait-ci/scripts/check-ci.sh
```

Use **`timeout: 120000`** on the Bash call. Check the exit code:

| Exit code | Meaning | Action |
|---|---|---|
| `0` | Terminal (`passed` or `failed`) | Break out of loop, proceed to Step 2 |
| `2` | Not yet terminal (`pending` or `no_checks`) | If `run < max_runs`, re-run; else report timeout |
| `1` | Fatal error | Report error and stop |

After each exit-2 result, set `ever_had_checks = ever_had_checks OR result.had_checks`.

**Timeout handling:** When all runs are exhausted (exit code 2 on the last run):
- If `ever_had_checks` is false → treat CI as non-blocking, then still run Step 3 before reporting a final status
- Otherwise → report `pending` with the list of still-running checks

The script outputs a JSON object with these fields:

| Field | Type | Description |
|---|---|---|
| `status` | string | `passed`, `failed`, `pending`, `no_checks`, or `comments` (set by caller) |
| `pr_url` | string | PR URL |
| `pr_number` | number | PR number |
| `head_sha` | string | PR head commit queried for this invocation; preserve it when upgrading the status to `comments` |
| `owner` / `repo` | string | Repo coordinates for subsequent calls |
| `had_checks` | bool | Whether any checks were seen on this invocation |
| `failed_checks` | array | Checks with `bucket == "fail"` |
| `passed_checks` | array | Checks with `bucket == "pass"` |
| `pending_checks` | array | Checks still running |
| `blocking_reviews` | array | Reviews with `CHANGES_REQUESTED` (latest per reviewer) |
| `failed_run_ids` | array | GitHub Actions run IDs extracted from failed check links |

### 2. Fetch failure logs (if `status == "failed"`)

For each run ID in `failed_run_ids`:

```bash
gh run view <run-id> --log-failed
```

Keep the last 100 lines if output is longer. External checks (no run ID) get no logs.

### 3. Gather PR comments (when checks are terminal or no checks exist)

```bash
bash skills/wait-ci/scripts/get-pr-comments.sh <owner> <repo> <pr-number> [<pr-author-login>]
```

Uses GraphQL to check `isResolved` on review threads directly — no jq `!=` workarounds needed.

Output fields:

| Field | Type | Description |
|---|---|---|
| `has_comments` | bool | True if any unaddressed comments exist |
| `unresolved_threads` | array | `{file, line, author, body}` per unresolved review thread |
| `issue_comments` | array | `{author, body}` blocking top-level human comments (excluding PR creator) |
| `informational_bot_comments` | array | `{author, body}` non-blocking top-level bot comments retained as evidence |

Unresolved review threads are blocking regardless of author. Top-level bot comments do not set `has_comments`; only unresolved threads and human top-level comments do.

After checks are terminal, inspect `informational_bot_comments`. If a bot explicitly reports that its review is pending or in progress, or asks the caller to check back, wait 10 seconds and call `get-pr-comments.sh` again while time remains before the overall deadline. Re-evaluate the latest evidence on every poll. Do not hard-code bot vendors or exact phrases; use the comment's meaning. A terminal current-head check from that bot supersedes an older progress notice. Completed summaries and ordinary status notices remain informational and do not delay completion.

At the overall deadline, use this precedence:

1. `failed` for failed checks or blocking reviews.
2. `comments` when actionable unresolved feedback exists, even if a review bot is still unfinished.
3. `pending` when checks or a review bot remain unfinished and no actionable feedback exists.
4. `passed` when CI is green or explicitly absent, no actionable feedback exists, and no review bot remains unfinished.

Preserve unfinished bot notices in the report even when actionable feedback makes the status `comments`. Never extend the overall deadline while waiting for review bots.

**Status upgrade:** If checks returned `passed` but `get-pr-comments.sh` returns `has_comments: true`, report the final status as `comments`.

**No-checks handling:** If polling timed out with no checks ever observed, run `get-pr-comments.sh` before reporting success. Report `comments` when `has_comments` is true; otherwise report `passed`.

## Output Format

```markdown
## CI Status: <passed | failed | pending | comments>

**PR:** <url>
**Elapsed:** ~<N> minutes

### Failed Checks
- **<check-name>** (FAILURE)
  Link: <details-url>
  Logs:
  ```
  <log output>
  ```

### Blocking Reviews
- **<reviewer>**: <review body>

### PR Comments
- **<author>** on `<file>` line <N>: <comment body>
- **<author>** (issue comment): <comment body>

### Informational Bot Comments
- **<author>**: <comment body>

### Passing Checks
- <check-name> (SUCCESS)

### Still Running
- <check-name> (PENDING/IN_PROGRESS)
```

Status meanings:
- `passed` — CI green, no blocking reviews or comments, and no bot review still in progress
- `failed` — CI failures or `CHANGES_REQUESTED` reviews (with logs)
- `comments` — CI green but unresolved PR comments need addressing; known actionable feedback takes precedence over unfinished review automation
- `pending` — checks or an explicitly unfinished bot review remain after max wait, with no actionable feedback available

## Notes

- Can be invoked standalone without prior workflow state
- Default: 10 runs × 90 seconds = ~15 minutes max wait; pass `--max-minutes N` to override
- **Never ask the user for permission mid-execution** — always run the full duration
- `CHANGES_REQUESTED` is a hard block; `APPROVED` and `COMMENTED` alone do not block
- Comment gathering runs after checks complete — bots post comments as part of their check, so they're available once the check finishes
- Log enrichment only works for GitHub Actions checks (not external status checks)

## Scripts Reference

| Script | Purpose |
|---|---|
| `scripts/check-ci.sh` | Single-invocation poller (90s, 10s interval) — call in a loop from the skill |
| `scripts/get-pr-comments.sh` | GraphQL comment fetcher — returns blocking review feedback and informational bot comments |
