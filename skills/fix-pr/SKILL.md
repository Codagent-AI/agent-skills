---
description: >
  Fixes CI failures and review comments on the current branch's pull request by dispatching
  a fixer subagent, verifying with the validator, and pushing the fix. Use when the user says
  "fix pr", "fix CI failures", "address review comments", or invokes "codagent:fix-pr".
---

# codagent:fix-pr

Fix CI failures and review comments on the current branch's PR by dispatching a fixer subagent with all failure context, verifying the fix with the validator, and pushing.

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

3. **Dispatch fixer subagent**

   Read the file `fixer-prompt.md` in this skill's directory.

   Substitute the following variables into the prompt:
   - `PR_URL` — the PR URL
   - `PR_NUMBER` — the PR number
   - `FAILED_CHECKS_CONTEXT` — structured list of failed checks with log output
   - `REVIEW_COMMENTS_CONTEXT` — structured list of review comments

   Spawn a fresh subagent with the following prompt (the contents of `fixer-prompt.md` with variables substituted):

   **Important:**
   - Spawn ONE fresh subagent — do NOT resume previous ones
   - Execute synchronously — wait for the subagent to return

4. **Verify the fix with the validator**

   After the subagent returns successfully:
   - Run the `agent-validator:validator-run` skill to verify the fix

   If the validator fails:
   - Report the validator failure — do NOT push
   - Let the caller decide whether to retry

5. **Push the fix**

   If the validator passes:
   - Run `codagent:push-pr` to commit and push the fix to the PR branch

6. **Report results**

   ```
   ## Fix-PR Summary

   ### Context Gathered
   - Failed checks: <N>
   - Blocking reviews: <N>
   - Inline comments: <N>

   ### Subagent Result
   <summary from subagent>

   ### Validator
   <passed | failed with details>

   ### Push
   PR updated: <url>
   ```

## Notes

- Can be invoked standalone — gathers its own context from the current branch's PR
- Addresses CI failures AND review comments in a single subagent pass
- Does NOT push if the validator fails — enforces quality gate before updating the PR
- After pushing, CI will re-run; caller should invoke `codagent:wait-ci` again
