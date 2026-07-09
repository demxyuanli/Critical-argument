# Toulmin 技能组合使用指南

> 8 个经过验证的技能组合，每个含适用场景、触发条件、使用步骤、成本、产物。
> 验证记录见 [`skill-combination-verification.md`](skill-combination-verification.md)。

---

## 快速选择表

| 你的情况 | 用组合 | 成本 |
|---------|--------|------|
| 从零开始一个有 3+ 步骤、多模块影响的任务 | **C1** 完整结构化 | 高 |
| 怀疑某个技术选型引用的外部事实过时 | **C2** 外部校核 | 中 |
| 设计"感觉太干净"，想做上线前压力测试 | **C3** 风险扫描 | 中 |
| 已经做了多轮审查，想汇总成一个结论 | **C4** 限定词合成 | 低 |
| 长周期项目，想看全局进度和历史 | **C5** 行为树 | 低 |
| 想要真正独立的对抗审查（非自我评估） | **C6** Agent派发 | 中 |
| 快速迭代但担心跑偏 | **C7** Vibe安全网 | 低 |
| Gate 卡住但风险可接受，需要放行 | **C8** Override放行 | 低 |

---

## C1 — 完整结构化流程

**组合**: `plan → verify → debate`（+ 可选 audit/premortem/qualify）

### 适用场景
- 架构变更、安全关键系统、绿地项目
- 多模块影响、不可逆决策
- 任务有明确的可验证成功标准

### 不适用
- 单文件脚本、一次性实验 → 用 C7 或直接写
- 探索性原型（需求还不清楚）→ 先 brainstorming

### 使用方法
```bash
/toulmin:toulmin-plan "给用户表加基于角色的权限校验" --lang zh
```
然后跟随流程：
1. 确认 scope + success criteria（可验证）
2. 确认任务分解
3. 编排者写 Gate 1（方向收敛论证）
4. **自动派发 verifier agent** 执行 Gate 2（L1-L4）
5. 实现代码
6. **自动派发 debater agent** 执行 Gate 3（R1-R3）
7. 可选：audit/premortem/qualify

### 产物
`gate-1-convergence.md` + `gate-2-verification.md` + `gate-3-debate.md`

### 实测价值
在 parse_config 任务上，verifier 和 debater 在隔离上下文中发现了**同一缺陷的两侧**（`defaults=None` 崩溃 + 非对象JSON崩溃）——单一视角会漏掉其中一个。

---

## C2 — 外部证据校核

**组合**: `audit` 独立

### 适用场景
- 设计依赖某个外部事实（"X库比Y库快"、"Z标准是最佳实践"）
- 技术选型的理由是"我记得..."而非"我刚查过..."
- 引用了可能过时的标准、benchmark、API 行为

### 不适用
- 纯设计意见（"应该用微服务"）—— 不可外部验证
- 内部逻辑问题 —— 用 verify/debate
- 一个子系统的整体审查 —— audit 针对单个主张，不是系统

### 使用方法
```bash
/toulmin:toulmin-audit "React 19 Server Components 已在生产环境稳定可用"
```
执行：
1. 主张分解为 Toulmin 六要素
2. 3-5 次 WebSearch（按风险优先级：Backing > Warrant > Ground）
3. 输出审计报告 + 修订限定词
4. 判定：STANDS / NARROW / REFUTED

### 触发建议
Gate 2/3 完成后，从 gate 文档的 **fact-check 候选表**中人工挑选高风险主张再校核——避免对所有主张全量搜索。

### 实测价值
审计 rustcoin3d 的深度约定主张，发现项目方案与行业标准（reverse-Z）的系统性偏差——这是内部审查不可能发现的。

---

## C3 — 失败风险扫描

**组合**: `premortem`（+ 可选 qualify）

### 适用场景
- 设计"感觉太干净"，想主动找脆弱点
- 重大 release / 部署前的最后检查
- 想发现级联失败、时序脆弱点（非单点bug）

### 不适用
- 还没有设计产出（premortem 需要审查对象）
- 只想验证单点正确性 → 用 verify 的 L4

### 使用方法
```bash
/toulmin:toulmin-premortem
```
执行（需先有 gate 文档或代码）：
1. 设定前提："该方案已失败"
2. 逆向推导 3 条独立死亡路径（触发→放大→级联→崩溃）
3. 每条映射到最脆弱的 Toulmin 要素
4. 综合：共享根因 + 推荐行动

### 认知原理
利用前瞻后见之明（prospective hindsight）：人在"假定已失败→逆推"模式下，比"预测风险"模式多发现 30% 的独特风险。

### 实测价值
分析 toulmin 自身发现 3 条退化路径（override退化/phantom hook/文档坟场），全部转化为已实现的防御机制。

---

## C4 — 统一限定词合成

**组合**: `qualify`（需要 C1/C2/C3 的产出）

### 适用场景
- 已经运行了多个审查工具，发现散落在各文档
- 需要一个可引用的"设计契约"（这个方案在什么条件下有效）
- 准备交付/归档，需要精确的作用域声明

### 不适用
- 还没有任何 gate/audit/premortem 产出 —— 无内容可合成
- 只做了一个工具 —— 直接看那个工具的输出即可

