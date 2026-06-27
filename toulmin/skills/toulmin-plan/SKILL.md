---
name: toulmin-plan
description: Start a structured Toulmin-framework task. Plan→Task→Target→Gate1→Verify→Gate2→Code→Verify→Debate→Gate3→Regression. Use for non-trivial tasks with 3+ steps, multi-module impact, or irreversible decisions.
user-invocable: true
argument-hint: "<task description> [--lang zh|en]"
disable-model-invocation: false
---

# Toulmin Plan — Structured Task Execution

Execute a task through the Toulmin framework's structured process chain with three argumentation gates. Each gate produces a documented Toulmin-format argument before the next phase can begin.

## Phase 0: Initialization

### Step 0.1: Parse arguments

Extract `--lang` flag (default `en`, supported: `en`, `zh`). Everything else is the task description.

### Step 0.2: Create state file and gate directory

```bash
TASK_SLUG=$(echo "<task description>" | head -c 50 | tr ' ' '-' | tr -cd 'a-zA-Z0-9-')
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
---
```

### Step 0.3: Confirm setup

Report: mode, task, gate directory, language. Then proceed.

## Phase 1: Plan

### Define problem boundary

1. What is IN scope? Enumerate explicitly.
2. What is explicitly OUT of scope? Be specific — this prevents scope creep.
3. What are the success criteria? Each must be binary-verifiable (test can say pass/fail).

**Gate rule**: Do not proceed until user confirms the boundary and success criteria.

## Phase 2: Task Decomposition

Decompose into tasks where each task:
- Is independently verifiable (has its own done condition)
- Has explicit dependencies declared
- Does not rely on "we'll figure it out later"

Format:
```
T1: [name] → done: [verifiable condition] → depends: [none / T0]
T2: [name] → done: [verifiable condition] → depends: [T1]
...
```

**Gate rule**: Do not proceed until user confirms the decomposition.

## Gate 1 — Direction Convergence

Write `{gate_dir}/gate-1-convergence.md`:

```markdown
# Gate 1 — Direction Convergence — [Date Time]

## Decision
[One-line summary of the chosen approach]

### Claim
[What we assert is the correct approach]

### Ground
[Evidence: why this approach fits the problem boundary and task decomposition]

### Warrant
[Logic: why the evidence supports this being the right approach]

### Backing
[Additional support: prior art, established patterns, constraints that favor this path]

### Rebuttal
[Alternative approaches considered and why rejected:
- Alternative A: [description] → rejected because [reason]
- Alternative B: [description] → rejected because [reason]]

### Qualifier
[Scope and expiration conditions:
- This decision is valid under what conditions?
- What event would trigger re-evaluation?
- Bounded to what scale/scope?]

## Verdict: PASSED
```

Update state file: `gates_passed: [gate-1]`, `gate_current: gate-2`.

# Gate 2 — Limited Verification

Delegate to the toulmin-verify skill:

> Invoke Skill("toulmin-verify"). The skill reads the state file, executes L1-L4, writes gate-2-verification.md, and updates the state file.

After toulmin-verify returns:
- Read gate-2-verification.md for the verdict.
- If FAILED: halt. Report why. Do not proceed.
- If PASSED: continue to Phase 3.

## Phase 3: Implementation

### Target

For each task, define the expected output structure (function signatures, data shapes, API contracts).

### Pseudocode

For each task, sketch the algorithm skeleton. Pseudocode must trace back to the verification conditions in gate-2.

### Code

Implement each task. Follow the pseudocode and targets.

### Verify

Verify each task independently against its done condition. All verifications must pass before proceeding.

Update state file: `phase: verify`, `gate_current: gate-3`.

## Gate 3 — Adversarial Debate

Delegate to the toulmin-debate skill:

> Invoke Skill("toulmin-debate"). The skill reads recent code changes, executes R1-R3, writes gate-3-debate.md, and updates the state file.

After toulmin-debate returns:
- Read gate-3-debate.md for the verdict.
- If FAILED: halt. Fix and re-run debate.
- If CONDITIONAL PASS: tag conditions for regression monitoring.
- If PASSED: continue to regression.

## Phase 4: Regression

1. Re-run all existing verifications — they must still pass.
2. Run any new verifications covering the boundaries from gate-2 and the conditions from gate-3.
3. All regression tests must pass.

## Completion

All 3 gates passed + regression passed = task complete. Report final status with gate document references.

---

## L0 Self-Monitoring (active throughout)

During the entire process, self-monitor:
1. **Fuzzy-word check**: Before stating any conclusion, check — am I using "maybe/probably/might"? If yes, replace with a definite assertion or explicit "I am uncertain because...".
2. **Drift check** (every ~10 rounds): Am I repeating already-settled points? Am I in narrative mode ("next we will...") without verification anchors?
3. **Boundary check**: Have I addressed edge cases, or am I generating smooth-path-only output?

If any self-check triggers: report it to the user before continuing.

## Output Language

All conversation output in the language specified by `lang` field in state file. Gate documents follow the same language.
