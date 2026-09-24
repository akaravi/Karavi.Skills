# karavi-terminal.agent-sanity.ps1
# Read-only local session report for agent Shell (no remote).
$ErrorActionPreference = 'Continue'
$shell = (Get-Process -Id $PID).Path
$ver = $PSVersionTable.PSVersion.ToString()
$enc = [Console]::OutputEncoding.WebName
$cwd = (Get-Location).Path
Write-Output "SHELL=$shell"
Write-Output "PS_VERSION=$ver"
Write-Output "CWD=$cwd"
Write-Output "ENCODING=$enc"
Write-Output "LASTEXITCODE=$LASTEXITCODE"
