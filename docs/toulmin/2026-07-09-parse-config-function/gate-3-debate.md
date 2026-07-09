# Gate 3 — Adversarial Debate — 2026-07-09

## Verdict: PASSED

**核心结论**: R1 发现一个与 gate-2 同源的缺陷 —— gate-2 修复了 `defaults=None`（合并操作左操作数），但**未修复对称的右操作数问题**：当文件包含合法但非对象的顶层 JSON（数组 / 数字 / 字符串 / 布尔 / null）时，`{**defaults, **parsed}` 抛出未包装的 `TypeError`。此缺陷 [ACCEPT] 并已修复（新增 `isinstance(parsed, dict)` 检查，抛 `ConfigParseError`）。其余 R1 发现均为 gate-1/gate-2 已显式声明的范围外项（调用方错误 / 环境故障），[DEMOTE] 处理。修复后 8/8 内联测试通过。

---

## R1: Structural Challenge

R1 以对抗式审查执行 D1-D6。目标是证伪，不是评估。所有发现均基于对 `parse_config_demo.py`（gate-2 修复后版本）的实测复现。

### D1 — Correctness: 合法非对象 JSON 顶层导致未包装 TypeError

**Location**: `parse_config_demo.py:37`（原 `return {**defaults, **parsed}`）

**Attack scenario**: 配置文件内容为**合法 JSON 但顶层不是对象**，例如：
- `[1, 2, 3]`（数组）
- `42`（数字）
- `"hello"`（字符串）
- `true`（布尔）
- `null`

这些均能通过 `json.loads()`（它们是合法 JSON），随后进入 `{**defaults, **parsed}`。

**Observed behavior**（实测）:
```
[array JSON file]  RAISED TypeError: 'list' object is not a mapping
[number JSON file] RAISED TypeError: 'int' object is not a mapping
"hello"            -> TypeError: 'str' object is not a mapping
true               -> TypeError: 'bool' object is not a mapping
null               -> TypeError: 'NoneType' object is not a mapping
```
`**parsed` 要求右操作数实现 `Mapping` 协议；非 dict 类型不实现，直接崩溃。且异常类型是原生 `TypeError`，绕过了 `ConfigParseError` 统一错误接口。

**Expected behavior**: 函数契约是 `-> dict`，与 defaults 合并。非对象顶层无法合并，应抛 `ConfigParseError`（保持错误接口一致），而非泄露 `TypeError`。

**Severity**: HIGH — 与 gate-2 的 A7/FM3.1 **同一缺陷类**（dict 解包遇到非 Mapping）。gate-2 只堵住了 `defaults` 侧（左操作数），对称的 `parsed` 侧（右操作数）从未被检查。这是可证明为假的逻辑缺陷，不是概率风险。

### D2 — Completeness: 需求 5 项边界的映射

**Location**: 需求（gate-1）vs 实现

**Attack scenario**: 逐条核对设计声明的 5 个边界条件是否落地：

| 需求边界 | 实现位置 | 状态 |
|---------|---------|------|
| (1) 文件不存在 → 返回 `{}`/defaults | `:18-19` `os.path.exists` | 已覆盖 |
| (2) 文件为空 → 返回 `{}`/defaults | `:29-30` `content.strip()` (gate-2 Fix 2) | 已覆盖 |
| (3) 无效 JSON → `ConfigParseError` | `:34-35` `except JSONDecodeError` | 已覆盖 |
| (4) defaults 回退 + 文件覆盖默认 | `:14-15` + `:37` merge (gate-2 Fix 1) | 已覆盖 |
| (5) 文件 >10MB → 读取前拒绝 | `:21-23` `getsize` 预检 | 已覆盖 |

**Observed behavior**: 5 项显式需求全部有对应实现。**但**需求 (3)「无效 JSON」的解释存在缺口 —— 设计将「无效」等同于 `json.JSONDecodeError`（语法错误），未涵盖「语法合法但语义不可用」（非对象顶层）。这正是 D1 命中的空隙。

**Expected behavior**: 需求 (3) 的意图应是「无法用作配置的输入」，涵盖非对象顶层。

**Severity**: MEDIUM — 需求逐条覆盖，但需求 (3) 的边界定义偏窄，与 D1 是同一问题的两面。

### D3 — Consistency: 签名契约 `-> dict` 与实际行为矛盾

**Location**: `parse_config_demo.py:12` 签名 vs `:37` 行为

**Attack scenario**: 函数签名声明 `-> dict`。所有成功返回路径（`:19` `:30` `:37`）确实返回 dict。但对合法非对象 JSON，函数既不返回 dict 也不抛声明的 `ConfigParseError`，而是抛 `TypeError`。

**Observed behavior**: 契约声明的两种结局（返回 dict / 抛 `ConfigParseError`）之外，存在第三种未声明结局（`TypeError`）。

**Expected behavior**: 函数的可观测行为应收敛到「返回 dict 或抛 ConfigParseError」两种。

