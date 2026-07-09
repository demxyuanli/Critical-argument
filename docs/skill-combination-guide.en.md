# Toulmin Skill Combination Guide

[中文](skill-combination-guide.md)

> 8 verified skill combinations, each with applicable scenarios, trigger conditions, usage steps, cost, and artifacts.
> Verification records in [`skill-combination-verification.md`](skill-combination-verification.md).

---

## Quick Selection Table

| Your situation | Use combination | Cost |
|---------|--------|------|
| Starting from scratch on a task with 3+ steps and multi-module impact | **C1** Full structured | High |
| Suspect that an external fact cited by a technical choice is outdated | **C2** External verification | Medium |
| The design "feels too clean" and you want a pre-launch stress test | **C3** Risk scan | Medium |
| Already ran multiple review rounds and want to synthesize a single conclusion | **C4** Qualifier synthesis | Low |
| Long-running project, want to see overall progress and history | **C5** Behavior tree | Low |
| Want a genuinely independent adversarial review (not self-evaluation) | **C6** Agent dispatch | Medium |
| Fast iteration but worried about drifting off course | **C7** Vibe safety net | Low |
| Gate is stuck but the risk is acceptable and you need to pass | **C8** Override pass | Low |

---

## C1 — Full Structured Workflow

**Combination**: `plan → verify → debate` (+ optional audit/premortem/qualify)

### Applicable scenarios
- Architecture changes, safety-critical systems, greenfield projects
- Multi-module impact, irreversible decisions
- Tasks with clear, verifiable success criteria

### Not applicable
- Single-file scripts, one-off experiments → use C7 or just write it
- Exploratory prototypes (requirements still unclear) → do brainstorming first

### Usage
```bash
/toulmin:toulmin-plan "Add role-based permission validation to the users table" --lang zh
```
Then follow the flow:
1. Confirm scope + success criteria (verifiable)
2. Confirm task decomposition
3. Orchestrator writes Gate 1 (direction convergence argument)
4. **Automatically dispatch the verifier agent** to execute Gate 2 (L1-L4)
5. Implement the code
6. **Automatically dispatch the debater agent** to execute Gate 3 (R1-R3)
7. Optional: audit/premortem/qualify

### Artifacts
`gate-1-convergence.md` + `gate-2-verification.md` + `gate-3-debate.md`

### Measured value
On the parse_config task, the verifier and debater discovered **two sides of the same defect** in isolated contexts (`defaults=None` crash + non-object JSON crash) — a single perspective would have missed one of them.

---

## C2 — External Evidence Verification

**Combination**: `audit` standalone

### Applicable scenarios
- The design depends on an external fact ("library X is faster than library Y", "standard Z is best practice")
- The reason for a technical choice is "I remember..." rather than "I just checked..."
- References a standard, benchmark, or API behavior that may be outdated

### Not applicable
- Pure design opinions ("we should use microservices") — not externally verifiable
- Internal logic problems — use verify/debate
- Overall review of a subsystem — audit targets a single claim, not a system

### Usage
```bash
/toulmin:toulmin-audit "React 19 Server Components are stable and production-ready"
```
Execution:
1. Decompose the claim into the six Toulmin elements
2. 3-5 WebSearches (by risk priority: Backing > Warrant > Ground)
3. Output an audit report + revised qualifier
4. Verdict: STANDS / NARROW / REFUTED

### Trigger recommendation
After Gate 2/3 completes, manually pick high-risk claims from the **fact-check candidate table** in the gate document to verify — avoid searching for every claim exhaustively.

### Measured value
Auditing rustcoin3d's depth-convention claim revealed a systematic deviation between the project's approach and the industry standard (reverse-Z) — something internal review could never find.

---

## C3 — Failure Risk Scan

**Combination**: `premortem` (+ optional qualify)

### Applicable scenarios
- The design "feels too clean" and you want to proactively find fragile points
- Final check before a major release / deployment
- Want to find cascading failures and timing fragilities (not single-point bugs)

### Not applicable
- No design output yet (premortem needs a review target)
- Only want to verify single-point correctness → use verify's L4

### Usage
```bash
/toulmin:toulmin-premortem
```
Execution (requires an existing gate document or code):
1. Set the premise: "This design has failed"
2. Reverse-engineer 3 independent death paths (trigger → amplify → cascade → collapse)
3. Map each to the most fragile Toulmin element
4. Synthesize: shared root cause + recommended actions

### Cognitive principle
Leverages prospective hindsight: in the "assume already failed → reverse-engineer" mode, people find 30% more unique risks than in the "predict risk" mode.

### Measured value
Analyzing toulmin itself uncovered 3 degradation paths (override degradation / phantom hook / documentation graveyard), all converted into implemented defense mechanisms.

---

## C4 — Unified Qualifier Synthesis

**Combination**: `qualify` (requires the output of C1/C2/C3)

### Applicable scenarios
- Already ran multiple review tools and findings are scattered across documents
- Need a citable "design contract" (under what conditions this design is valid)
- Preparing for delivery/archiving and need a precise scope statement

### Not applicable
- No gate/audit/premortem output yet — nothing to synthesize
- Only ran one tool — just look at that tool's output directly

### Usage
```bash
/toulmin:toulmin-qualify
```
Execution:
1. Scan all documents in gate_dir
2. Extract constraints by source (verify/debate/audit/premortem)
3. Merge and deduplicate, sort by priority (external > internal, fatal > severe)
4. Output: hard boundaries / soft boundaries / monitoring triggers / open risks / confidence

