param([Parameter(Mandatory = $true)][string]$RepoRoot)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'karavi-terminal.pty.psm1') -Force
Stop-KaraviPtyHost -RepoRoot $RepoRoot | ConvertTo-Json -Compress -Depth 4
