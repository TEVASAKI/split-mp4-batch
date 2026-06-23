param(
    [switch]$DryRun
)

# ==============================
# 設定
# ==============================
$BaseName   = "202601"
$GroupSize  = 10
$RootDir    = $PSScriptRoot
$LogDir     = Join-Path $RootDir "_log"
$TimeStamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile    = Join-Path $LogDir "split_mp4_$TimeStamp.log"

# ==============================
# 初期化
# ==============================
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

New-Item -ItemType File -Path $LogFile | Out-Null

function Log($msg) {
    $line = "[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"), $msg
    Write-Host $line
    Add-Content -LiteralPath $LogFile -Value $line -Encoding UTF8
}

function Abort($msg) {
    Log "ERROR: $msg"
    throw $msg
}

# ==============================
# 事前チェック
# ==============================
$files = Get-ChildItem -LiteralPath $RootDir -Filter *.mp4 | Sort-Object Name

if ($files.Count -eq 0) {
    Abort "mp4ファイルが見つかりません。"
}

Log "開始: mp4=$($files.Count) / DryRun=$DryRun"

# ==============================
# ロールバック用記録
# ==============================
$MoveHistory = @()

try {
    $index = 0

    foreach ($file in $files) {

        # 型安全なグループ計算
        $groupIndex = [int]($index / $GroupSize) + 1
        $folderName = "{0}{1:D2}" -f $BaseName, $groupIndex
        $targetDir  = Join-Path $RootDir $folderName
        $targetPath = Join-Path $targetDir $file.Name

        if (!(Test-Path -LiteralPath $targetDir)) {
            Log "MKDIR: $folderName"
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $targetDir | Out-Null
            }
        }

        Log "MOVE: $($file.Name) -> $folderName"

        if (-not $DryRun) {
            Move-Item `
                -LiteralPath $file.FullName `
                -Destination  $targetPath `
                -ErrorAction Stop

            $MoveHistory += [PSCustomObject]@{
                Index = $index
                From  = $targetPath
                To    = $file.FullName
            }
        }

        $index++
    }

    Log "正常終了"

}
catch {
    Log "例外発生。ロールバック開始"

    foreach ($m in ($MoveHistory | Sort-Object Index -Descending)) {
        if (Test-Path -LiteralPath $m.From) {
            # 復元先に同名ファイルがある場合は上書きせず記録する
            if (Test-Path -LiteralPath $m.To) {
                Log "ロールバック先に同名ファイルが存在するため、復元を中断しました: $($m.To)"
            }
            else {
                Move-Item -LiteralPath $m.From -Destination $m.To -ErrorAction Stop
                Log "ROLLBACK: $($m.From) -> $($m.To)"
            }
        }
    }

    Log "ロールバック完了"
    throw
}
finally {
    Log "処理終了"
}