### Artifacts
`qualifier.md` — the design's precise contract

### Measured value
Synthesizing rustcoin3d's audit (F1-F3) + premortem (P1-P3) produced a single statement with 3 hard boundaries + 3 soft boundaries + MEDIUM confidence.

---

## C5 — Behavior Tree Visualization

**Combination**: `tree` standalone

### Applicable scenarios
- Long-running project, want to see overall progress
- Multiple historical tasks, want to know the relationship between the current task and past ones
- State consistency check (whether all gates truly passed)

### Not applicable
- A task that just started (nothing to visualize)
- Only want to see current status numbers → use status (lighter)

### Usage
```bash
/toulmin:toulmin-tree
```
Execution:
1. Render the current task tree (phase → gate → verdict)
2. Scan the historical task directory
3. Fuzzy-match similar tasks (remind you to reuse lessons)
4. Output a Mermaid diagram + statistics

### Measured value
On the Critical-argument project, tree directly exposed `gates_passed: [gate-1, gate-3]` missing gate-2 — the visualization itself became a diagnostic tool.

---

## C6 — Agent Isolated Dispatch

**Combination**: the Agent dispatch mechanism within `plan` (Gate 2/3)

### Applicable scenarios
- Need a genuinely independent review perspective (not self-evaluation)
- The planning conversation is long and you worry verification will be anchored by the earlier discussion
- High-risk decisions that need "fresh eyes"

### Not applicable
- Simple tasks where the isolation overhead isn't worth it → run the verify/debate skill directly
- Gate 1, which needs interactive discussion → the orchestrator does it itself

### How it works
| Role | Context | Responsibility |
|------|--------|------|
| Orchestrator | Full conversation | Problem + decomposition + Gate 1 + implementation |
| verifier agent | **Isolated** | L1-L4, unaware of the planning discussion |
| debater agent | **Isolated** | D1-D6, no attachment to the code |

Triggered automatically via C1's toulmin-plan; no separate invocation needed.

### Measured value
The isolated context let two agents discover two sides of the same merge defect without knowing about each other — the strongest evidence for isolated adversarial review.

### Known limitations
Agents cannot access `CLAUDE_PLUGIN_ROOT`. It is recommended that state updates be performed by the orchestrator after the agent returns; the agent is only responsible for analysis + writing the document.

---

## C7 — Vibe Coding Safety Net

**Combination**: `vibe → checkpoint → VAC`

### Applicable scenarios
- Fast iteration, prototypes, spikes
- Requirements still being explored, not suited to a full structured workflow
- Want to keep the vibe rhythm but worried about drifting off course

### Not applicable
- Architecture changes, safety-critical → use C1
- A clearly defined multi-step task → use C1

### Usage
```bash
/toulmin:toulmin-vibe --lang zh --checkpoint 5
```
Automatic mechanisms:
1. Free iteration (coding → review → coding)
2. Every N rounds: the Stop hook injects an L0 signal scan + **drift self-check**
3. Drift self-check: "Have I strayed from the original task?" → if so, record a partition
4. VAC (60-second adversary): "In three sentences, say under what conditions this code blows up"

### Measured value
The checkpoint correctly fired on round 5, including the drift self-check injection; structured mode also injects a drift check every 30 rounds.

---

## C8 — Override Risk Pass

**Combination**: `override` standalone

### Applicable scenarios
- The gate failed but the risk is understood and acceptable
- Time pressure requires passing, but a decision record must be left
- The gate design is too strict and doesn't apply to the current scenario

### Not applicable
- Just too lazy to fix the problem → the cooldown period adds friction to stop you
- Repeated overrides → ratio tracking will warn "gate discipline is declining"

### Usage
```bash
/toulmin:toulmin-override "This boundary condition is impossible in the current deployment environment; risk accepted"
```
Escalating friction:
| Count | Requirement |
|------|------|
| 1st | Free |
| 2nd | Reason ≥ 30 characters |
| 3rd+ | Type `OVERRIDE` to confirm + show history + ratio warning |

### Artifacts
Appends an override record to the corresponding gate document (reason + timestamp + risk-acceptance statement)

### Design philosophy
Override is not an escape hatch; it is **recorded, friction-bearing risk acceptance**. The cooldown period prevents the "block every time → override" pattern from degrading into a formality.

---

## Typical Workflow Compositions

### Workflow A: Full flow for high-risk tasks
```
C1 (plan→verify→debate) → C2 (audit key claims) → C3 (premortem) → C4 (qualify) → C5 (tree archive)
```
Coverage: all four quadrants + synthesis + visualization. Highest cost, suited to architecture changes / safety-critical work.

### Workflow B: Standard feature development
```
C1 (plan→verify→debate) → C5 (tree)
```
Coverage: the two internal quadrants. Suited to day-to-day feature development.

### Workflow C: Fast iteration
```
C7 (vibe) → VAC when triggered
```
Coverage: L0 signals + on-demand adversarial review. Suited to prototypes/spikes.

### Workflow D: Targeted external verification
```
(existing design) → C2 (audit a single suspicious claim)
```
Coverage: external-static. Suited to verifying a particular technical choice.

---

> Document version: v1.0
> Created: 2026-07-09
> Based on: real-world verification of 8 combinations (skill-combination-verification.md)
