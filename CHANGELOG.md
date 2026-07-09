# Changelog

All notable changes to the Toulmin Critical Argumentation Framework.

---

## [1.2.1] — 2026-07-09

### Added
- English translations of theory framework (`ai-failure-detection-framework.en.md`, 1096 lines)
- English translation of skill combination guide (`docs/skill-combination-guide.en.md`, 301 lines)
- Language switcher links (`[English]`/`[中文]`) on all deep docs
- Additional Docs table in root READMEs linking bilingual resources

### Fixed
- **BUG-1 (critical)**: `update-gate.sh` — `gates_passed` array append silently failed for multi-element arrays. The grep regex `\[.\]` only matched single-character bracket content, causing `[gate-1]→[gate-1,gate-2]` to silently no-op.
- **BUG-2 (high)**: `partition-track.sh` — appended partition entries without comma separator, producing `["task""new", ]`
- **BUG-3 (medium)**: `toulmin-override` SKILL.md — `override_history` had the same YAML-array-append pattern as BUG-1/2

### Verified
- 8/8 skill combinations verified with full documentation (`docs/skill-combination-verification.md`)
- C1 (plan→verify→debate) confirmed isolated agent contexts produce genuinely independent adversarial perspectives

---

## [1.2.0] — 2026-07-08

### Added
- **Agent-orchestrated gate execution**: `toulmin-plan` dispatches dedicated `toulmin-verifier` and `toulmin-debater` agents for Gate 2/3. Agents run in isolated contexts — verification and debate findings are not contaminated by planning conversation.
- **`toulmin-tree` skill**: Behavior tree visualization with Mermaid diagrams. Renders task lifecycle, gate verdicts, context partitions, and cross-session references.
- **`partition-track.sh`**: Records context partition transitions. Stop hook injects drift self-check at checkpoints (vibe: every N iterations, structured: every 30).
- Agent orchestration pattern documented alongside grill-me and ralph-loop patterns.

### Changed
- `toulmin-plan` SKILL.md rewritten as agent orchestrator with dispatch rules
- READMEs restructured to 12-section format with review tool matrix

---

## [1.1.0] — 2026-07-08

### Added
- **`toulmin-audit` skill**: External evidence verification via WebSearch. Decomposes a claim into Toulmin elements, searches for counter-evidence (3-5 queries), outputs audit report with STANDS/NARROW/REFUTED verdict.
- **`toulmin-premortem` skill**: Prospective hindsight failure backtracking. Assumes the design has failed, reverse-engineers 3 independent causal death paths, maps each to vulnerable Toulmin element.
- **`toulmin-qualify` skill**: Unified qualifier synthesis. Aggregates findings from all review tools (verify, debate, audit, premortem) into a single scope statement with hard boundaries, soft boundaries, monitor triggers, open risks, and confidence level.
- **Override cooldown**: Escalating friction — 1st override free, 2nd requires 30+ character reason, 3rd+ requires typing `OVERRIDE` confirmation. Ratio tracking warns when overrides exceed natural gate passes.
- **Hook integrity awareness**: `toulmin-status` displays 5 known hook enforcement blind spots (headless `-p`, bypass mode, subagent, Bash bypass, async denial).
- **Historical task awareness**: `session-start.sh` scans past gate directories, detects similar task slugs (>3 char overlap), warns to review past lessons.
- **`bash-guard.sh`**: PreToolUse hook for Bash commands. Detects file-write patterns (`sed -i`, `echo >`, `tee`, `python -c` with `open`/`write`, `dd of=`) when `gate_blocked=true`.
- **Claim 10** in theory framework: "Internal argumentation has systematic external blind spots"

### Changed
- Theory document updated from 9 to 10 sections with four-quadrant model and degradation defense theory
- Final principles expanded from 4 to 7
- Applicability matrix adds audit/premortem/qualify columns

---

## [1.0.1] — 2026-06-27

### Added
- Tri-lingual READMEs (zh/en/ja)
- `toulmin-override` skill with gate state update
- `gate_attempts` counter in state file (display-only)
- L3.5 Causal Trace protocol (TOP_EVENT→CAUSAL_CHAIN→PROPAGATION_PATH→CRITICAL_JUNCTION)
- Approach A: gate document consistency verification (`verify_gate_blocked_consistency`, `verified_gate_count`)
- Marketplace manifest for Claude Bazaar

### Fixed
- **C1 (critical)**: `update-gate.sh` grep `-q "$GATE"` matched entire state file including `gate_current` line — gates_passed never updated. Fixed: anchored to `^gates_passed:.*\<${GATE}\>`
- **D1-1 (critical)**: `local cur_attempts` outside function scope caused `set -e` exit in update-gate.sh
- **F1**: Non-ASCII slug generation stripped CJK characters producing empty strings. Fixed: `task-HHMMSS` fallback
- **D1-2**: Quoted heredoc `<< 'EOF'` prevented date expansion in override SKILL.md

---

## [1.0.0] — 2026-06-27

### Added
- Initial release of the Toulmin Critical Argumentation Framework
- **5 skills**: `toulmin-plan`, `toulmin-vibe`, `toulmin-verify`, `toulmin-debate`, `toulmin-status`
- **2 agents**: `toulmin-debater` (D1-D6 attack dimensions), `toulmin-verifier` (L1-L4 verification)
- **3 hooks**: PreToolUse (Write/Edit deny), Stop (iteration + completion + checkpoint), SessionStart (recovery pointer)
- **3 scripts**: `state.sh` (shared parser), `update-gate.sh` (atomic sed), `pre-tool-use.sh`, `stop-hook.sh`, `session-start.sh`
- L0/L1/L2 layered detection framework (signal / verification / intervention)
- Three-gate process framework: Gate 1 (convergence), Gate 2 (limited verification L1-L4), Gate 3 (adversarial debate R1-R3)
- Vibe coding protocol with checkpoint triggers and VAC (Vibe Adversarial Check)
- 8 Toulmin-structured claims in unified theory framework
- Gate document system as third-party argumentation records
