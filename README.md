# PowerShell プロジェクト

PowerShell プロジェクトのルートです。

## フォルダ構成

```
src/
├── scripts/   # 実行用スクリプト
├── modules/   # 再利用可能なモジュール
├── tests/     # テストスクリプト
config/        # 設定ファイル
docs/          # ドキュメント
scripts/       # ビルド・デプロイ用スクリプト
.vscode/       # VS Code / Cursor 設定
```

## 本プロジェクトの構成（MP4 分割スクリプト）

- **src/scripts/** … 本番用スクリプト（Split_mp4_production_v1.ps1, v2, provisional_split_mp4_ROLLBACK.ps1）
- **src/tests/** … テスト用スクリプト（test_split_mp4_step.ps1, test_split_mp4_rollback.ps1）
- **docs/** … 手順書（README_v1.md, README_v2.md）、テストログ（test-logs/）

## 使い方

1. モジュールは `src/modules/` に配置
2. エントリポイントとなるスクリプトは `src/scripts/` に配置
3. テストは `src/tests/` に Pester 等で記述
4. 設定は `config/` に YAML/JSON 等で管理

## 必要環境

- PowerShell 5.1 または PowerShell 7+
