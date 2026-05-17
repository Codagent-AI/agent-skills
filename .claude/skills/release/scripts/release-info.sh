#!/usr/bin/env bash
set -euo pipefail

# release-info.sh — Gather merged PRs, classify by type, calculate version bump.
# Output: JSON with current_version, new_version, and PRs grouped by bump type.
# Works from any branch: includes merged-to-main PRs AND unmerged current-branch commits.

REPO="Codagent-AI/agent-skills"
PLUGIN_JSON=".claude-plugin/plugin.json"

# --- Prepare working branch ---
CURRENT_BRANCH=$(git branch --show-current)
BRANCH_PR=""
AHEAD=0

git fetch origin main --tags --quiet

if [ "$CURRENT_BRANCH" = "main" ]; then
  git pull origin main --quiet
else
  # Check for commits ahead of origin/main
  AHEAD=$(git log --oneline origin/main..HEAD | wc -l | tr -d ' ')
  if [ "$AHEAD" -gt 0 ]; then
    # Check if a PR exists for this branch (open or merged)
    BRANCH_PR=$(gh pr view --json number,title,labels,state 2>/dev/null) || BRANCH_PR=""
  fi

  # Merge origin/main into current branch
  if ! git merge origin/main --no-edit --quiet 2>/dev/null; then
    jq -n '{"error": "merge_conflict", "message": "Merge conflicts when merging origin/main. Resolve conflicts first."}' >&2
    exit 1
  fi
fi

# --- Find last release tag ---
LAST_TAG=$(git tag --list 'v*' --sort=-v:refname | head -1)
if [ -z "$LAST_TAG" ]; then
  TAG_DATE="1970-01-01T00:00:00Z"
else
  TAG_DATE=$(git log -1 --format=%cI "$LAST_TAG")
fi

# --- Current version from plugin.json ---
CURRENT_VERSION=$(jq -r '.version' "$PLUGIN_JSON")
if [[ ! "$CURRENT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  jq -n --arg v "$CURRENT_VERSION" '{"error": "invalid_version", "message": "Invalid version in plugin.json: \($v)"}' >&2
  exit 1
fi

# --- Fetch merged PRs since last tag ---
PRS=$(gh pr list --repo "$REPO" --state merged --base main \
  --search "merged:>$TAG_DATE" \
  --json number,title,mergedAt,labels --limit 100)

# --- Add current branch PR if not on main and has unmerged commits ---
if [ "$CURRENT_BRANCH" != "main" ] && [ "$AHEAD" -gt 0 ] && [ -n "$BRANCH_PR" ]; then
  BRANCH_STATE=$(echo "$BRANCH_PR" | jq -r '.state')
  if [ "$BRANCH_STATE" = "OPEN" ]; then
    # Open PR: include it as-is (it has unmerged changes not in the search results)
    PRS=$(jq -s '.[0] + [.[1]] | unique_by(.number)' <(echo "$PRS") <(echo "$BRANCH_PR"))
  elif [ "$BRANCH_STATE" = "MERGED" ]; then
    # PR already merged but branch has new commits not in any PR yet.
    # Generate a synthetic entry from the commit log so these changes appear in the release.
    COMMIT_SUMMARY=$(git log --oneline origin/main..HEAD --no-merges | head -5 | paste -sd '; ' -)
    SYNTHETIC_TITLE="fix: unmerged branch changes (${COMMIT_SUMMARY})"
    SYNTHETIC_PR=$(jq -n --arg title "$SYNTHETIC_TITLE" --argjson number 0 '{number: $number, title: $title, labels: [], mergedAt: null, is_branch_commits: true}')
    PRS=$(jq -s '.[0] + [.[1]]' <(echo "$PRS") <(echo "$SYNTHETIC_PR"))
  fi
fi

# --- Filter out release PRs and classify ---
RESULT=$(echo "$PRS" | jq --arg cv "$CURRENT_VERSION" '
  # Filter out release PRs
  [.[] | select(
    (.title | test("^chore: (release|version packages)") | not) and
    (.title | test("^chore\\(release\\)") | not)
  )] |

  # Classify each PR
  {
    current_version: $cv,
    major: [.[] | select(
      (.title | test("^\\w+(\\(.*\\))?!:")) or
      (.labels // [] | map(.name) | any(. == "breaking"))
    )],
    minor: [.[] | select(
      (.title | test("^feat(\\(.*\\))?:")) and
      (.title | test("^\\w+(\\(.*\\))?!:") | not) and
      ((.labels // [] | map(.name) | any(. == "breaking")) | not)
    )],
    patch: [.[] | select(
      (.title | test("^feat(\\(.*\\))?:") | not) and
      (.title | test("^\\w+(\\(.*\\))?!:") | not) and
      ((.labels // [] | map(.name) | any(. == "breaking")) | not)
    )]
  } |

  # Check if anything to release
  if (.major | length) + (.minor | length) + (.patch | length) == 0 then
    {error: "nothing_to_release", message: "No qualifying merged PRs found since last release."}
  else
    # Calculate new version
    ($cv | split(".") | map(tonumber)) as [$maj, $min, $pat] |
    if (.major | length) > 0 then
      .new_version = "\($maj + 1).0.0"
    elif (.minor | length) > 0 then
      .new_version = "\($maj).\($min + 1).0"
    else
      .new_version = "\($maj).\($min).\($pat + 1)"
    end
  end
')

echo "$RESULT"
