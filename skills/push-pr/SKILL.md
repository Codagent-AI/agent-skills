---
name: push-pr
description: >
  Commits changes, pushes to remote, and creates or updates a pull request for the current branch.
  Use when the user says "push pr", "create pr", "push and create pr", or invokes "codagent:push-pr".
---

# codagent:push-pr

Commit all changes, push to the remote, and create or update the pull request for the current branch.

## Steps

1. **Run validator detection**
   - Run `agent-validator detect 2>&1`
   - **Exit 0** → gates would run, invoke `agent-validator:validator-run` skill and wait for it to pass before proceeding
   - **Exit 2** → no gates would run (no changes or no applicable gates), skip to Step 2
   - **Exit 1** → error, report the error to the user and stop
   - **Any other exit code** → treat as error, report output to the user, and stop

2. **Check for uncommitted changes** using `git status --porcelain`
   - If there are changes, create a commit:
     - Run `git diff --staged` and `git diff` to see what's changed
     - Generate a concise, descriptive commit message based on the changes
     - Stage changed files by name (avoid staging sensitive files like `.env` or credentials)
     - Commit with: `git commit -m "message"`; add `-m "Co-Authored-By: <Name> <email>"` only when the co-author identity is explicitly configured or provided by the user
   - If there are no changes, proceed to push check

3. **Push to remote**
   - Get current branch: `git branch --show-current`
   - Push with upstream tracking: `git push -u origin <branch>`
   - If push fails, show the error and stop

4. **Check if PR exists**
   - Query the current branch explicitly: `gh pr list --head <branch> --state open --json url,title,state,number,headRefOid --limit 2`
   - If the command fails for auth, network, API, or another error, report stderr and stop
   - If the output is invalid JSON or contains more than one open PR, report the unexpected state and stop
   - If exactly one open PR exists, use it; do not let a prior closed or merged PR substitute for it
   - **If PR exists and is OPEN:**
     - Check if there are new commits by comparing current HEAD with PR's `headRefOid`
     - If new commits exist:
       - Get default branch: `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name`
       - Get all commits for the description: `git log <default-branch>..HEAD --oneline`
       - Regenerate the PR description based on all commits (including the new ones)
       - Update the PR: `gh pr edit <pr-number> --body "updated description"`
       - Print: "PR updated with new commits: <url>"
     - If no new commits: print "PR already exists: <url>"
   - **If no open PR exists:**
     - Optionally query `gh pr list --head <branch> --state all` for context. Treat `CLOSED` and
       `MERGED` as terminal history, not as the current PR.
     - Print that no open PR exists and create a new PR using the steps below.
     - Get default branch: `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name`
     - Get commit history for PR description: `git log <default-branch>..HEAD --oneline`
     - Generate a clear PR title and description based on the commits and change context
     - Create PR: `gh pr create --base <default-branch> --title "title" --body "description"`
     - Print the PR URL

5. **Print the PR URL** at the end so it's easy to find

## Notes

- Operates on the current branch — does NOT create or switch branches
- Uses descriptive commit messages that explain the "why" not just the "what"
- PR descriptions should summarize the changes and their purpose
- Always include the PR URL in the final output
- Can be invoked standalone at any point without prior workflow state
- A merged or closed PR for the current branch never prevents creating a new open PR
