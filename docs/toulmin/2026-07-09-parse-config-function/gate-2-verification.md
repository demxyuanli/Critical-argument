# Gate 2 — Limited Verification — 2026-07-09

## Overall Verdict: FAILED

**致命缺陷**: `defaults=None` 时 `{**defaults, **parsed}` 引发 `TypeError` —— 这是函数签名明确允许的合法调用，违反需求 (4)。**修复为一行代码** (`defaults = defaults or {}`)，修复后可通过。

---

### L1: Assumption Inventory — FAILED

**Claim**: 设计的10项假设中，9项已识别并缓解（或显式接受），1项高风险假设（A7）未缓解且可证明为假。

**Ground**: 从设计文档及其 warrant/backing/qualifier 中提取出以下假设：

| ID | 假设 | 若为假的影响 | 风险 | 缓解/接受 |
|----|------|-------------|------|-----------|
| A1 | 输入为本地文件路径 | 网络URL、管道、特殊设备全部失败 | LOW | Qualifier 限定"本地 JSON 文件" |
| A2 | 文件编码为 UTF-8 | `UnicodeDecodeError`，非 `ConfigParseError` | MEDIUM | JSON RFC 7159 要求 UTF-8；可接受 |
| A3 | `os.path.getsize()` 在所有平台返回字节数 | 10MB 阈值单位错误 | LOW | CPython 文档保证；POSIX stat 语义 |
| A4 | 路径指向常规文件（非目录） | `getsize()` 对目录返回 0（通过大小检查），随后 `open()` 失败产生非 `ConfigParseError` | MEDIUM | **未处理**。可用 `os.path.isfile()` 预检 |
| A5 | `json.load()` 对空文件抛出 `json.JSONDecodeError` | 需求 (2) 要求返回 `{}`，而非抛异常 | MEDIUM | 设计承认"需单独处理"但未指定机制 |
| A6 | 10MB 为近似阈值，忽略编码开销 | 边界值判断争议 | LOW | 工程上可接受 |
| **A7** | **`{**defaults, **parsed}` 在 `defaults=None` 时正常工作** | **`TypeError: 'NoneType' object is not a mapping`** —— 函数签名 `defaults: dict \| None = None` 明确允许 None | **HIGH** | **未缓解。证明为假：`python3 -c "{**None, **{}}"` 抛出 TypeError** |
| A8 | `json.load()` 一次性读入内存可行（<10MB） | 内存不足 | LOW | 10MB 在现代进程中安全 |
| A9 | 单线程运行环境 | 无竞态风险 | LOW | Qualifier 限定"单线程读取" |
| A10 | 文件操作含 TOCTOU 竞态（存在检查与读取之间） | 文件删除导致 `FileNotFoundError` 而非 `{}` | LOW | 本地配置文件场景可接受 |

**Warrant**: 9/10 假设的风险控制在 LOW-MEDIUM 范围内。A7 为可证明的缺陷——不是风险接受问题，而是逻辑错误：函数签名的默认值 `None` 直接导致合并操作崩溃。

**Rebuttal**:
- 挑战: A7 可通过将 `defaults: dict | None = None` 改为 `defaults: dict = {}` 解决。
  - 回应: Python 中可变默认参数是反模式。应保留 `None` 默认值，在函数体内添加 `defaults = defaults or {}`。
- 挑战: A4（目录路径）概率极低，不值得增加代码。
  - 回应: 接受此挑战。`os.path.isfile()` 增加一行代码，提供了有意义的边界防护。但也可选择接受——需求从未提及目录处理。
- 挑战: A5（空文件）的设计标注"需单独处理"足够，不需要在 gate-2 中指定具体机制。
  - 回应: 部分接受。标注表明意识到问题，但 gate-2 应确认处理策略存在。当前标注过于模糊。

**Qualifier**: A4 和 A5 的接受有效期至实现阶段。A7 必须在实现前修复——不是接受/拒绝的风险权衡，而是可证明的逻辑错误。

**Verdict: FAILED** — A7 为高风险、未缓解、可证明为假的假设。

---

### L2: Boundary Condition Matrix — FAILED

**Claim**: 部分边界值有处理策略，但 `defaults=None` 边界（核心输入维度）无处理，导致违反需求 (4)。

