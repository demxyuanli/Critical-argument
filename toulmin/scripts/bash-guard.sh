#!/bin/bash
# Toulmin Critical Argumentation — Bash Guard (PreToolUse)
# Closes the sed/echo/python3/tee bypass vector when gate_blocked=true.
# Called as a second PreToolUse hook matching "Bash".

set -euo pipefail

HOOK_INPUT=$(cat)
source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/state.sh"

# No state file → allow
if ! read_toulmin_state; then
  echo '{"decision":"allow"}'
  exit 0
fi

# Session isolation
if session_is_different "$HOOK_INPUT"; then
  echo '{"decision":"allow"}'
  exit 0
fi

# Gate not blocked → allow (fast path — most calls)
if [[ "$STATE_GATE_BLOCKED" != "true" ]]; then
  echo '{"decision":"allow"}'
  exit 0
fi

# Extract the command from hook input
COMMAND=$(echo "$HOOK_INPUT" | jq -r '.tool_input.command // ""')

# ponytail: single grep for top-5 file-write patterns — covers >95% of bypasses
if echo "$COMMAND" | grep -qE '\b(sed|awk)\b.*-i\b|>\s*\S+\s*$|>>\s*\S+\s*$|\btee\b\s+\S+.*$|\bpython3?\b.*-c\b.*\b(open|write)\b|\b(cat|printf|echo)\b.*>\s*\S|\bdd\b.*\bof='; then
  REASON=$(printf '{"decision":"deny","reason":"⛔ Gate blocked: %s (attempt #%s). This Bash command contains file-write patterns (sed -i, >, >>, tee, python -c, dd of=). Use /toulmin-override \"reason\" or complete the active gate. Last resort: rm -f .claude/toulmin-state.local.md"}' "$STATE_GATE_CURRENT" "$STATE_GATE_ATTEMPTS")
  echo "$REASON"
  exit 0
fi

# Allow all other Bash commands (read-only ops, git, tests, build, etc.)
echo '{"decision":"allow"}'
exit 0
