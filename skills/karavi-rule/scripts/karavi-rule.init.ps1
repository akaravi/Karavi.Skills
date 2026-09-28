[CmdletBinding()]
param(
    [ValidateSet('fa', 'en')]
    [string]$Language = 'en',
    [string]$SourceRoot = 'D:\SourceKaravi\Agents.Project',
    [switch]$NoBackup
)

$ErrorActionPreference = 'Stop'
$syncScript = Join-Path $SourceRoot 'Agent.Global.Rule\sync-global-rules.ps1'

if (!(Test-Path -LiteralPath $syncScript -PathType Leaf)) {
    throw "Canonical sync script was not found: $syncScript"
}

$syncParameters = @{ Language = $Language }
if (!$NoBackup) { $syncParameters['BackupExisting'] = $true }

Write-Output "Initializing Karavi global rules with language '$Language'."
Write-Output "Delegating to canonical sync script: $syncScript"
& $syncScript @syncParameters

Write-Output 'Karavi global-rule initialization completed after destination verification.'