**Ground**:

#### 输入维度：`path`

| 边界值 | 处理策略 | 状态 |
|--------|---------|------|
| `None` | `AttributeError` at `getsize()` | 未处理 |
| 空字符串 `""` | OS 依赖行为 | 未处理 |
| 不存在的文件 | 需求: 返回 `{}`。设计 warrant 未提及 `os.path.exists()` 检查 | 隐式处理 |
| 空文件 (0 bytes) | 需求: 返回 `{}`。设计标注"需单独处理"，未指定机制 | **未处理** |
| 有效 JSON (<10MB) | `json.load()` 正常流程 | 已处理 |
| 文件大小 == 10MB (精确) | 需求: "超过10MB时拒绝"。`>` vs `>=` 决策未记录 | 需明确 |
| 文件 > 10MB | `os.path.getsize()` 预检 → 拒绝 | 已处理 |
| 无效 JSON (格式错误) | `json.JSONDecodeError` → `ConfigParseError` | 已处理 |
| 目录路径 | `getsize()` 返回 0 → 通过大小检查 → `IsADirectoryError`/`PermissionError`（非 `ConfigParseError`） | 未处理 |
| 非 UTF-8 二进制 | `UnicodeDecodeError`（非 `ConfigParseError`） | 未处理 |
| 悬空符号链接 | `FileNotFoundError`（非 `ConfigParseError`） | 未处理 |

#### 输入维度：`defaults`

| 边界值 | 处理策略 | 状态 |
|--------|---------|------|
| **`None`（函数默认值）** | `{**None, **parsed}` → `TypeError` | **未处理 (FATAL)** |
| `{}`（空字典） | 正常流程 | 已处理 |
| 非 dict 类型 | `TypeError` at merge | 未处理 |
| 含非 JSON 可序列化值 | 不影响行为 | 已处理（按设计） |

#### 环境维度

| 边界值 | 处理策略 | 状态 |
|--------|---------|------|
| 磁盘 I/O 错误 | `OSError`（非 `ConfigParseError`） | 未处理 |
| 权限拒绝 | `PermissionError`（非 `ConfigParseError`） | 未处理 |
| 内存耗尽 | `MemoryError` | 未处理（LOW 概率，接受） |
| 文件被其他进程锁定 | `PermissionError`/`OSError` | 未处理 |

**Warrant**: `defaults=None` 是唯一 FATAL 的未处理边界——它是函数签名的合法默认值，任何不含 defaults 的调用都会触发。其他未处理边界要么概率极低（环境维度），要么与需求范围不重叠（路径类型错误）。

**Rebuttal**:
- 挑战: 环境维度（磁盘错误、权限）应全部包装为 `ConfigParseError`。
  - 回应: 拒绝。这些是通用运行时故障，包装会丢失原始错误信息。调用方应自行处理 `OSError` 系列异常。`ConfigParseError` 应专用于配置格式/内容问题。
- 挑战: `path=None` 和空字符串应显式处理。
  - 回应: 接受。但优先级低——这些是调用方错误，`TypeError`/`ValueError` 是合理的响应。

**Qualifier**: L2 覆盖的边界仅限于设计文档中隐含和显式声明的接口约定。修复 A7 后，`defaults` 维度变为完全处理。

**Verdict: FAILED** — `defaults=None` 边界 FATAL 未处理。`path` 维度的空文件和目录边界也未处理但可接受。

---

### L3: Failure Mode Walkthrough — FAILED

**Claim**: `parse_config` 主函数的两个 HIGH 严重性失效模式均来自未处理的边界条件，其中一个是单点故障。

**Ground**:

#### 模块 1: `ConfigParseError` 异常类

| FM | 描述 | 影响范围 | 概率 |
|----|------|---------|------|
| FM1.1 | 异常继承链错误（不继承 Exception） | 无法被 `except Exception` 捕获 | LOW |
| FM1.2 | 不保留原始异常链（不用 `from e`） | 调试信息丢失 | LOW |
| FM1.3 | 部分错误绕过 ConfigParseError（见 L2 未处理边界） | 不一致的错误接口 | MEDIUM |

#### 模块 2: 文件大小检查

