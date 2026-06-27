# Gate 1 — Direction Convergence — 2026-06-27

## Decision
对toulmin插件v1.0.0的12个缺陷采用最小侵入式修复策略——每个修复仅触及缺陷的直接原因，不重构架构，不添加新功能。

### Claim
12个修复在保持与ralph-loop/grill-me已验证模式一致性的前提下，消除了Toulmin框架实现中已被证明的逻辑缺口、遗漏和不一致性。

### Ground

审查范围覆盖全部12个源文件（5个技能、3个hook脚本、2个agent、hooks.json、plugin.json）。发现分布：

- **阻塞性bug (2个)**：F1非ASCII slug清空导致中文任务gate目录创建失败；F2 Skill工具调用使用非限定名
- **结构性缺陷 (3个)**：F3 PreToolUse缺少session隔离；F7 反方辩论对抗性软化；F11 state file更新机制未明确
- **健壮性/一致性缺陷 (7个)**：F4损坏状态文件未清理；F5/F12目录名不一致；F6 null gate_dir未处理；F8孤立字段；F9 phase值空间不完整

### Warrant

每个修复遵循三个约束原则：
1. **模式一致性**：优先对齐ralph-loop已验证的实现模式（session隔离、损坏清理、sed原子更新），而非发明新模式
2. **最小侵入**：只触及缺陷的直接原因。F1修复只改变slug生成逻辑，不重构整个初始化流程。F9只在各阶段边界增加sed调用，不改变阶段本身定义
3. **向后兼容**：所有修复仅改变行为细节，不改变state file schema、hook协议或技能间接口

### Backing

- F3的session隔离代码直接复用stop-hook.sh:27-31的已验证实现模式
- F4的损坏清理逻辑对齐ralph-loop的`stop-hook.sh:38-47`
- F11的sed原子更新模式与stop-hook.sh:42已使用的模式一致
- F1的slug fallback策略（`task-HHMMSS`）是Unix命名冲突解决的成熟模式

### Rebuttal

**替代方案A：全面重构**
将所有state file操作集中到一个helper脚本，消除竞态和不一致。
→ 拒绝：v1.0.0的目标是缺陷修复而非架构重构。重构增加了变更面（~200行 vs 当前~114行），引入了新的测试负担。重构的收益在v2中评估。

**替代方案B：仅修复高严重度缺陷**
只修F1和F2，其余推迟到v2。
→ 拒绝：F3（session隔离）和F11（更新竞态）虽然是"中"严重度，但它们的修复成本极低（F3: 9行，F11: 用已有模式替换）。推迟没有节省足够成本来抵消技术债务累积。

**替代方案C：回退到纯prompt驱动（放弃hook）**
担心hook的维护复杂度，退化为类似grill-me的纯SKILL.md方案。
→ 拒绝：放弃hook等于放弃框架的两个核心机制——gate拦截和checkpoint自动触发。grill-me模式无法在没有hook的情况下强制"gate未通过则不能coding"。

### Qualifier

- **有效期**：此决策的修复方向对v1.0.x系列有效。当以下任一条件发生时需重新评估：
  - 引入新hook事件（触发Stop/PreToolUse/SessionStart之外的事件）
  - state file schema变更（增加或删除字段）
  - Claude Code hook协议变更
- **范围边界**：仅适用于当前12个源文件的修复。不涉及框架理论文档、不涉及新功能、不涉及性能优化

## Verdict: PASSED
