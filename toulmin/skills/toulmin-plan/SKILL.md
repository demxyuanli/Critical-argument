---
name: toulmin-plan
description: Start a structured Toulmin critical argumentation task. Orchestrates agent-based gate execution — dispatches verifier agent for Gate 2, debater agent for Gate 3. Plan→Task→Target→Gate1→Verify(agent)→Gate2→Code→Debate(agent)→Gate3→[audit|premortem|qualify]→Regression.
user-invocable: true
argument-hint: "<task description> [--lang zh|en]"
disable-model-invocation: false
---

# Toulmin Plan — Agent-Orchestrated Task Execution

You are the **orchestrator**. You define the problem, decompose the task, execute Gate 1 yourself (design decisions require human interaction), then **dispatch dedicated agents** for verification (Gate 2) and debate (Gate 3). Agents have isolated contexts — their findings are not contaminated by planning conversation.

## Phase 0: Initialization

### Step 0.1: Parse arguments

Extract `--lang` flag (default `en`, supported: `en`, `zh`). Everything else is the task description.

### Step 0.2: Create state file and gate directory

```bash
TASK_SLUG=$(echo "<task description>" | head -c 50 | tr ' ' '-' | tr -cd 'a-zA-Z0-9-' | sed 's/-\+/-/g; s/^-//; s/-$//')
if [[ -z "$TASK_SLUG" ]]; then
  TASK_SLUG="task-$(date +%H%M%S)"
fi
GATE_DIR="docs/toulmin/$(date +%Y-%m-%d)-${TASK_SLUG}"
mkdir -p "${GATE_DIR}"
```

Write `.claude/toulmin-state.local.md`:

```yaml
---
gate_blocked: false
phase: plan
session_id: ${CLAUDE_CODE_SESSION_ID}
iteration: 0
gate_dir: ${GATE_DIR}
gates_passed: []
gate_current: gate-1
ca_mode: structured
lang: <lang>
checkpoint_interval: 0
gate_attempts: 0
override_count: 0
override_history: []
partitions: ["task"]
partition_current: task
---
```

### Step 0.3: Confirm setup

Report: mode, task, gate directory, language. Then proceed.

## Phase 1: Plan

Define:
1. **IN scope** — enumerate explicitly
2. **OUT of scope** — be specific, prevents scope creep
3. **Success criteria** — each must be binary-verifiable

**Gate rule**: Do not proceed until user confirms.
```bash
sed -i.bak 's/^phase: .*/phase: task/' .claude/toulmin-state.local.md
```

## Phase 2: Task Decomposition

Decompose into independently-verifiable tasks:
```
T1: [name] → done: [verifiable condition] → depends: [none / T0]
T2: [name] → done: [verifiable condition] → depends: [T1]
```

**Gate rule**: Do not proceed until user confirms.
```bash
sed -i.bak 's/^phase: .*/phase: gate-1/' .claude/toulmin-state.local.md
```

## Gate 1 — Direction Convergence (YOU execute)

Write `{gate_dir}/gate-1-convergence.md` with full Toulmin structure:
- Claim, Ground, Warrant, Backing, Rebuttal (rejected alternatives + reasons), Qualifier (validity scope + expiration conditions)

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh" gate-1 passed gate-2 gate-2
```

## Gate 2 — Limited Verification (DISPATCH agent)

**Dispatch a dedicated verification agent.** The agent has isolated context — it reads the design docs and code with fresh eyes, untainted by the planning conversation.

```bash
sed -i.bak 's/^phase: .*/phase: gate-2/' .claude/toulmin-state.local.md
```

Use the Agent tool with agent type `toulmin:toulmin-verifier`:

> **Agent prompt**: "Execute the Toulmin limited verification protocol (L1-L4 + L3.5 Causal Trace) against the design documented in {gate_dir}/gate-1-convergence.md and the task decomposition. The task is: <task description>. Language: <lang>. Write gate-2-verification.md to {gate_dir}/ and update state file via update-gate.sh."

The agent returns the verification results. After:
- Read `{gate_dir}/gate-2-verification.md` for the verdict.
- If FAILED: halt. Report why. Do not proceed.
- If PASSED: continue to Phase 3.
- Append fact-check candidate table to the gate-2 doc.

## Phase 3: Implementation (YOU execute)

Target → Pseudocode → Code → Verify. Each task verified independently against its done condition.

```bash
sed -i.bak \
  -e 's/^phase: .*/phase: verify/' \
  -e 's/^gate_current: .*/gate_current: gate-3/' \
  .claude/toulmin-state.local.md
```

## Gate 3 — Adversarial Debate (DISPATCH agent)

**Dispatch a dedicated debate agent.** The debater agent is adversarial by design — its sole objective is to REFUTE the implementation. This role separation is essential: you (the orchestrator) built the code; the debater has no attachment to it.

```bash
sed -i.bak 's/^phase: .*/phase: gate-3/' .claude/toulmin-state.local.md
```

Use the Agent tool with agent type `toulmin:toulmin-debater`:

> **Agent prompt**: "Execute the Toulmin adversarial debate protocol (R1-R3, D1-D6 attack dimensions) against the implementation at <list of changed files>. The original design is documented in {gate_dir}/gate-1-convergence.md. The verification results are in {gate_dir}/gate-2-verification.md. Language: <lang>. Write gate-3-debate.md to {gate_dir}/ and update state file via update-gate.sh."

The agent returns the debate results. After:
- Read `{gate_dir}/gate-3-debate.md` for the verdict.
- If FAILED: halt. Fix and re-dispatch the debater agent.
- If CONDITIONAL PASS: tag conditions for regression monitoring.
- If PASSED: continue.
- Append fact-check candidate table to the gate-3 doc.

## Optional: V3 Review Tools

After Gate 3 passes, offer the v3 review suite:

```
Gates 1-3 complete. Optional deep review tools:
  /toulmin:toulmin-audit "claim"  — external evidence verification (WebSearch)
  /toulmin:toulmin-premortem       — failure backtracking (3 death paths)
  /toulmin:toulmin-qualify         — unified qualifier synthesis
  /toulmin:toulmin-tree            — behavior tree visualization
```

These are manual — user decides which to run based on risk level.

## Phase 4: Regression (YOU execute)

```bash
sed -i.bak 's/^phase: .*/phase: regression/' .claude/toulmin-state.local.md
```

1. Re-run all existing verifications — must still pass.
2. Run new verifications covering Gate 2 boundaries + Gate 3 conditions.
3. All regression tests must pass.

## Completion

All 3 gates passed + regression passed = task complete.

```bash
sed -i.bak 's/^phase: .*/phase: complete/' .claude/toulmin-state.local.md
```

If qualify was run, reference `{gate_dir}/qualifier.md` as the design's contract.

## Agent Dispatch Rules

| Gate | Agent | Role | Context | Retry on FAIL |
|------|-------|------|---------|---------------|
| Gate 1 | YOU (orchestrator) | Design decision recorder | Full conversation | N/A (interactive) |
| Gate 2 | `toulmin:toulmin-verifier` | Fresh-eyes verifier | Design docs + code | Re-dispatch after fixes |
| Gate 3 | `toulmin:toulmin-debater` | Adversarial attacker | Code + gate docs | Re-dispatch after fixes |

**Why agents?** Skills run in your (orchestrator's) context — verification findings are influenced by planning conversation. Agents have isolated contexts: the verifier doesn't know what tradeoffs were discussed, the debater doesn't have attachment to design decisions. This isolation is the mechanism for genuine adversarial review.

## Output Language

All conversation output in the language specified by `lang` field in state file.
