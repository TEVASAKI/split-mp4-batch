# ==========================================
# MP4 分割処理 ステップ実行テスト版
# ==========================================

$baseName  = "202601"
$groupSize = 10
$testDir   = "_mp4_test_env"
$logFile   = "move_log_test.txt"

function Pause-Step($message) {
    Write-Host ""
    Write-Host "=== $message ===" -ForegroundColor Cyan
    Read-Host "Enterキーを押すと次へ進みます"
}

Clear-Host
Write-Host "MP4 分割処理 テストモード開始" -ForegroundColor Green

Pause-Step "① テスト環境を初期化します"

# --- テスト環境作成 ---
if (Test-Path $testDir) {
    Remove-Item $testDir -Recurse -Force
}
New-Item -ItemType Directory -Path $testDir | Out-Null
Set-Location $testDir

Pause-Step "② ダミーMP4を作成します（37個）"

# --- ダミーデータ生成 ---
1..37 | ForEach-Object {
    New-Item -ItemType File -Name ("video_{0:00}.mp4" -f $_) | Out-Null
}

Write-Host "作成されたMP4一覧:"
Get-ChildItem *.mp4 | Select-Object Name
Pause-Step "③ ログファイルを初期化します"

# --- ログ初期化 ---
"========== TEST START $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ==========" |
    Out-File $logFile -Encoding UTF8

Pause-Step "④ 分割処理を開始します（10件ずつ）"

# --- 本処理 ---
$files = Get-ChildItem *.mp4 | Sort-Object Name
$counter = 0
$folderIndex = 1

foreach ($file in $files) {

    if ($counter % $groupSize -eq 0) {
        $suffix = $folderIndex.ToString("00")
        $folderName = "$baseName$suffix"

        if (-not (Test-Path $folderName)) {
            New-Item -ItemType Directory -Path $folderName | Out-Null
            "[CREATE] $folderName" | Add-Content $logFile
            Write-Host "フォルダ作成: $folderName" -ForegroundColor Yellow
        }

        $folderIndex++
        Pause-Step "次のグループへ進みます"
    }

    $dest = Join-Path $folderName $file.Name
    Move-Item $file.FullName $dest

    $logLine = "[MOVE] $($file.Name) -> $folderName ($(Get-Date -Format 'HH:mm:ss'))"
    $logLine | Add-Content $logFile
    Write-Host $logLine

    $counter++
}

Pause-Step "⑤ 処理完了。結果を確認します"

# --- 結果確認 ---
Write-Host "フォルダ別ファイル数:"
Get-ChildItem -Directory | ForEach-Object {
    "{0} : {1} files" -f $_.Name, (Get-ChildItem $_.FullName | Measure-Object).Count
}

Pause-Step "⑥ ログ内容を表示します"

# --- ログ表示 ---
Get-Content $logFile

"========== TEST END $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ==========" |
    Add-Content $logFile

Write-Host ""
Write-Host "テスト完了。ログは $testDir\$logFile に保存されています。" -ForegroundColor Green
