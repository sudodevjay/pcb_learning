param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string[]]$SymbolPathContains
)

$ErrorActionPreference = "Stop"

$root = "D:\pcb_library\altium-library"
$source = Join-Path $root "Celestial Library.LibPkg"
$output = Join-Path $root "$Name.LibPkg"

if (-not (Test-Path -LiteralPath $source)) {
    throw "Source LibPkg not found: $source"
}

$lines = Get-Content -LiteralPath $source
$header = New-Object System.Collections.Generic.List[string]

for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\[Document\d+\]$') {
        break
    }
    $header.Add($lines[$i])
}

$sections = New-Object System.Collections.Generic.List[object]
$current = $null

foreach ($line in $lines) {
    if ($line -match '^\[Document\d+\]$') {
        if ($null -ne $current) {
            $sections.Add($current)
        }
        $current = New-Object System.Collections.Generic.List[string]
    }

    if ($null -ne $current) {
        $current.Add($line)
    }
}

if ($null -ne $current) {
    $sections.Add($current)
}

$selectedSymbols = @()
$allFootprints = @()

foreach ($section in $sections) {
    $pathLine = $section | Where-Object { $_ -match '^DocumentPath=' } | Select-Object -First 1
    if (-not $pathLine) {
        continue
    }

    $docPath = $pathLine -replace '^DocumentPath=', ''

    if ($docPath -like 'footprints\*.PcbLib' -or $docPath -like 'footprints\*.PCBLIB' -or $docPath -like 'footprints\*') {
        if ($docPath -match '\.PcbLib$|\.PCBLIB$') {
            $allFootprints += ,$section
        }
        continue
    }

    foreach ($needle in $SymbolPathContains) {
        if ($docPath -like "*$needle*") {
            $selectedSymbols += ,$section
            break
        }
    }
}

$outLines = New-Object System.Collections.Generic.List[string]
foreach ($line in $header) {
    $outLines.Add($line)
}

$docNum = 1
foreach ($section in ($selectedSymbols + $allFootprints)) {
    foreach ($line in $section) {
        if ($line -match '^\[Document\d+\]$') {
            $outLines.Add("[Document$docNum]")
        }
        else {
            $outLines.Add($line)
        }
    }
    $docNum++
}

$outLines | Set-Content -LiteralPath $output -Encoding ASCII

[PSCustomObject]@{
    Created = $output
    SymbolDocuments = $selectedSymbols.Count
    FootprintDocuments = $allFootprints.Count
    TotalDocuments = $selectedSymbols.Count + $allFootprints.Count
} | Format-List
