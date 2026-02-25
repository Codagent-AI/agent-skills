#!/usr/bin/env bash
# Poll CI check status for the current branch's PR.
#
# Usage: ./poll-ci.sh [--max-minutes N] [--interval SECONDS]
#
#   --max-minutes N    Maximum total wait time in minutes (default: 15)
#   --interval SECONDS Seconds between polls (default: 60)
#
# Outputs a JSON object:
# {
#   "status": "passed" | "failed" | "pending" | "comments",
#   "pr_url": "...",
#   "pr_number": 123,
#   "owner": "...",
#   "repo": "...",
#   "elapsed_minutes": N,
#   "checks": [...],
#   "blocking_reviews": [...],
#   "failed_run_ids": [...]
# }
#
# Notes:
# - "failed_run_ids" contains GitHub Actions run IDs for failed checks.
#   Callers should fetch logs with: gh run view <id> --log-failed
# - PR comments are NOT gathered here; use get-pr-comments.sh after this script.
# - Exit code 0 on terminal result (passed/failed/comments), 1 on timeout/error.

set -euo pipefail

MAX_MINUTES=15
INTERVAL=60

while [[ $# -gt 0 ]]; do
  case "$1" in
    --max-minutes) MAX_MINUTES="$2"; shift 2 ;;
    --interval)    INTERVAL="$2";    shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# Compute max polls from minutes, rounding up, minimum 1
MAX_POLLS=$(( (MAX_MINUTES * 60 + INTERVAL - 1) / INTERVAL ))
[[ $MAX_POLLS -lt 1 ]] && MAX_POLLS=1

# ── Find PR ──────────────────────────────────────────────────────────────────
pr_json=$(gh pr view --json number,url,headRefName 2>/dev/null) || {
  echo '{"error":"no PR found for current branch"}' >&2
  exit 1
}
pr_number=$(echo "$pr_json" | jq '.number')
pr_url=$(echo "$pr_json" | jq -r '.url')

# ── Repo info ─────────────────────────────────────────────────────────────────
repo_json=$(gh repo view --json owner,name)
owner=$(echo "$repo_json" | jq -r '.owner.login')
repo=$(echo "$repo_json" | jq -r '.name')

start_epoch=$(date +%s)
poll=0
first_poll=true

