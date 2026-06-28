# Toulmin — 批判的論証フレームワーク

[トゥールミン論証モデル](https://en.wikipedia.org/wiki/Stephen_Toulmin)に基づくClaude Codeプラグイン。「コーディング前の限定的検証」と「受け入れ前の反対討論」を3つの rigid Gate として制度化。Vibe CodingではL0シグナル検出と自動チェックポイントによりドリフトを識別する。中核的方法論：**Toulmin 批判的論証**。

[English](README.en.md) | [中文](README.md)

---

## 1. 設計理論 — 9つの中核的主張

各主張はトゥールミンの6要素（Claim, Ground, Warrant, Backing, Rebuttal, Qualifier）で構築。完全な論証連鎖は [`ai-failure-detection-framework.md`](ai-failure-detection-framework.md) を参照。

### 主張1: 不確かな語調は誤りのシグナル

> AIの結論文中の「かもしれない」「おそらく」は、モデルが複数の低信頼度トークン分岐の間で迷っていることを意味する——どのパスも暗黙の検証閾値を通過していない。

**区別**: 結論修飾 = red flag；リスク警告 = 正当な工学的慎重さ。

### 主張2: 回帰反復での繰り返し言及 = 認知的ドリフト

> AIには構造化された「解決済み」状態マシンがない。長文脈でのattention重み減衰→初期に解決済みの議論が忘却→古いパターンが新発見として再活性化。

**検出**: embedding類似度 + 論理的一貫性チェック。繰り返し + 新情報なし = ドリフト。

### 主張3: 明確なロードマップや参照物がない → 汎化性なし

> AIは抽象推論を行うのではなく、条件付き確率マッチングを行う。汎化には「複数インスタンスからの不変パターンの抽出」が必要——現在の仕様という単一インスタンスしかない場合、AIは本質的特徴と偶発的特徴を区別できない。

### 主張4: 収束なきコーディング = 無価値

> 設計段階の未解決問題は実装段階に入っても自己解決しない——技術的負債、境界バグ、アーキテクチャ衝突として再浮上する。AIは「疑似収束」の製造に長けている——流暢な要約で未解決問題を決着済みに見せかける。

**収束基準**: 少なくとも1つのyes/no質問 + 全参加者が回答に合意。

### 主張5: AIの推奨意見は厳格な証明が必要

> AIに自己証明を要求すること = 判断負荷を人間からAIに戻すこと + レビュー対象を「結論の尤もらしさ」から「推論連鎖の追跡可能性」に変えること。AIの推論能力を検証に使い、生成能力を意思決定に使わない。

**三段階証明**（信頼性順）: **境界**（失敗条件） > **反証**（代替案排除） > **溯源**（証拠引用）。

### 主張6: 長距離タスクは構造化タスク文書が必須

> plan→task→target→pseudocode→verify→regression チェーンの各ノードは独立した検証ゲート。制約がない場合、各ステップでのAIの出力空間が大きすぎる——正しさの確率はステップ数とともに指数関数的に減衰する。「次に...」という言語 = ナラティブモードであり実行モードではない。

### 主張7: AIの「平滑性バイアス」が境界問題をシステム的に隠蔽

> LLMの尤度最大化目標 + 自己回帰生成の平滑化ダイナミクス = 正常パスへのシステム的回帰。境界条件（null、極値、並行競合）は出力からシステム的に欠落する。

### 主張8: 「完了した作業」に対するAIの幻覚蓄積

> AIはコンパイラ/ランタイムを強制的現実フィードバックとして持たない。長い会話の中で仮定が徐々に「確認済み事実」に格上げされ、各エラー層が同じ表面的確信度を維持する。

**2つのメカニズム**: 記憶ベース（文脈管理で緩和可能） vs 推論ベース（モデル知識バイアスに根ざし、文脈リセットでは解決不能）。

### 主張9: 確認的レビューは未レビューと等価（補足）

> 人間のレビュアーは自動化バイアス + 確証バイアスの二重作用を受ける——正しさの証拠を探し、誤りの証拠を探さない。**反駁を明示的目的とするレビュー（反対討論）のみがこのバイアスを打ち破る。**

---

## 2. 検出フレームワーク — L0/L1/L2 階層モデル

```
L0 シグナル層（継続的監視、ゼロコストフラグ）
  ├─ ヘッジ語密度 > 閾値              → 信頼度不足
  ├─ 隣接ターン意味的類似度            → 文脈飽和
  ├─ 「次に/それから」密度スパイク     → ナラティブモード活性化
  ├─ 低い境界処理カバレッジ            → 平滑性バイアス活性化
  └─ 人間の応答時間減衰                → 注意力減衰（vibe専用）
  ↓ フラグトリガー
L1 検証層（オンデマンド、シグナル真偽判定）
  ├─ ヘッジ語 → 確定的断言または明示的「不確か」を要求
  ├─ 繰り返し → 新情報が導入されたか確認
  └─ ナラティブ → 最近の「done」宣言に検証が伴うか確認
  ↓ 検証失敗
L2 介入層（進行阻止、強制修正）
  └─ gate_blocked=true → PreToolUseフックがWrite/Editを拒否
```

---

## 3. プロセスフレームワーク — 3つのGate

```
plan → task → target ─┬─ [Gate 1: 方向収束] ──→ pseudocode → code → verify
                      │    トゥールミン論証記録        ↑              ↓
                      │    「なぜこの道か」       Gate 2:        Gate 3:
                      │                        限定的検証      反対討論
                      │                           L1-L4         R1-R3
                      ↓                            ↓              ↓
                   gate-1-convergence.md   gate-2-verify.md  gate-3-debate.md
```

### Gate 1 — 方向収束
**トゥールミン形式**: Claim/Ground/Warrant/Backing/Rebuttal/Qualifier。設計判断、却下された代替案とその理由、判断の有効範囲と失効条件を記録。

### Gate 2 — 限定的検証（L1-L4）
**L1 仮説棚卸**: 設計が依存する全仮説を列挙、リスク階層化、緩和または明示的受け入れ。  
**L2 境界行列**: 入力/状態/環境次元 × 処理戦略（または明示的「非対応」）。  
**L3 故障モードウォークスルー**: 主要モジュールごとに最も可能性の高い3つの故障 + 爆発半径 + 単一障害点チェック。  
**L4 「この設計を殺す一つのこと」**: 致命的仮説の特定。信頼度評価（高/中/低）。

### Gate 3 — 反対討論（R1-R3）
**R1 構造的異議**: 反対者がD1-D6攻撃次元（正当性/完全性/一貫性/堅牢性/セキュリティ/保守性）で証拠を挙げて攻撃。役割分離のため `toulmin-debater` エージェントの使用を推奨。  
**R2 応答**: 各指摘に応答——[ACCEPT]/[REBUT]/[CLARIFY]/[DEMOTE]。[IGNORE]と[VAGUE]は禁止。  
**R3 反論 + 評決**: REBUTとCLARIFY項目を再検討→最終評決 ✅/⚠️/❌。

---

## 4. Vibe Coding プロトコル

Vibeモードの4つの暗黙的前提とその破綻シグナル：

| 前提 | 破綻シグナル |
|------|-------------|
| 短いフィードバック ≈ 高品質設計 | 第Kラウンドの案が第K-Nラウンドと衝突 |
| 訓練分布が問題空間をカバー | 中核ロジックにヘッジ語 |
| Vibe-checkが有効な検証 | 「正常に見える」が実行可能な検証基準なし |
| タスクがvibe-sizeチャンクに分解可能 | 1反復の変更が別モジュールを破壊 |

### 複合チェックポイントトリガー

| トリガー | アクション |
|---------|-----------|
| 反復 % N == 0 (N=20) | Stopフックブロック → L0スキャンタスク注入 |
| gate_blocked=true | Stopフックブロック → 「Gate未通過、完了を主張できない」 |
| スループット減衰（5ラウンド<20行、新機能なし） | vibe慣性を警告 → /toulmin-plan を提案 |

### VAC — Vibe Adversarial Check（60秒）
「反対者モードに切り替え。このコードが壊れる具体的シナリオを3つ示せ。それぞれ'If...then...'で始め、具体的な入力または条件を記述せよ。」

---

## 5. インストール

```bash
# グローバルインストール（全プロジェクトで利用可能）
cp -r toulmin ~/.claude/skills/toulmin

# zip経由
claude plugin install ./toulmin-1.0.0.zip --scope user

# 開発モード
claude --plugin-dir ./toulmin
```

---

## 6. コマンドリファレンス

| コマンド | 用途 | 起動 |
|---------|------|------|
| `/toulmin:toulmin-plan "task" --lang zh` | 構造化実行エントリ | 手動 |
| `/toulmin:toulmin-vibe --lang zh` | Vibe coding + ドリフト検出 | 手動 |
| `/toulmin:toulmin-verify` | L1-L4検証（Gate 2） | Plan委譲 / vibe単独 |
| `/toulmin:toulmin-debate` | R1-R3討論（Gate 3） | Plan委譲 / vibe単独 |
| `/toulmin:toulmin-status` | フレームワーク状態表示（読取専用） | 手動 / チェックポイント |
| `/toulmin:toulmin-override "理由"` | 失敗gateの手動却下（リスク受諾を記録） | 手動 |

---

## 7. プラグインアーキテクチャ

```
toulmin/
├── skills/                       # 5スキル
│   ├── toulmin-plan/SKILL.md     #   構造化エントリ: p→t→t→gate制御フロー
│   ├── toulmin-vibe/SKILL.md     #   Vibeエントリ: チェックポイント/VAC/モード遷移
│   ├── toulmin-verify/SKILL.md   #   Gate 2: L1-L4 + gate文書書込
│   ├── toulmin-debate/SKILL.md   #   Gate 3: R1-R3 + gate文書書込
│   └── toulmin-status/SKILL.md   #   読取専用状態サマリ
├── hooks/
│   └── hooks.json                # 3フック登録
├── scripts/
│   ├── lib/
│   │   └── state.sh              #   共有state解析 + セッション分離 + デフォルト値
│   ├── update-gate.sh            #   統合gate状態更新（アトミックsed）
│   ├── pre-tool-use.sh           #   gate_blocked=true → Write/Edit拒否
│   ├── stop-hook.sh              #   反復カウンタ + 完了ブロック + チェックポイント注入
│   └── session-start.sh          #   復元ポインタ addContext
├── agents/
│   ├── toulmin-debater.md        #   反対審査者: D1-D6攻撃次元
│   └── toulmin-verifier.md       #   検証者: L1-L4検証層
├── .claude-plugin/
│   └── plugin.json
├── README.md
├── README.en.md
└── README.ja.md
```

### 実装パターン

**grill-meパターン**（純粋プロンプト駆動）: 5スキル + 2エージェント。言語制約による行動誘導——フック不要。

**ralph-loopパターン**（フック + stateファイル）: 3フックスクリプト + `.claude/toulmin-state.local.md`。ハード強制にはライフサイクルインターセプトが必要；状態にはクロスターン永続化が必要。

**共有インフラストラクチャ**:
- `scripts/lib/state.sh` — 統一frontmatter解析、セッション分離、フィールドデフォルト値。全3フックが `source` で再利用。
- `scripts/update-gate.sh` — 統合gate状態更新。アトミックsed、冪等追加、gate名ホワイトリスト検証。toulmin-plan/verify/debateが `${CLAUDE_PLUGIN_ROOT}` 経由で呼出。

**stateファイル設計** — 最小限、フック判断フィールドのみ:
```yaml
---
gate_blocked: false     # PreToolUseがこのフィールドをチェック
phase: plan             # 現在のフェーズ
session_id: xxx         # Stopフックのセッション分離用
iteration: 0            # Stopフックがインクリメント、チェックポイント検出
gate_dir: docs/toulmin/2026-06-27-xxx/  # gate文書パス
gates_passed: [gate-1]  # 通過済みgateリスト
gate_current: gate-2    # アクティブgate
ca_mode: structured     # structured | vibe
lang: zh                # 出力言語
checkpoint_interval: 20 # vibeチェックポイント間隔（0=無効）
gate_attempts: 0        # gate再試行カウンタ（表示のみ、自動動作なし）
---
```

---

## 8. プロジェクト成果物

```
docs/toulmin/YYYY-MM-DD-<task-slug>/
  gate-1-convergence.md    # 方向論証（Claim/Ground/Warrant/Backing/Rebuttal/Qualifier）
  gate-2-verification.md   # L1-L4結果（層ごとにトゥールミン形式）
  gate-3-debate.md         # R1-R3 + [ACCEPT/REBUT/CLARIFY/DEMOTE] + 評決

.claude/toulmin-state.local.md  # フック判断状態（タスク完了時にクリーンアップ）
```

Gate文書は**第三者論証記録**——プラグインや会話文脈から独立。失敗したgateも同様に記録される（「なぜこの道が塞がれたか」）、将来の参照用。

---

## 9. 上流ツールとの連携

Toulminは独立して動作——brainstormingや他のツールへの依存なし。プロジェクトに設計文書（spec）が存在する場合、gate文書は1行の参照でリンク：

```markdown
> 上流設計文書: docs/superpowers/specs/2026-06-27-role-based-auth-design.md
```

上流なし → 独立動作。Toulminフレームワークは疎結合。

---

## ライセンス

MIT
