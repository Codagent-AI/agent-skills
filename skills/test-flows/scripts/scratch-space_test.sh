#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)

for skill in test-flows prepare-acceptance; do
  file="$REPO_ROOT/skills/$skill/SKILL.md"

  if ! grep -q 'scratch_dir' "$file"; then
    echo "FAIL: $skill does not document scratch_dir" >&2
    exit 1
  fi

  if grep -q '/tmp' "$file"; then
    echo "FAIL: $skill mentions /tmp" >&2
    exit 1
  fi

  if ! grep -q '^## Scratch space$' "$file"; then
    echo "FAIL: $skill has no scratch-space guidance" >&2
    exit 1
  fi

  if ! grep -q 'unique scratch' "$file" || ! grep -q 'remove only' "$file"; then
    echo "FAIL: $skill does not require unique, owned scratch cleanup" >&2
    exit 1
  fi
done

echo "PASS: scratch-space guidance is present in both skills"
