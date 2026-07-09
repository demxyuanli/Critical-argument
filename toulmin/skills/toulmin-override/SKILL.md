---
name: toulmin-override
description: Manually override a failed gate with an explicit risk-acceptance statement. Records the override in the gate document and lifts the gate block. Enforces a cooldown period and escalating friction to prevent override degradation.
user-invocable: true
argument-hint: "\"risk acceptance reason\""
disable-model-invocation: false
---

# Toulmin Override — Manual Gate Override

Override the current failed gate by recording an explicit risk-acceptance statement. This is a deliberate human decision — not an automatic escape.

**Overrides are tracked.** Repeated overrides within a short window face escalating friction to prevent the override-from-default degradation pattern.

## Pre-flight

1. Read `.claude/toulmin-state.local.md` to get `gate_dir`, `gate_current`, `lang`, `override_count`, `iteration`.
2. Verify `gate_blocked` is `true` — if not, say "No gate is currently blocked. Nothing to override."

## Execution

### Step 1: Cooldown check (override friction)

Apply escalating friction based on override history:

**First override (override_count = 0):** Standard flow. No extra friction.

**Second override (override_count = 1):** Require reason ≥ 30 characters. Display:
```
⚠️  This is your 2nd override this session. Overrides bypass the verification
    and debate gates — each one is an accepted risk. Make it count.
```

**Third+ override (override_count ≥ 2):** Escalated friction:
- Require reason ≥ 50 characters
- Require the user to type `OVERRIDE` (all caps) as explicit confirmation
- Display full override history for this session
- Show warning:
```
🛑 This is your [N]th override. Gate discipline is degrading.
    The framework is becoming ceremonial — gates exist but are never
    completed. After 5 overrides, consider: is the gate design too strict,
    or are you bypassing real risks?
```

### Step 2: Confirm with user

Display the current gate and ask user to confirm:

```
Current blocked gate: [gate_current]
Risk acceptance reason: [user's argument]
Session override count: [N]
Cooldown check: [passed / escalated]

This will:
  - Mark the gate as CONDITIONAL PASS (override)
  - Record the override in the gate document
  - Lift the coding block

Continue? (yes/no)
```

For override_count ≥ 2, user must type `OVERRIDE` (not just "yes").

### Step 3: Append override to gate document

Determine which gate document to update:
- gate-1 → `{gate_dir}/gate-1-convergence.md`
- gate-2 → `{gate_dir}/gate-2-verification.md`
- gate-3 → `{gate_dir}/gate-3-debate.md`

Append to the end of the document:

```markdown
---

## Override — [Date Time]

**Reason**: [user's risk acceptance statement]
**Session override #[N]**

**Decision**: Gate overridden by explicit human risk acceptance. CONDITIONAL PASS.
```

Use Bash to append:
```bash
cat >> "{gate_dir}/{gate_doc}" << EOF

---

## Override — $(date -u +"%Y-%m-%dT%H:%M:%SZ")

**Reason**: <user's statement>
**Session override #<N+1>**

**Decision**: Gate overridden by explicit human risk acceptance. CONDITIONAL PASS.
EOF
```

### Step 4: Update state file

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh" <gate-name> passed <next-gate> <phase>
```

Gate mapping:
- gate-1 → `bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh" gate-1 passed gate-2 gate-1-overridden`
- gate-2 → `bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh" gate-2 passed gate-3 gate-2-overridden`
- gate-3 → `bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh" gate-3 passed "" gate-3-overridden`

Then update override counters:
```bash
# Increment override_count
NEW_COUNT=$((<override_count> + 1))
sed -i.bak "s/^override_count: .*/override_count: ${NEW_COUNT}/" .claude/toulmin-state.local.md
# Append to override_history (handle empty/non-empty array — same fix as update-gate.sh)
CURRENT_ITERATION=$(grep '^iteration:' .claude/toulmin-state.local.md | sed 's/iteration: *//')
ENTRY="${GATE}@${CURRENT_ITERATION}"
if grep -qE '^override_history: \[.+\]' .claude/toulmin-state.local.md; then
  sed -i.bak "s/^override_history: \[\(.*\)\]/override_history: [\1, ${ENTRY}]/" .claude/toulmin-state.local.md
else
  sed -i.bak "s/^override_history: \[\]/override_history: [${ENTRY}]/" .claude/toulmin-state.local.md
fi
rm -f .claude/toulmin-state.local.md.bak
```

### Step 5: Confirm + show stats

Report:
```
Gate [N] overridden. Gate document updated at {path}. Coding block lifted.

Session override stats: [N] override(s). Gates passed naturally: [M].
Override ratio: [N]:[M]. {If N > M: "⚠️ More overrides than natural passes — gate discipline in decline."}
```

Output in the language specified by `lang` field.