| FM | 描述 | 影响范围 | 概率 |
|----|------|---------|------|
| FM2.1 | TOCTOU：大小检查后文件被删除 | `FileNotFoundError` 而非 `{}` | LOW |
| FM2.2 | `getsize()` 对目录返回 0，绕过大小检查 | 后续 open 产生非 `ConfigParseError` | MEDIUM |
| FM2.3 | 阈值比较用 `>=` 而非 `>` | 精确 10MB 文件被拒绝 | LOW |

#### 模块 3: `parse_config` 主函数

| FM | 描述 | 影响范围 | 概率 |
|----|------|---------|------|
| **FM3.1** | **`defaults=None` 时 `{**None, **parsed}` 引发 `TypeError`** | **整个函数崩溃。所有不含 defaults 的调用均受影响** | **HIGH (100%)** |
| **FM3.2** | **空文件无特殊处理，`json.load()` 抛 `JSONDecodeError`** | **需求 (2) 违反：应返回 `{}` 却抛异常** | **HIGH** |
| FM3.3 | Unicode/编码错误泄露原生异常 | 不一致的错误接口 | MEDIUM |

#### 模块 4: 边界条件测试

| FM | 描述 | 影响范围 | 概率 |
|----|------|---------|------|
| FM4.1 | 测试不覆盖 `defaults=None` | FM3.1 未被测试捕获 | HIGH |
| FM4.2 | 测试不覆盖空文件 | FM3.2 未被测试捕获 | MEDIUM |

**Warrant**: FM3.1 和 FM3.2 均为 HIGH 严重性、高概率失效模式。FM3.1 是单点故障——一个合并操作崩溃整个函数。FM3.2 是需求级违例。两者都是可证明的，不需要概率估计。

**Single Point of Failure**: `{**defaults, **parsed}` 行。当 `defaults=None` 时（函数签名的合法默认值），此单行导致整个函数崩溃。目前设计中**无任何防护**。

**Rebuttal**: 无。两个 HIGH 严重性失效模式均来自可证明的设计缺陷，无法通过风险接受来处理。

**Qualifier**: FM3.1 修复后（一行代码），所有失效模式降至 MEDIUM 或 LOW。FM3.2 修复后（空内容预检），所有已知失效模式均可接受。

**Verdict: FAILED** — FM3.1 为无防护的单点故障，FM3.2 为需求级违例。修复为两行代码（`defaults = defaults or {}` + 空内容检查）。

---

### L3.5: Causal Trace

#### Causal Trace 1: `defaults=None` 崩溃

```
TOP EVENT: parse_config("valid.json") 引发 TypeError 而非返回解析结果

CAUSAL CHAIN:
  [root: 函数签名 defaults: dict | None = None]
    ──(AND: 调用方不传 defaults 参数, 这是最常见调用方式)──→
  [defaults 变量在合并点为 None]
    ──(直接)──→
  [{**defaults, **parsed} 尝试解包 None]
    ──(直接)──→
  [TypeError: 'NoneType' object is not a mapping]
    ──(直接)──→
  [TOP EVENT: 函数崩溃，无配置返回]

PROPAGATION PATH:
  [TypeError] → [parse_config 崩溃] → [调用方收到非预期 TypeError] → [应用启动失败 or 配置缺失导致静默错误]

CRITICAL JUNCTION:
  Node: {**defaults, **parsed} 合并行
  Blocked? NO — 当前设计无 None 检查
  Fix: defaults = defaults or {} 在合并前

EVIDENCE SOURCES:
  - L1: A7 (合并操作假设 defaults 为 dict)
  - L2: defaults=None 边界未处理
  - 设计 warrant: "{**defaults, **parsed}" 不含 None 防护
  - 实测: python3 -c "{**None, **{}}" → TypeError
```

#### Causal Trace 2: 空文件未处理

