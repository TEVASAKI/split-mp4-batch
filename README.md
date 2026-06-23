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

- **src/scripts/** … 本番スクリプト（1本のみ）
  - `Split_mp4.ps1` … **本番版**（ロールバック機能あり）
- **src/archive/** … 旧バージョン・仮本番スクリプト（参照用。実運用では使用しないこと）
- **src/tests/** … テスト用スクリプト（test_split_mp4.ps1, test_split_mp4_abnormal.ps1 等）
- **docs/** … 手順書（README_v1.md, README_v2.md）、テストログ（test-logs/）

## 重要な注意事項

- **実運用には `src/scripts/Split_mp4.ps1` を使用すること。**
- 本番実行前に必ず `-DryRun` スイッチで事前確認を行うこと。
- ロールバックは例外発生時に自動実行されるが、プロセスの強制終了・OS 停止・電源断などでは保証できない。重要なファイルは事前にバックアップを取ること。
- ロールバック時、移動先に同名ファイルが存在する場合は上書きせず、スキップして記録する。
- `-DryRun` 実行時のログには `[DRY-RUN]` プレフィックスが付与される。

## 使い方

1. モジュールは `src/modules/` に配置
2. エントリポイントとなるスクリプトは `src/scripts/` に配置
3. テストは `src/tests/` に Pester 等で記述
4. 設定は `config/` に YAML/JSON 等で管理

## 必要環境

- PowerShell 5.1 または PowerShell 7+