**Severity**: MEDIUM — 内部一致性缺陷，与 D1 同根。

### D4 — Robustness: 边界条件行为（多数为 gate-2 已声明的范围外项）

**Location**: `parse_config_demo.py:18-37`

**Attack scenario + Observed behavior**（实测）:

| 边界 | 实测结果 | gate-2 处置 |
|------|---------|------------|
| 目录路径 | `PermissionError` (Windows) / gate-2 分析在 POSIX 为 `IsADirectoryError` | A4，MEDIUM，建议性、未阻塞 |
| 非 UTF-8 二进制 | `UnicodeDecodeError` | A2，MEDIUM，「JSON RFC 要求 UTF-8，可接受」 |
| `path=None` | `TypeError`（来自 `os.path.exists`） | L2「调用方错误，TypeError 合理」 |
| `defaults=list`（非 dict） | `TypeError: 'list' object is not a mapping` | L2「非 dict 类型，调用方错误」 |
| TOCTOU（检查后删除） | `FileNotFoundError` | A10，LOW，本地场景接受 |

**Expected behavior**: 上述均为调用方错误或环境故障，gate-1 Qualifier（「本地 JSON 文件、单线程、<10MB」）与 gate-2 L1/L2 已显式限定范围并接受。

**Severity**: LOW（作为独立发现）—— 均在已声明的失效条件内。注意：非对象顶层 JSON（D1）**不属于**此类，因为它是合法本地 JSON 文件、在 Qualifier 有效范围内，却仍崩溃。

### D5 — Security: 无可利用漏洞

**Location**: 全文件

**Attack scenario**: 检查注入 / 越权 / 信息泄露 / 不安全默认值。`json.loads`（非 `eval`）无代码执行风险；无路径拼接（`path` 直接由调用方提供，无 traversal 放大）；`MAX_SIZE` 预检提供了 DoS 上限（10MB 读入内存）；无网络 / 无反序列化任意类型。

**Observed behavior**: 无可利用面。错误信息含文件路径 —— 属正常诊断信息，非敏感泄露。

**Expected behavior**: 同上。

**Severity**: NONE / LOW（信息类）。

### D6 — Maintainability: 无级联变更风险

**Location**: 全文件

**Attack scenario**: 检查硬编码依赖、god object、泄露抽象。函数 ~40 行，纯标准库，单一职责。`MAX_SIZE` 为模块级常量（`:10`），`ConfigParseError` 携带 `path` 属性便于调用方处理。修改阈值或错误消息为单点变更。

**Observed behavior**: 低耦合，无级联。唯一隐含耦合是错误消息使用中文字面量，若需 i18n 需集中改造 —— 但当前范围（demo/单语）内非债务。

**Expected behavior**: 同上。

**Severity**: LOW。

### R1 Summary

| 维度 | 发现数 | 最高严重性 |
|------|--------|-----------|
| D1 Correctness | 1 | HIGH |
| D2 Completeness | 1 | MEDIUM |
| D3 Consistency | 1 | MEDIUM |
| D4 Robustness | 5（均范围外） | LOW |
| D5 Security | 0 | — |
| D6 Maintainability | 0 | — |

**最关键问题**: D1 —— 合法非对象顶层 JSON 触发未包装 `TypeError`。这是 gate-2 A7 缺陷的**对称遗漏**：gate-2 修复了合并操作的左操作数（`defaults=None`），却未意识到右操作数（`parsed`）存在完全相同的 Mapping 协议要求。D2/D3 是同一缺陷在需求覆盖面与契约一致性上的投影。

---

## R2: Response

### [ACCEPT] D1 / D2 / D3 — 非对象顶层 JSON（三者同根）

真实缺陷，可复现。三个发现指向同一根因：`{**defaults, **parsed}` 假设 `parsed` 是 dict，但 `json.loads` 对合法 JSON 数组/标量返回非 dict。

**Fix applied**（`parse_config_demo.py:37-39`）:
```python
# Fix 3: top-level must be an object to merge with defaults (gate-3 D1/D3 finding)
if not isinstance(parsed, dict):
    raise ConfigParseError(f"配置必须是JSON对象: {path} (顶层为 {type(parsed).__name__})", path)
```
选择抛 `ConfigParseError` 而非静默转换 —— 保持与需求 (3) 一致的统一错误接口，且不猜测调用方意图。修复消解 D1（正确性）、D2（需求 3 边界补全）、D3（契约收敛为「dict 或 ConfigParseError」）。

**Regression test added**（C8, `:107-117`）: 数组顶层 JSON → 断言抛 `ConfigParseError` 且消息含「对象」。

### [DEMOTE] D4 — 目录 / 非 UTF-8 / path=None / defaults 非 dict / TOCTOU

