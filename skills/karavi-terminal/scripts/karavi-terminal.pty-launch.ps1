param(
    [string]$RepoRoot = (Get-Location).Path,
    [string]$Command = 'powershell.exe',
    [string[]]$ArgumentList = @('-NoLogo', '-NoProfile', '-NoExit', '-Command', 'Remove-Module PSReadLine -ErrorAction SilentlyContinue'),
    [string]$WorkingDirectory,
    [int]$Columns = 120,
    [int]$Rows = 30
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'karavi-terminal.pty.psm1') -Force
Start-KaraviPtySession -RepoRoot $RepoRoot -Command $Command -ArgumentList $ArgumentList -WorkingDirectory $WorkingDirectory -Columns $Columns -Rows $Rows | ConvertTo-Json -Compress -Depth 6
