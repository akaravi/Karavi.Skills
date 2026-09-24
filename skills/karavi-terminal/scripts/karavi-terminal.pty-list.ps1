param([Parameter(Mandatory = $true)][string]$RepoRoot)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'karavi-terminal.pty.psm1') -Force
Get-KaraviPtySessionList -RepoRoot $RepoRoot | ConvertTo-Json -Compress -Depth 6
