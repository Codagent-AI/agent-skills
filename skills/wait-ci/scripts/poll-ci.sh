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
# - Exit code 0 on terminal result (passed/failed), 1 on timeout/error.

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

# Validate inputs
if ! [[ "$MAX_MINUTES" =~ ^[0-9]+$ ]] || [[ "$MAX_MINUTES" -lt 1 ]]; then
  echo "Error: --max-minutes must be a positive integer" >&2; exit 1
fi
if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || [[ "$INTERVAL" -lt 1 ]]; then
  echo "Error: --interval must be a positive integer (seconds)" >&2; exit 1
fi

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
repo_json=$(gh repo view --json owner,name 2>/dev/null) || {
  echo '{"error":"failed to fetch repo info"}' >&2
  exit 1
}
owner=$(echo "$repo_json" | jq -r '.owner.login')
repo=$(echo "$repo_json" | jq -r '.name')

start_epoch=$(date +%s)
poll=0
ever_had_checks=false
checks_json='[]'
pending_checks='[]'

while [[ $poll -lt $MAX_POLLS ]]; do
  poll=$((poll + 1))

  # ── Fetch checks ─────────────────────────────────────────────────────────────
  # Fail explicitly on error — don't coerce failures into empty arrays, which
  # could cause the script to falsely report "passed" on auth/network issues.
  if ! checks_json=$(gh pr checks --json name,state,bucket,link 2>/dev/null); then
    jq -n --arg error "failed to fetch PR checks" '{error: $error}' >&2
    exit 1
  fi

  # ── Fetch reviews ─────────────────────────────────────────────────────────────
  if ! reviews_json=$(gh api "repos/${owner}/${repo}/pulls/${pr_number}/reviews?per_page=100" 2>/dev/null); then
    jq -n --arg error "failed to fetch PR reviews" '{error: $error}' >&2
    exit 1
  fi

  # ── Classify checks ─────────────────────────────────────────────────────────
  # Use 'bucket' field; fall back to 'state' if bucket absent.
  pending_checks=$(echo "$checks_json" | jq '[.[] | select((.bucket // .state) == "pending" or (.bucket // .state) == "in_progress" or (.bucket // .state) == "queued")]')
  failed_checks=$(echo "$checks_json" | jq '[.[] | select((.bucket // .state) == "fail" or (.bucket // .state) == "failure")]')
  passed_checks=$(echo "$checks_json" | jq '[.[] | select((.bucket // .state) == "pass" or (.bucket // .state) == "success")]')

  total_checks=$(echo "$checks_json" | jq 'length')
  failed_count=$(echo "$failed_checks" | jq 'length')
  pending_count=$(echo "$pending_checks" | jq 'length')

  # Track whether checks ever appeared (distinguishes "no CI" from a real timeout)
  if [[ $total_checks -gt 0 ]]; then
    ever_had_checks=true
  fi

  # ── Classify reviews — latest state per reviewer wins ───────────────────────
  blocking_reviews=$(echo "$reviews_json" | jq '
    reduce .[] as $r ({};
      if $r.state != "PENDING" then
        .[$r.user.login] = {login: $r.user.login, state: $r.state, body: $r.body}
      else . end
    ) | [to_entries[] | .value | select(.state == "CHANGES_REQUESTED")]
  ')
  blocking_count=$(echo "$blocking_reviews" | jq 'length')

  # ── Extract GitHub Actions run IDs from failed check links ──────────────────
  # Use try/select to skip non-Actions links without erroring.
  failed_run_ids_json=$(echo "$failed_checks" | jq '
    [
      .[]
      | (.link // "")
      | (try capture("/actions/runs/(?P<id>[0-9]+)/").id)
      | select(. != null and . != "")
    ]
    | unique
  ')

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

  # ── No checks yet: keep polling (handles delayed workflow scheduling) ────────
  if [[ $total_checks -eq 0 ]]; then
    sleep "$INTERVAL"
    continue
  fi

  # ── Still pending: wait and poll again ───────────────────────────────────────
  if [[ $pending_count -gt 0 ]]; then
    sleep "$INTERVAL"
    continue
  fi

  # ── All checks complete, no failures ─────────────────────────────────────────
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

# If no checks ever appeared, treat as passed (no CI configured for this PR/repo).
if [[ "$ever_had_checks" == "false" ]]; then
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

jq -n \
  --arg     status         "pending" \
  --arg     pr_url         "$pr_url" \
  --argjson pr_number      "$pr_number" \
  --arg     owner          "$owner" \
  --arg     repo           "$repo" \
  --argjson elapsed        "$elapsed" \
  --argjson checks         "$checks_json" \
  --argjson pending_checks "$pending_checks" \
  '{
    status: $status, pr_url: $pr_url, pr_number: $pr_number,
    owner: $owner, repo: $repo, elapsed_minutes: $elapsed,
    checks: $checks, failed_checks: [], passed_checks: [],
    pending_checks: $pending_checks, blocking_reviews: [], failed_run_ids: []
  }'
exit 1
