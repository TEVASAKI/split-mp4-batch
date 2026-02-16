# split_mp4.ps1 README

## 概要

本スクリプトは、指定ディレクトリ内の mp4 ファイルを  
**一定数（デフォルト10件）ごとにフォルダ分割して移動する PowerShell バッチ**である。 [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

- フォルダ命名規則：`<BaseName><連番2桁>`（例：20251001）
- DryRun（事前確認）対応
- 詳細ログ出力
- 例外発生時の完全ロールバック対応
- 異常系テストコード完備 [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

業務用途・大量ファイル・外付けHDD運用を前提に設計されている。 [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

***

## 基本仕様

| 項目       | 内容                              |
|------------|-----------------------------------|
| 対象拡張子 | `.mp4`                           |
| 分割単位   | 10ファイル（変更可）             |
| 並び順     | ファイル名昇順                   |
| 実行場所   | スクリプトと同一ディレクトリ     |
| ログ       | `_log/split_mp4_YYYYMMDD_HHMMSS.log` | [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

***

## 実装済み機能

### 1. DryRun 機能
- `-DryRun` 指定時は **ファイル・フォルダ操作を一切行わない**
- ログ出力は本番と完全一致
- 実行結果の事前検証が可能 [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

```powershell
.\split_mp4.ps1 -DryRun
```

### 2. ログ出力

時刻付きで以下を記録 [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

- 開始／終了
- フォルダ作成（MKDIR）
- ファイル移動（MOVE）
- エラー
- ロールバック操作

### 3. 例外時ロールバック

処理途中で例外が発生した場合： [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

- 移動済みファイルを 逆順で元の場所へ戻す
- 空フォルダは削除
- ロールバック失敗時もログに記録

### 4. 安全設計

- `-LiteralPath` を全面使用（ワイルドカード事故防止）
- 既存ファイル衝突時は即 Abort
- `Set-StrictMode -Version Latest` による品質担保 [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

## バージョンアップ履歴（重要）

### v1（初期）

- cmd（bat）ベース実装
- `/10` 演算ミスによるエラー発生
- ワイルドカード誤認識問題あり [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

### v2（PowerShell移行）

- PowerShell へ全面移行
- 基本分割ロジック実装
- ログ出力追加 [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

### v3（安定化）

- `-LiteralPath` 採用
- フォルダ名生成バグ修正
- フォーマット指定子エラー修正 [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

### v4（安全性強化）

- DryRun 実装
- try/catch/finally 導入
- 例外時ロールバック実装 [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

### v5（リファクタリング）

- 設定値を PSCustomObject 化
- フォルダ計算ロジックを関数化
- ロールバック順序を Index で保証
- 作成フォルダの重複管理修正
- ※ 仕様変更なし（純リファクタリング） [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

## テストコード構成

### 正常系テスト
- `test_split_mp4.ps1`
- ダミー mp4 自動生成
- DryRun → 本実行の段階実行
- フォルダ構成・ログ確認
- テスト後の自動クリーンアップ [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

### 異常系テスト
- `test_split_mp4_abnormal.ps1`
- 検証項目：
  - 既存ファイル衝突
  - 処理途中例外（強制削除）
  - 読み取り専用ファイル
- すべてにおいて：
  - 期待通り例外発生
  - ロールバック完全実行
  - 環境破壊なし [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

## 実行方法（本番）

```powershell
powershell -ExecutionPolicy Bypass -File split_mp4.ps1
```

DryRun：
```powershell
powershell -ExecutionPolicy Bypass -File split_mp4.ps1 -DryRun
```

## 想定ユースケース

- 外付けHDD（USB3）への大量動画整理
- 月次・案件単位でのファイルアーカイブ
- 人手作業の置き換え・事故防止 [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

## 注意事項

- mp4 以外は対象外
- 同名ファイルが既に存在する場合は処理中断
- 並列処理は未実装（安全性優先） [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

## 今後の拡張候補（未実装）

- 進捗率（%）表示
- 処理時間見積
- `-Confirm` オプション
- Pester による完全自動テスト [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

## まとめ

本スクリプトは  
「壊れない・戻せる・事前に検証できる」を  
最優先に設計されたファイル整理バッチである。 [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)

業務用途での使用を前提としており、  
テスト・ログ・ロールバックを含めた一連の運用が可能。 [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/25505934/2314c901-c9c4-49dc-9d4b-ed21de51670f/README_v3)