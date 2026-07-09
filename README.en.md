# Toulmin — Critical Argumentation Framework

A Claude Code plugin based on the [Toulmin Argumentation Model](https://en.wikipedia.org/wiki/Stephen_Toulmin). Institutionalizes "limited verification before coding" and "adversarial debate before acceptance" into rigid review gates for AI-assisted engineering.

**v1.2.0** · 9 skills · 2 agents · 3 hooks · 7 scripts · 10 claims

---

## Four-Quadrant Review System

```
                Internal                    External
    ┌─────────────────────────┬─────────────────────────┐
Static│ verify (L1-L4)          │ audit (WebSearch)        │
    ├─────────────────────────┼─────────────────────────┤
Dynamic│ debate (R1-R3)         │ premortem (backtracking) │
    └─────────────────────────┴─────────────────────────┘
                              ↓
                   qualify (synthesis) → tree (visualization)
```

## Quick Start

```bash
# Install
cp -r toulmin ~/.claude/skills/toulmin

# Structured task
/toulmin:toulmin-plan "Add role-based access control to user table" --lang zh

# Vibe coding
/toulmin:toulmin-vibe --lang zh
```

## Commands

| Command | Purpose |
|---------|---------|
| `/toulmin:toulmin-plan` | Agent-orchestrated structured execution |
| `/toulmin:toulmin-vibe` | Vibe coding + checkpoint + drift self-check |
| `/toulmin:toulmin-verify` | L1-L4 verification + L3.5 causal trace |
| `/toulmin:toulmin-debate` | R1-R3 adversarial debate (D1-D6) |
| `/toulmin:toulmin-audit` | WebSearch external evidence verification |
| `/toulmin:toulmin-premortem` | Failure backtracking (3 death paths) |
| `/toulmin:toulmin-qualify` | Unified qualifier synthesis |
| `/toulmin:toulmin-tree` | Behavior tree visualization (Mermaid) |
| `/toulmin:toulmin-status` | Framework status + integrity check |
| `/toulmin:toulmin-override` | Manual gate override (cooldown-tracked) |

## Docs

| Document | Content |
|----------|---------|
| [Plugin README (中文)](toulmin/README.md) | 完整使用文档 |
| [Plugin README (English)](toulmin/README.en.md) | Full documentation |
| [Plugin README (日本語)](toulmin/README.ja.md) | 完全なドキュメント |
| [Theory](ai-failure-detection-framework.md) | 10 claims + 10 sections |

## Versions

| Version | Key Additions |
|---------|---------------|
| v1.0.1 | Foundation: 5 skills + 3 hooks + L0-L2 + 3 gates + Vibe |
| v1.1.0 | v3 External review: audit + premortem + qualify + degradation defense |
| v1.2.0 | v2 Agent orchestration + tree + partition tracking + drift self-check |

## License

MIT
