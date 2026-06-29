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
  REASON="⛔ Gate拦截: ${STATE_GATE_CURRENT} 未通过（第${STATE_GATE_ATTEMPTS}次尝试）。运行 /toulmin-status。优先: /toulmin-override \"理由\"。最后手段: rm -f .claude/toulmin-state.local.md（丢失全部gate进度）。"
else
  REASON="⛔ Gate blocked: ${STATE_GATE_CURRENT} not passed (attempt #${STATE_GATE_ATTEMPTS}). Run /toulmin-status. Preferred: /toulmin-override \"reason\". Last resort: rm -f .claude/toulmin-state.local.md (loses all gate progress)."
fi

jq -n \
  --arg reason "$REASON" \
  '{
    "decision": "deny",
    "reason": $reason
  }'

exit 0
