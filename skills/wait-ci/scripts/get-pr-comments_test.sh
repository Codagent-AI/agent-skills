#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT="$SCRIPT_DIR/get-pr-comments.sh"
MOCK_BIN=$(mktemp -d)
trap 'rm -rf "$MOCK_BIN"' EXIT

cat >"$MOCK_BIN/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "$*" != *"__typename"* ]]; then
  echo "GraphQL query did not request author __typename" >&2
  exit 1
fi

printf '%s\n' "$MOCK_GRAPHQL_RESPONSE"
EOF
chmod +x "$MOCK_BIN/gh"

run_script() {
  PATH="$MOCK_BIN:$PATH" MOCK_GRAPHQL_RESPONSE="$1" \
    bash "$SCRIPT" owner repo 42 pr-author
}

only_bot_comments='{"data":{"repository":{"pullRequest":{"author":{"login":"pr-author","__typename":"User"},"reviewThreads":{"nodes":[]},"comments":{"nodes":[{"author":{"login":"qodo-merge-pro[bot]","__typename":"Bot"},"body":"Analysis summary"}]}}}}}'
result=$(run_script "$only_bot_comments")
jq -e '.has_comments == false' <<<"$result" >/dev/null
jq -e '.issue_comments == []' <<<"$result" >/dev/null
jq -e '.informational_bot_comments == [{"author":"qodo-merge-pro[bot]","body":"Analysis summary"}]' <<<"$result" >/dev/null

human_comment='{"data":{"repository":{"pullRequest":{"author":{"login":"pr-author","__typename":"User"},"reviewThreads":{"nodes":[]},"comments":{"nodes":[{"author":{"login":"reviewer","__typename":"User"},"body":"Please update this."}]}}}}}'
result=$(run_script "$human_comment")
jq -e '.has_comments == true' <<<"$result" >/dev/null
jq -e '.issue_comments == [{"author":"reviewer","body":"Please update this."}]' <<<"$result" >/dev/null
jq -e '.informational_bot_comments == []' <<<"$result" >/dev/null

unresolved_bot_thread='{"data":{"repository":{"pullRequest":{"author":{"login":"pr-author","__typename":"User"},"reviewThreads":{"nodes":[{"isResolved":false,"comments":{"nodes":[{"author":{"login":"qodo-merge-pro[bot]","__typename":"Bot"},"body":"Potential bug","path":"script.sh","line":12,"originalLine":null}]}}]},"comments":{"nodes":[]}}}}}'
result=$(run_script "$unresolved_bot_thread")
jq -e '.has_comments == true' <<<"$result" >/dev/null
jq -e '.unresolved_threads == [{"file":"script.sh","line":12,"author":"qodo-merge-pro[bot]","body":"Potential bug"}]' <<<"$result" >/dev/null

pr_author_comment='{"data":{"repository":{"pullRequest":{"author":{"login":"pr-author","__typename":"User"},"reviewThreads":{"nodes":[]},"comments":{"nodes":[{"author":{"login":"pr-author","__typename":"User"},"body":"Context from the author"}]}}}}}'
result=$(run_script "$pr_author_comment")
jq -e '.has_comments == false' <<<"$result" >/dev/null
jq -e '.issue_comments == []' <<<"$result" >/dev/null
jq -e '.informational_bot_comments == []' <<<"$result" >/dev/null

missing_author='{"data":{"repository":{"pullRequest":{"author":{"login":"pr-author","__typename":"User"},"reviewThreads":{"nodes":[]},"comments":{"nodes":[{"author":null,"body":"Comment from a deleted account"}]}}}}}'
result=$(run_script "$missing_author")
jq -e '.has_comments == true' <<<"$result" >/dev/null
jq -e '.issue_comments == [{"author":"unknown","body":"Comment from a deleted account"}]' <<<"$result" >/dev/null

echo "get-pr-comments tests passed"
