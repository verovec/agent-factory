#!/usr/bin/env bash
# Reads PreToolUse payload on stdin. Blocks Write/Edit whose new content contains emojis.
set -euo pipefail
payload="$(cat)"
content="$(printf '%s' "$payload" | jq -r '.tool_input.content // .tool_input.new_string // empty')"
if printf '%s' "$content" | grep -Pq '[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}\x{2190}-\x{21FF}\x{2B00}-\x{2BFF}]'; then
  echo "Blocked: emojis are not allowed in this workspace (see CLAUDE.md)." >&2
  exit 2
fi
exit 0
