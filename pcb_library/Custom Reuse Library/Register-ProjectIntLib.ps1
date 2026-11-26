param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $true)]
    [string]$IntLibPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $IntLibPath)) {
    throw "IntLib file not found: $IntLibPath"
}

if ([IO.Path]::GetExtension($IntLibPath) -ne ".IntLib") {
    throw "Expected a .IntLib file: $IntLibPath"
}

$root = Split-Path -Parent $PSCommandPath
$projectRoot = Join-Path $root "Project IntLibs"
$safeProjectName = ($ProjectName -replace '[\\/:*?"<>|]', '_').Trim()

if ([string]::IsNullOrWhiteSpace($safeProjectName)) {
    throw "ProjectName cannot be empty."
}

$destDir = Join-Path $projectRoot $safeProjectName
New-Item -ItemType Directory -Force -Path $destDir | Out-Null

$destFile = Join-Path $destDir "$safeProjectName.IntLib"
Copy-Item -LiteralPath $IntLibPath -Destination $destFile -Force

$indexPath = Join-Path $projectRoot "INDEX.md"
if (-not (Test-Path -LiteralPath $indexPath)) {
    "# Project Integrated Libraries`r`n" | Set-Content -LiteralPath $indexPath -Encoding UTF8
}

$relativePath = "Project IntLibs/$safeProjectName/$safeProjectName.IntLib"
$date = Get-Date -Format "yyyy-MM-dd HH:mm"
$entry = "- $safeProjectName | $relativePath | updated $date"

$existing = Get-Content -LiteralPath $indexPath -ErrorAction SilentlyContinue
$filtered = $existing | Where-Object { $_ -notmatch "^- $([regex]::Escape($safeProjectName)) \|" }
($filtered + $entry) | Set-Content -LiteralPath $indexPath -Encoding UTF8

Write-Output "Registered: $destFile"
