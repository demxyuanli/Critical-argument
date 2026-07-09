---
name: toulmin-debate
description: Execute the Toulmin adversarial debate protocol (R1-R3) against completed output. Dispatches toulmin-debater agent for isolated-context adversarial review. Writes gate-3-debate.md. Called by toulmin-plan at gate-3, or standalone in vibe mode.
user-invocable: true
disable-model-invocation: false
---

# Toulmin Adversarial Debate (Gate 3)

Dispatch the debate agent to execute R1-R3 against the completed output. The agent runs in an isolated context with a singular objective: REFUTE. This role separation is essential — the agent has no attachment to the code it attacks.

## Pre-flight

1. Read `.claude/toulmin-state.local.md` to get `gate_dir` and `lang`.
2. If `gate_dir` is null (vibe mode): create `docs/toulmin/YYYY-MM-DD-vibe-session/` and update state file `gate_dir` field.
3. Identify review target: recently modified code files, or specific files mentioned by user.
4. Read the original requirements/spec (if available) as correctness baseline.

## Execution

**Always dispatch a dedicated debate agent:**

> Use the Agent tool with agent type `toulmin:toulmin-debater`.
>
> **Prompt**: "Execute the Toulmin adversarial debate protocol against [list of changed files]. Original design: {gate_dir}/gate-1-convergence.md. Verification results: {gate_dir}/gate-2-verification.md (if available). Language: {lang}. Write gate-3-debate.md to {gate_dir}/. After writing, update state via: bash ${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh gate-3 passed '' gate-3-passed (if PASSED/CONDITIONAL) or bash ${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh gate-3 failed (if FAILED)."

The agent executes R1-R3 (D1-D6 attack dimensions) per its protocol definition. It writes `{gate_dir}/gate-3-debate.md`.

## Post-debate

1. Read `{gate_dir}/gate-3-debate.md` for the verdict.
2. If FAILED: halt. Fix defects and re-dispatch the agent.
3. If CONDITIONAL PASS: tag conditions for regression monitoring.
4. If PASSED: continue.
5. Scan the gate-3 document for REBUT and CLARIFY items invoking external references (RFCs, library docs, version claims, ecosystem comparisons, CVEs). Append a fact-check candidate table:

```markdown
## Fact-Check Candidates

Claims below reference external facts verifiable via web search. Mark `[x]` to audit with `/toulmin:toulmin-audit`.

| # | Claim (from debate) | Ground (cited in R2) | Audit focus | Risk | Est. tokens |
|---|--------------------|--------------------|-------------|------|-------------|
| 1 | "[disputed claim from R1→R2]" | [evidence cited in rebuttal] | [what to search] | H/M/L | ~3k |
```

Risk: H=rebuttal collapses if wrong, M=verdict confidence reduced, L=tangential. Skip if no externally-citable items.

6. Report verdict.

Output in the language specified by `lang` field.
