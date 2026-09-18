#!/usr/bin/env bash
# Single-invocation CI status check with short internal polling.
#
# Usage: ./check-ci.sh [--max-seconds N] [--interval S]
#
#   --max-seconds N   How long this invocation runs before exiting as "pending" (default: 90)
#   --interval S      Seconds between polls within this invocation (default: 10)
#
# Call this repeatedly from the skill to achieve a longer total wait time.
# Each call should have a Bash timeout: 120000 (2 minutes) to give headroom.
#
# Exit codes:
#   0 = terminal result — check "status" field for "passed" or "failed"
#   2 = not yet terminal — re-run to continue waiting
#   1 = fatal error
#
# JSON output fields:
#   status          "passed" | "failed" | "pending" | "no_checks"
#   pr_url          PR URL
#   pr_number       PR number
#   head_sha        PR head commit queried for this invocation
#   owner / repo    Repo coordinates for subsequent calls
#   had_checks      bool — whether any checks were seen on this invocation
#   checks          all checks from the last poll
#   failed_checks   checks with bucket == "fail" or cancellation states
#   passed_checks   checks with bucket == "pass" or non-blocking skip states
#   pending_checks  checks still running
#   blocking_reviews reviews with CHANGES_REQUESTED (latest per reviewer)
#   failed_run_ids  GitHub Actions run IDs from failed check links
#   mergeable       GraphQL mergeable: MERGEABLE | CONFLICTING | UNKNOWN
#   mergeStateStatus GraphQL merge state (DIRTY when conflicting)
#   conflicting_files paths that conflict with the PR base (when available)

set -euo pipefail

MAX_SECONDS=90
INTERVAL=10

