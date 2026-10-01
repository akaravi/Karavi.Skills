#Requires -Version 5.1
<#
.SYNOPSIS
  Section 1 of the karavi-folder skill: create the standard karavi/ skeleton (default: Full structure).
.DESCRIPTION
  Creates the canonical karavi/ workspace folders in a repo root.
  Scans and migrates legacy/variant folder structures inside karavi/ by renaming
  and relocating them to standard names without data loss.
  Default structure is Full (21 standard folders/subfolders).
.PARAMETER RepoRoot
  Target repo root. Default: walk up from this script until a repo root
  (folder containing '.git' or 'karavi') is found.
.PARAMETER Core
  If specified, only scaffolds the 10 core folders instead of the default Full structure.
.PARAMETER Full
  Explicitly enable Full structure (enabled by default).
.PARAMETER NoMigrate
  Skip legacy folder migration/renaming.
.PARAMETER WhatIf
  Preview only; create nothing.
.EXAMPLE
  .\karavi-folder.create.ps1                     # Full structure (default) + migration
  .\karavi-folder.create.ps1 -Core               # Core structure only
  .\karavi-folder.create.ps1 -WhatIf             # Preview
  .\karavi-folder.create.ps1 -RepoRoot D:\X\Y
#>
[CmdletBinding()]
param(
    [string]$RepoRoot,
    [switch]$Core,
    [switch]$Full,
    [switch]$NoMigrate,
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# If init script exists in same folder, delegate to init.ps1 for consistent behavior
$initScript = Join-Path $PSScriptRoot 'karavi-folder.init.ps1'
if (Test-Path -LiteralPath $initScript) {
    $params = @{}
    if ($RepoRoot) { $params['RepoRoot'] = $RepoRoot }
    if ($Core) { $params['Core'] = $true }
    if ($NoMigrate) { $params['NoMigrate'] = $true }
    if ($WhatIf) { $params['WhatIf'] = $true }
    & $initScript @params
    return
}

throw "Required sibling karavi-folder.init.ps1 is missing; refusing partial initialization without migration."
