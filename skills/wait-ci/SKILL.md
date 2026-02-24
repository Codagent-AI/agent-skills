---
description: >
  Polls CI check status for the current branch's pull request and reports pass/fail/pending.
  Use when the user says "wait for CI", "check CI", "poll CI", or invokes "flokay:wait-ci".
allowed-tools: Bash
---

# flokay:wait-ci

Poll CI check status for the current branch's PR and report the result, enriching failures with log output and checking for blocking reviews.

## Steps

1. **Find the current PR**

   ```bash
   gh pr view --json number,url,headRefName
   ```

   - If no PR found: report error and stop
   - Extract PR number and URL for use in subsequent steps

2. **Get repo information** (for review API calls)

   ```bash
   gh repo view --json owner,name
   ```

3. **Poll loop** — repeat up to 10 times (approximately 10 minutes total)

   At the start of each poll, fetch checks and reviews in parallel:

   ```bash
   # CI checks
   gh pr checks --json name,state,link

   # Blocking reviews
   gh api "repos/{owner}/{repo}/pulls/{pr-number}/reviews?per_page=100"
   ```

   **Evaluate checks:**
   - States to treat as pending: `PENDING`, `QUEUED`, `IN_PROGRESS`
   - States to treat as failed: `FAILURE`
   - All other states (e.g., `SUCCESS`): complete

   **Evaluate reviews:**
   - Filter reviews to the latest state per reviewer (later reviews override earlier ones)
   - A review with state `CHANGES_REQUESTED` is blocking

   **Decision after each poll:**
   - If any check is in state `FAILURE` OR any reviewer has `CHANGES_REQUESTED`:
     → **Fetch failure logs** (see Step 4) and **return failed result** immediately
   - If no checks are pending/queued/in-progress AND no failures:
     → **Return passed result** immediately
   - If checks are still pending:
     → Wait 60 seconds (`sleep 60`) then poll again
   - If no checks exist yet on the first poll:
     → Wait 60 seconds and try again
   - If no checks exist on subsequent polls:
     → **Return passed result** (no CI configured, treat as passing)

4. **Enrich failures with log output**

   For each failed check:
   - Extract the GitHub Actions run ID from the check's `link` field:
     - Link format: `https://github.com/{owner}/{repo}/actions/runs/{RUN_ID}/job/{JOB_ID}`
     - Extract `{RUN_ID}` with a regex match on `/actions/runs/(\d+)/`
   - Fetch failed logs for each unique run ID:
     ```bash
     gh run view <run-id> --log-failed
     ```
   - If log output exceeds 100 lines, keep the last 100 lines (truncate from the top)
   - Attach the log output to the corresponding failed check(s)
   - External checks (no GitHub Actions run ID in the link) get no log output

5. **Handle timeout**

   If 10 polls complete without a terminal result (pass or fail):
   - Report: `pending` status, list which checks are still running
   - Do NOT loop further — let the caller decide what to do

## Output Format

Report a structured result:

~~~
## CI Status: <passed | failed | pending>

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

### Passing Checks
- <check-name> (SUCCESS)

### Still Running
- <check-name> (PENDING/IN_PROGRESS)
~~~

- If `passed` with no blocking reviews: report success
- If `failed`: list all failed checks with logs and all blocking reviews
- If `pending`: list still-running checks and elapsed time

## Notes

- Can be invoked standalone without prior workflow state
- Polls the current branch's PR — no arguments needed
- 60-second interval × 10 polls = ~10 minute maximum wait
- Review awareness: only `CHANGES_REQUESTED` state blocks; `APPROVED` and `COMMENTED` do not
- Log enrichment only works for GitHub Actions checks (not external status checks)
