#!/bin/bash
# Toulmin Framework — PreToolUse Hook
# Intercepts Write/Edit when gate_blocked=true in state file.
# Blocks coding tools until the active gate is cleared.

set -euo pipefail

HOOK_INPUT=$(cat)
STATE_FILE=".claude/toulmin-state.local.md"

# No state file → no framework active → allow
if [[ ! -f "$STATE_FILE" ]]; then
  echo '{"decision":"allow"}'
  exit 0
fi

# Parse frontmatter fields
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
GATE_BLOCKED=$(echo "$FRONTMATTER" | grep '^gate_blocked:' | sed 's/gate_blocked: *//')
GATE_CURRENT=$(echo "$FRONTMATTER" | grep '^gate_current:' | sed 's/gate_current: *//' || echo "unknown")
CA_MODE=$(echo "$FRONTMATTER" | grep '^ca_mode:' | sed 's/ca_mode: *//' || echo "unknown")
LANG=$(echo "$FRONTMATTER" | grep '^lang:' | sed 's/lang: *//' || echo "en")

# Gate not blocked → allow
if [[ "$GATE_BLOCKED" != "true" ]]; then
  echo '{"decision":"allow"}'
  exit 0
fi

# Gate blocked — build reason message
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // "unknown"')

if [[ "$LANG" == "zh" ]]; then
  REASON="⛔ Gate拦截: ${GATE_CURRENT} 未通过。模式: ${CA_MODE}。运行 /toulmin-status 查看详情，或完成当前gate验证后重试。"
else
  REASON="⛔ Gate blocked: ${GATE_CURRENT} not passed. Mode: ${CA_MODE}. Run /toulmin-status for details, or complete the current gate verification and retry."
fi

jq -n \
  --arg reason "$REASON" \
  '{
    "decision": "deny",
    "reason": $reason
  }'

exit 0
