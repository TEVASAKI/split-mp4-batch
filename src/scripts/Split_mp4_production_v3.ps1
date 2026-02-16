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
    Add-Content -LiteralPath $LogFile -Value $line
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
$MoveHistory = @()
$CreatedDirs = @()

try {
    for ($i = 0; $i -lt $files.Count; $i++) {

        $file = $files[$i]
        $t    = Get-TargetInfo -Index $i -FileName $file.Name

        if (!(Test-Path -LiteralPath $t.TargetDir)) {
            Write-Log "MKDIR: $($t.FolderName)"
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $t.TargetDir | Out-Null
                if ($CreatedDirs -notcontains $t.TargetDir) {
                    $CreatedDirs += $t.TargetDir
                }
            }
        }

        if (Test-Path -LiteralPath $t.TargetPath) {
            Abort "既存ファイル衝突: $($t.TargetPath)"
        }

        Write-Log "MOVE: $($file.Name) -> $($t.FolderName)"

        $MoveHistory += [PSCustomObject]@{
            Index = $i
            From  = $file.FullName
            To    = $t.TargetPath
        }

        if (-not $DryRun) {
            Move-Item -LiteralPath $file.FullName -Destination $t.TargetPath
        }
    }

    Write-Log "正常終了"
}
catch {
    Write-Log "例外発生。ロールバック開始"

    foreach ($m in ($MoveHistory | Sort-Object Index -Descending)) {
        if (Test-Path -LiteralPath $m.To) {
            Move-Item -LiteralPath $m.To -Destination $m.From -Force
            Write-Log "ROLLBACK: $($m.To) -> $($m.From)"
        }
    }

    foreach ($dir in ($CreatedDirs | Sort-Object -Descending)) {
        if (Test-Path -LiteralPath $dir) {
            if (-not (Get-ChildItem -LiteralPath $dir -Force)) {
                Remove-Item -LiteralPath $dir
                Write-Log "RMDIR: $dir"
            }
        }
    }

    Write-Log "ロールバック完了"
    throw
}
finally {
    Write-Log "処理終了"
}