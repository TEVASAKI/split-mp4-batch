# ==============================
# 共通設定
# ==============================
$TestRoot = Join-Path $PSScriptRoot "_test_env_abnormal"
$BaseName = "202510"
$GroupSize = 10

function Reset-TestEnv {
    if (Test-Path $TestRoot) {
        Remove-Item -LiteralPath $TestRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $TestRoot | Out-Null
    Set-Location $TestRoot
}

function Create-DummyMp4($count) {
    1..$count | ForEach-Object {
        New-Item -ItemType File -Path ("dummy_{0:D2}.mp4" -f $_) | Out-Null
    }
}

# ==============================
# 異常系① 既存ファイル衝突
# ==============================
Write-Host "`n=== 異常① 既存ファイル衝突 ==="
Reset-TestEnv
Create-DummyMp4 5

# 衝突用フォルダ・ファイル作成
New-Item -ItemType Directory -Path "20251001" | Out-Null
New-Item -ItemType File -Path "20251001\dummy_01.mp4" | Out-Null

try {
    .\split_mp4.ps1
}
catch {
    Write-Host "✔ 期待通り Abort 発生"
}

Read-Host "Enterで次へ"

# ==============================
# 異常系② 途中例外（強制停止）
# ==============================
Write-Host "`n=== 異常② 処理途中で例外 ==="
Reset-TestEnv
Create-DummyMp4 15

# 途中で削除して Move-Item を失敗させる
$job = Start-Job {
    Start-Sleep -Seconds 1
    Remove-Item dummy_08.mp4 -Force
}

try {
    .\split_mp4.ps1
}
catch {
    Write-Host "✔ 例外発生を確認"
}

Receive-Job $job | Out-Null
Remove-Job $job

# ロールバック確認
Write-Host "残存mp4:"
Get-ChildItem *.mp4 | Format-Table Name

Read-Host "Enterで次へ"

# ==============================
# 異常系③ 読み取り専用ファイル
# ==============================
Write-Host "`n=== 異常③ 読み取り専用 ==="
Reset-TestEnv
Create-DummyMp4 10

# 1つをReadOnlyにする
$file = Get-Item dummy_03.mp4
$file.Attributes = 'ReadOnly'

try {
    .\split_mp4.ps1
}
catch {
    Write-Host "✔ 読み取り専用による例外発生"
}

# ロールバック確認
Write-Host "残存mp4:"
Get-ChildItem *.mp4 | Format-Table Name

Read-Host "Enterでテスト環境削除"

# ==============================
# クリーンアップ
# ==============================
Set-Location $PSScriptRoot
Remove-Item -LiteralPath $TestRoot -Recurse -Force
Write-Host "異常系テスト完了"