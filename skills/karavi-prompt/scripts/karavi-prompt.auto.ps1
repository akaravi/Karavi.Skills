[CmdletBinding(DefaultParameterSetName = 'Status')]
param(
    [Parameter(ParameterSetName = 'On', Mandatory)]
    [switch]$On,

    [Parameter(ParameterSetName = 'Off', Mandatory)]
    [switch]$Off,

    [Parameter(ParameterSetName = 'Status')]
    [switch]$Status,

    [Parameter(ParameterSetName = 'On')]
    [string[]]$Targets = @(),

    [string]$RepoRoot,

    [ValidateSet('Text', 'Json')]
    [string]$Format = 'Text'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'karavi-prompt.common.psm1') -Force

$resolvedRepoRoot = if ([string]::IsNullOrWhiteSpace($RepoRoot)) { (Get-Location).Path } else { $RepoRoot }

if ($On) {
    $normalizedTargets = @()
    if ($Targets) {
        foreach ($t in $Targets) {
            if ($t -match ',') {
                $normalizedTargets += ($t -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
            } else {
                $normalizedTargets += $t.Trim()
            }
        }
    }
    $result = Set-KaraviPromptAutoState -Enabled $true -Targets $normalizedTargets -RepoRoot $resolvedRepoRoot
    if ($Format -eq 'Json') {
        Write-Output (ConvertTo-KaraviPromptJson -Object $result)
    } else {
        Write-Output "KARAVI-PROMPT: AUTO ON"
        Write-Output "Mode: auto"
        Write-Output "Updated: $($result.updatedAt)"
        if ($result.targets -and $result.targets.Count -gt 0) {
            Write-Output "Targets: $($result.targets -join ', ')"
        } else {
            Write-Output "Targets: all subagents"
        }
    }
    exit 0
}

if ($Off) {
    $result = Set-KaraviPromptAutoState -Enabled $false -Targets @() -RepoRoot $resolvedRepoRoot
    if ($Format -eq 'Json') {
        Write-Output (ConvertTo-KaraviPromptJson -Object $result)
    } else {
        Write-Output "KARAVI-PROMPT: AUTO OFF"
        Write-Output "Mode: manual"
        Write-Output "Updated: $($result.updatedAt)"
    }
    exit 0
}

# Status mode (default)
$current = Get-KaraviPromptAutoState -RepoRoot $resolvedRepoRoot
if ($Format -eq 'Json') {
    Write-Output (ConvertTo-KaraviPromptJson -Object $current)
} else {
    $stateLabel = if ($current.enabled) { "ON" } else { "OFF" }
    Write-Output "KARAVI-PROMPT: AUTO $stateLabel"
    Write-Output "Mode: $(if ($current.enabled) { 'auto' } else { 'manual' })"
    if ($current.updatedAt) {
        Write-Output "Updated: $($current.updatedAt)"
    }
    if ($current.enabled -and $current.targets -and $current.targets.Count -gt 0) {
        Write-Output "Targets: $($current.targets -join ', ')"
    }
}
exit 0
