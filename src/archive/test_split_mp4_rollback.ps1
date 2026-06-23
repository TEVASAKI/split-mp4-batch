# ==============================
# 設定
# ==============================
$BaseName   = "202601"
$GroupSize  = 10
$WorkRoot   = Join-Path $PSScriptRoot "TEST_WORK"
$LogFile    = Join-Path $WorkRoot "test_dryrun.log"
$DryRun     = $true   # テスト専用（常に true）

function Pause($msg) {
    Write-Host ""
    Write-Host "=== $msg ===" -ForegroundColor Cyan
    Read-Host "Enterキーで次へ"
}

# ==============================
# 初期化
# ==============================
Clear-Host
Write-Host "MP4 分割処理 テスト（dry-run）開始" -ForegroundColor Green

Pause "① テスト環境初期化"

if (Test-Path $WorkRoot) {
    Remove-Item $WorkRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $WorkRoot | Out-Null
New-Item -ItemType File -Path $LogFile | Out-Null

# ==============================
# ダミーMP4生成
# ==============================
Pause "② ダミーMP4生成（23ファイル）"

1..23 | ForEach-Object {
    $name = "dummy_{0:D2}.mp4" -f $_
    New-Item -ItemType File -Path (Join-Path $WorkRoot $name) | Out-Null
}

Write-Host "生成済みファイル一覧:"
Get-ChildItem $WorkRoot -Filter *.mp4 | Select-Object Name

Pause "③ dry-run 分割テスト開始"

# ==============================
# メイン処理（dry-run）
# ==============================
$files = Get-ChildItem $WorkRoot -Filter *.mp4 | Sort-Object Name
$index = 0

foreach ($file in $files) {

    # ★ 型安全なグループ計算（int保証）
    $groupIndex = [int]($index / $GroupSize) + 1

    # ★ ゼロパディング安全生成
    $folderName = "{0}{1:D2}" -f $BaseName, $groupIndex
    $targetDir  = Join-Path $WorkRoot $folderName
    $targetPath = Join-Path $targetDir $file.Name

    if (!(Test-Path $targetDir)) {
        Write-Host "[作成予定] フォルダ: $folderName" -ForegroundColor Yellow
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $targetDir | Out-Null
        }
    }

    $logLine = "[DRY-RUN] {0} -> {1}" -f $file.Name, $folderName
    Write-Host $logLine
    Add-Content -Path $LogFile -Value $logLine

    if (-not $DryRun) {
        Move-Item $file.FullName $targetPath
    }

    $index++
    Read-Host "Enterで次のファイルへ"
}

# ==============================
# 結果確認
# ==============================
Pause "④ テスト結果確認"

Write-Host "`n--- dry-run 完了 ---" -ForegroundColor Green
Write-Host "実ファイル移動: なし"
Write-Host "ログ出力先: $LogFile"
Write-Host "`n--- ログ内容 ---"
Get-Content $LogFile

Pause "⑤ テスト終了"
