#!/bin/bash
# Toulmin Critical Argumentation — Stop Hook
# Responsibilities:
#   1. Iteration counting (every stop increments counter)
#   2. Completion enforcement (gate_blocked=true → block stop)
#   3. Checkpoint injection (vibe mode, iteration % N == 0 → block + inject checkpoint task)
#   4. Drift self-check (structured: every 30, vibe: at checkpoint)

set -euo pipefail

HOOK_INPUT=$(cat)
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/state.sh"

# No state file → allow
if ! read_toulmin_state; then
  exit 0
fi

# Session isolation
if session_is_different "$HOOK_INPUT"; then
  exit 0
fi

# Validate iteration is numeric
if [[ ! "$STATE_ITERATION" =~ ^[0-9]+$ ]]; then
  echo "⚠️  Toulmin: State file corrupted (iteration=$STATE_ITERATION). Resetting iteration to 0." >&2
  sed -i.bak 's/^iteration: .*/iteration: 0/' "$STATE_FILE" 2>/dev/null || true
  exit 0
fi

# Increment iteration
NEXT_ITERATION=$((STATE_ITERATION + 1))
TEMP_FILE="${STATE_FILE}.tmp.$$"
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$STATE_FILE"

# --- Block conditions ---

# Condition 1: gate_blocked → block completion
if [[ "$STATE_GATE_BLOCKED" == "true" ]]; then
  if [[ "$STATE_LANG" == "zh" ]]; then
    SYSTEM_MSG="⛔ 不能声称完成: ${STATE_GATE_CURRENT} 未通过（第${STATE_GATE_ATTEMPTS}次尝试）。运行 /toulmin-status 查看详情。驳回: /toulmin-override \"理由\"。"
    REASON="Gate ${STATE_GATE_CURRENT} 未通过——完成验证或override后重试。"
  else
    SYSTEM_MSG="⛔ Cannot claim completion: ${STATE_GATE_CURRENT} not passed (attempt #${STATE_GATE_ATTEMPTS}). Run /toulmin-status for details. Override: /toulmin-override \"reason\"."
    REASON="Gate ${STATE_GATE_CURRENT} not passed — complete verification or override."
  fi
  jq -n \
    --arg reason "$REASON" \
    --arg msg "$SYSTEM_MSG" \
    '{
      "decision": "block",
      "reason": $reason,
      "systemMessage": $msg
    }'
  exit 0
fi

# Condition 2: Vibe checkpoint due (iteration % interval == 0)
if [[ "$STATE_CA_MODE" == "vibe" ]] && [[ "$STATE_CHECKPOINT_INTERVAL" =~ ^[0-9]+$ ]] && [[ "$STATE_CHECKPOINT_INTERVAL" -gt 0 ]]; then
  if [[ $((NEXT_ITERATION % STATE_CHECKPOINT_INTERVAL)) -eq 0 ]]; then
    DRIFT_CHECK=""
    if [[ "$STATE_LANG" == "zh" ]]; then
      DRIFT_CHECK="同时运行漂移自检: 当前对话是否偏离了原始任务？如是，运行: bash \${CLAUDE_PLUGIN_ROOT}/scripts/partition-track.sh \"<新主题名>\" \"drift-detected\""
    else
      DRIFT_CHECK="Also run drift self-check: has the conversation drifted from the original task? If so, run: bash \${CLAUDE_PLUGIN_ROOT}/scripts/partition-track.sh \"<new-topic>\" \"drift-detected\""
    fi

    if [[ "$STATE_LANG" == "zh" ]]; then
      SYSTEM_MSG="🔍 Toulmin checkpoint: 第${NEXT_ITERATION}轮。请运行L0信号扫描: 检查模糊词密度、语义重复、叙事标记、未验证假设。${DRIFT_CHECK}。使用 /toulmin-status 查看状态，或回复'继续'跳过。"
    else
      SYSTEM_MSG="🔍 Toulmin checkpoint: iteration ${NEXT_ITERATION}. Run L0 signal scan: check fuzzy-word density, semantic repetition, narrative markers, unverified assumptions. ${DRIFT_CHECK} Use /toulmin-status for status, or reply 'continue' to skip."
    fi
    jq -n \
      --arg msg "$SYSTEM_MSG" \
      '{
        "decision": "block",
        "reason": "Checkpoint due at iteration '"${NEXT_ITERATION}"'. Run L0 signal scan + drift self-check.",
        "systemMessage": $msg
      }'
    exit 0
  fi
fi

# Condition 3: Structured mode drift check (every 30 iterations)
if [[ "$STATE_CA_MODE" == "structured" ]] && [[ $((NEXT_ITERATION % 30)) -eq 0 ]] && [[ "$NEXT_ITERATION" -gt 0 ]]; then
  if [[ "$STATE_LANG" == "zh" ]]; then
    SYSTEM_MSG="🔍 Toulmin 漂移自检 (第${NEXT_ITERATION}轮): 当前对话是否偏离了原始任务？如已偏离，运行: bash \${CLAUDE_PLUGIN_ROOT}/scripts/partition-track.sh \"<新主题>\" \"drift-detected\"。使用 /toulmin-tree 查看分区历史。"
  else
    SYSTEM_MSG="🔍 Toulmin drift check (iteration ${NEXT_ITERATION}): Has the conversation drifted from the original task? If so, run: bash \${CLAUDE_PLUGIN_ROOT}/scripts/partition-track.sh \"<new-topic>\" \"drift-detected\". Use /toulmin-tree to view partition history."
  fi
  jq -n \
    --arg msg "$SYSTEM_MSG" \
    '{
      "decision": "block",
      "reason": "Drift self-check at iteration '"${NEXT_ITERATION}"'.",
      "systemMessage": $msg
    }'
  exit 0
fi

# Allow stop
exit 0
