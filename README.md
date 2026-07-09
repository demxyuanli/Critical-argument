# Toulmin — 批判性论证框架

基于[图尔敏论证模型](https://en.wikipedia.org/wiki/Stephen_Toulmin)的Claude Code插件。将AI辅助工程中的"编码前有限验证"和"验收前反方辩论"制度化为刚性审查流程。

**v1.2.0** · 9技能 · 2Agent · 3Hook · 7脚本 · 10理论论点

---

## 四象限审查体系

```
                内部论证                    外部论证
    ┌─────────────────────────┬─────────────────────────┐
静态 │ verify (L1-L4验证)       │ audit (WebSearch校核)    │
    ├─────────────────────────┼─────────────────────────┤
动态 │ debate (R1-R3辩论)       │ premortem (失败回溯推演)  │
    └─────────────────────────┴─────────────────────────┘
                              ↓
                    qualify (限定词合成) → tree (行为树可视化)
```

## 快速开始

```bash
# 安装
cp -r toulmin ~/.claude/skills/toulmin

# 结构化任务
/toulmin:toulmin-plan "给用户表加基于角色的权限校验" --lang zh

# Vibe coding + 漂移检测
/toulmin:toulmin-vibe --lang zh
```

## 命令

| 命令 | 用途 |
|------|------|
| `/toulmin:toulmin-plan` | Agent编排的结构化执行（Gate 2/3派发隔离Agent） |
| `/toulmin:toulmin-vibe` | Vibe coding + checkpoint + 漂移自检 |
| `/toulmin:toulmin-verify` | L1-L4有限验证 + L3.5因果链 |
| `/toulmin:toulmin-debate` | R1-R3反方辩论（D1-D6攻击维度） |
| `/toulmin:toulmin-audit` | WebSearch外部证据校核 |
| `/toulmin:toulmin-premortem` | 失败回溯推演（3条死亡路径） |
| `/toulmin:toulmin-qualify` | 统一限定词合成 |
| `/toulmin:toulmin-tree` | 行为树可视化（Mermaid） |
| `/toulmin:toulmin-status` | 框架状态 + 完整性检查 |
| `/toulmin:toulmin-override` | 手动gate驳回（冷却期追踪） |

## 文档

| 文档 | 内容 |
|------|------|
| [插件README (中文)](toulmin/README.md) | 完整使用文档 |
| [Plugin README (English)](toulmin/README.en.md) | Full documentation |
| [プラグインREADME (日本語)](toulmin/README.ja.md) | 完全なドキュメント |
| [理论框架](ai-failure-detection-framework.md) | 10论点 + 10章节完整论证 |

## 版本

| 版本 | 核心增量 |
|------|---------|
| v1.0.1 | 基础：5技能 + 3Hook + L0-L2 + 3Gate + Vibe |
| v1.1.0 | v3外部论证：audit + premortem + qualify + 退化防御 |
| v1.2.0 | v2 Agent编排 + tree + 分区追踪 + 漂移自检 |

## 许可

MIT
