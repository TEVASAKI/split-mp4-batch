# split-mp4-batch

`.mp4` ファイルを10件単位で連番フォルダへ自動分類する PowerShell バッチ。

## 本番スクリプト

```
src/scripts/Split_mp4.ps1
```

## 使い方（概要）

```powershell
# 事前確認（必須）
.\Split_mp4.ps1 -DryRun

# 本番実行
.\Split_mp4.ps1
```

詳細な実行手順・設定変更・ロールバック仕様は **[docs/README.md](docs/README.md)** を参照。

## リポジトリ構成

```
split-mp4-batch/
├── src/
│   ├── scripts/
│   │   └── Split_mp4.ps1               ← 本番スクリプト
│   ├── tests/
│   │   ├── test_split_mp4.ps1          ← 正常系テスト
│   │   ├── test_split_mp4_abnormal.ps1 ← 異常系テスト
│   │   ├── test_split_mp4_step.ps1     ← ステップ実行テスト
│   │   └── 異常系のテスト.md
│   └── archive/                        ← 旧バージョン（実運用では使わない）
├── docs/
│   └── README.md                       ← 詳細手順書
└── README.md                           ← 本ファイル
```

## 必要環境

- Windows 10 / 11
- PowerShell 5.1 以上
- 管理者権限不要
