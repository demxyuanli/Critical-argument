#!/bin/bash
# Toulmin Critical Argumentation — SessionStart Hook
# Injects a minimal recovery pointer when state file exists.
# Claude reads the pointer, then reads the state file + gate docs for full context.

set -euo pipefail

source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/state.sh"

# No state file → nothing to inject
if ! read_toulmin_state; then
  exit 0
fi

# Build context line with localized labels
if [[ "$STATE_LANG" == "zh" ]]; then
  LABELS=("状态文件" "模式" "阶段" "Gate" "轮次" "Gate文档" "查看完整状态")
else
  LABELS=("State" "Mode" "Phase" "Gate" "Iteration" "Gate docs" "for full status")
fi

CLAIMED=$(gate_count)
VERIFIED=$(verified_gate_count)

GATE_DISPLAY="${CLAIMED}/3 passed"
if [[ $VERIFIED -ne $CLAIMED ]] && [[ -n "${STATE_GATE_DIR:-}" ]]; then
  # State file claims more passed gates than verified in gate docs — may be stale
  GATE_DISPLAY="${VERIFIED}/3 verified (state file claims ${CLAIMED})"
fi

PARTS=("[Toulmin] ${LABELS[0]}: ${STATE_FILE}")
PARTS+=("${LABELS[1]}: ${STATE_CA_MODE}")
PARTS+=("${LABELS[2]}: ${STATE_PHASE}")
PARTS+=("${LABELS[3]}: ${GATE_DISPLAY}")
PARTS+=("${LABELS[4]}: ${STATE_ITERATION}")
[[ -n "${STATE_GATE_DIR:-}" ]] && PARTS+=("${LABELS[5]}: ${STATE_GATE_DIR}")
PARTS+=("/toulmin-status ${LABELS[6]}")

CONTEXT=$(IFS=' | '; echo "${PARTS[*]}")

jq -n \
  --arg context "$CONTEXT" \
  '{
    "decision": "addContext",
    "context": $context
  }'

exit 0
