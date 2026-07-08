---
name: toulmin-audit
description: External evidence verification — search web for counter-evidence, alternatives, and boundary conditions against a specific claim. Output Toulmin-formatted audit report. Manual invocation, not a gate.
user-invocable: true
disable-model-invocation: false
---

# Toulmin Audit — External Evidence Verification

Verify a claim by searching for counter-evidence, alternatives, and updated information against each Toulmin element. Uses WebSearch to introduce information the model cannot know internally — prior art, production failure reports, superseded standards, competing approaches.

**This is NOT a gate.** It is a review tool invoked manually on specific claims that need external verification.

## When to invoke

- A claim from the fact-check candidate table (appended to gate-2/gate-3 docs)
- User suspects a warrant or backing relies on outdated/incorrect external information
- A critical design decision depends on an unverified external fact

## Input

Receive a claim to audit. Format: `/toulmin:toulmin-audit "具体主张"`

The claim should be a concrete, externally-verifiable statement — not a design opinion. Examples:
- ✅ "PostgreSQL row-level security 比应用层权限检查更适合此场景"
- ✅ "React 19 Server Components 已在生产环境稳定可用"
- ❌ "这个架构应该用微服务" (design opinion, not externally verifiable)

## Execution

### Step 1: Decompose claim into Toulmin elements

Identify the claim's internal structure:
- **Claim**: The core assertion
- **Ground**: What evidence/facts is the claim based on?
- **Warrant**: What reasoning connects ground to claim?
- **Backing**: What external authority/standard does it invoke?
- **Qualifier**: What scope does it implicitly claim?

### Step 2: Search for counter-evidence

Execute 3-5 WebSearch queries targeting the weakest Toulmin elements. Prioritize by risk:

| Risk | Target | Query pattern |
|------|--------|--------------|
| High | Backing | "[standard/authority] deprecated / superseded / vulnerability" |
| High | Warrant | "[assumed causal link] debunked / myth / alternative explanation" |
| Medium | Ground | "[claimed fact] counterexample / limitation / production failure" |
| Medium | Qualifier | "[claim scope] edge case / extreme condition / outside boundary" |
| Low | Claim | "[alternative approach] vs [current approach] production comparison" |

Execute at least 3 queries. Never exceed 5 without user request ("extended audit").

### Step 3: Evaluate each finding

For each search result that challenges the claim:
- **Category**: Counter-evidence / Scope narrowing / Alternative threat / Authority challenge
- **Impact**: critical / high / medium / low
- **Evidence**: URL or source description
- **What it means**: How this changes the claim's validity
- **Action**: What should be done about it

### Step 4: Output audit report

```markdown
## Audit Report — [Date Time]

### Claim Under Audit
> [Original claim text]

**Toulmin decomposition**:
- Claim: [core assertion]
- Ground: [cited evidence]
- Warrant: [reasoning chain]
- Backing: [referenced authority]
- Qualifier: [implied scope]

### Search Strategy
| # | Query | Target element | Rationale |
|---|-------|---------------|-----------|

### Findings

#### F[N]: [Category] — Impact: [critical/high/medium/low]
**Evidence**: [URL or source]
**Effect on claim**: [specific contradiction / scope narrowing / alternative threat]
**Recommended action**: [Accept limitation / Revise qualifier / Reject claim / Further investigate]

(No findings = report "All searches returned supporting or neutral evidence — no counter-evidence found within search depth.")

### Revised Qualifier
> Under [conditions], based on [evidence], the claim holds with [confidence]. Fails when [boundary].

### Verdict
- ✅ **STANDS** — Evidence supports the claim within its stated scope
- ⚠️ **NARROW** — Claim valid only within narrower bounds than originally stated
- ❌ **REFUTED** — Counter-evidence contradicts the claim
```

## Token Budget

Default: 3 searches (~3-5k tokens). User can request `--extended` for 5 searches. Each additional search costs ~1-2k tokens.

## Post-audit

1. Report the verdict and any revised qualifier.
2. If the audited claim came from a gate document, note the gate doc path so user can update it with the revised qualifier.
3. Do NOT automatically modify gate documents. Audit is read-only review.

Output in the language specified by `lang` field in state file, or the user's conversation language.
