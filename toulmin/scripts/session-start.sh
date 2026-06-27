#!/bin/bash
# Toulmin Critical Argumentation — SessionStart Hook
# Injects a minimal recovery pointer when state file exists.
# Claude reads the pointer, then reads the state file + gate docs for full context.

set -euo pipefail

STATE_FILE=".claude/toulmin-state.local.md"

# No state file → nothing to inject
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# Parse frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
CA_MODE=$(echo "$FRONTMATTER" | grep '^ca_mode:' | sed 's/ca_mode: *//' || echo "unknown")
PHASE=$(echo "$FRONTMATTER" | grep '^phase:' | sed 's/phase: *//' || echo "unknown")
GATE_CURRENT=$(echo "$FRONTMATTER" | grep '^gate_current:' | sed 's/gate_current: *//' || echo "none")
GATES_PASSED=$(echo "$FRONTMATTER" | grep '^gates_passed:' | sed 's/gates_passed: *//' || echo "[]")
GATE_DIR=$(echo "$FRONTMATTER" | grep '^gate_dir:' | sed 's/gate_dir: *//' || echo "")
LANG=$(echo "$FRONTMATTER" | grep '^lang:' | sed 's/lang: *//' || echo "en")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//' || echo "0")

# Parse gates_passed count (YAML array → count elements)
GATE_COUNT=$(echo "$GATES_PASSED" | grep -o '[a-z0-9_-]*' | grep -v '^$' | wc -l | tr -d ' ')

if [[ "$LANG" == "zh" ]]; then
  CONTEXT="[Toulmin] 状态文件: ${STATE_FILE} | 模式: ${CA_MODE} | 阶段: ${PHASE} | Gate: ${GATE_COUNT}/3 通过 | 轮次: ${ITERATION}"
  if [[ -n "$GATE_DIR" ]]; then
    CONTEXT="${CONTEXT} | Gate文档: ${GATE_DIR}"
  fi
  CONTEXT="${CONTEXT} | /toulmin-status 查看完整状态"
else
  CONTEXT="[Toulmin] State: ${STATE_FILE} | Mode: ${CA_MODE} | Phase: ${PHASE} | Gate: ${GATE_COUNT}/3 passed | Iteration: ${ITERATION}"
  if [[ -n "$GATE_DIR" ]]; then
    CONTEXT="${CONTEXT} | Gate docs: ${GATE_DIR}"
  fi
  CONTEXT="${CONTEXT} | /toulmin-status for full status"
fi

jq -n \
  --arg context "$CONTEXT" \
  '{
    "decision": "addContext",
    "context": $context
  }'

exit 0
