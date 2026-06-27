#!/bin/bash
# Toulmin Critical Argumentation — PreToolUse Hook
# Intercepts Write/Edit when gate_blocked=true in state file.
# Blocks coding tools until the active gate is cleared.

set -euo pipefail

HOOK_INPUT=$(cat)
# Load shared state reader
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/state.sh"

# No state file → no framework active → allow
if ! read_toulmin_state; then
  echo '{"decision":"allow"}'
  exit 0
fi

# Session isolation — skip enforcement for other sessions
if session_is_different "$HOOK_INPUT"; then
  echo '{"decision":"allow"}'
  exit 0
fi

# Gate not blocked → allow
if [[ "$STATE_GATE_BLOCKED" != "true" ]]; then
  echo '{"decision":"allow"}'
  exit 0
fi

# Gate blocked — build reason message
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // "unknown"')

if [[ "$STATE_LANG" == "zh" ]]; then
  REASON="⛔ Gate拦截: ${STATE_GATE_CURRENT} 未通过。模式: ${STATE_CA_MODE}。运行 /toulmin-status 查看详情，或完成当前gate验证后重试。"
else
  REASON="⛔ Gate blocked: ${STATE_GATE_CURRENT} not passed. Mode: ${STATE_CA_MODE}. Run /toulmin-status for details, or complete the current gate verification and retry."
fi

jq -n \
  --arg reason "$REASON" \
  '{
    "decision": "deny",
    "reason": $reason
  }'

exit 0
