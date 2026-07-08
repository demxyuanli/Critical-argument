---
name: toulmin-premortem
description: Prospective hindsight analysis — assume the output has failed, reverse-engineer the causal chains that led to failure. Identifies hidden vulnerabilities missed by forward-looking verification. Manual invocation, not a gate.
user-invocable: true
disable-model-invocation: false
---

# Toulmin Pre-mortem — 失败回溯推演

Prospective hindsight analysis: assume the current design/implementation HAS ALREADY FAILED, then reverse-engineer the causal chains that led there. This exploits the cognitive mechanism identified by Gary Klein (2007): humans identify 30% more unique risks when constructing backward narratives than when predicting forward.

**This is NOT a gate.** It is a diagnostic tool invoked manually to surface blind spots in Gate 2 and Gate 3.

## When to invoke

- After Gate 2 (verify) and Gate 3 (debate) pass — before committing to the design
- When a design decision feels "too clean" and you want adversarial stress-testing
- Before a major release or deployment
- In vibe mode — as a 90-second "what could go wrong" sanity check

## Input

The premortem operates on the current design or implementation. It reads:
1. Gate documents (gate-1, gate-2, gate-3) if available — to understand the ratified assumptions
2. The current code/design artifacts
3. The original task description or requirements

No explicit claim input needed. The premise is always: "This has failed."

## Execution

### Step 1: Set the premise

> 假定当前方案/代码已经失败。现在我们反向重建调查报告——
> 它不是怎么成功的，而是怎么死的。

The timeline is task-appropriate — could be "the first production deployment," "after 6 months of scaling," or "after the third sprint." Choose the most revealing horizon.

### Step 2: Generate 3 independent death-path narratives

For each path, construct a complete causal chain:

```
触发条件 → 放大机制 → 级联效应 → 最终崩溃
```

Each node in the chain must reference a specific vulnerability in the current design.

The three paths should be **orthogonal** — each exploiting a different class of weakness:

| Path | Exploits | Typical triggers |
|------|---------|-----------------|
| P1: Assumption collapse | A key assumption from L1 is wrong | Scale/time/context shift invalidates the assumption |
| P2: Boundary breach | A boundary condition from L2 is hit | Real-world input exceeds the modeled range |
| P3: Interaction death | Two components interact badly | Independent modules have conflicting assumptions |

### Step 3: Map each path to Toulmin elements

For each death path, identify which Toulmin element of the original design was the root vulnerability:

- **Claim refuted**: The core claim was never true
- **Ground falsified**: The data/evidence the design relied on was wrong
- **Warrant broken**: The reasoning chain had a hidden gap
- **Backing obsolete**: The external authority was superseded or misapplied
- **Qualifier absent**: The design assumed universal scope but had narrow validity

### Step 4: Score and prioritize

For each path:
- **Likelihood**: How probable is the trigger? (high/medium/low)
- **Impact**: If this path fires, what's the blast radius? (fatal/severe/manageable)
- **Detectability**: Would current monitoring catch it? (immediate/delayed/silent)
- **Root assumption**: Which L1 assumption or L2 boundary is the linchpin?

### Step 5: Recommendations

For each death path:
- **Prevention**: What to change NOW to prevent the trigger
- **Detection**: What to monitor to catch early signals
- **Mitigation**: What to prepare as a fallback if it starts happening

## Output format

```markdown
# Pre-mortem Analysis — [Date Time]

## Premise
> [Task-appropriate failure premise]

## Death Path 1: [Name] — Likelihood: [H/M/L] | Impact: [fatal/severe/manageable]

### Narrative
**Trigger**: [specific condition or event]
**Amplification**: [how the initial problem grows]
**Cascade**: [what else breaks as a result]
**Collapse**: [the final failure state]

### Toulmin Root Cause
- **Vulnerable element**: [Claim/Ground/Warrant/Backing/Qualifier]
- **Current assumption**: [what the design currently assumes]
- **Why it fails**: [specific mechanism of failure]

### Defense
- **Prevention**: [design change now]
- **Detection**: [monitoring signal]
- **Mitigation**: [fallback if it fires]

## Death Path 2: [Name] — ...
## Death Path 3: [Name] — ...

## Synthesis

### Top vulnerability
[The single most dangerous assumption/design choice across all paths]

### Pattern analysis
[Do the death paths share a common root cause? E.g., all three exploit overconfidence in a single component, or all three trace to one unfalsifiable assumption.]

### Recommended actions
1. [Immediate — prevent the most likely fatal path]
2. [Short-term — add detection for silent paths]
3. [Monitor — triggers that should prompt re-running premortem]
```

## Comparison with existing gates

| | L3.5 Causal Trace | L4 "One Thing" | **Pre-mortem** |
|---|---|---|---|
| Direction | Forward (cause→effect) | Static snapshot | Backward (failure→causes) |
| Causal depth | Single chain per failure | One fatal assumption | 3 independent multi-hop narratives |
| Cognitive mode | Analytical | Judgment | Prospective hindsight |
| Output | AND/OR trees | One named assumption | 3 stories + synthesis |

## Token budget

~2-4k tokens. No web search. The analysis is creative but constrained — all vulnerability claims must reference specific elements from gate documents or code structure.

## Post-analysis

1. Report findings.
2. If gate documents exist, append the synthesis as a "Pre-mortem Addendum" to gate-3.
3. Do NOT modify design. Pre-mortem is diagnostic, not prescriptive.

Output in the language specified by `lang` field in state file, or the user's conversation language.