均为 gate-1 Qualifier 与 gate-2 L1/L2 **显式声明的失效条件或范围外项**：
- 目录路径（A4）：gate-2 标记 MEDIUM、建议性、明确「未阻塞 gate-2」「需求从未提及目录处理」。
- 非 UTF-8（A2）：gate-2 接受，依据 JSON RFC 7159 要求 UTF-8。
- `path=None` / `defaults` 非 dict：gate-2 L2 判定为「调用方错误，`TypeError` 是合理响应」。
- TOCTOU（A10）：gate-2 LOW，本地配置场景接受。

这些不是被忽略，而是有据可查的知情接受（declared limitation），符合 [DEMOTE] 定义。

### [REBUT] D5 / D6 — 无需响应

R1 在 D5/D6 未提出具体缺陷（发现数 0），无可争议项。

---

## R3: Rebuttal + Verdict

### 复检 [DEMOTE] 项是否应升级为 ACCEPT

逐项检验「声明的限制」是否掩盖了核心功能缺陷：

- **目录路径**: 挑战可持续吗？在 gate-1 Qualifier「本地 JSON 文件」下，目录不是 JSON 文件，属调用方误用。挑战**撤回**，维持 DEMOTE。（可选一行加固 `os.path.isfile()`，但非阻塞。）
- **非 UTF-8**: JSON 标准要求 UTF-8，非 UTF-8 输入本身违反格式约定。挑战**撤回**，维持 DEMOTE。
- **path=None / defaults 非 dict**: 类型错误应由类型系统 / 调用方保证，函数签名已用类型注解声明契约。挑战**撤回**，维持 DEMOTE。
- **TOCTOU**: 本地单线程配置读取场景（Qualifier 明确限定），竞态窗口无安全含义。挑战**撤回**，维持 DEMOTE。

无 DEMOTE 项升级。

### 复检 [ACCEPT] 修复有效性

修复后实测：数组/数字/字符串/布尔/null 顶层 JSON 均抛 `ConfigParseError`（含「对象」诊断），不再泄露 `TypeError`。8/8 内联测试通过（C1-C8）。D1/D2/D3 消解。

### Verdict: PASSED

- 所有 ACCEPT 项（D1/D2/D3，同根）已修复并有回归测试。
- 所有 sustained challenge：无 —— DEMOTE 项经 R3 复检全部为知情接受，挑战撤回。
- 无未回应挑战。
- 未发现「kill the design」级缺陷 —— gate-1 的纯标准库方向依然成立；D1 是实现遗漏，非方向错误。

---

## Actions Required

### 已完成（阻塞项）
1. **D1/D2/D3 修复** — `parse_config_demo.py:37-39` 新增 `isinstance(parsed, dict)` 检查，非对象顶层抛 `ConfigParseError`。已验证。
2. **回归测试** — C8（数组顶层 JSON）加入内联自检。8/8 通过。

### 监控标签（不阻塞，回归阶段关注）
- **M-1 目录路径加固**（gate-2 A4 遗留）: 可选 `if not os.path.isfile(path): raise ConfigParseError(...)`。当前依赖 Qualifier 范围限定，接受。
- **M-2 10MB 阈值比较符**（gate-2 遗留）: 当前用 `>`（`:22`），精确 10MB 文件被接受。已在代码中确定，记录于此。

### 风险接受（显式声明的限制）
- 非 UTF-8 编码 → `UnicodeDecodeError`（依据 JSON RFC 7159 UTF-8 要求）。
- `path=None` / `defaults` 非 dict → `TypeError`（调用方类型契约违例）。
- TOCTOU 竞态（本地单线程场景，无安全含义）。

---

## Fact-Check Candidates

本次辩论的 ACCEPT 项（D1/D2/D3）基于 CPython dict 解包语义的**实测复现**（`{**None}`、`{**[1,2,3]}` 均可本地重现抛 `TypeError`），非外部引用。DEMOTE 项的依据：

| # | Claim (from debate) | Ground (cited in R2) | Audit focus | Risk | Est. tokens |
|---|--------------------|--------------------|-------------|------|-------------|
| 1 | 「JSON RFC 7159 要求 UTF-8 编码」 | R2 DEMOTE（非 UTF-8） / gate-2 A2 | 核实 RFC 8259（7159 的后继）对 JSON 传输编码的默认 UTF-8 规定 | L | ~2k |
| 2 | 「`**` 解包要求右操作数实现 Mapping 协议」 | R1 D1 / R2 ACCEPT | 一般 Python 知识，已本地实测确认（多类型 TypeError） | L | ~1k |

两项均为 LOW 风险：Claim 2 已实测确认，是 ACCEPT 的直接证据（缺陷成立不依赖外部核实）；Claim 1 为 DEMOTE 的支撑而非承重依据，即使 RFC 细节有出入，非 UTF-8 仍属范围外的格式约定违例。**无 HIGH 风险外部引用 —— 核心裁决（D1 缺陷 + 修复）完全基于内部逻辑与本地实测。**