while [[ $poll -lt $MAX_POLLS ]]; do
  poll=$((poll + 1))

  # ── Fetch checks and reviews in parallel ────────────────────────────────────
  checks_json=$(gh pr checks --json name,state,bucket,link 2>/dev/null || echo '[]')
  reviews_json=$(gh api "repos/${owner}/${repo}/pulls/${pr_number}/reviews?per_page=100" 2>/dev/null || echo '[]')

  # ── Classify checks ─────────────────────────────────────────────────────────
  # Use 'bucket' field; fall back to 'state' if bucket absent.
  pending_checks=$(echo "$checks_json" | jq '[.[] | select((.bucket // .state) == "pending" or (.bucket // .state) == "in_progress" or (.bucket // .state) == "queued")]')
  failed_checks=$(echo "$checks_json" | jq '[.[] | select((.bucket // .state) == "fail" or (.bucket // .state) == "failure")]')
  passed_checks=$(echo "$checks_json" | jq '[.[] | select((.bucket // .state) == "pass" or (.bucket // .state) == "success")]')

  total_checks=$(echo "$checks_json" | jq 'length')
  failed_count=$(echo "$failed_checks" | jq 'length')
  pending_count=$(echo "$pending_checks" | jq 'length')

  # ── Classify reviews — latest state per reviewer wins ───────────────────────
  # Build an object keyed by reviewer login, keeping only the last entry.
  blocking_reviews=$(echo "$reviews_json" | jq '
    reduce .[] as $r ({};
      if $r.state != "PENDING" then
        .[$r.user.login] = {login: $r.user.login, state: $r.state, body: $r.body}
      else . end
    ) | [to_entries[] | .value | select(.state == "CHANGES_REQUESTED")]
  ')
  blocking_count=$(echo "$blocking_reviews" | jq 'length')

  # ── Extract GitHub Actions run IDs from failed check links ──────────────────
  failed_run_ids=$(echo "$failed_checks" | jq -r '
    [.[] | .link // "" | capture("/actions/runs/(?P<id>[0-9]+)/") | .id] | unique | .[]
  ' 2>/dev/null || true)
  failed_run_ids_json=$(echo "$failed_run_ids" | jq -R . | jq -s .)

  elapsed=$(( ($(date +%s) - start_epoch) / 60 ))

  # ── Terminal: failure ────────────────────────────────────────────────────────
  if [[ $failed_count -gt 0 || $blocking_count -gt 0 ]]; then
    jq -n \
      --arg     status          "failed" \
      --arg     pr_url          "$pr_url" \
      --argjson pr_number       "$pr_number" \
      --arg     owner           "$owner" \
      --arg     repo            "$repo" \
      --argjson elapsed         "$elapsed" \
      --argjson checks          "$checks_json" \
      --argjson failed_checks   "$failed_checks" \
      --argjson passed_checks   "$passed_checks" \
      --argjson pending_checks  "$pending_checks" \
      --argjson blocking_reviews "$blocking_reviews" \
      --argjson failed_run_ids  "$failed_run_ids_json" \
      '{
        status: $status, pr_url: $pr_url, pr_number: $pr_number,
        owner: $owner, repo: $repo, elapsed_minutes: $elapsed,
        checks: $checks, failed_checks: $failed_checks,
        passed_checks: $passed_checks, pending_checks: $pending_checks,
        blocking_reviews: $blocking_reviews, failed_run_ids: $failed_run_ids
      }'
    exit 0
  fi

  # ── No checks on first poll: wait and retry ──────────────────────────────────
  if [[ $total_checks -eq 0 && "$first_poll" == "true" ]]; then
    first_poll=false
    sleep "$INTERVAL"
    continue
  fi

  first_poll=false

  # ── No checks on subsequent polls: treat as passed (no CI configured) ────────
  if [[ $total_checks -eq 0 ]]; then
    jq -n \
      --arg     status         "passed" \
      --arg     pr_url         "$pr_url" \
      --argjson pr_number      "$pr_number" \
      --arg     owner          "$owner" \
      --arg     repo           "$repo" \
      --argjson elapsed        "$elapsed" \
      '{
        status: $status, pr_url: $pr_url, pr_number: $pr_number,
        owner: $owner, repo: $repo, elapsed_minutes: $elapsed,
        checks: [], failed_checks: [], passed_checks: [],
        pending_checks: [], blocking_reviews: [], failed_run_ids: []
      }'
    exit 0
  fi

  # ── Still pending: wait and poll again ───────────────────────────────────────
  if [[ $pending_count -gt 0 ]]; then
    sleep "$INTERVAL"
    continue
  fi

  # ── All checks complete, no failures ─────────────────────────────────────────
  # Status is "passed" for now; caller should run get-pr-comments.sh and
  # upgrade to "comments" if there are unresolved threads.
  jq -n \
    --arg     status         "passed" \
    --arg     pr_url         "$pr_url" \
    --argjson pr_number      "$pr_number" \
    --arg     owner          "$owner" \
    --arg     repo           "$repo" \
    --argjson elapsed        "$elapsed" \
    --argjson checks         "$checks_json" \
    --argjson passed_checks  "$passed_checks" \
    '{
      status: $status, pr_url: $pr_url, pr_number: $pr_number,
      owner: $owner, repo: $repo, elapsed_minutes: $elapsed,
      checks: $checks, failed_checks: [], passed_checks: $passed_checks,
      pending_checks: [], blocking_reviews: [], failed_run_ids: []
    }'
  exit 0
done

# ── Timeout ────────────────────────────────────────────────────────────────────
elapsed=$(( ($(date +%s) - start_epoch) / 60 ))
jq -n \
  --arg     status         "pending" \
  --arg     pr_url         "$pr_url" \
  --argjson pr_number      "$pr_number" \
  --arg     owner          "$owner" \
  --arg     repo           "$repo" \
  --argjson elapsed        "$elapsed" \
  --argjson pending_checks "$pending_checks" \
  '{
    status: $status, pr_url: $pr_url, pr_number: $pr_number,
    owner: $owner, repo: $repo, elapsed_minutes: $elapsed,
    checks: [], failed_checks: [], passed_checks: [],
    pending_checks: $pending_checks, blocking_reviews: [], failed_run_ids: []
  }'
exit 1
