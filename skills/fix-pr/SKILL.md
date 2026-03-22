---
description: >
  Fixes CI failures and review comments on the current branch's pull request by dispatching
  the `flokay:fixer` agent, verifying with gauntlet, and pushing the fix. Use when the user says
  "fix pr", "fix CI failures", "address review comments", or invokes "flokay:fix-pr".
---

# flokay:fix-pr

Fix CI failures and review comments on the current branch's PR by dispatching the `flokay:fixer` agent with all failure context, verifying the fix with gauntlet, and pushing.

## Steps

1. **Gather CI failure context**

   ```bash
   # Get PR details
   gh pr view --json number,url,headRefName,baseRefName

   # Get all CI check results
   gh pr checks --json name,state,bucket,link
   ```

   For each failed check (bucket = `fail`):
   - Extract the GitHub Actions run ID from the `link` field:
     - Pattern: `/actions/runs/(\d+)/`
   - Fetch failed logs:
     ```bash
     gh run view <run-id> --log-failed
     ```
   - Collect: check name, link, and log output

2. **Gather review comment context**

   ```bash
   # Get repo info
   gh repo view --json owner,name

   # Get all reviews
   gh api "repos/{owner}/{repo}/pulls/{pr-number}/reviews?per_page=100"

   # Get unresolved inline review threads via GraphQL (includes resolution status)
   # IMPORTANT: Inline owner, repo, and PR number directly into the query.
   # Do NOT use GraphQL variables ($owner, $repo) — the $ signs get stripped by the shell.
   gh api graphql -f query='
     query {
       repository(owner: "<owner>", name: "<repo>") {
         pullRequest(number: <pr-number>) {
           reviewThreads(first: 100) {
             nodes {
               id
               isResolved
               comments(first: 10) {
                 nodes {
                   author { login }
                   path
                   line
                   body
                 }
               }
             }
           }
         }
       }
     }
   '
   ```

   - Filter reviews to latest state per reviewer
   - Collect `CHANGES_REQUESTED` reviews: author, body
   - From the GraphQL result, collect only threads where `isResolved` is `false`: author, file path, line, body

3. **Dispatch the `flokay:fixer` agent**

   Read the file `fixer-prompt.md` in this skill's directory.

   Substitute the following variables into the prompt:
   - `PR_URL` — the PR URL
   - `PR_NUMBER` — the PR number
   - `FAILED_CHECKS_CONTEXT` — structured list of failed checks with log output
   - `REVIEW_COMMENTS_CONTEXT` — structured list of review comments

   Dispatch the `flokay:fixer` agent with the prepared prompt (the contents of `fixer-prompt.md` with variables substituted).

   **Important:**
   - Each invocation gets a FRESH `flokay:fixer` agent — do NOT resume previous ones
   - Execute synchronously — wait for the agent to return

4. **Verify the fix with gauntlet**

   After the `flokay:fixer` agent returns successfully:
   - Run the `gauntlet-run` skill to verify the fix

   If gauntlet fails:
   - Report the gauntlet failure — do NOT push
   - Let the caller decide whether to retry

5. **Push the fix**

   If gauntlet passes:
   - Run `flokay:push-pr` to commit and push the fix to the PR branch

6. **Report results**

   ```
   ## Fix-PR Summary

   ### Context Gathered
   - Failed checks: <N>
   - Blocking reviews: <N>
   - Inline comments: <N>

   ### Agent Result
   <summary from fixer agent>

   ### Gauntlet
   <passed | failed with details>

   ### Push
   PR updated: <url>
   ```

## Notes

- Can be invoked standalone — gathers its own context from the current branch's PR
- Addresses CI failures AND review comments in a single `flokay:fixer` agent pass
- Does NOT push if gauntlet fails — enforces quality gate before updating the PR
- After pushing, CI will re-run; caller should invoke `flokay:wait-ci` again
