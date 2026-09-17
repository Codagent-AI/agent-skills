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
#   "unresolved_threads": [...],    # actionable unresolved review threads
#   "deferred_threads": [...],      # unresolved threads deferred by the PR author
#   "issue_comments": [...],        # blocking top-level human comments
#   "informational_bot_comments": [...] # non-blocking top-level bot comments
# }
#
# Each unresolved_thread and deferred_thread entry:
# { "file": "...", "line": N, "author": "...", "body": "..." }
#
# Each issue_comment and informational_bot_comment entry:
# { "author": "...", "body": "..." }
#
# Notes:
# - Unresolved review threads block unless the latest non-bot comment is from the
#   PR author (fix-pr's reply-and-do-not-resolve deferral). Later bot acknowledgments
#   do not re-block; a later human reviewer reply is actionable again.
# - Top-level comments by the PR creator are omitted.
# - Top-level bot comments are returned as informational evidence, not blockers.
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
      author { __typename login }
      reviewThreads(first: 100) {
        nodes {
          isResolved
          comments(first: 10) {
            nodes {
              author { __typename login }
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
          author { __typename login }
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
# metadata (file, line) and all comment bodies. A thread is deferred when the
# latest non-bot comment is from the PR author; later bot acks do not re-block.
classified_threads=$(echo "$result" | jq --arg pr_author "$PR_AUTHOR" '
  [
    .data.repository.pullRequest.reviewThreads.nodes[]?
    | select(.isResolved == false)
    | .comments.nodes as $comments
    | ($comments | first) as $first
    | ($comments | map(select((.author.__typename // "") != "Bot")) | last) as $latest_human
    | {
        file: ($first.path // ""),
        line: ($first.line // $first.originalLine // null),
        author: ($first.author.login // "unknown"),
        body: ($first.body // ""),
        deferred: (
          ($pr_author != "")
          and ($latest_human != null)
          and (($latest_human.author.login // "") == $pr_author)
        )
      }
  ]
')
unresolved_threads=$(echo "$classified_threads" | jq '[.[] | select(.deferred != true) | del(.deferred)]')
deferred_threads=$(echo "$classified_threads" | jq '[.[] | select(.deferred == true) | del(.deferred)]')

# ── Top-level human comments ──────────────────────────────────────────────────
# Only explicit Bot actors are informational. Missing or unfamiliar actor types
# remain blocking so unavailable author metadata cannot hide feedback.
issue_comments=$(echo "$result" | jq --arg pr_author "$PR_AUTHOR" '
  [
    .data.repository.pullRequest.comments.nodes[]?
    | select($pr_author == "" or (.author.login // "") != $pr_author)
    | select((.author.__typename // "") != "Bot")
    | { author: (.author.login // "unknown"), body: (.body // "") }
  ]
')

# ── Top-level bot comments ────────────────────────────────────────────────────
informational_bot_comments=$(echo "$result" | jq --arg pr_author "$PR_AUTHOR" '
  [
    .data.repository.pullRequest.comments.nodes[]?
    | select($pr_author == "" or (.author.login // "") != $pr_author)
    | select((.author.__typename // "") == "Bot")
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
  --argjson deferred_threads    "$deferred_threads" \
  --argjson issue_comments      "$issue_comments" \
  --argjson informational_bot_comments "$informational_bot_comments" \
  '{
    has_comments: $has_comments,
    unresolved_threads: $unresolved_threads,
    deferred_threads: $deferred_threads,
    issue_comments: $issue_comments,
    informational_bot_comments: $informational_bot_comments
  }'
