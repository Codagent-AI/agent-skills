#!/usr/bin/env bash
set -euo pipefail

# release-info.sh — Gather merged PRs, classify by type, calculate version bump.
# Output: JSON with current_version, new_version, and PRs grouped by bump type.
# Works from any branch: includes merged-to-main PRs AND the current branch's PR.

REPO="Codagent-AI/agent-skills"
PLUGIN_JSON=".claude-plugin/plugin.json"

# --- Prepare working branch ---
CURRENT_BRANCH=$(git branch --show-current)
BRANCH_PR=""
AHEAD=0

error_json() {
  local code="$1"
  local message="$2"
  jq -n --arg error "$code" --arg message "$message" \
    '{error: $error, message: $message}'
}

git fetch origin main --tags --quiet

if [ "$CURRENT_BRANCH" = "main" ]; then
  if ! git merge-base --is-ancestor origin/main HEAD; then
    error_json "branch_behind" "Local main does not contain origin/main. Update main before creating a release."
    exit 1
  fi
else
  if ! git merge-base --is-ancestor origin/main HEAD; then
    error_json "branch_behind" "Current branch does not contain origin/main. Rebase or merge main before creating a release."
    exit 1
  fi

  # Check for commits ahead of origin/main
  AHEAD=$(git log --oneline origin/main..HEAD | wc -l | tr -d ' ')
  if [ "$AHEAD" -gt 0 ]; then
    # Verify a PR exists for this branch
    BRANCH_PR=$(gh pr view "$CURRENT_BRANCH" --repo "$REPO" --json number,title,labels 2>/dev/null) || {
      error_json "no_pr" "Current branch has changes not on main but no PR exists. Create a PR first."
      exit 1
    }
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
  error_json "invalid_version" "Invalid version in plugin.json: $CURRENT_VERSION"
  exit 1
fi

# --- Fetch merged PRs since last tag ---
PRS=$(gh pr list --repo "$REPO" --state merged --base main \
  --search "merged:>$TAG_DATE" \
  --json number,title,mergedAt,labels --limit 100)

# --- Add current branch PR if not on main and has commits ahead ---
if [ "$CURRENT_BRANCH" != "main" ] && [ "$AHEAD" -gt 0 ] && [ -n "$BRANCH_PR" ]; then
  PRS=$(jq -s '.[0] + [.[1]] | unique_by(.number)' <(echo "$PRS") <(echo "$BRANCH_PR"))
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
