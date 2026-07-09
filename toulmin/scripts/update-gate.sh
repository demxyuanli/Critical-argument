#!/bin/bash
# Toulmin Critical Argumentation — Shared state file updater
# Usage: update-gate.sh <gate-name> <verdict> [next-gate] [next-phase]
#   verdict: passed | failed
#   gate-name: gate-1, gate-2, gate-3
#
# Called by Claude via Bash tool from toulmin-plan, toulmin-verify, and toulmin-debate SKILL.md.

set -euo pipefail

GATE="${1:?missing gate-name}"
VERDICT="${2:?missing verdict}"
NEXT_GATE="${3:-}"
NEXT_PHASE="${4:-${GATE}-passed}"
STATE_FILE=".claude/toulmin-state.local.md"

# Validate gate name
case "$GATE" in
  gate-1|gate-2|gate-3) ;;
  *) echo "⚠️  update-gate.sh: Invalid gate '$GATE' (expected gate-1, gate-2, or gate-3)" >&2; exit 1 ;;
esac

if [[ ! -f "$STATE_FILE" ]]; then
  echo "⚠️  update-gate.sh: State file not found at $STATE_FILE" >&2
  exit 1
fi

if [[ "$VERDICT" == "passed" ]]; then
  # Build sed expressions for single atomic invocation
  SED_EXPRS=()

  # Idempotent append to gates_passed (anchored to gates_passed line only)
  if ! grep -q "^gates_passed:.*\<${GATE}\>" "$STATE_FILE"; then
    if grep -qE '^gates_passed: \[.+\]' "$STATE_FILE"; then
      # Non-empty array [x, y] → append ", gate"
      SED_EXPRS+=(-e "s/^gates_passed: \[\(.*\)\]/gates_passed: [\1, ${GATE}]/")
    else
      # Empty array [] → set [gate]
      SED_EXPRS+=(-e "s/^gates_passed: \[\]/gates_passed: [${GATE}]/")
    fi
  fi

  # Update gate_current (skip if NEXT_GATE is empty — final gate)
  if [[ -n "$NEXT_GATE" ]]; then
    SED_EXPRS+=(-e "s/^gate_current: .*/gate_current: ${NEXT_GATE}/")
  fi

  SED_EXPRS+=(-e 's/^gate_blocked: .*/gate_blocked: false/')
  SED_EXPRS+=(-e "s/^phase: .*/phase: ${NEXT_PHASE}/")
  SED_EXPRS+=(-e 's/^gate_attempts: .*/gate_attempts: 0/')

  sed -i.bak "${SED_EXPRS[@]}" "$STATE_FILE"

elif [[ "$VERDICT" == "failed" ]]; then
  # Increment gate attempt counter
  cur_attempts=$(grep '^gate_attempts:' "$STATE_FILE" | sed 's/gate_attempts: *//' || echo 0)
  cur_attempts=$((cur_attempts + 1))
  sed -i.bak \
    -e 's/^gate_blocked: .*/gate_blocked: true/' \
    -e "s/^gate_current: .*/gate_current: ${GATE}/" \
    -e "s/^phase: .*/phase: ${GATE}-failed/" \
    -e "s/^gate_attempts: .*/gate_attempts: ${cur_attempts}/" \
    "$STATE_FILE"
else
  echo "⚠️  update-gate.sh: Invalid verdict '$VERDICT' (expected 'passed' or 'failed')" >&2
  exit 1
fi

# Clean up backup
rm -f "${STATE_FILE}.bak"
