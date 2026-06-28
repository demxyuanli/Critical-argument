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
if [[ "$STATE_LANG" == "zh" ]]; then
  REASON="⛔ Gate拦截: ${STATE_GATE_CURRENT} 未通过（第${STATE_GATE_ATTEMPTS}次尝试）。运行 /toulmin-status 查看详情。驳回: /toulmin-override \"理由\"。手动解除: rm -f .claude/toulmin-state.local.md。"
else
  REASON="⛔ Gate blocked: ${STATE_GATE_CURRENT} not passed (attempt #${STATE_GATE_ATTEMPTS}). Run /toulmin-status for details. Override: /toulmin-override \"reason\". Manual unblock: rm -f .claude/toulmin-state.local.md."
fi

jq -n \
  --arg reason "$REASON" \
  '{
    "decision": "deny",
    "reason": $reason
  }'

exit 0
