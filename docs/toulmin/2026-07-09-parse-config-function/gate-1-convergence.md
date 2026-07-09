# Gate 1 — Direction Convergence — 2026-07-09

## Decision
使用标准库 `json` + `os.path` 实现，不引入第三方依赖。文件大小用 `os.path.getsize()` 预检，异常链用 `raise ConfigParseError(...) from e`。

## Claim
纯标准库方案是此任务的最优路径——需求简单（单格式、单文件、本地读取），引入 `pydantic`/`marshmallow` 等框架属于过度工程。

## Ground
- Python 标准库已覆盖所有需求：`json.load()`（解析）、`os.path.getsize()`（大小检查）、`os.path.exists()`（存在检查）
- 5 个边界条件均可在 ~30 行代码内处理
- 无并发需求，无需 schema 校验

## Warrant
- 文件大小 → `os.path.getsize()` 是 O(1) syscall，不读取文件内容 → 满足"大文件拒绝需在读取前完成"
- JSON 解析 → `json.load()` 自带格式校验 → 无效 JSON 直接触发 `json.JSONDecodeError` → 包装为 `ConfigParseError`
- defaults 回退 → `{**defaults, **parsed}` 实现文件值覆盖默认值

## Backing
- CPython `os.path.getsize` 文档明确返回字节数（stat syscall），线程安全
- `json.load` 标准行为：空文件抛异常（需单独处理）、格式错误抛 `JSONDecodeError`
- PEP 3134（Exception Chaining）— `raise X from e` 保留异常链

## Rebuttal
- **Alternative A: pydantic BaseModel** → 引入第三方依赖 + schema 定义开销 + 过度工程。Rejected。
- **Alternative B: tomllib + json 双格式** → 超出需求范围（OUT of scope）。Rejected。
- **Alternative C: 内存映射文件 (mmap)** → 对小文件无性能收益，增加复杂度。Rejected。

## Qualifier
- **有效范围**: 本地 JSON 文件，单线程读取，<10MB
- **失效条件**: 需要热重载时本方案不够；需要远程读取时需额外网络层
- **决策有效期**: 当前版本。如有 schema 验证需求 → 重评估 pydantic

## Verdict: PASSED
