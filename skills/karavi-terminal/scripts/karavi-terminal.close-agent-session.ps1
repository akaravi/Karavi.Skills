param([Parameter(Mandatory)][string]$SessionId,[string]$RepoRoot=(Get-Location).Path)
$ErrorActionPreference='Stop'; Import-Module (Join-Path $PSScriptRoot 'karavi-terminal.agent-session.psm1') -Force; Close-KaraviTerminalSession -RepoRoot $RepoRoot -SessionId $SessionId | ConvertTo-Json -Compress