```
TOP EVENT: 空 JSON 文件引发 ConfigParseError/JSONDecodeError 而非返回 {}

CAUSAL CHAIN:
  [root: 空文件通过所有前置检查 (存在 + 大小 < 10MB)]
    ──(AND: 文件大小为 0 bytes)──→
  [json.load() 尝试解析空字符串]
    ──(直接)──→
  [json.JSONDecodeError: "Expecting value: line 1 column 1 (char 0)"]
    ──(OR: 被设计包装为 ConfigParseError)──→
  [TOP EVENT: 异常抛出，需求 (2) 违反]

PROPAGATION PATH:
  [JSONDecodeError] → [(可能包装为 ConfigParseError)] → [调用方收到异常] → [需求 (2) "文件为空返回空dict" 违反]

CRITICAL JUNCTION:
  Node: json.load() 调用前的决策点 — 是否读取并检查内容为空
  Blocked? PARTIAL — 设计承认"需单独处理"但未指定机制
  Fix: 读取文件内容后，if not content.strip(): return {}

EVIDENCE SOURCES:
  - L1: A5 (json.load 对空内容抛异常)
  - L2: path=空文件边界未处理
  - 设计 backing: "json.load 标准行为：空文件抛异常（需单独处理）"
  - 实测: json.load(StringIO('')) → JSONDecodeError
```

---

### L4: "One Thing That Kills This Design" — FAILED

**致命假设**: `{**defaults, **parsed}` 合并操作在 `defaults=None` 时安全运行。

**如果此假设为假（它确实是假的）**: 任何不含 `defaults` 参数的调用（即最常见的调用方式 `parse_config("config.json")`）都会崩溃。设计的所有其他部分——大小检查、异常包装、回退逻辑——都不会被执行，因为函数在到达合并点时已崩溃。

**置信度**: **HIGH（假设确实为假）**。这不是概率评估——`python3 -c "{**None, **{}}"` 可重现地抛出 `TypeError`。CPython 的 dict 解包语义明确要求操作数实现 `Mapping` 协议，`None` 不实现。

**L4 通过条件**: 致命假设置信度 >= 可接受阈值。但此处的"置信度"评估的是"假设为真"的概率，而我们 HIGH 确信假设为假——这直接导致 L4 失败。

**修复后的致命假设**: 如果添加 `defaults = defaults or {}`，致命假设变为 "json.load() 是此任务正确的解析策略"。置信度: HIGH（JSON 是唯一需求格式，`json.load` 是 stdlib 标准解）。此假设通过 L4。

**Verdict: FAILED** — 致命假设可证明为假，设计存在单点致命缺陷。

---

## Actions Required

### 阻塞性修复（必须在重新验证前完成）

1. **修复 A7/FM3.1 — `defaults=None` 崩溃** (HIGH, 1行)
   - 在合并操作前添加: `if defaults is None: defaults = {}`
   - 或使用: `defaults = defaults or {}`
   - 或使用: `result = {**(defaults or {}), **parsed}`

2. **修复 A5/FM3.2 — 空文件处理** (HIGH, 2-3行)
   - 在 `json.load()` 前检查读取内容: `if not content.strip(): return {}`
   - 或捕获 `json.JSONDecodeError` 并检查 `"Expecting value"` 消息——但显式检查更清晰

### 建议性修复（不阻塞 gate-2，但推荐在实现前处理）

3. **A4 — 目录路径检测** (MEDIUM, 1行)
   - 添加 `if not os.path.isfile(path): return {}` 或抛 `ConfigParseError`

4. **L2 — 明确 10MB 阈值的比较运算符** (文档)
   - 记录使用 `>` 还是 `>=`

5. **L2 — 空字符串 path** (LOW, 1行)
   - 添加 `if not path: raise ValueError("path must be non-empty")`

### 修复后重新验证

预计修复量: 2-3 行关键代码 + 1-2 行建议代码。修复后预期所有层通过。

---

## Fact-Check Candidates

| # | Claim | Ground (cited basis) | Audit focus | Risk | Est. tokens |
|---|-------|---------------------|-------------|------|-------------|
| 1 | "`os.path.getsize()` 是 O(1) syscall" | design warrant | 验证 getsize 在各 OS (Linux/macOS/Windows) 的实际复杂度 | L | ~2k |
| 2 | "`json.load` 标准行为：空文件抛异常" | design backing | 验证——已在本 gate-2 实测确认 | L | ~1k |
| 3 | "`json.load()` 自带格式校验" | design warrant | 验证 JSON 规范符合性、边界 JSON 结构 | L | ~2k |

以上 3 项均为 LOW 风险——不影响设计决策。Claim 1 和 3 为一般性 Python 知识，不需要 web 验证。Claim 2 已在本验证中实测确认。
