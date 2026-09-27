---
description: >-
  Adds the release that every PR must carry, and runs before creating or
  pushing any PR. Bumps the plugin version and writes changelog entries:
  gathers merged PRs since the last tag plus unmerged current-branch changes,
  decides the semver bump, and commits the release onto the current branch (or
  opens a release PR from main). Runs non-interactively. Triggers when
  preparing, pushing, or finalizing a PR, or when the user says "release",
  "cut a release", "create a release PR", "prepare a release", or "bump
  version".
---

Add a release (version bump + changelog) to the current branch before its PR is created or updated. Every PR must include a release.

This skill is **non-interactive**. Decide the version and changelog yourself; do not ask the user to confirm the classification, version, or wording. Only stop and report if a script returns an error.

## Steps

### 1. Gather release info

Run the info script to collect merged PRs and calculate the version:

```bash
bash .claude/skills/release/scripts/release-info.sh 2>&1
```

Capture the JSON output (errors may arrive on stderr, hence `2>&1`). If the error is `already_released`, the branch already carries its release commit (each branch gets exactly one; later commits such as review fixes ship under it). There is nothing to do, so skip the remaining steps and report that. This is not a failure. For any other `"error"`, stop and report the message to the user.

### 2. Decide the classification and version

The script's classification comes from conventional commit prefixes, which is only a heuristic. Review it and adjust on your own judgment:
- Internal changes (tooling, CI, repo automation, skills used only by maintainers such as this one) are patch-level even if prefixed with `feat:`.
- User-facing new capabilities in shipped skills are minor.
- Breaking changes to shipped skills' behavior or interfaces are major.

Recompute `new_version` from `current_version` if you change any category (major → `X+1.0.0`, minor → `X.Y+1.0`, otherwise `X.Y.Z+1`). Briefly state the chosen version and classification in your output, then continue without waiting.

### 3. Write changelog descriptions

For each PR in the JSON output, write a one-sentence description that is slightly more informative than the raw PR title. Strip the conventional commit prefix from the title (`feat:`, `fix:`, `chore:`, etc.) and expand it into a sentence that gives enough context to understand the change without clicking through.

If an entry has `"is_branch_commits": true` and `"number": 0`, it represents unmerged commits on the current branch. Read the commit messages (`git log origin/main..HEAD --oneline --no-merges`) and write a description summarizing those changes. Omit the PR link for these entries since they have no PR yet — just use a bullet with the description.

### 4. Format the changelog section

Build the changelog section for the new version. Only include sections that have entries. Sort entries by PR number ascending within each section.

Format:

```
## <new_version>

### Major Changes

- [#<number>](https://github.com/Codagent-AI/agent-skills/pull/<number>) <description>

### Minor Changes

- [#<number>](https://github.com/Codagent-AI/agent-skills/pull/<number>) <description>

### Patch Changes

- [#<number>](https://github.com/Codagent-AI/agent-skills/pull/<number>) <description>
- <description without link> (for branch-commit entries with no PR)
```

### 5. Write the changelog section to a temp file

Write the formatted changelog section (from step 4) to a temporary file:

```bash
TMPFILE=$(mktemp)
cat <<'CHANGELOG_EOF' > "$TMPFILE"
<paste the formatted changelog section here>
CHANGELOG_EOF
echo "$TMPFILE"
```

### 6. Commit the release

Run the release script with the new version and temp file path:

```bash
bash .claude/skills/release/scripts/create-release-pr.sh <new_version> <tmpfile_path>
```

On a feature branch, this commits the release onto the branch and pushes it; if the branch has no PR yet, the calling workflow (e.g. `codagent:push-pr` or `codagent:finalize-pr`) creates it next. On `main`, it creates a `release/v<new_version>` branch and opens a release PR.

### 7. Report

Print the version and the PR URL returned by the script (or note that no PR exists yet).

Clean up the temp file:

```bash
rm -f "$TMPFILE"
```
