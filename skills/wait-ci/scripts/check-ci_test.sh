#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT="$SCRIPT_DIR/check-ci.sh"
MOCK_BIN=$(mktemp -d)
trap 'rm -rf "$MOCK_BIN"' EXIT

cat >"$MOCK_BIN/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "$1" == "pr" && "$2" == "view" ]]; then
  printf '%s\n' "$MOCK_PR_VIEW"
  exit 0
fi

if [[ "$1" == "repo" && "$2" == "view" ]]; then
  printf '%s\n' '{"owner":{"login":"owner"},"name":"repo"}'
  exit 0
fi

if [[ "$1" == "pr" && "$2" == "checks" ]]; then
  printf '%s\n' "${MOCK_CHECKS:-[]}"
  exit 0
fi

if [[ "$1" == "api" ]]; then
  printf '%s\n' "${MOCK_REVIEWS:-[]}"
  exit 0
fi

echo "unexpected gh invocation: $*" >&2
exit 1
EOF
chmod +x "$MOCK_BIN/gh"

cat >"$MOCK_BIN/git" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "$1" == "cat-file" ]]; then
  exit 0
fi

if [[ "$1" == "merge-tree" ]]; then
  printf '%s\n' "${MOCK_MERGE_TREE:-}"
  exit 1
fi

echo "unexpected git invocation: $*" >&2
exit 1
EOF
chmod +x "$MOCK_BIN/git"

GREEN_CHECKS='[{"name":"CodeRabbit","state":"SUCCESS","bucket":"pass","link":"https://example.com"}]'

run_script() {
  PATH="$MOCK_BIN:$PATH" \
    MOCK_PR_VIEW="$1" \
    MOCK_CHECKS="$2" \
    MOCK_REVIEWS="${3:-[]}" \
    MOCK_MERGE_TREE="${4:-}" \
    bash "$SCRIPT" --max-seconds 1 --interval 1
}

assert_exit() {
  local expected="$1" actual="$2" label="$3"
  if [[ "$actual" -ne "$expected" ]]; then
    echo "FAIL: $label expected exit $expected, got $actual" >&2
    exit 1
  fi
}

conflicting_pr='{"number":86,"url":"https://github.com/owner/repo/pull/86","headRefName":"branch","headRefOid":"abc123","baseRefOid":"def456","mergeable":"CONFLICTING","mergeStateStatus":"DIRTY"}'
set +e
result=$(run_script "$conflicting_pr" "$GREEN_CHECKS" '[]' $'.github/workflows/factory-routing.yml')
code=$?
set -e
assert_exit 0 "$code" "CONFLICTING with green checks"
jq -e '.status == "failed"' <<<"$result" >/dev/null
jq -e '.mergeable == "CONFLICTING"' <<<"$result" >/dev/null
jq -e '.conflicting_files == [".github/workflows/factory-routing.yml"]' <<<"$result" >/dev/null

unknown_pr='{"number":86,"url":"https://github.com/owner/repo/pull/86","headRefName":"branch","headRefOid":"abc123","baseRefOid":"def456","mergeable":"UNKNOWN","mergeStateStatus":"UNKNOWN"}'
set +e
result=$(run_script "$unknown_pr" "$GREEN_CHECKS")
code=$?
set -e
assert_exit 2 "$code" "UNKNOWN with green checks"
jq -e '.status != "passed"' <<<"$result" >/dev/null
jq -e '.mergeable == "UNKNOWN"' <<<"$result" >/dev/null

mergeable_pr='{"number":86,"url":"https://github.com/owner/repo/pull/86","headRefName":"branch","headRefOid":"abc123","baseRefOid":"def456","mergeable":"MERGEABLE","mergeStateStatus":"CLEAN"}'
set +e
result=$(run_script "$mergeable_pr" "$GREEN_CHECKS")
code=$?
set -e
assert_exit 0 "$code" "MERGEABLE with green checks"
jq -e '.status == "passed"' <<<"$result" >/dev/null
jq -e '.mergeable == "MERGEABLE"' <<<"$result" >/dev/null

echo "check-ci tests passed"
