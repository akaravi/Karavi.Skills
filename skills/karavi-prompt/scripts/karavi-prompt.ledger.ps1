[CmdletBinding(DefaultParameterSetName = 'Append')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Append')][string]$Id,
    [Parameter(Mandatory, ParameterSetName = 'Append')][ValidateSet('armed', 'dispatched', 'closed')][string]$Event,
    [string]$Verdict = '',
    [string]$Digest = '',
    [string]$Target = '',
    [string]$Mode = '',
    [int]$RawTokens = 0,
    [int]$ArmedTokens = 0,
    [string]$Outcome = '',
    [string]$Note = '',
    [double]$Score = 0,

    [Parameter(Mandatory, ParameterSetName = 'List')][switch]$List,
    [string]$RepoRoot,
    [int]$Last = 0
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'karavi-prompt.common.psm1') -Force

$ledgerPath = Get-KaraviPromptLedgerPath -RepoRoot $RepoRoot

if ($PSCmdlet.ParameterSetName -eq 'List') {
    if (-not (Test-Path -LiteralPath $ledgerPath -PathType Leaf)) {
        Write-Output "LEDGER=$ledgerPath"
        Write-Output 'ENTRIES=0'
        exit 0
    }
    $lines = @(Get-Content -LiteralPath $ledgerPath -Encoding UTF8 | Where-Object { $_.Trim() })
    if ($Last -gt 0 -and $lines.Count -gt $Last) { $lines = $lines[($lines.Count - $Last)..($lines.Count - 1)] }
    Write-Output "LEDGER=$ledgerPath"
    Write-Output "ENTRIES=$($lines.Count)"
    foreach ($l in $lines) { Write-Output $l }
    exit 0
}

$record = [ordered]@{
    ts          = [datetime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
    id          = $Id
    event       = $Event
    verdict     = $Verdict
    digest      = $Digest
    target      = $Target
    mode        = $Mode
    rawTokens   = $RawTokens
    armedTokens = $ArmedTokens
}
if ($Event -eq 'closed') {
    $record['outcome'] = $Outcome
    if ($Score -gt 0) { $record['score'] = $Score }
    if ($Note) { $record['note'] = $Note }
}

$json = ConvertTo-Json -InputObject ([pscustomobject]$record) -Depth 6 -Compress
$json = $json.Replace("`r", '').Replace("`n", '')

if (-not (Test-Path -LiteralPath (Split-Path -Parent $ledgerPath))) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $ledgerPath) -Force | Out-Null
}
$enc = New-Object System.Text.UTF8Encoding($false)
$sw = [System.IO.StreamWriter]::new($ledgerPath, $true, $enc)
try { $sw.WriteLine($json) } finally { $sw.Dispose() }

Write-Output "LEDGER=$ledgerPath"
Write-Output "APPENDED=$Id/$Event"
