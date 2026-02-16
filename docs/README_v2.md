---

# MP4ファイル分割スクリプト

## README / 修正履歴

---

## 概要

本スクリプト `split_mp4_production.ps1` は、
実行フォルダ直下に存在する `.mp4` ファイルを **10ファイル単位**で
連番フォルダに自動分類する PowerShell スクリプトである。

* フォルダ名形式：`YYYYMMNN`（例：`20251001`）
* dry-run 対応
* 実行ログ自動出力
* 例外発生時の自動ロールバック対応
* 特殊文字を含むファイル名に完全対応

---

## 主な機能

* mp4 ファイルの自動分類（10件単位）
* 実行前検証（`-DryRun`）
* ログ出力（時刻付き）
* 処理途中の例外検知
* ロールバックによる原状復帰
* `[` `]` `*` `?` を含むファイル名の安全処理

---

## 実行方法（要約）

### dry-run（事前確認）

```powershell
.\split_mp4_production.ps1 -DryRun
```

### 本番実行

```powershell
.\split_mp4_production.ps1
```

---

## 出力構成例

```
.
├─ 20251001
│   ├─ movie01.mp4
│   └─ movie10.mp4
├─ 20251002
│   └─ movie11.mp4
└─ _log
    └─ split_mp4_YYYYMMDD_HHMMSS.log
```

---

## 修正履歴（差分記録）

### v1.0（初期版）

* mp4 ファイルを 10 件単位で分類
* フォルダ自動生成
* dry-run 機能実装
* ログ出力対応

#### 問題点

* ファイル名に `[` `]` を含む場合、以下のエラーが発生

```
Cannot retrieve the dynamic parameters for the cmdlet.
The specified wildcard character pattern is not valid
```

---

### v1.1（型安全修正）

#### 修正内容

* グループ計算ロジックを型安全に修正

**修正前**

```powershell
$groupIndex = [math]::Floor($index / $GroupSize) + 1
```

**修正後**

```powershell
$groupIndex = [int]($index / $GroupSize) + 1
```

#### 効果

* `"{1:D2}"` フォーマット例外を完全解消

---

### v1.2（ファイル名ワイルドカード問題修正・現行版）

#### 修正内容

PowerShell が `[` `]` をワイルドカードとして解釈する問題に対応。

**すべてのファイル操作を `-LiteralPath` に統一**

#### 修正前（問題あり）

```powershell
Move-Item $file.FullName $targetPath
```

#### 修正後（現行）

```powershell
Move-Item -LiteralPath $file.FullName -Destination $targetPath
```

#### ロールバック側も同様に修正

```powershell
Move-Item -LiteralPath $m.From -Destination $m.To -Force
```

#### 効果

* `[` `]` `*` `?` を含む実在ファイル名に完全対応
* PowerShell の動的パラメータ解釈エラーを根本解決
* 業務用ファイル（FC2 / 同人 / 自動生成名 等）で安全動作

---

## 技術的注意点

* `-Path` は使用しない
  → **必ず `-LiteralPath` を使用**
* PowerShell における仕様対応であり、回避策ではない
* dry-run を通さず本番実行しないこと

---

## 今後の拡張候補（未実装）

* CSV形式ログ出力
* 拡張子指定の外部化（mp4 / mkv / avi）
* GUI（右クリック実行）
* 再実行検知（既存フォルダスキップ）

---

## ステータス

* 状態：**運用可能（Production Ready）**
* 想定外入力への耐性：対応済み
* 既知の未解決不具合：なし

---

以上。
