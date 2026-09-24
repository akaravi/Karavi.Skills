# karavi-terminal-session.open-interactive.ps1
# Opens a visible PowerShell window for interactive SSH/login; writes session JSON.
# Exit: 0 ok, 1 bad args, 2 Start-Process failed
[CmdletBinding()]
param(
    [string]$RepoRoot = (Get-Location).Path,
    [string]$HostAlias = "remote",
    [string]$RemoteHost,
    [int]$Port = 22,
    [string]$User,
    [string]$SshExtraArgs = "",
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'

if (-not $RemoteHost -or -not $User) {
    Write-Error "RemoteHost and User are required."
    exit 1
}

$cursorDir = Join-Path $RepoRoot '.cursor'
$metaPath = Join-Path $cursorDir ("{0}-terminal-session.json" -f $HostAlias)

$sshLine = "ssh -p $Port $User@$RemoteHost"
if ($SshExtraArgs) { $sshLine = "$sshLine $SshExtraArgs" }

$inner = @"
Set-Location '$RepoRoot'
Write-Host '=== karavi-terminal-session: interactive login ===' -ForegroundColor Cyan
Write-Host ('PowerShell PID: ' + `$PID) -ForegroundColor Yellow
Write-Host 'Agent uses Shell tool separately; type password/MFA here only.' -ForegroundColor DarkGray
$sshLine
"@

if ($WhatIf) {
    Write-Host "[WhatIf] Would open powershell.exe and write $metaPath"
    Write-Host $sshLine
    exit 0
}

$p = Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoExit', '-NoProfile', '-Command', $inner) -PassThru -WindowStyle Normal
if (-not $p) { exit 2 }

New-Item -ItemType Directory -Force -Path $cursorDir | Out-Null
$meta = @{
    powershellPid = $p.Id
    host          = $RemoteHost
    port          = $Port
    user          = $User
    openedAt      = (Get-Date -Format 'o')
    note          = 'Interactive login only. Agent cannot type into this PID; use agent Shell or paste approved commands.'
    skill         = 'karavi-terminal-session'
}
$meta | ConvertTo-Json | Set-Content -Path $metaPath -Encoding UTF8
Write-Host "Opened PowerShell PID=$($p.Id); metadata: $metaPath"
exit 0
