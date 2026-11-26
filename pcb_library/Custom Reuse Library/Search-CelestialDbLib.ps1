param(
    [Parameter(Mandatory = $true)]
    [string[]]$Search
)

$ErrorActionPreference = "Stop"

$dbLibPath = "D:\pcb_library\altium-library\Altium Database Library V2.DbLib"
if (-not (Test-Path -LiteralPath $dbLibPath)) {
    throw "DbLib not found: $dbLibPath"
}

$connectionLine = Get-Content -LiteralPath $dbLibPath |
    Where-Object { $_ -match '^\s*ConnectionString\s*=' } |
    Select-Object -First 1

if (-not $connectionLine) {
    throw "ConnectionString not found in: $dbLibPath"
}

$connectionString = ($connectionLine -replace '^\s*ConnectionString\s*=\s*', '').Trim()
$conn = New-Object -ComObject ADODB.Connection
$conn.ConnectionTimeout = 15
$conn.CommandTimeout = 45
$conn.Open($connectionString)

try {
    foreach ($term in $Search) {
        $safeTerm = $term.Replace("'", "''")
        $sql = @"
DECLARE @term nvarchar(100) = N'%$safeTerm%';
DECLARE @sql nvarchar(max) = N'';

SELECT @sql = @sql +
  CASE WHEN LEN(@sql) > 0 THEN N' UNION ALL ' ELSE N'' END +
  N'SELECT TOP 5 ''' + REPLACE(TABLE_NAME,'''','''''') + N''' AS TableName, ' +
  N'CAST([Part Number] AS nvarchar(255)) AS PartNumber, ' +
  N'CAST(COALESCE([Description], '''') AS nvarchar(500)) AS Description ' +
  N'FROM ' + QUOTENAME(TABLE_NAME) + N' WHERE ' +
  N'CAST(COALESCE([Part Number], '''') AS nvarchar(max)) LIKE @term OR ' +
  N'CAST(COALESCE([Description], '''') AS nvarchar(max)) LIKE @term'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME = 'Part Number';

EXEC sp_executesql @sql, N'@term nvarchar(100)', @term;
"@

        $rs = $conn.Execute($sql)
        $found = $false
        while (-not $rs.EOF) {
            $found = $true
            [PSCustomObject]@{
                Search      = $term
                Table       = [string]$rs.Fields.Item("TableName").Value
                PartNumber  = [string]$rs.Fields.Item("PartNumber").Value
                Description = (([string]$rs.Fields.Item("Description").Value) -replace '[\r\n]+', ' ')
            }
            $rs.MoveNext()
        }
        $rs.Close()

        if (-not $found) {
            [PSCustomObject]@{
                Search      = $term
                Table       = "NO MATCH"
                PartNumber  = ""
                Description = ""
            }
        }
    }
}
finally {
    $conn.Close()
}
