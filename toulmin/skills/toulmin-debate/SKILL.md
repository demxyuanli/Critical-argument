---
name: toulmin-debate
description: Execute the Toulmin adversarial debate protocol (R1-R3) against completed output. Writes gate-3-debate.md. Called by toulmin-plan at gate-3, or standalone in vibe mode.
user-invocable: true
disable-model-invocation: false
---

# Toulmin Adversarial Debate (Gate 3)

Execute the three-round adversarial debate against the completed output. This is a GATE — failure blocks acceptance. The debate is adversarial by design: Round 1's goal is to REFUTE, not to evaluate.

## Pre-flight

1. Read `.claude/toulmin-state.local.md` to get `gate_dir` and `lang`.
2. If `gate_dir` is null (vibe mode, no gate dir yet): create `docs/toulmin/YYYY-MM-DD-vibe-session/` and update state file `gate_dir` field.
3. Identify review target: recently modified code files, or specific files mentioned by user.
4. Read the original requirements/spec (if available) to use as correctness baseline.

## Execution

### Round 1: Structural Challenge (as adversarial reviewer)

**YOU are now the adversary.** Your goal is to find concrete, verifiable defects. For non-trivial output, you MUST use the toulmin-debater agent (via Agent tool) to perform R1 — the agent's isolated context provides the adversarial separation this gate requires. Execute R1 yourself only for trivial outputs (single-function, <50 lines).

Attack dimensions (in order):
- **D1 Correctness**: Any input producing wrong output?
- **D2 Completeness**: All stated requirements covered?
- **D3 Consistency**: Internal contradictions?
- **D4 Robustness**: Behavior under boundary conditions defined?
- **D5 Security**: Exploitable vulnerabilities?
- **D6 Maintainability**: Cascading-change risk?

For each finding: location + attack scenario + observed behavior + expected behavior + severity.

Present all findings to the user. Wait for acknowledgment before Round 2.

### Round 2: Response

For each Round 1 finding, respond:
- **[ACCEPT]**: Real defect. Fix: [description].
- **[REBUT]**: Challenge invalid because [evidence].
- **[CLARIFY]**: Challenge based on misunderstanding. Actual behavior: [explanation].
- **[DEMOTE]**: Known limitation, explicitly declared as not handled.

Forbidden responses:
- **[IGNORE]**: No response = default accept.
- **[VAGUE]**: "This should be fine" = treated as no response.

Apply fixes for all ACCEPT items before Round 3.

### Round 3: Rebuttal + Verdict

Take the REBUT and CLARIFY items from Round 2. Re-examine each:
- Challenge sustained → escalate to ACCEPT (must fix)
- Challenge withdrawn → accepted rebuttal

**Verdict**:
- ✅ **PASSED**: All ACCEPT items fixed. All sustained challenges have explicit risk acceptance. No unanswered challenges.
- ⚠️ **CONDITIONAL PASS**: Sustained challenges exist but blast radius is contained. Challenges tagged for regression monitoring.
- ❌ **FAILED**: Unaddressed ACCEPT-level defects remain. Sustained challenges affect core functionality. A "kill the design"-level defect was discovered.

## Gate Document

Write `{gate_dir}/gate-3-debate.md`:

```markdown
# Gate 3 — Adversarial Debate — [Date Time]

## Verdict: [PASSED / CONDITIONAL PASS / FAILED]

### R1: Structural Challenge
[D1-D6 findings with Toulmin structure for each]

### R2: Response
[ACCEPT/REBUT/CLARIFY/DEMOTE per finding, with evidence]

### R3: Rebuttal + Verdict
[Final disposition of each disputed finding]

## Actions Required
[Fix list, monitoring tags, risk acceptances]
```

## Post-debate

1. Update `.claude/toulmin-state.local.md`:
   - If PASSED/CONDITIONAL:
     ```bash
     bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh" gate-3 passed "" gate-3-passed
     ```
   - If FAILED:
     ```bash
     bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh" gate-3 failed
     ```
2. Report verdict.
3. Scan the gate-3 debate document for REBUT and CLARIFY items that invoke external references (RFC standards, library docs, version claims, ecosystem comparisons, security CVEs). Extract them into a fact-check candidate table appended to the gate document:

```markdown
## Fact-Check Candidates

Claims below reference external facts verifiable via web search. Mark `[x]` to audit with `/toulmin:toulmin-audit`.

| # | Claim (from debate) | Ground (cited in R2) | Audit focus | Risk | Est. tokens |
|---|--------------------|--------------------|-------------|------|-------------|
| 1 | "[disputed claim from R1→R2]" | [evidence cited in rebuttal] | [what to search for] | H/M/L | ~3k |
```

Risk assessment:
- **H**: If the external reference is wrong, the rebuttal collapses → finding becomes ACCEPT.
- **M**: External reference is supporting, not load-bearing. Wrong → verdict confidence reduced.
- **L**: External reference is tangential to the rebuttal.

If no externally-citable items: "No fact-check candidates — all REBUT/CLARIFY items based on internal logic."

Output in the language specified by `lang` field.
