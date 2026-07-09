# Toulmin — Critical Argumentation Framework

[中文](README.md) | [日本語](README.ja.md)

A Claude Code plugin based on the [Toulmin Argumentation Model](https://en.wikipedia.org/wiki/Stephen_Toulmin). v1.2 expands "verification before coding" and "adversarial debate before acceptance" into a **complete four-quadrant review system**: internal argumentation (verify + debate) + external argumentation (audit + premortem) + qualifier synthesis (qualify) + agent orchestration + behavior tree visualization (tree) + context drift detection.

**9 skills · 2 agents · 3 hooks · 7 scripts · 10 theoretical claims**

---

## 1. Design Theory — 10 Core Claims

Full Toulmin argument chains (6 elements each) in [`ai-failure-detection-framework.md`](ai-failure-detection-framework.md).

| # | Claim | Mechanism |
|---|-------|-----------|
| 1 | Uncertain language signals error | Hedge-word density → low confidence; distinct from risk warnings |
| 2 | Repeated mentions = cognitive drift | Attention decay → forgotten discussions → old patterns reactivated |
| 3 | No reference → no generalization | AI does conditional probability matching, not abstract reasoning |
| 4 | Coding without convergence = worthless | Design issues don't self-resolve; AI manufactures "pseudo-convergence" |
| 5 | AI recommendations must be proven | Shift judgment burden human→AI; review reasoning chain, not conclusion |
| 6 | Long-range tasks need structured docs | Each node = independent gate; correctness decays exponentially |
| 7 | Smoothness bias masks boundary issues | Likelihood maximization → regression toward normal paths |
| 8 | Hallucination accumulation on "done" | AI lacks compiler/runtime feedback; assumptions become "confirmed facts" |
| 9 | Confirmatory review = no review | Automation bias + confirmation bias; only adversarial review breaks it |
| **10** | **Internal argumentation has external blind spots** | **v3: models have knowledge cutoffs + distribution bias → external verification required** |

---

## 2. Review Tool Matrix — Four-Quadrant Model

v1.2 organizes all review tools into a complete internal/external × static/dynamic matrix:

```
                Internal                    External
          (training data+docs+code)    (WebSearch+reverse narrative)
    ┌─────────────────────────┬─────────────────────────┐
Static│ Gate 2: verify          │ audit                   │
    │ L1-L4 + L3.5 causal     │ WebSearch counter-evidence│
    │ Known-dimension checks   │ Challenge external facts │
    ├─────────────────────────┼─────────────────────────┤
Dynamic│ Gate 3: debate         │ premortem               │
    │ R1-R3 adversarial       │ Assume failure→3 death paths│
    │ D1-D6 attack dimensions │ Narrative vulnerabilities │
    └─────────────────────────┴─────────────────────────┘
                              ↓
                         qualify
                Unified qualifier synthesis
         (hard/soft boundaries + confidence + monitors)
                              ↓
                          tree
                Behavior tree visualization
           (Mermaid diagram + partitions + cross-session)
```

**Completeness principle**: Missing any quadrant leaves that class of blind spot as residual risk. Skipping a tool = explicit risk acceptance for that blind spot type.

---

## 3. Detection Framework — L0/L1/L2 + Partition Tracking

```
L0 Signal Layer (continuous, zero-cost)
  ├─ Hedge density > threshold        → confidence deficit
  ├─ Adjacent-turn semantic similarity → context saturation
  ├─ "Next/then" density spike        → narrative mode
  ├─ Low boundary coverage            → smoothness bias
  └─ Human response-time decay        → attention decay (vibe)
  ↓ triggers
L1 Verification Layer (on-demand)
  ↓ verification fails
L2 Intervention Layer (blocks progress)
  └─ gate_blocked=true → PreToolUse denies Write/Edit + Bash file writes
  ↓
Partition Tracking (Stop hook drift self-check)
  ├─ Vibe mode: every checkpoint → inject drift self-check
  ├─ Structured mode: every 30 iterations → inject drift self-check
  └─ partition-track.sh records shifts → toulmin-tree visualizes
```

---

## 4. Process Framework — Three Gates + Agent Orchestration

```
toulmin-plan (orchestrator)
  │
  ├─ plan → task → target
  ├─ [Gate 1: Convergence] ← YOU (orchestrator)
  │     └─ Toulmin argument record
  │
  ├─ [Gate 2: Verification] ← Agent(toulmin-verifier)  [isolated context]
  │     └─ L1-L4 + L3.5 causal trace → gate-2-verification.md
  │
  ├─ pseudocode → code → verify
  │
  ├─ [Gate 3: Debate] ← Agent(toulmin-debater)  [isolated context]
  │     └─ R1-R3 (D1-D6) → gate-3-debate.md
  │
  ├─ [optional] audit → premortem → qualify → tree
  │
  └─ regression → complete
```

### Gate 1 — Direction Convergence (orchestrator)
Toulmin format: Claim/Ground/Warrant/Backing/Rebuttal/Qualifier. Records decisions, rejected alternatives, validity scope, expiration conditions.

### Gate 2 — Limited Verification (agent dispatch)
Dispatches `toulmin-verifier` agent — isolated context, uncontaminated by planning.  
**L1** Assumption inventory | **L2** Boundary matrix | **L3** Failure walkthrough | **L3.5** Causal trace | **L4** "One thing that kills this design"

### Gate 3 — Adversarial Debate (agent dispatch)
Dispatches `toulmin-debater` agent — role separation, objective is REFUTE not evaluate.  
**R1** D1-D6 attacks | **R2** [ACCEPT/REBUT/CLARIFY/DEMOTE] | **R3** Verdict ✅/⚠️/❌

### External Review Tools (manual invocation)
| Tool | Quadrant | Function |
|------|----------|----------|
| `/toulmin:toulmin-audit` | External-Static | WebSearch for counter-examples, alternatives, boundary failures |
| `/toulmin:toulmin-premortem` | External-Dynamic | Assume failure → reverse-engineer 3 causal death paths |
| `/toulmin:toulmin-qualify` | Synthesis | Aggregate all findings → hard/soft boundaries + confidence |
| `/toulmin:toulmin-tree` | Visualization | Mermaid behavior tree + partition history + cross-session refs |

---

## 5. Agent Orchestration Architecture

toulmin-plan upgraded from prompt-driven skill to agent orchestrator:

| Role | Executor | Context | Responsibility |
|------|----------|---------|----------------|
| Orchestrator | YOU (toulmin-plan) | Full conversation | Problem, decomposition, Gate 1, implementation |
| Verifier Agent | `toulmin-verifier` | **Isolated** | L1-L4 + L3.5 causal trace. No planning discussion |
| Debater Agent | `toulmin-debater` | **Isolated** | D1-D6 attacks. No attachment to design decisions |

**Why agents?** Skills run in orchestrator context — verification tainted by planning conversation. Agents have isolated contexts: the verifier doesn't know what tradeoffs were discussed, the debater has no attachment to design decisions. This isolation is the mechanism for genuine adversarial review.

---

## 6. Framework Degradation Defense

Premortem analysis of toulmin itself identified three degradation patterns, all defended:

| Pattern | Mechanism | Defense |
|---------|-----------|---------|
| **Form over substance** | Override becomes default reflex | Cooldown + escalating friction + ratio tracking |
| **Platform blind spot** | Hooks fail silently in headless/bypass/subagent | Status shows 5 blind spots + iteration cross-check |
| **Knowledge burial** | Gate docs written then forgotten | SessionStart scans history + similar task matching |

---

## 7. Vibe Coding Protocol

Three-layer safety net: checkpoints + VAC + drift self-check.

| Trigger | Action |
|---------|--------|
| iteration % N == 0 (N=20) | Stop hook block → L0 scan + **drift self-check** |
| gate_blocked=true | Stop hook block → cannot claim completion |
| Throughput decay | Alert vibe inertia → suggest /toulmin-plan |

### VAC — Vibe Adversarial Check (60s)
"Switch to adversary mode. Give me three specific scenarios where this code breaks."

---

## 8. Installation

```bash
# Global install
cp -r toulmin ~/.claude/skills/toulmin

# Via zip
claude plugin install ./toulmin-1.2.0.zip --scope user

# Development mode
claude --plugin-dir ./toulmin
```

---

## 9. Command Reference

| Command | Purpose | Invocation |
|---------|---------|------------|
| `/toulmin:toulmin-plan "task" --lang zh` | Agent-orchestrated structured entry | Manual |
| `/toulmin:toulmin-vibe --lang zh` | Vibe coding + checkpoint + drift | Manual |
| `/toulmin:toulmin-verify` | L1-L4 verification (Gate 2) | Plan dispatches agent / vibe standalone |
| `/toulmin:toulmin-debate` | R1-R3 debate (Gate 3) | Plan dispatches agent / vibe standalone |
| `/toulmin:toulmin-audit "claim"` | External verification (WebSearch) | Manual (gate doc candidate table) |
| `/toulmin:toulmin-premortem` | Failure backtracking (3 death paths) | Manual (after Gate 2/3) |
| `/toulmin:toulmin-qualify` | Unified qualifier synthesis | Manual (after all reviews) |
| `/toulmin:toulmin-tree` | Behavior tree visualization (Mermaid) | Manual / status review |
| `/toulmin:toulmin-status` | Framework status + integrity check | Manual / checkpoint |
| `/toulmin:toulmin-override "reason"` | Manual gate override (cooldown-tracked) | Manual |

---

## 10. Plugin Architecture

```
toulmin/
├── skills/                       # 9 skills
│   ├── toulmin-plan/SKILL.md     #   Agent orchestrator: plan→gates→agents→regression
│   ├── toulmin-vibe/SKILL.md     #   Vibe entry: checkpoint/VAC/mode transition
│   ├── toulmin-verify/SKILL.md   #   Gate 2: L1-L4 + gate doc + candidate table
│   ├── toulmin-debate/SKILL.md   #   Gate 3: R1-R3 + gate doc + candidate table
│   ├── toulmin-audit/SKILL.md   #   External verification: WebSearch → STANDS/NARROW/REFUTED
│   ├── toulmin-premortem/SKILL.md #   Backtracking: 3 death paths + defenses
│   ├── toulmin-qualify/SKILL.md  #   Qualifier synthesis: boundaries + confidence + monitors
│   ├── toulmin-tree/SKILL.md    #   Behavior tree: Mermaid + partitions + cross-session
│   └── toulmin-status/SKILL.md   #   Status + integrity + override stats
├── hooks/
│   └── hooks.json                # PreToolUse(Write/Edit+Bash) + Stop + SessionStart
├── scripts/
│   ├── lib/state.sh              #   Shared parser + session isolation + 12 field defaults
│   ├── update-gate.sh            #   Gate state updater (atomic sed + idempotent)
│   ├── pre-tool-use.sh           #   gate_blocked → deny Write/Edit
│   ├── bash-guard.sh             #   gate_blocked → deny Bash file-write bypass
│   ├── partition-track.sh        #   Context partition shift recorder
│   ├── stop-hook.sh              #   Iteration + completion block + checkpoint + drift check
│   └── session-start.sh          #   Recovery pointer + history scan + similar task match
├── agents/
│   ├── toulmin-debater.md        #   Adversary: D1-D6 attacks (isolated context)
│   └── toulmin-verifier.md       #   Verifier: L1-L4 + causal trace (isolated context)
├── .claude-plugin/plugin.json
├── README.md / README.en.md / README.ja.md
└── ai-failure-detection-framework.md  # Full theory (10 claims + 10 sections)
```

### Implementation Patterns

**Agent orchestration**: Orchestrator handles problem + decomposition + Gate 1 + implementation. Gates 2/3 dispatch isolated agents. Review findings uncontaminated by planning.

**grill-me** (pure prompt): 9 skills + 2 agents. Language constraints guide behavior. No hooks needed.

**ralph-loop** (hook + state): 3 hook scripts + `.claude/toulmin-state.local.md`. Hard enforcement via lifecycle interception.

**Known hook limits** (verified by toulmin-audit):
- ✅ Interactive + exit code 2 → deterministic block
- ❌ headless `-p` → hooks not invoked; subagent calls → PreToolUse not triggered
- ⚠️ Bash bypass → bash-guard.sh; bypass mode → async delay

**State file**:
```yaml
---
gate_blocked: false     # PreToolUse check
phase: plan             # plan|task|gate-1|gate-2|code|verify|gate-3|regression|complete
iteration: 0            # Stop hook increments
gate_dir: docs/toulmin/YYYY-MM-DD-<slug>/
gates_passed: [gate-1]  # Passed gates
gate_current: gate-2    # Active gate
ca_mode: structured     # structured|vibe
lang: zh                # zh|en
checkpoint_interval: 20 # Vibe checkpoint interval
gate_attempts: 0        # Retry counter
override_count: 0       # Override total (cooldown)
override_history: []    # [gate@round, ...]
partitions: ["task"]    # [src→dst@iteration:reason, ...]
partition_current: task # Active partition
---
```

---

## 11. Project Artifacts

```
docs/toulmin/YYYY-MM-DD-<task-slug>/
  gate-1-convergence.md    # Direction argument (Toulmin 6 elements)
  gate-2-verification.md   # L1-L4 + L3.5 causal trace + fact-check candidates
  gate-3-debate.md         # R1-R3 + [ACCEPT/REBUT/CLARIFY/DEMOTE] + verdict
  qualifier.md             # Unified qualifier (hard/soft boundaries + confidence)

.claude/toulmin-state.local.md  # Hook decision state (cleaned on completion)
```

Gate documents are **third-party argumentation records** — independent of plugin and conversation. Failed gates also recorded. `qualifier.md` is the design's precise contract.

---

## 12. Version History

| Version | Date | Key Additions |
|---------|------|---------------|
| v1.0.1 | 2026-06 | Foundation: 5 skills + 3 hooks + L0-L2 + 3 gates + Vibe protocol |
| v1.1.0 | 2026-07 | v3 External review: audit + premortem + qualify + degradation defenses |
| v1.2.0 | 2026-07 | v2 Agent orchestration + tree + partition tracking + drift self-check |

---

## License

MIT
