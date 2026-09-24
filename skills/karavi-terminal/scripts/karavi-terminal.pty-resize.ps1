param([Parameter(Mandatory = $true)][string]$RepoRoot, [Parameter(Mandatory = $true)][string]$SessionId, [Parameter(Mandatory = $true)][int]$Columns, [Parameter(Mandatory = $true)][int]$Rows)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'karavi-terminal.pty.psm1') -Force
Resize-KaraviPtySession -RepoRoot $RepoRoot -SessionId $SessionId -Columns $Columns -Rows $Rows | ConvertTo-Json -Compress -Depth 6
