param(
    [string]$RootPath = ".",
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$pattern = 'https://ppl-ai-file-upload\.s3\.amazonaws\.com/\S+'
$extensions = @("*.md","*.txt","*.ps1","*.json","*.yml","*.yaml")

$files = Get-ChildItem -Path $RootPath -Recurse -Include $extensions -File

$modifiedFiles = @()

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match $pattern) {

        if ($DryRun) {
            Write-Host "MATCH FOUND in: $($file.FullName)"
            $matches = [regex]::Matches($content, $pattern)
            foreach ($m in $matches) {
                Write-Host "  -> $($m.Value)"
            }
        }
        else {
            $newContent = $content -replace $pattern, ""
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
            $modifiedFiles += $file.FullName
        }
    }
}

if ($DryRun) {
    Write-Host "`nDryRun complete. No files modified."
}
else {
    if ($modifiedFiles.Count -gt 0) {
        Write-Host "Modified files:"
        $modifiedFiles | ForEach-Object { Write-Host $_ }
    }
    else {
        Write-Host "No matching links found."
    }
}