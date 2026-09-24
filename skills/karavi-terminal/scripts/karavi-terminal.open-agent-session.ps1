param([string]$RepoRoot=(Get-Location).Path,[string]$Shell='pwsh.exe')
$ErrorActionPreference='Stop'; Import-Module (Join-Path $PSScriptRoot 'karavi-terminal.agent-session.psm1') -Force; New-KaraviTerminalSession -RepoRoot $RepoRoot -Shell $Shell | ConvertTo-Json -Compress
