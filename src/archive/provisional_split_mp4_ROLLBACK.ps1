# ==================================================
# 仮本番用スクリプト（ロールバック機能なし）
# ==================================================
# このスクリプトは仮本番確認用の簡易版です。
# 完全なロールバック機能は実装していません。
# 現行の本番版は Split_mp4_production_v3.ps1 です。
# 実運用には原則として v3 を使用してください。
# ==================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ==============================
# 仮本番設定（ダミーデータ用）
# ==============================
$BaseName  = "202510"
$GroupSize = 10
$WorkRoot  = Join-Path $PSScriptRoot "TEST_WORK"   # ← ダミー生成済みフォルダ
$LogFile   = Join-Path $WorkRoot "provisional_run.log"
$DryRun    = $false   # ★ 仮本番：実移動する

try {
    # ==============================
    # 前提チェック
    # ==============================
    if (!(Test-Path -LiteralPath $WorkRoot)) {
        throw "TEST_WORK が存在しません。テストコードを先に実行してください。"
    }

    $mp4Files = Get-ChildItem -LiteralPath $WorkRoot -Filter *.mp4
    if ($mp4Files.Count -eq 0) {
        throw "mp4 ファイルが見つかりません。"
    }

    New-Item -ItemType File -Path $LogFile -Force | Out-Null

    Write-Host "仮本番処理開始（実移動あり）" -ForegroundColor Green
    Write-Host "対象フォルダ: $WorkRoot"
    Write-Host "対象ファイル数: $($mp4Files.Count)"
    Write-Host ""

    # ==============================
    # メイン処理
    # ==============================
    $files = $mp4Files | Sort-Object Name
    $index = 0

    foreach ($file in $files) {

        # グループ計算（型安全）
        $groupIndex = [int]($index / $GroupSize) + 1
        $folderName = "{0}{1:D2}" -f $BaseName, $groupIndex
        $targetDir  = Join-Path $WorkRoot $folderName
        $targetPath = Join-Path $targetDir $file.Name

        if (!(Test-Path -LiteralPath $targetDir)) {
            Write-Host "[作成] フォルダ: $folderName"
            New-Item -ItemType Directory -Path $targetDir -ErrorAction Stop | Out-Null
        }

        # 移動先に同名ファイルがある場合は中断する
        if (Test-Path -LiteralPath $targetPath) {
            throw "移動先に同名ファイルが存在するため、処理を中断します: $targetPath"
        }

        Write-Host "[MOVE] $($file.Name) -> $folderName"
        Add-Content -LiteralPath $LogFile -Value "[MOVE] $($file.Name) -> $folderName" -Encoding UTF8

        if (-not $DryRun) {
            Move-Item -LiteralPath $file.FullName -Destination $targetPath -ErrorAction Stop
        }

        $index++
    }

    # ==============================
    # 完了
    # ==============================
    Write-Host ""
    Write-Host "仮本番処理完了" -ForegroundColor Green
    Write-Host "作成フォルダ一覧:"
    Get-ChildItem -LiteralPath $WorkRoot -Directory | Select-Object Name

    Write-Host ""
    Write-Host "ログ出力先:"
    Write-Host $LogFile
}
catch {
    Write-Host "エラーが発生しました。手動で状態を確認してください。" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
finally {
    Write-Host "処理終了"
}
