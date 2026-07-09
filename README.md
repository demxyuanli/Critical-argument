# Toulmin — 批判性论证框架

[English](README.en.md) | [日本語](README.ja.md)

基于[图尔敏论证模型](https://en.wikipedia.org/wiki/Stephen_Toulmin)的Claude Code插件。v1.2将"编码前验证"和"验收前辩论"扩展为**完整的四象限审查体系**：内部论证（verify + debate）+ 外部论证（audit + premortem）+ 限定词合成（qualify）+ Agent编排 + 行为树可视化（tree）+ 上下文漂移检测。

**9个技能 · 2个Agent · 3个Hook · 7个脚本 · 10个理论论点**

---

## 1. 设计理论 — 10个核心论点

完整论证链（Toulmin六要素）见 [`ai-failure-detection-framework.md`](ai-failure-detection-framework.md)。

| # | 论点 | 核心机制 |
|---|------|---------|
| 1 | 不确定语气是错误信号 | 模糊词密度 → 置信度不足；区别于风险预警 |
| 2 | 重复提及 = 认知漂移 | attention衰减 → 已解决讨论被遗忘 → 旧模式重新激活 |
| 3 | 无参照物 → 无泛化性 | AI做条件概率匹配，非抽象推理；单实例无法提取不变模式 |
| 4 | 无收敛coding = 无价值 | 设计问题不因进入实现而自愈；AI制造"伪收敛" |
| 5 | AI推进建议必须严格证明 | 判断负担转移人类→AI；审查对象从结论可信度→推理链可追踪性 |
| 6 | 长程任务须结构化任务书 | 每节点独立验证门；正确概率随步骤数指数衰减 |
| 7 | 平滑性偏差掩盖边界问题 | 似然最大化 → 向正常路径回归；边界条件系统性缺失 |
| 8 | "已完成工作"的幻觉积累 | AI无编译器/运行时反馈；假设升级为"已确认事实" |
| 9 | 确认性审查 = 未审查 | 自动化偏差+确认偏差；唯反方辩论打破 |
| **10** | **内部论证存在系统性外部盲区** | **v3新增：模型知识有截止日期和分布偏向 → 必须外部校核** |

---

## 2. 审查工具矩阵 — 四象限模型

v1.2将审查工具组织为内部/外部 × 静态/动态的完整矩阵：

```
                内部论证                    外部论证
               (AI训练数据+文档+代码)       (WebSearch+逆向叙事)
    ┌─────────────────────────┬─────────────────────────┐
静态 │ Gate 2: verify          │ audit                   │
    │ L1-L4 + L3.5因果链      │ WebSearch反证搜索        │
    │ 检查已知维度的正确性      │ 挑战引用的外部事实        │
    ├─────────────────────────┼─────────────────────────┤
动态 │ Gate 3: debate          │ premortem               │
    │ R1-R3 反方辩论           │ 假定失败→逆向推导3条路径  │
    │ D1-D6 攻击维度           │ 发现叙事性脆弱点          │
    └─────────────────────────┴─────────────────────────┘
                              ↓
                         qualify
                    统一限定词合成
              (硬边界 / 软边界 / 监控触发 / 置信度)
                              ↓
                          tree
                    行为树可视化
              (Mermaid图 + 分区 + 跨会话)
```

**矩阵完整性原则**：缺失任何象限，对应盲区即成为残余风险来源。跳过某工具 = 对那类盲区的显式风险接受。

---

## 3. 检测框架 — L0/L1/L2分层 + 分区追踪

```
L0 信号层（持续监控，零成本标记）
  ├─ 模糊词密度 > 阈值       → 置信度不足
  ├─ 相邻轮次语义相似度       → 上下文饱和
  ├─ "下一步/然后"密度突增   → 叙事模式激活
  ├─ 边界处理覆盖率低         → 平滑性偏差活跃
  └─ 人类响应时间衰减         → 注意力衰减（vibe专用）
  ↓ 标记触发
L1 验证层（按需验证，判定信号真伪）
  ↓ 验证失败
L2 干预层（阻止推进，强制纠正）
  └─ gate_blocked=true → PreToolUse hook拦截Write/Edit + Bash文件写入
  ↓
分区追踪（Stop hook注入漂移自检）
  ├─ Vibe模式：每次checkpoint → 注入drift self-check
  ├─ Structured模式：每30轮 → 注入drift self-check
  └─ partition-track.sh 记录分区切换 → toulmin-tree 可视化
```

---

## 4. 过程框架 — 三大Gate + Agent编排

```
toulmin-plan (orchestrator)
  │
  ├─ plan → task → target
  ├─ [Gate 1: 方向收敛] ← YOU (orchestrator)
  │     └─ Toulmin论证记录 (Claim/Ground/Warrant/Backing/Rebuttal/Qualifier)
  │
  ├─ [Gate 2: 有限验证] ← Agent(toulmin-verifier)  [隔离上下文]
  │     └─ L1-L4 + L3.5因果链 → gate-2-verification.md
  │
  ├─ pseudocode → code → verify
  │
  ├─ [Gate 3: 反方辩论] ← Agent(toulmin-debater)  [隔离上下文]
  │     └─ R1-R3 (D1-D6) → gate-3-debate.md
  │
  ├─ [可选] audit → premortem → qualify → tree
  │
  └─ regression → complete
```

### Gate 1 — 方向收敛（编排者执行）
**Toulmin格式**: Claim/Ground/Warrant/Backing/Rebuttal/Qualifier。记录选型决策、替代方案排除理由、决策有效期和失效条件。

### Gate 2 — 有限验证（Agent派发）
派发 `toulmin-verifier` agent —— 隔离上下文，不受规划对话影响。  
**L1** 假设清单 | **L2** 边界矩阵 | **L3** 失效模式遍历 | **L3.5** 因果链追踪 | **L4** "一件事杀死设计"

### Gate 3 — 反方辩论（Agent派发）
派发 `toulmin-debater` agent —— 角色分离，目标是REFUTE而非评估。  
**R1** D1-D6攻击 | **R2** [ACCEPT/REBUT/CLARIFY/DEMOTE] | **R3** 反驳+判定 ✅/⚠️/❌

### 外部审查工具（手动触发）
| 工具 | 象限 | 作用 |
|------|------|------|
| `/toulmin:toulmin-audit` | 外部-静态 | WebSearch搜索反例/替代方案/边界失效 |
| `/toulmin:toulmin-premortem` | 外部-动态 | 假定失败→逆向重建3条因果死亡路径 |
| `/toulmin:toulmin-qualify` | 合成 | 汇总所有发现→硬边界/软边界/置信度 |
| `/toulmin:toulmin-tree` | 可视化 | Mermaid行为树 + 分区历史 + 跨会话引用 |

---

## 5. Agent编排架构

toulmin-plan从"prompt驱动的skill"升级为"agent编排者"：

| 角色 | 执行者 | 上下文 | 职责 |
|------|--------|--------|------|
| 编排者 | YOU (toulmin-plan) | 完整对话 | Problem定义、Task分解、Gate 1、Implementation |
| 验证Agent | `toulmin-verifier` | **隔离** | L1-L4 + L3.5因果链。不接触规划讨论 |
| 辩论Agent | `toulmin-debater` | **隔离** | D1-D6攻击。对代码无情感依附 |

**为什么用Agent？** Skills在编排者上下文中运行——验证发现被规划对话污染。Agent拥有隔离上下文：验证者不知道做了什么tradeoff，辩论者对设计决策无依附。这种隔离是真正对抗性审查的机制保证。

---

## 6. 框架退化防御

Premortem对toulmin自身的分析发现了三条退化路径，已全部内置防御：

| 退化模式 | 机制 | 防御 |
|---------|------|------|
| **形式替代实质** | override从例外变默认 | 冷却期+递增摩擦（1st自由/2nd 30字/3rd+ 输入OVERRIDE）+ 比率追踪 |
| **平台依赖无感知** | hook在headless/bypass/subagent模式下失效 | toulmin-status显式列出5个盲区 + iteration双重检查 |
| **知识掩埋** | gate文档写后即忘 | SessionStart扫历史 + 模糊匹配相似任务 + 提醒复用教训 |

---

## 7. Vibe Coding协议

Vibe模式包含checkpoint + VAC + 漂移自检的三层安全网：

| 触发条件 | 动作 |
|---------|------|
| 轮次 % N == 0 (N=20) | Stop hook block → L0信号扫描 + **漂移自检** |
| gate_blocked=true | Stop hook block → 不能声称完成 |
| 吞吐量衰减 | 提示vibe惯性 → 建议/toulmin-plan |

### VAC — Vibe Adversarial Check (60秒)
"切换到反方模式。用三句话告诉我，这段代码在什么情况下会炸。"

---

## 8. 安装

```bash
# 全局安装
cp -r toulmin ~/.claude/skills/toulmin

# 通过zip安装
claude plugin install ./toulmin-1.2.0.zip --scope user

# 开发模式
claude --plugin-dir ./toulmin
```

---

## 9. 命令参考

| 命令 | 用途 | 触发 |
|------|------|------|
| `/toulmin:toulmin-plan "任务" --lang zh` | Agent编排的结构化执行入口 | 手动 |
| `/toulmin:toulmin-vibe --lang zh` | Vibe coding + checkpoint + 漂移检测 | 手动 |
| `/toulmin:toulmin-verify` | L1-L4验证（Gate 2） | plan派发Agent / vibe独立 |
| `/toulmin:toulmin-debate` | R1-R3辩论（Gate 3） | plan派发Agent / vibe独立 |
| `/toulmin:toulmin-audit "主张"` | 外部证据校核（WebSearch） | 手动（gate文档候选表） |
| `/toulmin:toulmin-premortem` | 失败回溯推演（3条死亡路径） | 手动（Gate 2/3通过后） |
| `/toulmin:toulmin-qualify` | 统一限定词合成 | 手动（所有审查后） |
| `/toulmin:toulmin-tree` | 行为树可视化（Mermaid） | 手动 / 状态查看 |
| `/toulmin:toulmin-status` | 框架状态 + 完整性检查 | 手动 / checkpoint |
| `/toulmin:toulmin-override "理由"` | 手动驳回失败gate（冷却期追踪） | 手动 |

---

## 10. 插件架构

```
toulmin/
├── skills/                       # 9个技能
│   ├── toulmin-plan/SKILL.md     #   Agent编排: p→t→t→Gate1→Agent(G2)→code→Agent(G3)
│   ├── toulmin-vibe/SKILL.md     #   Vibe入口: checkpoint/VAC/模式转换
│   ├── toulmin-verify/SKILL.md   #   Gate 2: L1-L4 + gate文档 + 候选表
│   ├── toulmin-debate/SKILL.md   #   Gate 3: R1-R3 + gate文档 + 候选表
│   ├── toulmin-audit/SKILL.md   #   外部校核: WebSearch反证 → STANDS/NARROW/REFUTED
│   ├── toulmin-premortem/SKILL.md #   回溯推演: 3条死亡路径 + 防御建议
│   ├── toulmin-qualify/SKILL.md  #   限定词合成: 硬/软边界 + 置信度 + 监控触发
│   ├── toulmin-tree/SKILL.md    #   行为树: Mermaid图 + 分区 + 跨会话
│   └── toulmin-status/SKILL.md   #   状态摘要 + hook完整性 + override统计
├── hooks/
│   └── hooks.json                # PreToolUse(Write/Edit+Bash) + Stop + SessionStart
├── scripts/
│   ├── lib/state.sh              #   共享state解析 + session隔离 + 12字段默认值
│   ├── update-gate.sh            #   统一gate状态更新（原子sed + 幂等追加）
│   ├── pre-tool-use.sh           #   gate_blocked=true → deny Write/Edit
│   ├── bash-guard.sh             #   gate_blocked=true → deny Bash文件写入绕过
│   ├── partition-track.sh        #   上下文分区切换记录
│   ├── stop-hook.sh              #   轮次计数 + 完成拦截 + checkpoint + 漂移自检
│   └── session-start.sh          #   恢复指针 + 历史任务扫描 + 相似任务匹配
├── agents/
│   ├── toulmin-debater.md        #   反方辩手: D1-D6攻击维度（隔离上下文）
│   └── toulmin-verifier.md       #   验证者: L1-L4 + L3.5因果链（隔离上下文）
├── .claude-plugin/plugin.json
├── README.md / README.en.md / README.ja.md
└── ai-failure-detection-framework.md  # 完整理论文档（10论点 + 10章节）
```

### 实现模式

**Agent编排**（toulmin-plan）: 编排者负责problem + task + Gate 1 + implementation。Gate 2/3派发隔离Agent。审查结果不受规划对话污染。

**grill-me**（纯prompt驱动）: 9个技能 + 2个Agent。语言约束引导行为，无需hook。

**ralph-loop**（hook + state file）: 3个hook脚本 + `.claude/toulmin-state.local.md`。硬性拦截需要生命周期拦截；状态需要跨轮次持久化。

**Hook强制力已知限制**（经toulmin-audit审查验证）:
- ✅ 交互模式 + exit code 2 → 确定性阻断
- ❌ headless `-p` → hooks不调用；subagent工具调用 → PreToolUse不触发
- ⚠️ Bash绕过 → bash-guard.sh覆盖；bypass模式 → 异步延迟

**State file设计**:
```yaml
---
gate_blocked: false     # PreToolUse检查
phase: plan             # plan|task|gate-1|gate-2|code|verify|gate-3|regression|complete
iteration: 0            # Stop hook递增
gate_dir: docs/toulmin/YYYY-MM-DD-<slug>/  # gate文档路径
gates_passed: [gate-1]  # 已通过gate
gate_current: gate-2    # 活跃gate
ca_mode: structured     # structured|vibe
lang: zh                # zh|en
checkpoint_interval: 20 # vibe checkpoint间隔
gate_attempts: 0        # gate尝试次数
override_count: 0       # override总次数（冷却期追踪）
override_history: []    # override记录 [gate@round, ...]
partitions: ["task"]    # 分区追踪 [src→dst@iteration:reason, ...]
partition_current: task # 活跃分区
---
```

---

## 11. 项目产物

```
docs/toulmin/YYYY-MM-DD-<task-slug>/
  gate-1-convergence.md    # 方向论证（Toulmin六要素）
  gate-2-verification.md   # L1-L4 + L3.5因果链 + fact-check候选表
  gate-3-debate.md         # R1-R3 + [ACCEPT/REBUT/CLARIFY/DEMOTE] + 判定
  qualifier.md             # 统一限定词（硬/软边界 + 置信度 + 监控触发）

.claude/toulmin-state.local.md  # Hook决策状态（任务完成时清理）
```

Gate文档是**第三方论证记录**——独立于插件和对话上下文。失败的gate同样记录。qualifier.md是设计的精确契约。

---

## 12. 版本历史

| 版本 | 日期 | 核心增量 |
|------|------|---------|
| v1.0.1 | 2026-06 | 基础框架：5技能 + 3Hook + L0-L2 + 3Gate + Vibe协议 |
| v1.1.0 | 2026-07 | v3外部论证：audit + premortem + qualify + 退化防御 |
| v1.2.0 | 2026-07 | v2 Agent编排 + tree + 分区追踪 + 漂移自检 |

---

## 附加文档

| 文档 | 内容 |
|------|------|
| [技能组合使用指南](docs/skill-combination-guide.md) | 8个组合的适用场景、使用方法、典型工作流 |
| [技能组合验证记录](docs/skill-combination-verification.md) | 8个组合的实战验证 + 发现的3个bug |
| [理论框架](ai-failure-detection-framework.md) | 10论点 + 10章节完整论证 |

---

## 许可

MIT
