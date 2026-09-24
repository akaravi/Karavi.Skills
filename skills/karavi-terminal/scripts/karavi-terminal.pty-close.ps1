param([Parameter(Mandatory = $true)][string]$RepoRoot, [Parameter(Mandatory = $true)][string]$SessionId)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'karavi-terminal.pty.psm1') -Force
Close-KaraviPtySession -RepoRoot $RepoRoot -SessionId $SessionId | ConvertTo-Json -Compress -Depth 6
