---
description: >
  Polls CI check status for the current branch's pull request and reports pass/fail/pending/comments,
  surfacing PR review comments even when CI is green.
  Use when the user says "wait for CI", "check CI", "poll CI", or invokes "flokay:wait-ci".
allowed-tools: Bash
---

# flokay:wait-ci

Poll CI check status for the current branch's PR and report the result, enriching failures with log output and checking for blocking reviews.

Use the bundled scripts for all API calls — they encode the correct field names, jq patterns, and GraphQL queries. Do not rewrite API calls inline.

> **NEVER pause to ask the user for permission to wait.** Always run the full polling duration silently. Asking mid-execution breaks automation and is never needed — the caller already decided to invoke this skill.

## Steps

### 1. Run the CI poller

```bash
bash skills/wait-ci/scripts/poll-ci.sh [--max-minutes N] [--interval SECONDS]
```

Options: `--max-minutes N` (default 15) · `--interval SECONDS` (default 60)

The skill accepts an optional `--max-minutes` argument, e.g. `flokay:wait-ci --max-minutes 20`. Pass it through to the script. Do not ask for permission to wait — run silently until the time expires or a terminal result is reached.

The script outputs a JSON object with these fields:

| Field | Type | Description |
|---|---|---|
| `status` | string | `passed`, `failed`, `pending` (timeout), `comments` (set by caller after comment check) |
| `pr_url` | string | PR URL |
| `pr_number` | number | PR number |
| `owner` / `repo` | string | Repo coordinates for subsequent calls |
| `elapsed_minutes` | number | Time spent polling |
| `failed_checks` | array | Checks with `bucket == "fail"` |
| `passed_checks` | array | Checks with `bucket == "pass"` |
| `pending_checks` | array | Checks still running (timeout case) |
| `blocking_reviews` | array | Reviews with `CHANGES_REQUESTED` (latest per reviewer) |
| `failed_run_ids` | array | GitHub Actions run IDs extracted from failed check links |

Exit code 0 = terminal result (passed/failed). Exit code 1 = timeout.

### 2. Fetch failure logs (if `status == "failed"`)

For each run ID in `failed_run_ids`:

```bash
gh run view <run-id> --log-failed
```

Keep the last 100 lines if output is longer. External checks (no run ID) get no logs.

### 3. Gather PR comments (when checks are terminal)

```bash
bash skills/wait-ci/scripts/get-pr-comments.sh <owner> <repo> <pr-number> [<pr-author-login>]
```

The script uses GraphQL to check `isResolved` on review threads directly — no jq `!=` workarounds needed.

Output fields:

| Field | Type | Description |
|---|---|---|
| `has_comments` | bool | True if any unaddressed comments exist |
| `unresolved_threads` | array | `{file, line, author, body}` per unresolved review thread |
| `issue_comments` | array | `{author, body}` top-level PR comments (excluding PR creator) |

**Status upgrade:** If `poll-ci.sh` returned `passed` but `get-pr-comments.sh` returns `has_comments: true`, report the final status as `comments`.

### 4. Handle timeout

If `poll-ci.sh` exits 1 (timed out): report `pending`, list which checks are still running, and stop. Do not re-poll. Do not ask the user whether to wait longer — just report the timeout and return.

## Output Format

```markdown
## CI Status: <passed | failed | pending | comments>

**PR:** <url>
**Elapsed:** <N> minutes

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

### Passing Checks
- <check-name> (SUCCESS)

### Still Running
- <check-name> (PENDING/IN_PROGRESS)
```

Status meanings:
- `passed` — CI green, no blocking reviews, no PR comments
- `failed` — CI failures or `CHANGES_REQUESTED` reviews (with logs)
- `comments` — CI green but unresolved PR comments need addressing
- `pending` — checks still running after timeout (list which ones)

## Notes

- Can be invoked standalone without prior workflow state
- Polls the current branch's PR — no arguments needed for the poller
- Default: 60-second interval × 15 minutes max wait; pass `--max-minutes N` to override
- **Never ask the user for permission mid-execution** — always wait the full duration
- `CHANGES_REQUESTED` is a hard block; `APPROVED` and `COMMENTED` alone do not block
- Comment gathering runs after checks complete — bots post comments as part of their check, so they're available once the check finishes
- Log enrichment only works for GitHub Actions checks (not external status checks)

## Scripts Reference

| Script | Purpose |
|---|---|
| `scripts/poll-ci.sh` | Main poller — finds PR, polls checks and reviews, returns JSON |
| `scripts/get-pr-comments.sh` | GraphQL comment fetcher — returns unresolved threads and issue comments |
