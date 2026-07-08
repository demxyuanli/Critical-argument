---
name: toulmin-status
description: Display current Toulmin critical argumentation status — phase, gate progress, signal history, unverified assumptions. Read-only diagnostic.
user-invocable: true
disable-model-invocation: false
---

# Toulmin Status

Read the current framework state and present it to the user.

## Instructions

1. **Check state file existence**: `test -f .claude/toulmin-state.local.md && echo "EXISTS" || echo "NOT_FOUND"`
2. **If NOT_FOUND**: Say "No active Toulmin critical argumentation session. Start one with /toulmin-plan or /toulmin-vibe."
3. **If EXISTS**: Read `.claude/toulmin-state.local.md`. If `gate_dir` is null or empty: report "No gate documents yet. Run /toulmin-verify or /toulmin-debate to create gate documents." Otherwise, for each gate document in the directory referenced by `gate_dir`, read and summarize. Present:

```
## Toulmin Framework Status

**Mode**: [structured / vibe]
**Phase**: [current phase]
**Gate progress**: [N]/3 passed
**Current gate**: [gate name]
**Iteration**: [N]
**Language**: [lang]

### Gate documents
[For each gate doc found in gate_dir]:
  Gate N ([filename]): [PASSED / FAILED] — [one-line decision summary]

### Active warnings
- [Any gate_blocked=true → "Coding tools BLOCKED — gate not passed"]
- [Any failed gate → "Gate N failed — see gate doc for details"]
- [Vibe mode checkpoint status]
- [override_count > 0 → "⚠️  [N] gate(s) overridden this session. Override ratio: [N]:[M passed naturally]"]
- [override_count ≥ 3 → "🛑 Gate discipline degraded — more overrides than completions. Framework becoming ceremonial."]

### Hook integrity
Known hook enforcement blind spots (verified by toulmin-audit — see README):
- ✅ Interactive mode + exit code 2 → deterministic blocking
- ❌ headless `-p` mode → hooks not invoked at all
- ❌ `--dangerously-skip-permissions` → hooks run async, denial delayed
- ❌ subagent tool calls → PreToolUse not triggered for subagent Bash/Write
- ⚠️  Bash write bypass → covered by bash-guard.sh (sed/echo>/tee patterns)
- To verify hooks are active: check that iteration counter is incrementing (run status twice — if iteration is the same, Stop hook may be silent)

### Historical context
[If docs/toulmin/ contains directories beyond current gate_dir]:
```
Past tasks in this project: [N] session(s)
  [List of directories with dates and one-line gate-1 summaries]
Run: ls docs/toulmin/ to review. Consider: does the current task overlap with any past task?
```

### Next action
[If gate_blocked: what to do to unblock]
[If all gates passed: "All gates passed. Regression testing remaining."]
[If no gates yet: "Work in progress. Continue with current phase."]
```

Output in the language specified by the `lang` field in the state file frontmatter.
