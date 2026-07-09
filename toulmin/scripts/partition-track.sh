#!/bin/bash
# Toulmin Critical Argumentation — Partition Tracker
# Records context partition transitions for drift detection.
# Usage: partition-track.sh <new-partition-name> [reason]
# Called via Bash tool from skills or hooks.

set -euo pipefail

PARTITION="${1:?missing partition name}"
REASON="${2:-manual}"
STATE_FILE=".claude/toulmin-state.local.md"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "⚠️  partition-track.sh: State file not found at $STATE_FILE" >&2
  exit 1
fi

source "${CLAUDE_PLUGIN_ROOT}/scripts/lib/state.sh"

if ! read_toulmin_state; then
  echo "⚠️  partition-track.sh: Cannot read state" >&2
  exit 1
fi

CURRENT="${STATE_PARTITION_CURRENT:-task}"
ITERATION="${STATE_ITERATION:-0}"

# No-op if same partition
if [[ "$PARTITION" == "$CURRENT" ]]; then
  exit 0
fi

# Append to partition history
NEW_ENTRY="${CURRENT}→${PARTITION}@${ITERATION}:${REASON}"
if grep -qE '^partitions: \[.+\]' "$STATE_FILE"; then
  # Non-empty array → insert comma before new entry
  sed -i.bak "s/^partitions: \[\(.*\)\]/partitions: [\1, \"${NEW_ENTRY}\"]/" "$STATE_FILE"
else
  # Empty array [] → first entry
  sed -i.bak "s/^partitions: \[\]/partitions: [\"${NEW_ENTRY}\"]/" "$STATE_FILE"
fi

# Update current partition
sed -i.bak "s/^partition_current: .*/partition_current: ${PARTITION}/" "$STATE_FILE"

rm -f "${STATE_FILE}.bak"
exit 0
