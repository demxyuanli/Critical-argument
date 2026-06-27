---
name: toulmin-vibe
description: Start vibe coding with Toulmin safety net. Fast iteration with automatic drift detection, checkpoint prompts, and adversarial checks. The framework intervenes only when signals indicate drift.
user-invocable: true
argument-hint: "[--lang zh|en] [--checkpoint N]"
disable-model-invocation: false
---

# Toulmin Vibe — Fast Iteration with Drift Detection

Vibe coding with a safety net. You iterate freely. The framework monitors for drift signals and intervenes at checkpoints — not every turn.

## Phase 0: Initialization

### Step 0.1: Parse arguments

- `--lang` (default `en`, supported: `en`, `zh`)
- `--checkpoint` (default `20`, interval for automatic checkpoint; 0 = no automatic checkpoint)

### Step 0.2: Create state file

```bash
mkdir -p docs/toulmin
```

Write `.claude/toulmin-state.local.md`:

```yaml
---
gate_blocked: false
phase: null
session_id: ${CLAUDE_CODE_SESSION_ID}
iteration: 0
gate_dir: null
gates_passed: []
gate_current: null
ca_mode: vibe
lang: <lang>
checkpoint_interval: <checkpoint>
---
```

### Step 0.3: Confirm

"Toulmin Vibe active. Checkpoint every [N] iterations. /toulmin-status to view state. /toulmin-verify or /toulmin-debate anytime for gate checks."

## Vibe Coding Protocol

### Normal operation

Proceed with normal coding. The framework's hooks handle:
- **Iteration counting**: Stop hook increments counter automatically.
- **Gate blocking**: If a gate is set to blocked, Write/Edit tools are intercepted.
- **Session recovery**: SessionStart hook injects a state pointer.

### Your responsibilities during vibe coding

1. **Before claiming "done" or "this should work"**: Perform a 30-second self-check:
   - What three assumptions would break this code if wrong?
   - If input is null/empty/extreme, does it crash or silently fail?
   - What is the most likely failure mode?

2. **Fuzzy-word vigilance**: If you catch yourself writing "maybe/probably/might" in a conclusion, flag it to the user explicitly.

3. **Boundary awareness**: When generating code, actively think about edge cases. The smoothness bias is real — counteract it.

### Checkpoint protocol (automatic, via Stop hook)

When the stop hook detects `iteration % checkpoint_interval == 0`, it blocks exit and injects a checkpoint task. At this point:

1. **L0 Signal Scan**:
   - **Fuzzy-word density**: Scan your recent conclusions for hedge words.
   - **Semantic repetition**: Have you re-raised already-settled points?
   - **Narrative markers**: Are you saying "next we will..." without verification?
   - **Version confusion**: Are there multiple inconsistent versions of the same concept in context?

2. **Assumption check**:
   - List the top 3 unverified assumptions currently in play.
   - For each: risk level and what would happen if wrong.

3. **Throughput check**:
   - Are iterations producing substantive functional increments, or just style tweaks?
   - If the last 5 iterations changed <20 lines each with no new functionality → possible vibe inertia.

4. **Output**: Report findings. If no signals → "Checkpoint clear." If signals detected → present them with recommendations.

### VAC — Vibe Adversarial Check

At any time (user-requested or at checkpoint), run a 60-second adversarial check:

> "Switch to adversary mode. Give me three specific scenarios where this code breaks. Each must start with 'If...then...' and describe a concrete input or condition."

This outputs exactly three failure scenarios. The user reads them and decides whether to act.

### Mode transition triggers

If any of these occur, suggest switching to structured mode (`/toulmin-plan`):
- 3+ consecutive checkpoints with unresolved signals
- `gate_blocked` becomes `true` (PreToolUse blocks coding)
- User expresses confusion about current state
- Cross-session continuation where context is unclear

Say: "Vibe assumptions may be breaking. Consider /toulmin-plan to re-establish structure. I can continue in vibe mode if you prefer."

## Standalone Gate Execution

In vibe mode, gates can be run standalone without the full plan structure:

### /toulmin-verify (standalone)
Runs L1-L4 against current code. Creates `docs/toulmin/YYYY-MM-DD-vibe-session/gate-2-verification.md`. If FAILED: sets `gate_blocked=true`.

### /toulmin-debate (standalone)
Runs R1-R3 against current or specified code. Creates gate-3-debate.md in the same directory. Same gate_blocked behavior on failure.

## Output Language

All conversation output in the language specified by `lang` field in state file. Gate documents follow the same language.

## State Cleanup

To end vibe monitoring: delete `.claude/toulmin-state.local.md` or run:
```bash
rm .claude/toulmin-state.local.md
```
This removes all hook interventions. Gate documents persist in `docs/toulmin/`.
