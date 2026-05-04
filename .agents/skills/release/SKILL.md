---
description: >-
  Creates a release PR from merged PRs — gathers merged PRs since last tag
  (plus any unmerged current-branch PR), calculates semver bump from
  conventional commit titles, generates changelog entries, and opens a release
  PR. Works from any branch: includes both main and current branch changes.
  Activates for requests such as "release", "cut a release", "create a release
  PR", "prepare a release", or "bump version".
---

Create a release PR by gathering merged PRs, calculating the version bump, writing changelog entries, and opening the PR.

## Out of Scope

This skill does not resolve merge conflicts, create release PRs when required GitHub tooling is unavailable, or curate changelog content beyond the generated PR set. Stop and report the blocker when prerequisites fail.

## Steps

### 1. Gather release info

Run the info script to collect merged PRs and calculate the version:

```bash
bash .agents/skills/release/scripts/release-info.sh
```

Capture stdout as JSON. The script writes all structured responses, including errors, to stdout. If the output contains `"error"`, stop and report the message to the user.

### 2. Show the release summary

Display to the user:
- Version bump: `current_version` → `new_version`
- Number of PRs by category
- List each PR number and title, grouped by Major / Minor / Patch

### 3. Write changelog descriptions

For each PR in the JSON output, write a one-sentence description that is slightly more informative than the raw PR title. Strip the conventional commit prefix from the title (`feat:`, `fix:`, `chore:`, etc.) and expand it into a sentence that gives enough context to understand the change without clicking through.

### 4. Format the changelog section

Build the changelog section for the new version. Only include sections that have entries. Sort entries by PR number ascending within each section.

Format:

```markdown
## <new_version>

### Major Changes

- [#<number>](https://github.com/Codagent-AI/agent-skills/pull/<number>) <description>

### Minor Changes

- [#<number>](https://github.com/Codagent-AI/agent-skills/pull/<number>) <description>

### Patch Changes

- [#<number>](https://github.com/Codagent-AI/agent-skills/pull/<number>) <description>
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

### 6. Create the release PR

Run the release script with the new version and temp file path:

```bash
bash .agents/skills/release/scripts/create-release-pr.sh <new_version> <tmpfile_path>
```

### 7. Report

Print the PR URL returned by the script.

Clean up the temp file:

```bash
rm -f "$TMPFILE"
```
