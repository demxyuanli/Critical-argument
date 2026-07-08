# Toulmin — Critical Argumentation Framework

A Claude Code plugin based on the [Toulmin Argumentation Model](https://en.wikipedia.org/wiki/Stephen_Toulmin). Institutionalizes "limited verification before coding" and "adversarial debate before acceptance" as three rigid Gates. In vibe coding, detects drift through L0 signal monitoring and automatic checkpoints. Core methodology: **Toulmin Critical Argumentation**.

[中文](README.md) | [日本語](README.ja.md)

---

## 1. Design Theory — 9 Core Claims

Each claim is constructed with Toulmin's six elements (Claim, Ground, Warrant, Backing, Rebuttal, Qualifier). Full argumentation chain in [`ai-failure-detection-framework.md`](ai-failure-detection-framework.md).

### Claim 1: Uncertain language signals error

> Hedge words ("maybe", "probably") in AI conclusions mean the model is vacillating between low-confidence token branches — no path passes the implicit verification threshold.

**Distinction**: Conclusion modifiers = red flag; risk qualifiers = legitimate engineering prudence.

### Claim 2: Repeated mentions in regression = cognitive drift

> AI has no structured "resolved" state machine. Attention weight decay in long contexts → early settled discussions forgotten → old patterns reactivated as new discoveries.

**Detection**: embedding similarity + logical coherence check. Repetition + no new information = drift.

### Claim 3: No clear roadmap or reference → no generalization

> AI does not abstract-reason; it does conditional probability matching. Generalization requires "extracting invariant patterns from multiple instances" — with only one instance (the current spec), AI cannot distinguish essential from accidental features.

### Claim 4: Coding without convergence = worthless

> Unresolved design issues do not self-resolve by entering implementation — they resurface as technical debt, boundary bugs, and architectural conflicts. AI excels at manufacturing "pseudo-convergence" — fluent summaries that package unresolved issues as settled.

**Convergence criterion**: at least one yes/no question + all participants agree on the answer.

### Claim 5: AI recommendations must be rigorously proven

> Demanding self-proof from AI = shifting the judgment burden from human back to AI + changing the review object from "conclusion plausibility" to "reasoning chain traceability." Use AI's reasoning capability for verification, not its generation capability for decision-making.

**Three-tier proof** (reliability order): **Boundary** (failure conditions) > **Counter-evidence** (alternative exclusion) > **Traceability** (evidence citation).

### Claim 6: Long-range tasks require structured task documents

> Each node in plan→task→target→pseudocode→verify→regression is an independent verification gate. Without constraints, AI's output space at each step is too large — correctness probability decays exponentially with step count. "Next we will..." language = narrative mode, not execution mode.

### Claim 7: AI's "smoothness bias" systematically masks boundary issues

> LLM likelihood-maximization objective + autoregressive generation's smoothing dynamics = systemic regression toward normal paths. Boundary conditions (null, extreme values, concurrent conflicts) are systematically absent from output.

### Claim 8: AI hallucination accumulation on "completed work"

> AI lacks compilers/runtimes as mandatory reality feedback. In long conversations, assumptions progressively upgrade to "confirmed facts", with each error layer maintaining equal surface confidence.

**Two mechanisms**: memory-based (mitigated by context management) vs. inference-based (rooted in model knowledge bias, unresolvable by context reset).

### Claim 9: Confirmatory review equals no review (supplementary)

> Human reviewers face automation bias + confirmation bias simultaneously — seeking evidence of correctness, not evidence of error. **Only review with refutation as its explicit objective (adversarial debate) breaks this bias.**

---

## 2. Detection Framework — L0/L1/L2 Layered Model

```
L0 Signal Layer (continuous monitoring, zero-cost flagging)
  ├─ Hedge-word density > threshold        → insufficient confidence
  ├─ Adjacent-turn semantic similarity     → context saturation
  ├─ "Next/then" density spike            → narrative mode active
  ├─ Low boundary-handling coverage        → smoothness bias active
  └─ Human response-time decay             → attention decay (vibe-specific)
  ↓ flag triggers
L1 Verification Layer (on-demand, confirms signal authenticity)
  ├─ Hedge words → demand definite assertion or explicit "uncertain"
  ├─ Repetition  → check if new information introduced
  └─ Narrative   → check if recent "done" claims have verification
  ↓ verification fails
L2 Intervention Layer (blocks progress, forces correction)
  └─ gate_blocked=true → PreToolUse hook denies Write/Edit
```

---

## 3. Process Framework — Three Gates

```
plan → task → target ─┬─ [Gate 1: Convergence] ──→ pseudocode → code → verify
                      │    Toulmin argument record       ↑              ↓
                      │    "Why this path"          Gate 2:       Gate 3:
                      │                          Verification    Debate
                      │                             L1-L4         R1-R3
                      ↓                              ↓              ↓
                   gate-1-convergence.md   gate-2-verify.md  gate-3-debate.md
```

### Gate 1 — Direction Convergence
**Toulmin format**: Claim/Ground/Warrant/Backing/Rebuttal/Qualifier. Records design decisions, rejected alternatives with reasons, decision validity scope and expiration conditions.

### Gate 2 — Limited Verification (L1-L4)
**L1 Assumption Inventory**: List every design assumption, risk-tier, mitigate or explicitly accept.  
**L2 Boundary Matrix**: Input/state/environment dimensions × handling strategy (or explicit "not handled").  
**L3 Failure Walkthrough**: 3 most-likely failures per key module + blast radius + single-point-of-failure check.  
**L3.5 Causal Trace**: For high-severity failures, derive causal chains from L1 assumptions + L2 boundaries + code structure (AND/OR edges). No user questions.  
**L4 "One Thing That Kills This Design"**: Identify the fatal assumption. Confidence rating (high/medium/low).

### Gate 3 — Adversarial Debate (R1-R3)
**R1 Structural Challenge**: Adversary attacks with D1-D6 dimensions (correctness/completeness/consistency/robustness/security/maintainability). Use `toulmin-debater` agent for role separation.  
**R2 Response**: Respond per finding — [ACCEPT]/[REBUT]/[CLARIFY]/[DEMOTE]. [IGNORE] and [VAGUE] forbidden.  
**R3 Rebuttal + Verdict**: Re-examine REBUT and CLARIFY items → final verdict ✅/⚠️/❌.

---

## 4. Vibe Coding Protocol

Vibe mode's 4 implicit assumptions and their rupture signals:

| Assumption | Rupture Signal |
|------------|---------------|
| Short feedback ≈ quality design | Round-K proposal conflicts with round-K-N |
| Training distribution covers problem space | Hedge words on core logic |
| Vibe-check is effective verification | "Looks normal" but no executable verification |
| Task decomposable into vibe-size chunks | One iteration's change breaks another module |

### Combined checkpoint triggers

| Trigger | Action |
|---------|--------|
| iteration % N == 0 (N=20) | Stop hook block → inject L0 scan task |
| gate_blocked=true | Stop hook block → "Gate not passed, cannot claim completion" |
| Throughput decay (5 rounds <20 lines, no new functionality) | Alert vibe inertia → suggest /toulmin-plan |

### VAC — Vibe Adversarial Check (60s)
"Switch to adversary mode. Give me three specific scenarios where this code breaks. Each must start with 'If...then...' and describe a concrete input or condition."

---

## 5. Installation

```bash
# Global install (all projects)
cp -r toulmin ~/.claude/skills/toulmin

# Via zip
claude plugin install ./toulmin-1.0.1.zip --scope user

# Development mode
claude --plugin-dir ./toulmin
```

---

## 6. Command Reference

| Command | Purpose | Invocation |
|---------|---------|------------|
| `/toulmin:toulmin-plan "task" --lang zh` | Structured execution entry | Manual |
| `/toulmin:toulmin-vibe --lang zh` | Vibe coding + drift detection | Manual |
| `/toulmin:toulmin-verify` | L1-L4 verification (Gate 2) | Plan delegate / vibe standalone |
| `/toulmin:toulmin-debate` | R1-R3 debate (Gate 3) | Plan delegate / vibe standalone |
| `/toulmin:toulmin-status` | View framework status (read-only) | Manual / checkpoint |
| `/toulmin:toulmin-override "reason"` | Manually override failed gate (records risk acceptance) | Manual |
| `/toulmin:toulmin-audit "claim"` | External evidence verification — search counter-examples, alternatives, boundary failures | Manual (gate doc candidate table) |

---

## 7. Plugin Architecture

```
toulmin/
├── skills/                       # 6 skills
│   ├── toulmin-plan/SKILL.md     #   Structured entry: p→t→t→gate control flow
│   ├── toulmin-vibe/SKILL.md     #   Vibe entry: checkpoint/VAC/mode transition
│   ├── toulmin-verify/SKILL.md   #   Gate 2: L1-L4 + gate doc writer
│   ├── toulmin-debate/SKILL.md   #   Gate 3: R1-R3 + gate doc writer
│   ├── toulmin-audit/SKILL.md   #   External evidence verification (WebSearch counter-evidence)
│   └── toulmin-status/SKILL.md   #   Read-only status summary
├── hooks/
│   └── hooks.json                # 3 hook registrations
├── scripts/
│   ├── lib/
│   │   └── state.sh              #   Shared state parser + session isolation + defaults
│   ├── update-gate.sh            #   Unified gate state updater (atomic sed)
│   ├── pre-tool-use.sh           #   gate_blocked=true → deny Write/Edit
│   ├── bash-guard.sh             #   gate_blocked=true → deny Bash file-write bypass
│   ├── stop-hook.sh              #   Iteration counter + completion blocker + checkpoint injector
│   └── session-start.sh          #   Recovery pointer addContext
├── agents/
│   ├── toulmin-debater.md        #   Adversarial reviewer: D1-D6 attack dimensions
│   └── toulmin-verifier.md       #   Verifier: L1-L4 verification layers
├── .claude-plugin/
│   └── plugin.json
├── README.md
└── README.en.md
```

### Implementation Patterns

**grill-me pattern** (pure prompt-driven): 6 skills + 2 agents. Behavioral guidance through language constraints — no hooks needed.

**ralph-loop pattern** (hook + state file): 3 hook scripts + `.claude/toulmin-state.local.md`. Hard enforcement requires lifecycle interception; state requires cross-turn persistence.

**Known hook enforcement limits** (see `toulmin-audit` review):
- ✅ Interactive mode + exit code 2 → deterministic blocking
- ❌ headless `-p` mode → hooks not invoked
- ❌ `--dangerously-skip-permissions` → hooks async, denial delayed
- ❌ subagent tool calls → PreToolUse not triggered
- ⚠️ Bash write bypass → covered via `bash-guard.sh` (sed/echo>/tee, etc.)

**Shared infrastructure**:
- `scripts/lib/state.sh` — Unified frontmatter parsing, session isolation, field defaults. Sourced by all 3 hooks.
- `scripts/update-gate.sh` — Unified gate state update. Atomic sed, idempotent append, gate-name whitelist validation. Called via `${CLAUDE_PLUGIN_ROOT}` from toulmin-plan/verify/debate.

**State file design** — minimal, hook-decision fields only:
```yaml
---
gate_blocked: false     # PreToolUse checks this field
phase: plan             # Current phase
session_id: xxx         # Stop hook session isolation
iteration: 0            # Stop hook increments; checkpoint detection
gate_dir: docs/toulmin/2026-06-27-xxx/  # Gate doc path
gates_passed: [gate-1]  # Passed gates list
gate_current: gate-2    # Active gate
ca_mode: structured     # structured | vibe
lang: zh                # Output language
checkpoint_interval: 20 # Vibe checkpoint interval (0=disabled)
gate_attempts: 0        # Gate retry counter (display only, no automatic behavior)
---
```

---

## 8. Project Artifacts

```
docs/toulmin/YYYY-MM-DD-<task-slug>/
  gate-1-convergence.md    # Direction argument (Claim/Ground/Warrant/Backing/Rebuttal/Qualifier)
  gate-2-verification.md   # L1-L4 results (Toulmin format per layer)
  gate-3-debate.md         # R1-R3 + [ACCEPT/REBUT/CLARIFY/DEMOTE] + verdict

.claude/toulmin-state.local.md  # Hook decision state (cleaned on task completion)
```

Gate documents are **third-party argumentation records** — independent of the plugin and conversation context. Failed gates are also recorded ("why this path was blocked"), for future reference.

---

## 9. Upstream Tool Collaboration

Toulmin runs independently — no dependency on brainstorming or other tools. If project design documents (specs) exist, gate documents link via a single reference line:

```markdown
> Upstream design: docs/superpowers/specs/2026-06-27-role-based-auth-design.md
```

No upstream → independent operation. The Toulmin framework is decoupled.

---

## License

MIT
