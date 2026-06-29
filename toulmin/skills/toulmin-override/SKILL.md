---
name: toulmin-override
description: Manually override a failed gate with an explicit risk-acceptance statement. Records the override in the gate document and lifts the gate block. Use when a gate cannot be passed but the risk is understood and accepted.
user-invocable: true
argument-hint: "\"risk acceptance reason\""
disable-model-invocation: false
---

# Toulmin Override — Manual Gate Override

Override the current failed gate by recording an explicit risk-acceptance statement. This is a deliberate human decision — not an automatic escape.

## Pre-flight

1. Read `.claude/toulmin-state.local.md` to get `gate_dir`, `gate_current`, `lang`.
2. Verify `gate_blocked` is `true` — if not, say "No gate is currently blocked. Nothing to override."

## Execution

### Step 1: Confirm with user

Display the current gate and ask user to confirm:

```
Current blocked gate: [gate_current]
Risk acceptance reason: [user's argument]

This will:
  - Mark the gate as CONDITIONAL PASS (override)
  - Record the override in the gate document
  - Lift the coding block

Continue? (yes/no)
```

### Step 2: Append override to gate document

Determine which gate document to update:
- gate-1 → `{gate_dir}/gate-1-convergence.md`
- gate-2 → `{gate_dir}/gate-2-verification.md`
- gate-3 → `{gate_dir}/gate-3-debate.md`

Append to the end of the document:

```markdown
---

## Override — [Date Time]

**Reason**: [user's risk acceptance statement]

**Decision**: Gate overridden by explicit human risk acceptance. CONDITIONAL PASS.
```

Use Bash to append:
```bash
cat >> "{gate_dir}/{gate_doc}" << EOF

---

## Override — $(date -u +"%Y-%m-%dT%H:%M:%SZ")

**Reason**: <user's statement>

**Decision**: Gate overridden by explicit human risk acceptance. CONDITIONAL PASS.
EOF
```

### Step 3: Update state file

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh" <gate-name> passed <next-gate> <phase>
```

Gate mapping:
- gate-1 → `bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh" gate-1 passed gate-2 gate-1-overridden`
- gate-2 → `bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh" gate-2 passed gate-3 gate-2-overridden`
- gate-3 → `bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh" gate-3 passed "" gate-3-overridden`

### Step 4: Confirm

Report: "Gate [N] overridden. Gate document updated at {path}. Coding block lifted."

Output in the language specified by `lang` field.
