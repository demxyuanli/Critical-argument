#!/bin/bash
# Toulmin Critical Argumentation — Stop Hook
# Responsibilities:
#   1. Iteration counting (every stop increments counter)
#   2. Completion enforcement (gate_blocked=true → block stop)
#   3. Checkpoint injection (vibe mode, iteration % N == 0 → block + inject checkpoint task)

set -euo pipefail

HOOK_INPUT=$(cat)
STATE_FILE=".claude/toulmin-state.local.md"

# No state file → allow
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# Parse frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
GATE_BLOCKED=$(echo "$FRONTMATTER" | grep '^gate_blocked:' | sed 's/gate_blocked: *//' || echo "false")
CA_MODE=$(echo "$FRONTMATTER" | grep '^ca_mode:' | sed 's/ca_mode: *//' || echo "structured")
LANG=$(echo "$FRONTMATTER" | grep '^lang:' | sed 's/lang: *//' || echo "en")
CHECKPOINT_INTERVAL=$(echo "$FRONTMATTER" | grep '^checkpoint_interval:' | sed 's/checkpoint_interval: *//' || echo "0")

# Session isolation
STATE_SESSION=$(echo "$FRONTMATTER" | grep '^session_id:' | sed 's/session_id: *//' || true)
HOOK_SESSION=$(echo "$HOOK_INPUT" | jq -r '.session_id // ""')
if [[ -n "$STATE_SESSION" ]] && [[ "$STATE_SESSION" != "$HOOK_SESSION" ]]; then
  exit 0
fi

# Validate iteration is numeric
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "⚠️  Toulmin: State file corrupted (iteration=$ITERATION). Removing state file to stop interventions." >&2
  echo "   Run /toulmin-plan or /toulmin-vibe to start fresh." >&2
  rm -f "$STATE_FILE" 2>/dev/null || true
  exit 0
fi

# Increment iteration
NEXT_ITERATION=$((ITERATION + 1))
TEMP_FILE="${STATE_FILE}.tmp.$$"
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$STATE_FILE"

# --- Block conditions ---

# Condition 1: gate_blocked → block completion
if [[ "$GATE_BLOCKED" == "true" ]]; then
  GATE_CURRENT=$(echo "$FRONTMATTER" | grep '^gate_current:' | sed 's/gate_current: *//' || echo "unknown")
  if [[ "$LANG" == "zh" ]]; then
    SYSTEM_MSG="⛔ 不能声称完成: ${GATE_CURRENT} 未通过。运行 /toulmin-status 查看详情，或 /toulmin-verify 执行验证。"
    REASON="Gate ${GATE_CURRENT} 未通过，请先完成当前gate验证。"
  else
    SYSTEM_MSG="⛔ Cannot claim completion: ${GATE_CURRENT} not passed. Run /toulmin-status for details, or /toulmin-verify to execute verification."
    REASON="Gate ${GATE_CURRENT} not passed. Complete the current gate verification first."
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
if [[ "$CA_MODE" == "vibe" ]] && [[ "$CHECKPOINT_INTERVAL" =~ ^[0-9]+$ ]] && [[ "$CHECKPOINT_INTERVAL" -gt 0 ]]; then
  if [[ $((NEXT_ITERATION % CHECKPOINT_INTERVAL)) -eq 0 ]]; then
    if [[ "$LANG" == "zh" ]]; then
      SYSTEM_MSG="🔍 Toulmin checkpoint: 第${NEXT_ITERATION}轮。请运行L0信号扫描: 检查模糊词密度、语义重复、叙事标记、未验证假设。使用 /toulmin-status 查看状态，或回复'继续'跳过。"
    else
      SYSTEM_MSG="🔍 Toulmin checkpoint: iteration ${NEXT_ITERATION}. Run L0 signal scan: check fuzzy-word density, semantic repetition, narrative markers, unverified assumptions. Use /toulmin-status for status, or reply 'continue' to skip."
    fi
    jq -n \
      --arg msg "$SYSTEM_MSG" \
      '{
        "decision": "block",
        "reason": "Checkpoint due at iteration '"${NEXT_ITERATION}"'. Run L0 signal scan.",
        "systemMessage": $msg
      }'
    exit 0
  fi
fi

# Allow stop
exit 0
