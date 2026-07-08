---
name: toulmin-qualify
description: Synthesize all gate/audit/premortem findings into a unified qualifier — a precise scope statement defining where the design is valid and where it fails. Manual invocation, typically the last step before regression.
user-invocable: true
disable-model-invocation: false
---

# Toulmin Qualify — Unified Qualifier Synthesis

Read all artifacts in the current gate directory and synthesize a single, precise qualifier statement. The qualifier is the **contract** of the design — it says where it works, where it fails, and with what confidence.

Without this step, each tool's findings (verify boundaries, debate rebuttals, audit counter-evidence, premortem death paths) remain siloed in separate documents.

## When to invoke

After all review tools have been applied to a task. Typically:
```
plan → gate-1 → verify → gate-2 → debate → gate-3 → audit → premortem → qualify → regression
```

Can also be run mid-cycle if the user wants to check the current accumulated scope.

## Input

Reads from the `gate_dir` in `.claude/toulmin-state.local.md`. Scans all documents present:

| Document | Extracts |
|----------|---------|
| `gate-1-convergence.md` | Validity scope, expiration conditions, rejected alternatives |
| `gate-2-verification.md` | L1 assumptions, L2 boundary matrix, L3 failure modes, L3.5 causal traces, L4 fatal assumption |
| `gate-3-debate.md` | REBUT/CLARIFY items, DEMOTE decisions, verdict conditions |
| `gate-*-audit-*.md` (or inline audit sections) | External evidence challenges, revised qualifiers from audit |
| `gate-*-premortem-*.md` (or inline premortem sections) | Death paths, root vulnerabilities |

## Execution

### Step 1: Collect all limitations

Read each available document. For every limitation found, extract:

```
Source: [which tool found it]
Domain: [input | state | environment | assumption | dependency | platform]
Condition: [when does it apply]
Effect: [what happens if the condition is violated]
Severity: [fatal — design must change | severe — significant rework | manageable — workaround exists]
```

### Step 2: Merge and categorize

Group by domain. Merge semantically identical limitations (same condition from different tools → single entry with dual attribution).

Priority order for conflicting qualifiers:
- External evidence (audit) > internal verification (verify)
- Adversarial finding (debate) > self-assessment (gate-2)
- Fatal severity > severe > manageable

### Step 3: Classification

Classify each limitation:

- **HARD BOUNDARY**: Violating this condition → design is invalid. Must redesign or accept with override.
- **SOFT BOUNDARY**: Violating this condition → degraded behavior, but design still functions.
- **MONITOR**: Condition to watch — not a current limitation but a drift indicator.

### Step 4: Generate unified qualifier

```markdown
# Unified Qualifier — [Date Time]

## Design Scope Statement

> Under **[conditions that must hold]**, based on **[evidence sources]**,
> the design **[achieves its claim]** with **[confidence level]**.
>
> The design **FAILS** when **[critical boundary conditions]**.
>
> The design **DEGRADES** when **[soft boundary conditions]**.

## Confidence

**[high / medium / low]**

**Basis**: [summary of evidence — what was verified vs what was assumed vs what was externally challenged]

## Hard Boundaries (design invalid if violated)

| # | Condition | Effect | Source | Severity |
|---|-----------|--------|--------|----------|
| 1 | [specific condition] | [what breaks] | gate-2 L2 / audit F3 | fatal |

## Soft Boundaries (design degrades if violated)

| # | Condition | Degradation | Source | Severity |
|---|-----------|-------------|--------|----------|
| 1 | [specific condition] | [how it degrades] | gate-3 R1-4 / premortem P2 | severe |

## Monitor Triggers (drift indicators, not current failures)

| # | Signal | Why | Source |
|---|--------|-----|--------|
| 1 | [observable change] | [what it would mean] | premortem P1 |

## Open Risks (accepted, not mitigated)

| # | Risk | Acceptance rationale | Source |
|---|------|---------------------|--------|
| 1 | [known unmitigated risk] | [why accepted] | gate-2 L1 / override |

## Evidence Sources

| Tool | Status | Key contribution |
|------|--------|-----------------|
| Gate 2 (verify) | ✅/❌ | [L1-L4 findings count] |
| Gate 3 (debate) | ✅/⚠️/❌ | [findings: N ACCEPT, M REBUT, K DEMOTE] |
| Audit | ✅/⚠️/❌ | [N external challenges, M qualifier revisions] |
| Pre-mortem | N/A | [N death paths, top vulnerability] |

## Revision History

| Date | Change | Trigger |
|------|--------|---------|
| [date] | Initial synthesis | All tools applied |
```

### Step 5: Write and report

Write to `{gate_dir}/qualifier.md`.

Report summary to user:
```
Qualifier synthesized from [N] sources.
  Hard boundaries: [N]   (design invalid if violated)
  Soft boundaries: [N]   (design degrades if violated)
  Monitor triggers: [N]  (drift indicators)
  Open risks: [N]        (accepted, not mitigated)
  Confidence: [high/medium/low]

Qualifier document: {gate_dir}/qualifier.md
```

Output in the language specified by `lang` field.
