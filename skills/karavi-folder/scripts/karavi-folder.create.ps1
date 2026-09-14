#Requires -Version 5.1
<#
.SYNOPSIS
  Section 1 of the karavi-folder skill: create the standard karavi/ skeleton.
.DESCRIPTION
  Creates the canonical karavi/ workspace folders in a repo root. Core folders
  are always created; optional folders only with -Full. Never imports from
  another project.
.PARAMETER RepoRoot
  Target repo root. Default: walk up from this script until a repo root
  (folder containing 'karavi') or '.git' is found.
.PARAMETER Full
  Also create optional folders (assets, doc, business model, social media,
  grafana config, plans.mockup, scripts index).
.PARAMETER WhatIf
  Preview only; create nothing.
.EXAMPLE
  .\karavi-folder.create.ps1                     # core skeleton
  .\karavi-folder.create.ps1 -Full               # core + optional
  .\karavi-folder.create.ps1 -RepoRoot D:\X\Y
#>
[CmdletBinding()]
param(
    [string]$RepoRoot,
    [switch]$Full,
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Resolve-RepoRoot {
    param([string]$Start = $PSScriptRoot)
    $dir = $Start
    while ($dir) {
        if ((Test-Path -LiteralPath (Join-Path $dir '.git')) -or
            (Test-Path -LiteralPath (Join-Path $dir 'karavi'))) {
            return $dir
        }
        $parent = Split-Path -Parent $dir
        if ($parent -eq $dir) { break }
        $dir = $parent
    }
    throw "Repo root (folder containing .git or karavi/) not found from: $Start"
}

if (-not $RepoRoot) {
    $RepoRoot = Resolve-RepoRoot
}
if (-not (Test-Path -LiteralPath $RepoRoot)) {
    throw "RepoRoot not found: $RepoRoot"
}

$k = Join-Path $RepoRoot 'karavi'

$core = @(
    'karavi.plans.prompt/cursor',
    'karavi.plans.prompt/claude',
    'karavi.plans.prompt/other',
    'karavi.history',
    'karavi.logs',
    'karavi.status',
    'karavi.build.config',
    'karavi.build.files',
    'karavi.deploy.config',
    'karavi.deploy.files',
    'karavi.publish.config',
    'karavi.publish.files',
    'karavi.scripts.command',
    'karavi.scripts.tools'
)

$optional = @(
    'karavi.assets/brand',
    'karavi.assets/icons',
    'karavi.assets/screenshots',
    'karavi.assets/templates',
    'karavi.doc/workflows',
    'karavi.BusinessModel.Doc',
    'karavi.Customer.doc',
    'karavi.plans.mockup',
    'karavi.scripts',
    'karavi.SociaMediaContent',
    'karavi.grafana.config'
)

$created = 0
foreach ($rel in $core) {
    $target = Join-Path $k ($rel -replace '/', [IO.Path]::DirectorySeparatorChar)
    $rootCheck = (Join-Path $RepoRoot '') -replace '\\$', ''
    if (-not $target.StartsWith($rootCheck, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refused: $target resolves outside repo root."
    }
    if (-not (Test-Path -LiteralPath $target)) {
        if ($WhatIf) { Write-Host "[WhatIf] Create dir: $target" }
        else { New-Item -ItemType Directory -Force -Path $target | Out-Null }
        $created++
    }
}

if ($Full) {
    foreach ($rel in $optional) {
        $target = Join-Path $k ($rel -replace '/', [IO.Path]::DirectorySeparatorChar)
        if (-not (Test-Path -LiteralPath $target)) {
            if ($WhatIf) { Write-Host "[WhatIf] Create dir: $target" }
            else { New-Item -ItemType Directory -Force -Path $target | Out-Null }
            $created++
        }
    }
}

Write-Host "karavi-folder create: $created folder(s) processed under $k"
if (-not $WhatIf -and -not (Test-Path -LiteralPath (Join-Path $k '.gitkeep'))) {
    Write-Host 'Next: add the "# --- karavi ---" block to .gitignore (see references/folders.md).'
}