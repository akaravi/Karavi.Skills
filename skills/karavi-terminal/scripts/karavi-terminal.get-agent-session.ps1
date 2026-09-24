param([string]$RepoRoot=(Get-Location).Path)
$ErrorActionPreference='Stop'; Import-Module (Join-Path $PSScriptRoot 'karavi-terminal.agent-session.psm1') -Force; Sync-KaraviTerminalRegistry -RepoRoot $RepoRoot | ConvertTo-Json -Compress
