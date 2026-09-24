param([Parameter(Mandatory = $true)][string]$RepoRoot, [Parameter(Mandatory = $true)][string]$SessionId, [Parameter(Mandatory = $true)][string]$Keys)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'karavi-terminal.pty.psm1') -Force
Send-KaraviPtyKeys -RepoRoot $RepoRoot -SessionId $SessionId -Keys $Keys | ConvertTo-Json -Compress -Depth 6