while [[ $# -gt 0 ]]; do
  case "$1" in
    --max-seconds)
      [[ $# -ge 2 ]] || { echo "Error: --max-seconds requires a value" >&2; exit 1; }
      MAX_SECONDS="$2"; shift 2 ;;
    --interval)
      [[ $# -ge 2 ]] || { echo "Error: --interval requires a value" >&2; exit 1; }
      INTERVAL="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if ! [[ "$MAX_SECONDS" =~ ^[0-9]+$ ]] || [[ "$MAX_SECONDS" -lt 1 ]]; then
  echo "Error: --max-seconds must be a positive integer" >&2; exit 1
fi
if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || [[ "$INTERVAL" -lt 1 ]]; then
  echo "Error: --interval must be a positive integer (seconds)" >&2; exit 1
fi

MAX_POLLS=$(( (MAX_SECONDS + INTERVAL - 1) / INTERVAL ))
[[ $MAX_POLLS -lt 1 ]] && MAX_POLLS=1

# ── Find PR ───────────────────────────────────────────────────────────────────
pr_json=$(gh pr view --json number,url,headRefName,headRefOid,baseRefOid,mergeable,mergeStateStatus 2>/dev/null) || {
  echo '{"error":"no PR found for current branch"}' >&2
  exit 1
}
pr_number=$(echo "$pr_json" | jq '.number')
pr_url=$(echo "$pr_json" | jq -r '.url')
head_sha=$(echo "$pr_json" | jq -er '.headRefOid | strings | select(length > 0)') || {
  echo '{"error":"PR head SHA is missing"}' >&2
  exit 1
}
mergeable=$(echo "$pr_json" | jq -r '.mergeable // ""')
merge_state_status=$(echo "$pr_json" | jq -r '.mergeStateStatus // ""')
base_oid=$(echo "$pr_json" | jq -r '.baseRefOid // ""')
conflicting_files_json='[]'

collect_conflicting_files() {
  local merge_base="$1" merge_head="$2" output
  if [[ -z "$merge_base" || -z "$merge_head" ]]; then
    echo '[]'
    return 0
  fi
  if ! git cat-file -e "${merge_base}^{commit}" 2>/dev/null; then
    echo '[]'
    return 0
  fi
  if ! git cat-file -e "${merge_head}^{commit}" 2>/dev/null; then
    echo '[]'
    return 0
  fi
  output=$(git merge-tree --name-only --no-messages "$merge_base" "$merge_head" 2>/dev/null || true)
  printf '%s\n' "$output" | jq -R -s 'split("\n") | map(select(length > 0 and (test("^[0-9a-f]{40,64}$") | not)))'
}

refresh_merge_state() {
  local latest
  if latest=$(gh pr view --json mergeable,mergeStateStatus,baseRefOid 2>/dev/null); then
    mergeable=$(echo "$latest" | jq -r '.mergeable // ""')
    merge_state_status=$(echo "$latest" | jq -r '.mergeStateStatus // ""')
    base_oid=$(echo "$latest" | jq -r '.baseRefOid // ""')
  fi
}

emit_ci_json() {
  local status="$1"
  jq -n \
    --arg     status            "$status" \
    --arg     pr_url            "$pr_url" \
    --argjson pr_number         "$pr_number" \
    --arg     head_sha          "$head_sha" \
    --arg     owner             "$owner" \
    --arg     repo              "$repo" \
    --argjson had_checks        "$( [[ $had_checks == true ]] && echo true || echo false )" \
    --argjson checks            "${checks_json:-[]}" \
    --argjson failed_checks     "${failed_checks:-[]}" \
    --argjson passed_checks     "${passed_checks:-[]}" \
    --argjson pending_checks    "${pending_checks:-[]}" \
    --argjson blocking_reviews  "${blocking_reviews:-[]}" \
    --argjson failed_run_ids    "${failed_run_ids_json:-[]}" \
    --arg     mergeable         "${mergeable:-}" \
    --arg     mergeStateStatus  "${merge_state_status:-}" \
    --argjson conflicting_files "$conflicting_files_json" \
    '{
      status: $status, pr_url: $pr_url, pr_number: $pr_number, head_sha: $head_sha,
      owner: $owner, repo: $repo, had_checks: $had_checks,
      checks: $checks, failed_checks: $failed_checks,
      passed_checks: $passed_checks, pending_checks: $pending_checks,
      blocking_reviews: $blocking_reviews, failed_run_ids: $failed_run_ids,
      mergeable: $mergeable, mergeStateStatus: $mergeStateStatus,
      conflicting_files: $conflicting_files
    }'
}

# ── Repo info ─────────────────────────────────────────────────────────────────
repo_json=$(gh repo view --json owner,name 2>/dev/null) || {
  echo '{"error":"failed to fetch repo info"}' >&2
  exit 1
}
owner=$(echo "$repo_json" | jq -r '.owner.login')
repo=$(echo "$repo_json" | jq -r '.name')

poll=0
had_checks=false
checks_json='[]'
pending_checks='[]'

while [[ $poll -lt $MAX_POLLS ]]; do
  poll=$((poll + 1))
  refresh_merge_state

  # ── Fetch checks ──────────────────────────────────────────────────────────────
  # gh pr checks exits 1 with "no checks reported" for a valid empty state.
  _gh_err=$(mktemp)
  if ! checks_json=$(gh pr checks --json name,state,bucket,link 2>"$_gh_err"); then
    _err_msg=$(cat "$_gh_err"); rm -f "$_gh_err"
    if [[ "$_err_msg" == *"no checks reported"* ]]; then
      checks_json='[]'
    else
      jq -n --arg error "failed to fetch PR checks: $_err_msg" '{error: $error}' >&2
      exit 1
    fi
  else
    rm -f "$_gh_err"
  fi

  # ── Fetch reviews ─────────────────────────────────────────────────────────────
  _reviews_err=$(mktemp)
  if ! reviews_json=$(gh api --paginate "repos/${owner}/${repo}/pulls/${pr_number}/reviews?per_page=100" 2>"$_reviews_err" | jq -s 'add // []'); then
    _err_msg=$(cat "$_reviews_err"); rm -f "$_reviews_err"
    jq -n --arg error "failed to fetch PR reviews: $_err_msg" '{error: $error}' >&2
    exit 1
  else
    rm -f "$_reviews_err"
  fi

  # ── Classify checks ───────────────────────────────────────────────────────────
  pending_checks=$(echo "$checks_json" | jq '[.[] | select((.bucket // .state) as $s | $s == "pending" or $s == "in_progress" or $s == "queued")]')
  failed_checks=$(echo "$checks_json" | jq '[.[] | select((.bucket // .state) as $s | $s == "fail" or $s == "failure" or $s == "cancel" or $s == "cancelled")]')
  passed_checks=$(echo "$checks_json" | jq '[.[] | select((.bucket // .state) as $s | $s == "pass" or $s == "success" or $s == "skipping" or $s == "skipped" or $s == "neutral")]')

  total_checks=$(echo "$checks_json" | jq 'length')
  failed_count=$(echo "$failed_checks" | jq 'length')
  pending_count=$(echo "$pending_checks" | jq 'length')
  passed_count=$(echo "$passed_checks" | jq 'length')

  [[ $total_checks -gt 0 ]] && had_checks=true

  # ── Classify reviews ──────────────────────────────────────────────────────────
  blocking_reviews=$(echo "$reviews_json" | jq '
    reduce .[] as $r ({};
      if $r.state != "PENDING" then
        .[$r.user.login] = {login: $r.user.login, state: $r.state, body: $r.body}
      else . end
    ) | [to_entries[] | .value | select(.state == "CHANGES_REQUESTED")]
  ')
  blocking_count=$(echo "$blocking_reviews" | jq 'length')

  # ── Extract GitHub Actions run IDs ───────────────────────────────────────────
  failed_run_ids_json=$(echo "$failed_checks" | jq '
    [
      .[]
      | (.link // "")
      | (try capture("/actions/runs/(?P<id>[0-9]+)/").id)
      | select(. != null and . != "")
    ]
    | unique
  ')

  # ── Terminal: merge conflict ──────────────────────────────────────────────────
  if [[ "$mergeable" == "CONFLICTING" ]]; then
    conflicting_files_json=$(collect_conflicting_files "$base_oid" "$head_sha")
    emit_ci_json "failed"
    exit 0
  fi

  # ── Terminal: failure ─────────────────────────────────────────────────────────
  if [[ $failed_count -gt 0 || $blocking_count -gt 0 ]]; then
    emit_ci_json "failed"
    exit 0
  fi

  # ── Terminal: passed ──────────────────────────────────────────────────────────
  # UNKNOWN mergeability is still computing — keep polling instead of passing.
  if [[ "$mergeable" != "UNKNOWN" && $total_checks -gt 0 && $pending_count -eq 0 && $failed_count -eq 0 && $passed_count -eq $total_checks ]]; then
    failed_checks='[]'
    pending_checks='[]'
    blocking_reviews='[]'
    failed_run_ids_json='[]'
    emit_ci_json "passed"
    exit 0
  fi

  # ── Not yet terminal — sleep and retry within this invocation ─────────────────
  if [[ $poll -lt $MAX_POLLS ]]; then
    sleep "$INTERVAL"
  fi
done

# ── This invocation timed out without a terminal result ───────────────────────
# Caller should re-invoke to continue waiting toward the total max_minutes limit.
failed_checks='[]'
passed_checks='[]'
blocking_reviews='[]'
failed_run_ids_json='[]'
if [[ "$mergeable" == "UNKNOWN" || $had_checks == true ]]; then
  emit_ci_json "pending"
else
  emit_ci_json "no_checks"
fi
exit 2
