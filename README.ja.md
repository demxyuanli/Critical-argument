# Toulmin — 批判的論証フレームワーク

[トゥールミン論証モデル](https://en.wikipedia.org/wiki/Stephen_Toulmin)に基づくClaude Codeプラグイン。AI支援エンジニアリングにおける「コーディング前の限定的検証」と「受け入れ前の反対討論」を rigid なレビューゲートとして制度化。

**v1.2.0** · 9スキル · 2エージェント · 3フック · 7スクリプト · 10主張

---

## 四象限レビュー体系

```
                内部論証                    外部論証
    ┌─────────────────────────┬─────────────────────────┐
静的 │ verify (L1-L4検証)       │ audit (WebSearch校核)    │
    ├─────────────────────────┼─────────────────────────┤
動的 │ debate (R1-R3討論)       │ premortem (失敗遡及推演)  │
    └─────────────────────────┴─────────────────────────┘
                              ↓
                    qualify (限定詞合成) → tree (行動木可視化)
```

## クイックスタート

```bash
# インストール
cp -r toulmin ~/.claude/skills/toulmin

# 構造化タスク
/toulmin:toulmin-plan "ユーザーテーブルにロールベースの権限チェックを追加" --lang zh

# Vibe coding
/toulmin:toulmin-vibe --lang zh
```

## コマンド

| コマンド | 用途 |
|---------|------|
| `/toulmin:toulmin-plan` | Agent編成の構造化実行 |
| `/toulmin:toulmin-vibe` | Vibe coding + チェックポイント + ドリフト自己チェック |
| `/toulmin:toulmin-verify` | L1-L4検証 + L3.5因果連鎖 |
| `/toulmin:toulmin-debate` | R1-R3反対討論 (D1-D6) |
| `/toulmin:toulmin-audit` | WebSearch外部証拠検証 |
| `/toulmin:toulmin-premortem` | 失敗遡及推演 (3死亡経路) |
| `/toulmin:toulmin-qualify` | 統一限定詞合成 |
| `/toulmin:toulmin-tree` | 行動木可視化 (Mermaid) |
| `/toulmin:toulmin-status` | フレームワーク状態 + 整合性 |
| `/toulmin:toulmin-override` | 手動gate却下 (クールダウン追跡) |

## ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [Plugin README (中文)](toulmin/README.md) | 完全な使用文書 |
| [Plugin README (English)](toulmin/README.en.md) | Full documentation |
| [Plugin README (日本語)](toulmin/README.ja.md) | 完全なドキュメント |
| [理論](ai-failure-detection-framework.md) | 10主張 + 10章 |

## バージョン

| バージョン | 主要追加 |
|-----------|---------|
| v1.0.1 | 基盤: 5スキル + 3フック + L0-L2 + 3Gate + Vibe |
| v1.1.0 | v3 外部レビュー: audit + premortem + qualify + 退化防御 |
| v1.2.0 | v2 Agent編成 + tree + 分区追跡 + ドリフト自己チェック |

## ライセンス

MIT
