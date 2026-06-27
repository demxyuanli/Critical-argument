#!/bin/bash
# Toulmin Critical Argumentation — Shared state file updater
# Usage: update-gate.sh <gate-name> <verdict> [next-gate] [next-phase]
#   verdict: passed | failed
#   gate-name: gate-2, gate-3
#
# Called by Claude via Bash tool from toulmin-verify and toulmin-debate SKILL.md.

set -euo pipefail

GATE="${1:?missing gate-name}"
VERDICT="${2:?missing verdict}"
NEXT_GATE="${3:-null}"
NEXT_PHASE="${4:-${GATE}-passed}"
STATE_FILE=".claude/toulmin-state.local.md"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "⚠️  update-gate.sh: State file not found at $STATE_FILE" >&2
  exit 1
fi

if [[ "$VERDICT" == "passed" ]]; then
  # Idempotent append to gates_passed
  if ! grep -q "$GATE" "$STATE_FILE"; then
    if grep -q '^gates_passed: \[.\]' "$STATE_FILE"; then
      sed -i.bak "s/^gates_passed: \[\(.*\)\]/gates_passed: [\1, ${GATE}]/" "$STATE_FILE"
    else
      sed -i.bak "s/^gates_passed: \[\]/gates_passed: [${GATE}]/" "$STATE_FILE"
    fi
  fi
  sed -i.bak \
    -e "s/^gate_current: .*/gate_current: ${NEXT_GATE}/" \
    -e 's/^gate_blocked: .*/gate_blocked: false/' \
    -e "s/^phase: .*/phase: ${NEXT_PHASE}/" \
    "$STATE_FILE"
elif [[ "$VERDICT" == "failed" ]]; then
  sed -i.bak \
    -e 's/^gate_blocked: .*/gate_blocked: true/' \
    -e "s/^gate_current: .*/gate_current: ${GATE}/" \
    -e "s/^phase: .*/phase: ${GATE}-failed/" \
    "$STATE_FILE"
else
  echo "⚠️  update-gate.sh: Invalid verdict '$VERDICT' (expected 'passed' or 'failed')" >&2
  exit 1
fi
