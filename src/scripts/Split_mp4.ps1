param(
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ==============================
# 設定（型安全）
# ==============================
$Config = [PSCustomObject]@{
    BaseName  = "202510"
    GroupSize = 10
    RootDir   = $PSScriptRoot
    LogDir    = Join-Path $PSScriptRoot "_log"
}

$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile   = Join-Path $Config.LogDir "split_mp4_$TimeStamp.log"

# ==============================
# ログ
# ==============================
function Write-Log {
    param([string]$Message)

    $line = "[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"), $Message
    Write-Host $line
    Add-Content -LiteralPath $LogFile -Value $line -Encoding UTF8
}

function Abort {
    param([string]$Message)
    Write-Log "ERROR: $Message"
    throw $Message
}

# ==============================
# 初期化
# ==============================
if (!(Test-Path -LiteralPath $Config.LogDir)) {
    New-Item -ItemType Directory -Path $Config.LogDir | Out-Null
}
New-Item -ItemType File -Path $LogFile -Force | Out-Null

# ==============================
# ヘルパー
# ==============================
function Get-TargetInfo {
    param(
        [int]$Index,
        [string]$FileName
    )

    $groupIndex = [int]($Index / $Config.GroupSize) + 1
    $folderName = "{0}{1:D2}" -f $Config.BaseName, $groupIndex
    $targetDir  = Join-Path $Config.RootDir $folderName
    $targetPath = Join-Path $targetDir $FileName

    return [PSCustomObject]@{
        FolderName = $folderName
        TargetDir  = $targetDir
        TargetPath = $targetPath
    }
}

# ==============================
# 事前チェック
# ==============================
$files = Get-ChildItem -LiteralPath $Config.RootDir -Filter *.mp4 | Sort-Object Name
if ($files.Count -eq 0) {
    Abort "mp4ファイルが見つかりません。"
}

Write-Log "開始: mp4=$($files.Count) / GroupSize=$($Config.GroupSize) / DryRun=$DryRun"

# ==============================
# 実行
# ==============================
$MoveHistory  = @()
$CreatedDirs  = @()
# 正常完了フラグ（false のまま finally に入った場合はロールバックを試行する）
$script:正常完了 = $false

try {
    for ($i = 0; $i -lt $files.Count; $i++) {

        $file = $files[$i]
        $t    = Get-TargetInfo -Index $i -FileName $file.Name

        if (!(Test-Path -LiteralPath $t.TargetDir)) {
            Write-Log "MKDIR: $($t.FolderName)"
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $t.TargetDir -ErrorAction Stop | Out-Null
                if ($CreatedDirs -notcontains $t.TargetDir) {
                    $CreatedDirs += $t.TargetDir
                }
            }
        }

        if (Test-Path -LiteralPath $t.TargetPath) {
            Abort "既存ファイル衝突: $($t.TargetPath)"
        }

        # Dry-run 時はログに識別子を付けて、実移動は行わない
        if ($DryRun) {
            Write-Log "[DRY-RUN] MOVE: $($file.Name) -> $($t.FolderName)"
        }
        else {
            Write-Log "MOVE: $($file.Name) -> $($t.FolderName)"

            Move-Item -LiteralPath $file.FullName -Destination $t.TargetPath -ErrorAction Stop

            # 移動成功後のみ履歴へ記録する
            $MoveHistory += [PSCustomObject]@{
                Index = $i
                From  = $file.FullName
                To    = $t.TargetPath
            }
        }
    }

    Write-Log "正常終了"
    # すべての処理が成功した場合のみフラグを立てる
    $script:正常完了 = $true
}
catch {
    Write-Log "エラーが発生しました: $($_.Exception.Message)"
    throw
}
finally {
    # finallyが実行される終了経路ではロールバックを試行するが、
    # プロセス強制終了、OS停止、電源断などではロールバックを保証できない。
    if (-not $script:正常完了 -and -not $DryRun -and ($MoveHistory.Count -gt 0 -or $CreatedDirs.Count -gt 0)) {
        Write-Log "ロールバック開始"

        foreach ($m in ($MoveHistory | Sort-Object Index -Descending)) {
            if (Test-Path -LiteralPath $m.To) {
                # 復元先に同名ファイルがある場合は上書きせず記録する
                if (Test-Path -LiteralPath $m.From) {
                    Write-Log "ロールバック先に同名ファイルが存在するため、復元を中断しました: $($m.From)"
                    continue
                }

                try {
                    Move-Item -LiteralPath $m.To -Destination $m.From -ErrorAction Stop
                    Write-Log "ROLLBACK: $($m.To) -> $($m.From)"
                }
                catch {
                    Write-Log "ロールバックに失敗しました。手動で状態を確認してください: $($m.To)"
                }
            }
        }

        foreach ($dir in ($CreatedDirs | Sort-Object -Descending)) {
            if (Test-Path -LiteralPath $dir) {
                $残存項目 = @(Get-ChildItem -LiteralPath $dir -Force)

                if ($残存項目.Count -eq 0) {
                    try {
                        Remove-Item -LiteralPath $dir -ErrorAction Stop
                        Write-Log "RMDIR: $dir"
                    }
                    catch {
                        Write-Log "空フォルダの削除に失敗しました: $dir"
                    }
                }
            }
        }

        Write-Log "ロールバック処理終了"
    }

    Write-Log "処理終了"
}
