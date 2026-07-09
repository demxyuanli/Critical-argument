---
name: toulmin-verify
description: Execute the Toulmin limited verification protocol (L1-L4) against the current design or implementation. Dispatches toulmin-verifier agent for isolated-context review. Writes gate-2-verification.md. Called by toulmin-plan at gate-2, or standalone in vibe mode.
user-invocable: true
disable-model-invocation: false
---

# Toulmin Limited Verification (Gate 2)

Dispatch the verification agent to execute L1-L4 + L3.5 Causal Trace against the current design or implementation. The agent runs in an isolated context — its findings are not influenced by planning conversation.

## Pre-flight

1. Read `.claude/toulmin-state.local.md` to get `gate_dir`, `lang`, `ca_mode`.
2. If `gate_dir` is null (vibe mode): create `docs/toulmin/YYYY-MM-DD-vibe-session/` and update state file `gate_dir` field.
3. Confirm target: read current design artifacts (spec doc, task decomposition, or current code if vibe mode).

## Execution

Dispatch the verification agent with isolated context:

> Use the Agent tool with agent type `toulmin:toulmin-verifier`.
>
> **Prompt**: "Execute the Toulmin limited verification protocol against [target description]. The design/gate-1 is at [path if available]. Write gate-2-verification.md to {gate_dir}/. Language: {lang}. After writing, update state via: bash ${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh gate-2 passed gate-3 gate-2-passed (if PASSED) or bash ${CLAUDE_PLUGIN_ROOT}/scripts/update-gate.sh gate-2 failed (if FAILED)."

The agent executes L1-L4 + L3.5 Causal Trace per its protocol definition. It writes `{gate_dir}/gate-2-verification.md`.

## Post-verification

1. Read `{gate_dir}/gate-2-verification.md` for the verdict.
2. If FAILED: halt. Report why. Do not proceed.
3. If PASSED: continue.
4. Scan the gate-2 document for claims referencing external facts. Append a fact-check candidate table:

```markdown
## Fact-Check Candidates

Claims below reference external facts verifiable via web search. Mark `[x]` to audit with `/toulmin:toulmin-audit`.

| # | Claim | Ground (cited basis) | Audit focus | Risk | Est. tokens |
|---|-------|---------------------|-------------|------|-------------|
| 1 | "[exact claim from L1-L4]" | [what it's based on] | [what to search for] | H/M/L | ~3k |
```

Risk: H=design changes if wrong, M=scope adjustment, L=minor correction. Skip if no externally-verifiable claims.

5. Report verdict.

Output in the language specified by `lang` field.
