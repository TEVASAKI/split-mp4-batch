# ==============================
# テスト設定
# ==============================
$TestRoot = Join-Path $PSScriptRoot "_test_env"
$DummyCount = 27      # テスト用 mp4 数
$BaseName = "202510"
$GroupSize = 10

Write-Host "=== テスト環境作成 ==="

# クリーンアップ
if (Test-Path -LiteralPath $TestRoot) {
    Remove-Item -LiteralPath $TestRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $TestRoot | Out-Null

# テスト対象スクリプトをテスト環境にコピー（Split_mp4.ps1 は $PSScriptRoot をルートにするため）
$ScriptUnderTest = Join-Path $PSScriptRoot "..\scripts\Split_mp4.ps1"
if (-not (Test-Path -LiteralPath $ScriptUnderTest)) { throw "テスト対象が見つかりません: $ScriptUnderTest" }
Copy-Item -LiteralPath $ScriptUnderTest -Destination (Join-Path $TestRoot "Split_mp4.ps1") -Force

$元のディレクトリ = Get-Location

try {
    Set-Location $TestRoot

    # ==============================
    # ダミー mp4 作成
    # ==============================
    Write-Host "ダミーmp4作成中..."

    1..$DummyCount | ForEach-Object {
        $name = ("dummy_{0:D2}.mp4" -f $_)
        New-Item -ItemType File -Path $name | Out-Null
    }

    Get-ChildItem -Filter *.mp4 | Format-Table Name

    Read-Host "Enterで DryRun テスト開始"

    # ==============================
    # 本番処理（DryRun）
    # ==============================
    .\Split_mp4.ps1 -DryRun

    Read-Host "Enterで 本実行テスト開始"

    # ==============================
    # 本番処理（本実行）
    # ==============================
    .\Split_mp4.ps1

    # ==============================
    # 結果確認
    # ==============================
    Write-Host "`n=== フォルダ構成確認 ==="
    Get-ChildItem -Directory | Format-Table Name

    Write-Host "`n=== 各フォルダ内 ==="
    Get-ChildItem -Directory | ForEach-Object {
        Write-Host "`n[$($_.Name)]"
        Get-ChildItem -LiteralPath $_.FullName | Format-Table Name
    }

    # ==============================
    # ログ確認
    # ==============================
    Write-Host "`n=== ログ一覧 ==="
    Get-ChildItem -LiteralPath "_log" | Format-Table Name

    Read-Host "Enterでテスト環境削除（確認）"

    # ==============================
    # クリーンアップ
    # ==============================
    Set-Location -LiteralPath $元のディレクトリ
    Remove-Item -LiteralPath $TestRoot -Recurse -Force

    Write-Host "テスト完了。"
}
finally {
    # 異常終了時もカレントディレクトリを確実に戻す
    Set-Location -LiteralPath $元のディレクトリ
}
