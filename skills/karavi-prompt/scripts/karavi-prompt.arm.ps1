[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Spec,
    [string]$RepoRoot,
    [ValidateSet('Auto', 'Box', 'Markdown', 'Json')][string]$PanelFormat = 'Auto',
    [int]$Width = 78,
    [int]$MaxPromptLines = 24,
    [switch]$Ansi,
    [switch]$NoColor,
    [switch]$NoLedger,
    [switch]$AllowPlaceholders
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'karavi-prompt.common.psm1') -Force

if (-not (Test-Path -LiteralPath $Spec -PathType Leaf)) {
    Write-Error "Spec not found: $Spec" -ErrorAction Continue
    exit 3
}
try { $specObject = Get-Content -LiteralPath $Spec -Raw -Encoding UTF8 | ConvertFrom-Json }
catch { Write-Error "Spec is not valid JSON: $Spec" -ErrorAction Continue; exit 3 }

foreach ($required in @('armedPrompt', 'intent')) {
    if (-not $specObject.PSObject.Properties[$required]) {
        Write-Error "Spec is missing '$required': $Spec" -ErrorAction Continue
        exit 3
    }
}
if (-not $specObject.PSObject.Properties['target']) {
    Write-Error "Spec is missing 'target': $Spec" -ErrorAction Continue
    exit 3
}

$created = [datetime]::UtcNow
$rawText = ''
if ($specObject.PSObject.Properties['rawPrompt']) { $rawText = [string]$specObject.rawPrompt }
$target = $specObject.target
$intent = $specObject.intent
$techniques = @()
if ($specObject.PSObject.Properties['techniques'] -and $specObject.techniques) {
    $techniques = @($specObject.techniques | ForEach-Object { [string]$_ })
}
$language = 'en'
if ($specObject.PSObject.Properties['language'] -and $specObject.language) { $language = [string]$specObject.language }
$notes = ''
if ($specObject.PSObject.Properties['notes']) { $notes = [string]$specObject.notes }

# --- GUARD ------------------------------------------------------------------
$guardArgs = @{ Spec = $Spec; Format = 'Json' }
if ($AllowPlaceholders) { $guardArgs['AllowPlaceholders'] = $true }
$guardScript = Join-Path $PSScriptRoot 'karavi-prompt.guard.ps1'
$guardRaw = & $guardScript @guardArgs
$guardExit = $LASTEXITCODE
$guard = $guardRaw | ConvertFrom-Json

# The guard's redacted text is the only text that may be persisted or dispatched.
$armedText = [string]$guard.armedText
$digest = Get-KaraviPromptDigest -Text $armedText
$runId = New-KaraviPromptRunId -Digest $digest -Timestamp $created

$runsRoot = Get-KaraviPromptRunsRoot -RepoRoot $RepoRoot
$runPath = Join-Path $runsRoot "$runId.json"
$rawPath = Join-Path $runsRoot "$runId.raw.txt"
$promptPath = Join-Path $runsRoot "$runId.armed.txt"
$panelPath = Join-Path $runsRoot "$runId.panel.txt"

$envelope = [ordered]@{
    id          = $runId
    createdUtc  = $created.ToString('yyyy-MM-ddTHH:mm:ssZ')
    stage       = 'armed'
    language    = $language
    notes       = $notes
    techniques  = $techniques
    intent      = $intent
    target      = $target
    rawTokens   = [int]$guard.rawTokens
    armedTokens = [int]$guard.armedTokens
    deltaPercent = 0
    rawDigest   = if ($rawText) { Get-KaraviPromptDigest -Text $rawText } else { '' }
    digest      = $digest
    guard       = [ordered]@{
        verdict  = [string]$guard.verdict
        counts   = $guard.counts
        findings = @($guard.findings)
    }
    artifacts   = [ordered]@{
        envelope = $runPath
        raw      = $rawPath
        prompt   = $promptPath
        panel    = $panelPath
    }
    dispatch    = $armedText
    closed      = $false
}
if ($envelope.rawTokens -gt 0) {
    $envelope.deltaPercent = [int][math]::Round((($envelope.armedTokens - $envelope.rawTokens) / [double]$envelope.rawTokens) * 100)
}
else { $envelope.deltaPercent = $null }

# A block ends the run. Artifacts that would help the user fix it are written;
# the panel is not, because nothing on screen may look dispatchable.
if ($guard.verdict -eq 'block') {
    $envelope.stage = 'blocked'
    if ($rawText) { Write-KaraviPromptFile -Path $rawPath -Content $rawText }
    Write-KaraviPromptFile -Path $promptPath -Content $armedText
    Write-KaraviPromptFile -Path $runPath -Content (ConvertTo-KaraviPromptJson -Object ([pscustomobject]$envelope))
    if (-not $NoLedger) {
        & (Join-Path $PSScriptRoot 'karavi-prompt.ledger.ps1') -Id $runId -Event 'armed' -Verdict 'block' `
            -Digest $digest -Target "$($target.host)/$($target.agent)" -Mode ([string]$target.mode) `
            -RawTokens $envelope.rawTokens -ArmedTokens $envelope.armedTokens -RepoRoot $RepoRoot | Out-Null
    }
    Write-Output "RUN=$runId"
    Write-Output "VERDICT=block"
    Write-Output "ENVELOPE=$runPath"
    foreach ($f in @($guard.findings)) {
        Write-Output ("{0}/{1}: {2}" -f $f.id, ([string]$f.severity).ToUpperInvariant(), [string]$f.message)
    }
    Write-Output 'PANEL=none (blocked before dispatch)'
    exit 1
}

# --- PANEL ------------------------------------------------------------------
if ($rawText) { Write-KaraviPromptFile -Path $rawPath -Content $rawText }
Write-KaraviPromptFile -Path $promptPath -Content $armedText
Write-KaraviPromptFile -Path $runPath -Content (ConvertTo-KaraviPromptJson -Object ([pscustomobject]$envelope))

$panelScript = Join-Path $PSScriptRoot 'karavi-prompt.panel.ps1'
$panelArgs = @{ Run = $runPath; Format = $PanelFormat; Width = $Width; MaxPromptLines = $MaxPromptLines; OutFile = $panelPath }
if ($Ansi) { $panelArgs['Ansi'] = $true }
if ($NoColor) { $panelArgs['NoColor'] = $true }
& $panelScript @panelArgs | Out-Null
$panelText = (Get-Content -LiteralPath $panelPath -Raw -Encoding UTF8).TrimEnd()

if (-not $NoLedger) {
    & (Join-Path $PSScriptRoot 'karavi-prompt.ledger.ps1') -Id $runId -Event 'armed' -Verdict ([string]$guard.verdict) `
        -Digest $digest -Target "$($target.host)/$($target.agent)" -Mode ([string]$target.mode) `
        -RawTokens $envelope.rawTokens -ArmedTokens $envelope.armedTokens -RepoRoot $RepoRoot | Out-Null
}

Write-Output $panelText
Write-Output ''
Write-Output "RUN=$runId"
Write-Output "VERDICT=$($guard.verdict)"
Write-Output "ENVELOPE=$runPath"
Write-Output "PROMPT=$promptPath"
Write-Output '---DISPATCH---'
Write-Output $armedText
exit $guardExit
