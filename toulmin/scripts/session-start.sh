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

# --- Historical awareness: scan past gate docs ---
PAST_CONTEXT=""
PAST_DIR="docs/toulmin"
if [[ -d "$PAST_DIR" && -n "${STATE_GATE_DIR:-}" ]]; then
  # Count past task dirs (excluding current)
  PAST_COUNT=$(find "$PAST_DIR" -maxdepth 1 -type d -mindepth 1 2>/dev/null | while read d; do
    [[ "$d" != "${STATE_GATE_DIR%/}" ]] && echo "$d"
  done | wc -l)

  if [[ "$PAST_COUNT" -gt 0 ]]; then
    # Get current task slug for matching
    CURRENT_TASK=$(basename "${STATE_GATE_DIR%/}" | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-//')

    # Quick scan for similar past tasks (>3 char overlap in task slug)
    SIMILAR=""
    if [[ -n "$CURRENT_TASK" ]]; then
      SIMILAR=$(find "$PAST_DIR" -maxdepth 1 -type d -mindepth 1 -name "*${CURRENT_TASK:0:3}*" 2>/dev/null | while read d; do
        [[ "$d" != "${STATE_GATE_DIR%/}" ]] && echo "$(basename "$d")"
      done | tr '\n' ' ')
    fi

    if [[ "$STATE_LANG" == "zh" ]]; then
      PAST_CONTEXT="历史任务: ${PAST_COUNT}个 (ls docs/toulmin/)。"
      [[ -n "$SIMILAR" ]] && PAST_CONTEXT="${PAST_CONTEXT} ⚠️ 疑似相关: ${SIMILAR}— 需检查教训是否复用。"
    else
      PAST_CONTEXT="Past tasks: ${PAST_COUNT} (ls docs/toulmin/)."
      [[ -n "$SIMILAR" ]] && PAST_CONTEXT="${PAST_CONTEXT} ⚠️ Possible related: ${SIMILAR} — check if past lessons apply."
    fi
  fi
fi

PARTS+=("Override: ${STATE_OVERRIDE_COUNT:-0}")
[[ -n "$PAST_CONTEXT" ]] && PARTS+=("$PAST_CONTEXT")

CONTEXT=$(IFS=' | '; echo "${PARTS[*]}")

jq -n \
  --arg context "$CONTEXT" \
  '{
    "decision": "addContext",
    "context": $context
  }'

exit 0
