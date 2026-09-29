#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT="$SCRIPT_DIR/release-info.sh"
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir "$TEST_DIR/bin"
cat >"$TEST_DIR/bin/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$1 $2" == "pr view" ]]; then
  exit 1
fi
if [[ "$1 $2" == "pr list" ]]; then
  echo '[]'
  exit 0
fi
echo "unexpected gh invocation: $*" >&2
exit 1
EOF
chmod +x "$TEST_DIR/bin/gh"
export PATH="$TEST_DIR/bin:$PATH"

git init --bare --quiet "$TEST_DIR/origin.git"
git clone --quiet "$TEST_DIR/origin.git" "$TEST_DIR/work"
cd "$TEST_DIR/work"
git config user.name 'Release Test'
git config user.email 'release-test@example.com'
git checkout -q -b main
mkdir .claude-plugin
printf '{"version":"0.12.0"}\n' > .claude-plugin/plugin.json
printf '# Changelog\n' > CHANGELOG.md
printf 'base\n' > conflict.txt
git add .claude-plugin/plugin.json CHANGELOG.md conflict.txt
git commit -qm 'chore: initial release'
git push -q -u origin main
git tag v0.12.0
git push -q origin v0.12.0

git checkout -q -b branch-a
printf 'A\n' > a.txt
git add a.txt
git commit -qm 'fix: branch A change'
printf '{"version":"0.12.1"}\n' > .claude-plugin/plugin.json
git add .claude-plugin/plugin.json
git commit -qm 'chore: release v0.12.1'

git checkout -q main
git checkout -q -b branch-b
printf 'B\n' > b.txt
git add b.txt
git commit -qm 'fix: branch B change'
printf '{"version":"0.12.1"}\n' > .claude-plugin/plugin.json
git add .claude-plugin/plugin.json
git commit -qm 'chore: release v0.12.1'

run_info() {
  local expected_code="$1" expected_error="$2" label="$3" code
  set +e
  bash "$SCRIPT" > "$TEST_DIR/stdout" 2> "$TEST_DIR/stderr"
  code=$?
  set -e
  if [[ "$expected_code" == 0 && "$code" -ne 0 ]] ||
     [[ "$expected_code" != 0 && "$code" -eq 0 ]]; then
    echo "FAIL: $label: exit $code, expected $expected_code" >&2
    cat "$TEST_DIR/stdout" "$TEST_DIR/stderr" >&2
    exit 1
  fi
  if [[ "$expected_code" == 0 ]]; then
    if [[ -n "$expected_error" ]]; then
      jq -e --arg error "$expected_error" '.error == $error' "$TEST_DIR/stdout" >/dev/null
    else
      jq -e 'has("error") | not' "$TEST_DIR/stdout" >/dev/null
    fi
  else
    jq -e --arg error "$expected_error" '.error == $error' "$TEST_DIR/stderr" >/dev/null
  fi
}

# A release commit is valid while its version is ahead of main and untagged.
run_info 0 already_released 'branch B before A merges'

# A tag alone makes the branch release stale, even before main advances.
git tag v0.12.1 branch-a
git push -q origin v0.12.1
run_info 1 stale_release 'branch B with existing tag'

git checkout -q main
git merge -q --no-edit branch-a
git push -q origin main
git checkout -q branch-b
run_info 1 stale_release 'branch B after A merges and tags'
jq -e '.message | contains("v0.12.1")' "$TEST_DIR/stderr" >/dev/null

# The version comparison must detect the same stale release without a tag.
git tag -d v0.12.1 >/dev/null
git push -q origin :refs/tags/v0.12.1
run_info 1 stale_release 'branch B after A merges without tag'

# A branch without a release commit continues to the normal PR classification.
git checkout -q main
git checkout -q -b no-release HEAD~2
printf 'unreleased\n' > unreleased.txt
git add unreleased.txt
git commit -qm 'fix: unreleased change'
run_info 0 '' 'branch without release commit'
jq -e '.current_version == "0.12.1" and .new_version == "0.12.2"' "$TEST_DIR/stdout" >/dev/null

# Merge conflicts still take precedence over release checks.
git checkout -q main
git checkout -q -b conflicting HEAD~2
printf 'branch\n' > conflict.txt
git add conflict.txt
git commit -qm 'fix: conflicting change'
git checkout -q main
printf 'main\n' > conflict.txt
git add conflict.txt
git commit -qm 'fix: main conflict'
git push -q origin main
git checkout -q conflicting
run_info 1 merge_conflict 'conflicting branch'

echo 'release-info tests passed'
