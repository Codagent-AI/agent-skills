#!/usr/bin/env bash
# Fetch PR comments via GraphQL, including unresolved review thread status.
#
# Usage: ./get-pr-comments.sh <owner> <repo> <pr-number> [<pr-author-login>]
#
# Uses the GraphQL API to avoid jq '!=' shell-escaping issues that occur
# when using 'gh api ... --jq' with inequality operators.
#
# Outputs a JSON object:
# {
#   "has_comments": true | false,
#   "unresolved_threads": [...],    # inline review threads not yet resolved
#   "issue_comments": [...]         # top-level PR conversation comments
# }
#
# Each unresolved_thread entry:
# { "file": "...", "line": N, "author": "...", "body": "..." }
#
# Each issue_comment entry:
# { "author": "...", "body": "..." }
#
# Notes:
# - Only returns comments NOT authored by the PR creator (pass pr-author-login to exclude).
# - Resolved threads are omitted.
# - Fetches up to 100 review threads and 100 issue comments.

set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <owner> <repo> <pr-number> [<pr-author-login>]" >&2
  exit 1
fi

OWNER="$1"
REPO="$2"
PR_NUMBER="$3"
PR_AUTHOR="${4:-}"

# ── GraphQL query ─────────────────────────────────────────────────────────────
# reviewThreads gives us isResolved directly — no need for jq != workarounds.
query='
query($owner: String!, $repo: String!, $prNumber: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $prNumber) {
      author { login }
      reviewThreads(first: 100) {
        nodes {
          isResolved
          comments(first: 10) {
            nodes {
              author { login }
              body
              path
              line
              originalLine
            }
          }
        }
      }
      comments(first: 100) {
        nodes {
          author { login }
          body
        }
      }
    }
  }
}
'

result=$(gh api graphql \
  -f query="$query" \
  -f owner="$OWNER" \
  -f repo="$REPO" \
  -F prNumber="$PR_NUMBER")

# ── Extract PR author if not provided ────────────────────────────────────────
if [[ -z "$PR_AUTHOR" ]]; then
  PR_AUTHOR=$(echo "$result" | jq -r '.data.repository.pullRequest.author.login // ""')
fi

# ── Unresolved review threads ─────────────────────────────────────────────────
# Filter to threads where isResolved == false, then take the first comment's
# metadata (file, line) and all comment bodies.
unresolved_threads=$(echo "$result" | jq --arg pr_author "$PR_AUTHOR" '
  [
    .data.repository.pullRequest.reviewThreads.nodes[]
    | select(.isResolved == false)
    | .comments.nodes as $comments
    | ($comments | first) as $first
    | {
        file: ($first.path // ""),
        line: ($first.line // $first.originalLine // null),
        author: ($first.author.login // "unknown"),
        body: ($first.body // "")
      }
    | select(.author != $pr_author)
  ]
')

# ── Issue-level comments ──────────────────────────────────────────────────────
issue_comments=$(echo "$result" | jq --arg pr_author "$PR_AUTHOR" '
  [
    .data.repository.pullRequest.comments.nodes[]
    | select((.author.login // "") != $pr_author)
    | { author: (.author.login // "unknown"), body: (.body // "") }
  ]
')

# ── Combine and output ────────────────────────────────────────────────────────
unresolved_count=$(echo "$unresolved_threads" | jq 'length')
issue_count=$(echo "$issue_comments" | jq 'length')
has_comments=$(( unresolved_count + issue_count > 0 ))

jq -n \
  --argjson has_comments        "$([ "$has_comments" -gt 0 ] && echo true || echo false)" \
  --argjson unresolved_threads  "$unresolved_threads" \
  --argjson issue_comments      "$issue_comments" \
  '{
    has_comments: $has_comments,
    unresolved_threads: $unresolved_threads,
    issue_comments: $issue_comments
  }'
