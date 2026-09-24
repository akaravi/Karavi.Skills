param([Parameter(Mandatory = $true)][string]$RepoRoot, [Parameter(Mandatory = $true)][string]$SessionId, [int]$TimeoutMs = 1000)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'karavi-terminal.pty.psm1') -Force
Wait-KaraviPtySession -RepoRoot $RepoRoot -SessionId $SessionId -TimeoutMs $TimeoutMs | ConvertTo-Json -Compress -Depth 6
