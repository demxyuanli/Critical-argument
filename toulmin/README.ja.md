# Toulmin — 批判的論証フレームワーク

[English](README.en.md) | [中文](README.md)

[トゥールミン論証モデル](https://en.wikipedia.org/wiki/Stephen_Toulmin)に基づくClaude Codeプラグイン。v1.2は「コーディング前の検証」と「受け入れ前の反対討論」を**完全な四象限レビュー体系**に拡張：内部論証（verify + debate）+ 外部論証（audit + premortem）+ 限定詞合成（qualify）+ Agent編成 + 行動木可視化（tree）+ コンテキストドリフト検出。

**9スキル · 2エージェント · 3フック · 7スクリプト · 10理論的主張**

---

## 1. 設計理論 — 10の中核的主張

完全な論証連鎖（6要素）は [`ai-failure-detection-framework.md`](ai-failure-detection-framework.md) を参照。

| # | 主張 | メカニズム |
|---|------|-----------|
| 1 | 不確かな語調は誤りのシグナル | ヘッジ語密度 → 低信頼度；リスク警告とは区別 |
| 2 | 繰り返し言及 = 認知的ドリフト | attention減衰 → 解決済み議論の忘却 → 旧パターン再活性化 |
| 3 | 参照物なし → 汎化性なし | AIは条件付き確率マッチング、抽象推論ではない |
| 4 | 収束なきコーディング = 無価値 | 設計問題は実装段階で自己解決しない；AIは「疑似収束」を製造 |
| 5 | AI推奨意見は厳格な証明が必要 | 判断負荷を人間→AIへ；推論連鎖の追跡可能性をレビュー |
| 6 | 長距離タスクは構造化文書必須 | 各ノードが独立検証ゲート；正しさ確率は指数関数的に減衰 |
| 7 | 平滑性バイアスが境界問題を隠蔽 | 尤度最大化 → 正常パスへの回帰；境界条件がシステム的に欠落 |
| 8 | 「完了した作業」への幻覚蓄積 | AIにコンパイラ/ランタイムフィードバックなし；仮定が「事実」に格上げ |
| 9 | 確認的レビュー = 未レビュー | 自動化バイアス+確証バイアス；反対討論のみが打破 |
| **10** | **内部論証には外部盲点がある** | **v3: モデル知識に締切と分布偏向 → 外部検証が必要** |

---

## 2. レビューツール行列 — 四象限モデル

v1.2は全レビューツールを内部/外部 × 静的/動的の完全な行列に組織化：

```
                内部論証                    外部論証
          (訓練データ+文書+コード)       (WebSearch+逆ナラティブ)
    ┌─────────────────────────┬─────────────────────────┐
静的 │ Gate 2: verify          │ audit                   │
    │ L1-L4 + L3.5因果連鎖    │ WebSearch反証検索        │
    │ 既知次元の正しさ検査      │ 外部事実への挑戦          │
    ├─────────────────────────┼─────────────────────────┤
動的 │ Gate 3: debate          │ premortem               │
    │ R1-R3 反対討論           │ 失敗仮定→3つの死亡経路    │
    │ D1-D6 攻撃次元           │ 物語的脆弱性の発見        │
    └─────────────────────────┴─────────────────────────┘
                              ↓
                         qualify
                    統一限定詞合成
           (硬境界/軟境界/信頼度/監視トリガー)
                              ↓
                          tree
                    行動木可視化
           (Mermaid図 + 分区 + セッション間)
```

**完全性の原則**：任意の象限の欠落 = その盲点クラスが残留リスクとなる。ツールのスキップ = その盲点タイプへの明示的リスク受諾。

---

## 3. 検出フレームワーク — L0/L1/L2 + 分区追跡

```
L0 シグナル層（継続的、ゼロコスト）
  ├─ ヘッジ密度 > 閾値              → 信頼度不足
  ├─ 隣接ターン意味的類似度          → 文脈飽和
  ├─ 「次に/それから」密度スパイク   → ナラティブモード
  ├─ 低境界カバレッジ                → 平滑性バイアス
  └─ 人間応答時間減衰                → 注意力減衰（vibe）
  ↓ トリガー
L1 検証層（オンデマンド）
  ↓ 検証失敗
L2 介入層（進行阻止）
  └─ gate_blocked=true → PreToolUseがWrite/Edit + Bash書込を拒否
  ↓
分区追跡（Stopフック ドリフト自己チェック）
  ├─ Vibe: 各チェックポイント → ドリフト自己チェック注入
  ├─ Structured: 30反復毎 → ドリフト自己チェック注入
  └─ partition-track.sh 遷移記録 → toulmin-tree 可視化
```

---

## 4. プロセスフレームワーク — 3Gate + Agent編成

```
toulmin-plan (編成者)
  │
  ├─ plan → task → target
  ├─ [Gate 1: 方向収束] ← あなた (編成者)
  │     └─ トゥールミン論証記録
  │
  ├─ [Gate 2: 限定的検証] ← Agent(toulmin-verifier)  [隔離コンテキスト]
  │     └─ L1-L4 + L3.5因果連鎖 → gate-2-verification.md
  │
  ├─ pseudocode → code → verify
  │
  ├─ [Gate 3: 反対討論] ← Agent(toulmin-debater)  [隔離コンテキスト]
  │     └─ R1-R3 (D1-D6) → gate-3-debate.md
  │
  ├─ [オプション] audit → premortem → qualify → tree
  │
  └─ regression → complete
```

### Gate 1 — 方向収束（編成者が実行）
トゥールミン形式: Claim/Ground/Warrant/Backing/Rebuttal/Qualifier

### Gate 2 — 限定的検証（Agent派发）
`toulmin-verifier` Agentを派发 — 隔離コンテキスト、計画会話に非汚染。  
**L1** 仮説棚卸 | **L2** 境界行列 | **L3** 故障モード | **L3.5** 因果連鎖 | **L4** 「設計を殺す一事」

### Gate 3 — 反対討論（Agent派发）
`toulmin-debater` Agentを派发 — 役割分離、目的はREFUTE。  
**R1** D1-D6攻撃 | **R2** [ACCEPT/REBUT/CLARIFY/DEMOTE] | **R3** 評決 ✅/⚠️/❌

### 外部レビューツール（手動起動）
| ツール | 象限 | 機能 |
|------|------|------|
| `/toulmin:toulmin-audit` | 外部-静的 | WebSearchで反例・代替案・境界障害を検索 |
| `/toulmin:toulmin-premortem` | 外部-動的 | 失敗仮定→3つの因果死亡経路を逆導出 |
| `/toulmin:toulmin-qualify` | 合成 | 全発見を集約→硬/軟境界+信頼度 |
| `/toulmin:toulmin-tree` | 可視化 | Mermaid行動木 + 分区履歴 + セッション間参照 |

---

## 5. Agent編成アーキテクチャ

toulmin-planがプロンプト駆動スキルからAgent編成者にアップグレード：

| 役割 | 実行者 | コンテキスト | 責務 |
|------|--------|-------------|------|
| 編成者 | あなた (toulmin-plan) | 完全会話 | 問題定義、タスク分解、Gate 1、実装 |
| 検証Agent | `toulmin-verifier` | **隔離** | L1-L4 + L3.5因果連鎖。計画議論に非接触 |
| 討論Agent | `toulmin-debater` | **隔離** | D1-D6攻撃。設計判断への感情的依附なし |

**なぜAgentか？** Skillsは編成者コンテキストで実行—検証結果が計画会話に汚染される。Agentは隔離コンテキスト：検証者はトレードオフ議論を知らず、討論者は設計決定に依附しない。この隔離が真の敵対的レビューのメカニズム。

---

## 6. フレームワーク退化防御

Premortemがtoulmin自身を分析し3つの退化経路を特定、すべて防御済み：

| パターン | メカニズム | 防御 |
|---------|-----------|------|
| **形式が実質を代替** | overrideがデフォルト反射に | クールダウン+段階的摩擦+比率追跡 |
| **プラットフォーム盲点** | headless/bypass/subagentでフック無音故障 | 5盲点表示+反復クロスチェック |
| **知識の埋没** | gate文書が書いて忘れられる | SessionStart履歴スキャン+類似タスク照合 |

---

## 7. Vibe Codingプロトコル

チェックポイント + VAC + ドリフト自己チェックの三層安全網。

| トリガー | アクション |
|---------|-----------|
| 反復 % N == 0 (N=20) | Stopブロック → L0スキャン + **ドリフト自己チェック** |
| gate_blocked=true | Stopブロック → 完了主張不可 |
| スループット減衰 | vibe慣性警告 → /toulmin-plan提案 |

### VAC — Vibe Adversarial Check（60秒）
「反対者モードに切替。このコードが壊れる3つの具体的シナリオを示せ。」

---

## 8. インストール

```bash
# グローバルインストール
cp -r toulmin ~/.claude/skills/toulmin

# zip経由
claude plugin install ./toulmin-1.2.0.zip --scope user

# 開発モード
claude --plugin-dir ./toulmin
```

---

## 9. コマンドリファレンス

| コマンド | 用途 | 起動 |
|---------|------|------|
| `/toulmin:toulmin-plan "task" --lang zh` | Agent編成の構造化エントリ | 手動 |
| `/toulmin:toulmin-vibe --lang zh` | Vibe coding + チェックポイント + ドリフト | 手動 |
| `/toulmin:toulmin-verify` | L1-L4検証（Gate 2） | PlanがAgent派发 / vibe単独 |
| `/toulmin:toulmin-debate` | R1-R3討論（Gate 3） | PlanがAgent派发 / vibe単独 |
| `/toulmin:toulmin-audit "主張"` | 外部証拠検証（WebSearch） | 手動（gate文書候補表） |
| `/toulmin:toulmin-premortem` | 失敗遡及推演（3死亡経路） | 手動（Gate 2/3通過後） |
| `/toulmin:toulmin-qualify` | 統一限定詞合成 | 手動（全レビュー後） |
| `/toulmin:toulmin-tree` | 行動木可視化（Mermaid） | 手動 / 状態確認 |
| `/toulmin:toulmin-status` | フレームワーク状態 + 整合性 | 手動 / チェックポイント |
| `/toulmin:toulmin-override "理由"` | 手動gate却下（クールダウン追跡） | 手動 |

---

## 10. プラグインアーキテクチャ

```
toulmin/
├── skills/                       # 9スキル
│   ├── toulmin-plan/SKILL.md     #   Agent編成: plan→gates→agents→regression
│   ├── toulmin-vibe/SKILL.md     #   Vibeエントリ: checkpoint/VAC/モード遷移
│   ├── toulmin-verify/SKILL.md   #   Gate 2: L1-L4 + gate文書 + 候補表
│   ├── toulmin-debate/SKILL.md   #   Gate 3: R1-R3 + gate文書 + 候補表
│   ├── toulmin-audit/SKILL.md   #   外部検証: WebSearch → STANDS/NARROW/REFUTED
│   ├── toulmin-premortem/SKILL.md #   遡及推演: 3死亡経路 + 防御提案
│   ├── toulmin-qualify/SKILL.md  #   限定詞合成: 境界 + 信頼度 + 監視
│   ├── toulmin-tree/SKILL.md    #   行動木: Mermaid + 分区 + セッション間
│   └── toulmin-status/SKILL.md   #   状態 + 整合性 + override統計
├── hooks/
│   └── hooks.json                # PreToolUse(Write/Edit+Bash) + Stop + SessionStart
├── scripts/
│   ├── lib/state.sh              #   共有解析 + セッション分離 + 12フィールド既定値
│   ├── update-gate.sh            #   Gate状態更新 (アトミックsed + 冪等)
│   ├── pre-tool-use.sh           #   gate_blocked → Write/Edit拒否
│   ├── bash-guard.sh             #   gate_blocked → Bash書込迂回拒否
│   ├── partition-track.sh        #   分区遷移記録
│   ├── stop-hook.sh              #   反復 + 完了ブロック + checkpoint + ドリフトチェック
│   └── session-start.sh          #   復元ポインタ + 履歴スキャン + 類似タスク照合
├── agents/
│   ├── toulmin-debater.md        #   反対者: D1-D6攻撃 (隔離コンテキスト)
│   └── toulmin-verifier.md       #   検証者: L1-L4 + 因果連鎖 (隔離コンテキスト)
├── .claude-plugin/plugin.json
├── README.md / README.en.md / README.ja.md
└── ai-failure-detection-framework.md  # 完全理論文書 (10主張 + 10章)
```

### 実装パターン

**Agent編成**: 編成者がproblem + 分解 + Gate 1 + 実装を担当。Gate 2/3は隔離Agentに派发。レビュー結果が計画会話に非汚染。

**grill-me** (純粋プロンプト): 9スキル + 2エージェント。言語制約で行動誘導。

**ralph-loop** (フック + state): 3フック + `.claude/toulmin-state.local.md`。ライフサイクル遮断で強制。

**フック制限** (toulmin-audit検証済):
- ✅ 対話モード + exit code 2 → 決定的ブロック
- ❌ headless `-p` → フック未発火; subagent呼出 → PreToolUse未発火
- ⚠️ Bash迂回 → bash-guard.sh; bypassモード → 非同期遅延

**Stateファイル**:
```yaml
---
gate_blocked: false     # PreToolUseチェック
phase: plan             # plan|task|gate-1|gate-2|code|verify|gate-3|regression|complete
iteration: 0            # Stopフック増分
gate_dir: docs/toulmin/YYYY-MM-DD-<slug>/
gates_passed: [gate-1]  # 通過済gate
gate_current: gate-2    # アクティブgate
ca_mode: structured     # structured|vibe
lang: zh                # zh|en
checkpoint_interval: 20 # vibeチェックポイント間隔
gate_attempts: 0        # 再試行カウンタ
override_count: 0       # override総数 (クールダウン)
override_history: []    # [gate@round, ...]
partitions: ["task"]    # [src→dst@iteration:reason, ...]
partition_current: task # アクティブ分区
---
```

---

## 11. プロジェクト成果物

```
docs/toulmin/YYYY-MM-DD-<task-slug>/
  gate-1-convergence.md    # 方向論証 (トゥールミン6要素)
  gate-2-verification.md   # L1-L4 + L3.5因果連鎖 + fact-check候補
  gate-3-debate.md         # R1-R3 + [ACCEPT/REBUT/CLARIFY/DEMOTE] + 評決
  qualifier.md             # 統一限定詞 (硬/軟境界 + 信頼度 + 監視)

.claude/toulmin-state.local.md  # フック判断状態 (タスク完了時にクリーン)
```

Gate文書は**第三者論証記録**。qualifier.mdは設計の精確な契約。

---

## 12. バージョン履歴

| バージョン | 日付 | 主要追加 |
|-----------|------|---------|
| v1.0.1 | 2026-06 | 基盤: 5スキル + 3フック + L0-L2 + 3Gate + Vibe |
| v1.1.0 | 2026-07 | v3 外部レビュー: audit + premortem + qualify + 退化防御 |
| v1.2.0 | 2026-07 | v2 Agent編成 + tree + 分区追跡 + ドリフト自己チェック |

---

## ライセンス

MIT
