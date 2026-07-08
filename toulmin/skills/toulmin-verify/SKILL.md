---
name: toulmin-verify
description: Execute the Toulmin limited verification protocol (L1-L4) against the current design or implementation. Writes gate-2-verification.md. Called by toulmin-plan at gate-2, or standalone in vibe mode.
user-invocable: true
disable-model-invocation: false
---

# Toulmin Limited Verification (Gate 2)

Execute the four-layer limited verification protocol against the current design or implementation. This is a GATE — failure blocks progress.

## Pre-flight

1. Read `.claude/toulmin-state.local.md` to get `gate_dir`, `lang`, `ca_mode`.
2. If `gate_dir` is null (vibe mode, no gate dir yet): create `docs/toulmin/YYYY-MM-DD-vibe-session/` and update state file `gate_dir` field.
3. Confirm target: read the current design artifacts (spec doc, task decomposition, interface contracts, or current code if vibe mode).

## Execution

Execute L1-L4 following the protocol in the toulmin-verifier agent. For each layer:

### L1: Assumption Inventory
List every assumption the design depends on. For each: what is assumed, what breaks if wrong, risk level (high/medium/low), mitigation or acceptance.

### L2: Boundary Condition Matrix
Enumerate boundary values for input dimensions, state dimensions, and environment dimensions. Each boundary must have a handling strategy or explicit "not handled" declaration.

### L3: Failure Mode Walkthrough
For each key module: three most likely failure modes, blast radius, single-point-of-failure check. Mitigation or acceptance for each.

### L3.5: Causal Trace
For each HIGH-severity failure mode from L3, construct a causal chain. **Do NOT ask the user.** Derive everything from already-available sources: L1 assumptions (root cause nodes), L2 boundaries (trigger conditions), and code structure analysis (call graph, data flow, shared state, error handling chain via grep/codegraph).

Format per trace:
```
TOP EVENT → CAUSAL CHAIN (AND/OR edges) → PROPAGATION PATH → CRITICAL JUNCTION (blocked?)
```
Each edge labeled with AND (all must fire) or OR (any trigger). Each node labeled with evidence source (L1/L2/code:line).

### L4: "One Thing That Kills This Design"
Identify the single fatal assumption. State confidence level (high/medium/low) with rationale.

## Gate Document

Write `{gate_dir}/gate-2-verification.md` with the following Toulmin structure:

```markdown
# Gate 2 — Limited Verification — [Date Time]

## Overall Verdict: [PASSED / FAILED]

[For each L1-L4 layer, record findings in Toulmin format]

### L1: Assumption Inventory — [PASSED / FAILED]
**Claim**: [The assumptions are sufficiently mitigated]
**Ground**: [Listed assumptions with risk levels]
**Warrant**: [Why the mitigations are adequate]
**Rebuttal**: [Challenged assumptions and responses]
**Qualifier**: [Scope of validity]

[Repeat for L2, L3, L3.5, L4]

## Actions Required
[If FAILED: what must change before retry]
[If PASSED: conditions to monitor in subsequent phases]
```

## Post-verification

1. Update `.claude/toulmin-state.local.md`:
   - If PASSED:
     ```bash
     bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh" gate-2 passed gate-3 gate-2-passed
     ```
   - If FAILED:
     ```bash
     bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh" gate-2 failed
     ```
2. Report verdict to user.
3. If FAILED: halt. Do not proceed. Return control to user.
4. Scan the gate-2 document for claims that reference external facts (library versions, tool capabilities, performance benchmarks, industry standards). Extract them into a fact-check candidate table appended to the gate document:

```markdown
## Fact-Check Candidates

Claims below reference external facts verifiable via web search. Mark `[x]` to audit with `/toulmin:toulmin-audit`.

| # | Claim | Ground (cited basis) | Audit focus | Risk | Est. tokens |
|---|-------|---------------------|-------------|------|-------------|
| 1 | "[exact claim from L1-L4]" | [what it's based on] | [what to search for] | H/M/L | ~3k |
```

Risk assessment:
- **H**: Claim underpins a design decision with no fallback. If wrong, design must change.
- **M**: Claim influences a non-critical decision. Wrong → scope adjustment, not redesign.
- **L**: Claim is supplementary. Wrong → minor correction.

If no externally-verifiable claims found: "No fact-check candidates — all claims are design judgments or logic-based."

Output in the language specified by `lang` field.
