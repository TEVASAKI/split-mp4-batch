# ==============================
# 仮本番設定（ダミーデータ用）
# ==============================
$BaseName   = "202510"
$GroupSize  = 10
$WorkRoot   = Join-Path $PSScriptRoot "TEST_WORK"   # ← ダミー生成済みフォルダ
$LogFile    = Join-Path $WorkRoot "provisional_run.log"
$DryRun     = $false   # ★ 仮本番：実移動する

function Abort($msg) {
    Write-Host "ERROR: $msg" -ForegroundColor Red
    exit 1
}

# ==============================
# 前提チェック
# ==============================
if (!(Test-Path $WorkRoot)) {
    Abort "TEST_WORK が存在しません。テストコードを先に実行してください。"
}

$mp4Files = Get-ChildItem $WorkRoot -Filter *.mp4
if ($mp4Files.Count -eq 0) {
    Abort "mp4 ファイルが見つかりません。"
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

    # ★ 型安全なグループ計算
    $groupIndex = [int]($index / $GroupSize) + 1
    $folderName = "{0}{1:D2}" -f $BaseName, $groupIndex
    $targetDir  = Join-Path $WorkRoot $folderName
    $targetPath = Join-Path $targetDir $file.Name

    if (!(Test-Path $targetDir)) {
        Write-Host "[作成] フォルダ: $folderName"
        New-Item -ItemType Directory -Path $targetDir | Out-Null
    }

    Write-Host "[MOVE] $($file.Name) -> $folderName"
    Add-Content -Path $LogFile -Value "[MOVE] $($file.Name) -> $folderName"

    if (-not $DryRun) {
        Move-Item $file.FullName $targetPath -Force
    }

    $index++
}

# ==============================
# 完了
# ==============================
Write-Host ""
Write-Host "仮本番処理完了" -ForegroundColor Green
Write-Host "作成フォルダ一覧:"
Get-ChildItem $WorkRoot -Directory | Select-Object Name

Write-Host ""
Write-Host "ログ出力先:"
Write-Host $LogFile
