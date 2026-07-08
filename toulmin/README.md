# Toulmin — 批判性论证框架

[English](README.en.md) | [日本語](README.ja.md)

基于[图尔敏论证模型](https://en.wikipedia.org/wiki/Stephen_Toulmin)的Claude Code插件。将"编码前的有限验证"和"验收前的反方辩论"制度化为三个刚性Gate，在vibe coding中通过L0信号检测和自动checkpoint识别漂移。核心方法论：**Toulmin 批判性论证**。

---

## 1. 设计理论 — 8个核心论点

每个论点均以图尔敏六要素（Claim, Ground, Warrant, Backing, Rebuttal, Qualifier）构建，完整论证链见 [`ai-failure-detection-framework.md`](ai-failure-detection-framework.md)。

### 论点1: 不确定语气是错误信号

> AI结论句中的"可能"、"大概"意味着模型在多个低置信度token分支间徘徊——没有一条路径通过隐式的验证门槛。

**区分**: 结论修饰 = red flag；风险预警 = 合理的工程审慎。

### 论点2: 回归迭代中的重复提及 = 认知漂移

> AI没有结构化的"已解决"状态机。长上下文中attention权重衰减→早期已完成的讨论被遗忘→旧模式被当作新发现重新激活。

**检测**: embedding相似度 + 逻辑连贯性检查。重复 + 无新信息 = 漂移。

### 论点3: 缺乏明确路线和参照物 → 成果无泛化性

> AI不进行抽象推理，进行的是条件概率匹配。泛化性需要"从多个实例中提取不变模式"——当只提供一个实例（当前需求），AI无法区分本质特征和偶然特征。

### 论点4: 无收敛即coding = 无价值

> 设计阶段的未收敛问题不会因为进入实现阶段而自行解决——它们以技术债务、边界bug、架构冲突的形式重新浮现。AI特别擅长制造"伪收敛"——流畅总结包装未解决问题。

**收敛判据**: 至少一个yes/no问题 + 所有参与者答案一致。

### 论点5: AI推进建议必须严格证明

> 要求AI自证 = 判断负担从人类转移回AI + 审查对象从"结论可信度"变为"推理链可追踪性"。利用AI的推理能力进行验证，而非利用AI的生成能力进行决策。

**三层证明**（可靠性排序）: **边界**（失效条件） > **反证**（替代方案排除） > **溯源**（引用证据）。

### 论点6: 长程任务必须有结构化任务书

> p→t→t→p→v→r链条中每个节点是独立的验证门。缺少约束时AI的输出空间在每一步都过大，正确概率随步骤数指数衰减。"下一步"语言 = 叙事模式而非执行模式。

### 论点7: AI的"平滑性偏差"系统性掩盖边界问题

> LLM的似然最大化目标 + 自回归生成的平滑动力学 = 系统性地向正常路径回归。边界条件（null、超长、并发冲突）在输出中系统性缺失。

### 论点8: AI对"已完成工作"的幻觉积累

> AI缺乏编译器/运行时作为强制性现实反馈。在长对话中假设逐步升级为"已确认事实"，每一层错误叠加保持相同的表面置信度。

**两种机制**: 记忆性（上下文管理可缓解） vs 推理性（根植模型知识偏差，上下文重置也无法消除）。

### 论点9: 确认性审查等于未审查（补充）

> 人类审查AI输出时自动化偏差 + 确认偏差双重作用——寻找"对"的证据，而非"错"的证据。**只有以refute为目标的审查（反方辩论）才能打破此偏差。**

---

## 2. 检测框架 — L0/L1/L2分层模型

```
L0 信号层（持续监控，零成本标记）
  ├─ 模糊词密度 > 阈值       → 置信度不足
  ├─ 相邻轮次语义相似度 > 阈值 → 上下文饱和
  ├─ "下一步/然后"密度突增   → 叙事模式激活
  ├─ 边界处理覆盖率低         → 平滑性偏差活跃
  └─ 人类响应时间衰减         → 注意力衰减（vibe专用）
  ↓ 标记触发
L1 验证层（按需验证，判定信号真伪）
  ├─ 模糊词 → 要求确定性断言或显式声明"不确定"
  ├─ 重复   → 检查是否引入新信息
  └─ 叙事   → 检查最近done声明是否伴随验证
  ↓ 验证失败
L2 干预层（阻止推进，强制纠正）
  └─ gate_blocked=true → PreToolUse hook拦截Write/Edit
```

---

## 3. 过程框架 — 三大Gate

```
plan → task → target ─┬─ [Gate 1: 方向收敛] ───→ pseudocode → code → verify
                      │    Toulmin论证记录           ↑              ↓
                      │    "为什么选这条路"      Gate 2:      Gate 3:
                      │                         有限验证      反方辩论
                      │                         L1-L4        R1-R3
                      ↓                          ↓              ↓
                   gate-1-convergence.md   gate-2-verify.md  gate-3-debate.md
```

### Gate 1 — 方向收敛
**Toulmin格式**: Claim/Ground/Warrant/Backing/Rebuttal(Qualifier。记录选型决策、替代方案排除理由、决策有效期和失效条件。

### Gate 2 — 有限验证（L1-L4）
**L1 假设清单**: 逐条列出设计依赖的假设，风险分级，缓解或显式接受。  
**L2 边界条件矩阵**: 输入/状态/环境维度 × 处理策略（或显式"不处理"）。  
**L3 失效模式遍历**: 每个关键模块最可能的3种失败 + 爆炸半径 + 单点故障检查。  
**L3.5 因果链追踪**: 对高严重度失效模式，从L1假设+L2边界+代码结构推导因果链（AND/OR边）。不询问用户。  
**L4 "一件事杀死设计"**: 识别致命假设，评估置信度（高/中/低）。

### Gate 3 — 反方辩论（R1-R3）
**R1 结构性质疑**: 反方以refute为目标，按D1-D6攻击维度（正确性/完整性/一致性/鲁棒性/安全性/可维护性）逐条举证。推荐使用独立的 `toulmin-debater` agent以保持角色分离。  
**R2 成果方回应**: 逐条回应——[ACCEPT]/[REBUT]/[CLARIFY]/[DEMOTE]。禁止[IGNORE]和[VAGUE]。  
**R3 反方反驳 + 判定**: 重审REBUT和CLARIFY项→最终判定✅/⚠️/❌。

---

## 4. Vibe Coding协议

Vibe模式的4个隐含假设及其破裂时的L0信号：

| 假设 | 破裂信号 |
|------|---------|
| 短反馈循环 ≈ 高质量设计 | AI第K轮方案与第K-N轮隐藏冲突 |
| AI训练分布覆盖问题空间 | 模糊词修饰核心逻辑 |
| Vibe-check是有效验证 | 功能"看起来正常"但无可执行验证标准 |
| 任务可分解为独立vibe-size块 | 一个迭代的修改引发其他模块bug |

### 组合触发checkpoint

| 触发条件 | 动作 |
|---------|------|
| 轮次 % N == 0 (N=20) | Stop hook block → 注入L0信号扫描任务 |
| gate_blocked=true | Stop hook block → "Gate未通过，不能声称完成" |
| 吞吐量衰减 (5轮<20行/无新功能) | 提示vibe惯性 → 建议/toulmin-plan |

### VAC — Vibe Adversarial Check (60秒)
"切换到反方模式。用三句话告诉我，这段代码在什么情况下会炸。每句以'如果...那么...'。"

---

## 5. 安装

```bash
# 全局安装（所有项目可用）
cp -r toulmin ~/.claude/skills/toulmin

# 通过zip安装
claude plugin install ./toulmin-1.0.1.zip --scope user

# 开发模式
claude --plugin-dir ./toulmin
```

---

## 6. 命令参考

| 命令 | 用途 | 触发 |
|------|------|------|
| `/toulmin:toulmin-plan "任务" --lang zh` | 结构化执行入口 | 手动 |
| `/toulmin:toulmin-vibe --lang zh` | Vibe coding + 漂移检测 | 手动 |
| `/toulmin:toulmin-verify` | L1-L4有限验证（Gate 2） | plan委托 / vibe独立 |
| `/toulmin:toulmin-debate` | R1-R3反方辩论（Gate 3） | plan委托 / vibe独立 |
| `/toulmin:toulmin-status` | 查看框架状态（只读） | 手动 / checkpoint |
| `/toulmin:toulmin-override "理由"` | 手动驳回失败gate（记录风险接受） | 手动 |
| `/toulmin:toulmin-audit "主张"` | 外部证据校核——搜索反例/替代方案/边界外失效 | 手动（gate文档候选表） |
| `/toulmin:toulmin-premortem` | 失败回溯推演——假定已失败，逆向重建3条因果链 | 手动（Gate 2/3通过后） |
| `/toulmin:toulmin-qualify` | 统一限定词合成——汇总所有工具发现，生成精确作用域声明 | 手动（所有审查工具完成后） |

**使用示例**:
```bash
/toulmin:toulmin-plan "给用户表加基于角色的权限校验" --lang zh
/toulmin:toulmin-vibe --lang zh --checkpoint 15
```

---

## 7. 插件架构

```
toulmin/
├── skills/                       # 8个技能
│   ├── toulmin-plan/SKILL.md     #   结构化入口：p→t→t→gate控制流
│   ├── toulmin-vibe/SKILL.md     #   Vibe入口：checkpoint/VAC/模式转换
│   ├── toulmin-verify/SKILL.md   #   Gate 2: L1-L4 + gate文档写入
│   ├── toulmin-debate/SKILL.md   #   Gate 3: R1-R3 + gate文档写入
│   ├── toulmin-audit/SKILL.md   #   外部证据校核（WebSearch反证搜索）
│   ├── toulmin-premortem/SKILL.md #   失败回溯推演（假定失败→逆向因果链）
│   ├── toulmin-qualify/SKILL.md  #   统一限定词合成（汇总→精确作用域声明）
│   └── toulmin-status/SKILL.md   #   只读状态摘要
├── hooks/
│   └── hooks.json                # 3个hook注册
├── scripts/
│   ├── lib/
│   │   └── state.sh              #   共享state解析 + session隔离 + 默认值
│   ├── update-gate.sh            #   统一gate状态更新（原子sed）
│   ├── pre-tool-use.sh           #   gate_blocked=true → deny Write/Edit
│   ├── bash-guard.sh             #   gate_blocked=true → deny Bash文件写入绕过
│   ├── stop-hook.sh              #   轮次计数 + 完成拦截 + checkpoint注入
│   └── session-start.sh          #   恢复指针 addContext
├── agents/
│   ├── toulmin-debater.md        #   反方辩手：D1-D6攻击维度
│   └── toulmin-verifier.md       #   验证者：L1-L4验证层
├── .claude-plugin/
│   └── plugin.json
└── README.md
```

### 实现模式

**grill-me模式**（纯prompt驱动）: 8个技能 + 2个agent。对话引导通过语言约束实现，不需要hook。

**ralph-loop模式**（hook + state file）: 3个hook脚本 + `.claude/toulmin-state.local.md`。硬性拦截需要生命周期拦截；状态需要跨轮次持久化。

**Hook强制力的已知限制**（详见 `toulmin-audit` 审查）:
- ✅ 交互模式 + exit code 2 → 确定性阻断
- ❌ headless `-p` 模式 → hooks不被调用
- ❌ `--dangerously-skip-permissions` → hooks异步，阻断延迟
- ❌ subagent工具调用 → PreToolUse不触发
- ⚠️ Bash写入绕过 → 已通过 `bash-guard.sh` 覆盖（sed/echo>/tee等）

**共享基础设施**:
- `scripts/lib/state.sh` — 统一frontmatter解析、session隔离、字段默认值。3个hook通过 `source` 复用。
- `scripts/update-gate.sh` — 统一gate状态更新。原子sed操作，幂等追加，gate名白名单校验。toulmin-plan/verify/debate通过 `${CLAUDE_PLUGIN_ROOT}` 调用。

**state file设计** — 最小化，仅存hook决策字段:
```yaml
---
gate_blocked: false     # PreToolUse检查此字段
phase: plan             # 当前阶段
session_id: xxx         # Stop hook用此字段做会话隔离
iteration: 0            # Stop hook递增，checkpoint轮次检测
gate_dir: docs/toulmin/2026-06-27-xxx/  # gate文档路径
gates_passed: [gate-1]  # 已通过gate列表
gate_current: gate-2    # 当前活跃gate
ca_mode: structured     # structured | vibe
lang: zh                # 对话语言
checkpoint_interval: 20 # vibe checkpoint间隔（0=禁用）
gate_attempts: 0        # 当前gate连续尝试次数（仅提示）
override_count: 0       # 本次会话override总次数（冷却期追踪）
override_history: []    # override记录 [gate@round, ...]
---
```

---

## 8. 项目产物

```
docs/toulmin/YYYY-MM-DD-<task-slug>/
  gate-1-convergence.md    # 方向收敛论证（Claim/Ground/Warrant/Backing/Rebuttal/Qualifier）
  gate-2-verification.md   # 有限验证L1-L4结果（每层Toulmin格式）
  gate-3-debate.md         # 反方辩论R1-R3 + [ACCEPT/REBUT/CLARIFY/DEMOTE] + 判定

.claude/toulmin-state.local.md  # Hook决策状态（任务完成时清理）
```

Gate文档是**第三方论证记录**——独立于插件和对话上下文。失败的gate同样记录（"此路不通及为什么"），供后续引用。

---

## 9. 与上游工具的协作

Toulmin独立运行，不依赖brainstorming或其他工具。如果项目已有设计文档（spec），gate文档通过一行引用关联：

```markdown
> 上游设计文档: docs/superpowers/specs/2026-06-27-role-based-auth-design.md
```

没有上游 → 独立运行。Toulmin框架解耦。

---

## 许可

MIT
