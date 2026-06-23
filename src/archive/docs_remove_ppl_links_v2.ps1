param(
    [string]$RootPath = ".",
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# 不完全リンクパターン
$pattern = '\[ppl-ai-file-upload\.s3\.amazonaws\]\('

$extensions = @("*.md","*.txt")

$files = Get-ChildItem -Path $RootPath -Recurse -Include $extensions -File

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    if ($content -match $pattern) {

        if ($DryRun) {
            Write-Host "MATCH FOUND in: $($file.FullName)"
            [regex]::Matches($content, $pattern) |
                ForEach-Object { Write-Host "  -> $($_.Value)" }
        }
        else {
            $newContent = $content -replace $pattern, ""
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
            Write-Host "Modified: $($file.FullName)"
        }
    }
}

if ($DryRun) {
    Write-Host "`nDryRun complete. No files modified."
}