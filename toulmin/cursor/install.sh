#!/bin/bash
# Install toulmin plugin for Cursor IDE
# Usage: bash toulmin/cursor/install.sh
#
# Copies skills to ~/.cursor/skills-cursor/toulmin/
# Merges hooks into ~/.cursor/hooks.json (backs up original)

set -euo pipefail

CURSOR_HOME="${HOME}/.cursor"
SKILLS_DST="${CURSOR_HOME}/skills-cursor/toulmin"
HOOKS_DST="${CURSOR_HOME}/hooks.json"
SRC_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Toulmin Cursor Install ==="

# 1. Copy skills + agents + scripts
mkdir -p "${SKILLS_DST}"
cp -r "${SRC_DIR}/skills" "${SKILLS_DST}/"
cp -r "${SRC_DIR}/agents" "${SKILLS_DST}/"
cp -r "${SRC_DIR}/scripts" "${SKILLS_DST}/"
cp "${SRC_DIR}/.claude-plugin/plugin.json" "${SKILLS_DST}/" 2>/dev/null || true
echo "  Skills → ${SKILLS_DST}"

# 2. Install hooks
CURSOR_HOOKS="${SRC_DIR}/cursor/hooks.json"
if [[ -f "${HOOKS_DST}" ]]; then
  cp "${HOOKS_DST}" "${HOOKS_DST}.toulmin-backup"
  echo "  Backed up existing hooks → ${HOOKS_DST}.toulmin-backup"
  echo ""
  echo "  ⚠️  Merge required. Add these entries to ${HOOKS_DST}:"
  echo ""
  echo "  preToolUse array (append to existing entries):"
  echo '    { "matcher": "Write|Edit", "command": "env CLAUDE_PLUGIN_ROOT=... bash ...pre-tool-use.sh" }'
  echo '    { "matcher": "Bash",     "command": "env CLAUDE_PLUGIN_ROOT=... bash ...bash-guard.sh" }'
  echo ""
  echo "  sessionStart array (append to existing entries):"
  echo '    { "matcher": "startup",  "command": "env CLAUDE_PLUGIN_ROOT=... bash ...session-start.sh" }'
  echo ""
  echo "  Merged example: toulmin/cursor/hooks.merged-example.json"
else
  cp "${CURSOR_HOOKS}" "${HOOKS_DST}"
  echo "  Created → ${HOOKS_DST}"
fi

# 3. Summary
echo ""
echo "Done. Restart Cursor."
echo ""
echo "Cursor limitations vs Claude Code:"
echo "  - No Stop hook → iteration counting disabled"
echo "  - No Stop hook → checkpoint injection disabled"
echo "  - No Stop hook → drift self-check disabled"
echo "  - No Agent tool → Gate 2/3 use grill-me (prompt-driven, no isolation)"
echo "  - State file still works via update-gate.sh (called from skills)"
echo ""
echo "Commands:"
echo "  /toulmin:toulmin-plan \"task\" --lang zh"
echo "  /toulmin:toulmin-vibe --lang zh"
echo "  ... (all 9 skills available)"