### 使用方法
```bash
/toulmin:toulmin-qualify
```
执行：
1. 扫描 gate_dir 所有文档
2. 按来源提取限制条件（verify/debate/audit/premortem）
3. 合并去重，按优先级排序（外部>内部、致命>严重）
4. 输出：硬边界 / 软边界 / 监控触发 / 开放风险 / 置信度

### 产物
`qualifier.md` —— 设计的精确契约

### 实测价值
合成 rustcoin3d 的 audit(F1-F3) + premortem(P1-P3)，得到 3硬边界 + 3软边界 + MEDIUM置信度的单一声明。

---

## C5 — 行为树可视化

**组合**: `tree` 独立

### 适用场景
- 长周期项目，想看全局进度
- 多个历史任务，想知道当前任务和过去的关系
- 状态一致性检查（gate 是否真的都过了）

### 不适用
- 刚开始的任务（没什么可视化的）
- 只想看当前状态数字 → 用 status（更轻）

### 使用方法
```bash
/toulmin:toulmin-tree
```
执行：
1. 渲染当前任务树（阶段→gate→判定）
2. 扫描历史任务目录
3. 模糊匹配相似任务（提醒复用教训）
4. 输出 Mermaid 图 + 统计

### 实测价值
在 Critical-argument 项目上，tree 直接暴露了 `gates_passed: [gate-1, gate-3]` 缺 gate-2——可视化本身成了诊断工具。

---

## C6 — Agent 隔离派发

**组合**: `plan` 内的 Agent 派发机制（Gate 2/3）

### 适用场景
- 需要真正独立的审查视角（非自我评估）
- 规划对话很长，担心验证被之前的讨论锚定
- 高风险决策，需要"新鲜眼睛"

### 不适用
- 简单任务，隔离开销不值得 → 用 verify/debate skill 直接执行
- 需要交互式讨论的 Gate 1 → 编排者自己做

### 工作原理
| 角色 | 上下文 | 职责 |
|------|--------|------|
| 编排者 | 完整对话 | Problem + 分解 + Gate 1 + 实现 |
| verifier agent | **隔离** | L1-L4，不知道规划讨论 |
| debater agent | **隔离** | D1-D6，对代码无依附 |

自动通过 C1 的 toulmin-plan 触发，无需单独调用。

### 实测价值
隔离上下文让两个 agent 在互不知情下发现了同一 merge 缺陷的两侧——这是隔离对抗审查的最强证据。

### 已知限制
Agent 无法访问 `CLAUDE_PLUGIN_ROOT`。state 更新建议由编排者在 agent 返回后执行，agent 只负责分析 + 写文档。

---

## C7 — Vibe Coding 安全网

**组合**: `vibe → checkpoint → VAC`

### 适用场景
- 快速迭代、原型、spike
- 需求还在探索中，不适合完整结构化流程
- 想保持 vibe 节奏但担心跑偏

### 不适用
- 架构变更、安全关键 → 用 C1
- 明确的多步骤任务 → 用 C1

### 使用方法
```bash
/toulmin:toulmin-vibe --lang zh --checkpoint 5
```
自动机制：
1. 自由迭代（coding → review → coding）
2. 每 N 轮：Stop hook 注入 L0 信号扫描 + **漂移自检**
3. 漂移自检："偏离原始任务了吗？"→ 若是，记录分区
4. VAC（60秒反方）："用三句话说这代码在什么情况下会炸"

### 实测价值
checkpoint 在第5轮正确触发，含漂移自检注入；structured 模式每30轮也注入漂移检查。

---

## C8 — Override 风险放行

**组合**: `override` 独立

### 适用场景
- Gate 失败但风险已理解且可接受
- 时间压力下需要放行，但要留下决策记录
- gate 设计过严，当前场景不适用

### 不适用
- 只是懒得修问题 → 冷却期会增加摩擦阻止你
- 反复 override → 比率追踪会告警"gate纪律下降"

### 使用方法
```bash
/toulmin:toulmin-override "此边界条件在当前部署环境不可能出现，风险接受"
```
递增摩擦：
| 次数 | 要求 |
|------|------|
| 1st | 自由 |
| 2nd | 理由 ≥30 字 |
| 3rd+ | 输入 `OVERRIDE` 确认 + 显示历史 + 比率告警 |

### 产物
在对应 gate 文档追加 override 记录（理由 + 时间 + 风险接受声明）

### 设计哲学
override 不是逃生舱，是**有记录、有摩擦的风险接受**。冷却期防止"每次拦截→override"退化为形式主义。

---

## 典型工作流组合

### 工作流 A：高风险任务全流程
```
C1 (plan→verify→debate) → C2 (audit关键主张) → C3 (premortem) → C4 (qualify) → C5 (tree归档)
```
覆盖：全部四象限 + 合成 + 可视化。成本最高，适合架构变更/安全关键。

### 工作流 B：标准功能开发
```
C1 (plan→verify→debate) → C5 (tree)
```
覆盖：内部两象限。适合日常功能开发。

### 工作流 C：快速迭代
```
C7 (vibe) → 触发时 VAC
```
覆盖：L0 信号 + 按需对抗。适合原型/spike。

### 工作流 D：针对性外部校核
```
(已有设计) → C2 (audit 单个可疑主张)
```
覆盖：外部-静态。适合验证某个技术选型。

---

> 文档版本: v1.0
> 创建日期: 2026-07-09
> 基于: 8个组合的实战验证（skill-combination-verification.md）
