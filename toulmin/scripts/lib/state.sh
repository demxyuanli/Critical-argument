#!/bin/bash
# Toulmin Critical Argumentation — Shared state file reader
# Source this file then call read_toulmin_state; access fields via $STATE_* vars.
# Returns 0 (and sets vars) if state file exists, 1 if absent.

set -euo pipefail

read_toulmin_state() {
  STATE_FILE=".claude/toulmin-state.local.md"

  if [[ ! -f "$STATE_FILE" ]]; then
    return 1
  fi

  local fm
  fm=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")

  state_field() { echo "$fm" | grep "^${1}:" | sed "s/^${1}: *//" || true; }

  STATE_SESSION_ID=$(state_field "session_id")
  STATE_GATE_BLOCKED=$(state_field "gate_blocked")
  STATE_GATE_CURRENT=$(state_field "gate_current")
  STATE_CA_MODE=$(state_field "ca_mode")
  STATE_LANG=$(state_field "lang")
  STATE_PHASE=$(state_field "phase")
  STATE_ITERATION=$(state_field "iteration")
  STATE_GATES_PASSED=$(state_field "gates_passed")
  STATE_GATE_DIR=$(state_field "gate_dir")
  STATE_CHECKPOINT_INTERVAL=$(state_field "checkpoint_interval")

  # Apply defaults for unset fields
  : "${STATE_GATE_BLOCKED:=false}"
  : "${STATE_CA_MODE:=unknown}"
  : "${STATE_LANG:=en}"
  : "${STATE_PHASE:=unknown}"
  : "${STATE_ITERATION:=0}"
  : "${STATE_GATES_PASSED:=[]}"
  : "${STATE_CHECKPOINT_INTERVAL:=0}"
  : "${STATE_GATE_CURRENT:=none}"
  : "${STATE_GATE_DIR:=}"

  return 0
}

# Returns 0 (true) if this hook should skip due to session ID mismatch.
# Call after read_toulmin_state succeeded.
session_is_different() {
  local hook_input="$1"
  local hook_session
  hook_session=$(echo "$hook_input" | jq -r '.session_id // ""')
  [[ -n "${STATE_SESSION_ID:-}" && "${STATE_SESSION_ID:-}" != "$hook_session" ]]
}

# Count gates in STATE_GATES_PASSED array [gate-1, gate-2, ...]
gate_count() {
  if [[ "${STATE_GATES_PASSED:-}" == "[]" ]]; then
    echo 0
  else
    echo "${STATE_GATES_PASSED}" | tr -cd ',' | wc -c | awk '{print $1 + 1}'
  fi
}
