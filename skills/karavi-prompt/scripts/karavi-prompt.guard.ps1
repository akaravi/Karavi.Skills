[CmdletBinding(DefaultParameterSetName = 'Spec')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Spec')][string]$Spec,
    [Parameter(Mandatory, ParameterSetName = 'Run')][string]$Run,
    [Parameter(Mandatory, ParameterSetName = 'Text')][AllowEmptyString()][string]$Text,
    [string]$RawText,
    [string]$ModelClass = 'frontier',
    [string]$Mode = 'read-only',
    [string[]]$Untrusted = @(),
    [switch]$AllowPlaceholders,
    [ValidateSet('Text', 'Json')][string]$Format = 'Text'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'karavi-prompt.common.psm1') -Force

# Resolve inputs from whichever parameter set was used.
$armed = $null
$raw = $RawText
$metaModel = $ModelClass
$metaMode = $Mode
$metaUntrusted = @($Untrusted)

switch ($PSCmdlet.ParameterSetName) {
    'Spec' {
        if (-not (Test-Path -LiteralPath $Spec -PathType Leaf)) {
            Write-Error "Spec not found: $Spec" -ErrorAction Continue
            exit 3
        }
        try { $specObject = Get-Content -LiteralPath $Spec -Raw -Encoding UTF8 | ConvertFrom-Json }
        catch { Write-Error "Spec is not valid JSON: $Spec" -ErrorAction Continue; exit 3 }
        if (-not $specObject.PSObject.Properties['armedPrompt']) {
            Write-Error "Spec is missing armedPrompt: $Spec" -ErrorAction Continue
            exit 3
        }
        $armed = [string]$specObject.armedPrompt
        if ($specObject.PSObject.Properties['rawPrompt']) { $raw = [string]$specObject.rawPrompt }
        if ($specObject.PSObject.Properties['target']) {
            $t = $specObject.target
            if ($t.PSObject.Properties['model'] -and $t.model) { $metaModel = [string]$t.model }
            if ($t.PSObject.Properties['mode'] -and $t.mode) { $metaMode = [string]$t.mode }
        }
        if ($specObject.PSObject.Properties['intent'] -and $specObject.intent.PSObject.Properties['untrusted'] -and $specObject.intent.untrusted) {
            $metaUntrusted = @($specObject.intent.untrusted | ForEach-Object { [string]$_ })
        }
    }
    'Run' {
        if (-not (Test-Path -LiteralPath $Run -PathType Leaf)) {
            Write-Error "Run envelope not found: $Run" -ErrorAction Continue
            exit 3
        }
        try { $runObject = Get-Content -LiteralPath $Run -Raw -Encoding UTF8 | ConvertFrom-Json }
        catch { Write-Error "Run envelope is not valid JSON: $Run" -ErrorAction Continue; exit 3 }
        $armed = [string]$runObject.dispatch
        if ($runObject.PSObject.Properties['artifacts'] -and $runObject.artifacts.PSObject.Properties['raw']) {
            $rawPath = [string]$runObject.artifacts.raw
            if ($rawPath -and (Test-Path -LiteralPath $rawPath -PathType Leaf)) {
                $raw = Get-Content -LiteralPath $rawPath -Raw -Encoding UTF8
            }
        }
        if ($runObject.PSObject.Properties['target']) {
            $t = $runObject.target
            if ($t.PSObject.Properties['model'] -and $t.model) { $metaModel = [string]$t.model }
            if ($t.PSObject.Properties['mode'] -and $t.mode) { $metaMode = [string]$t.mode }
        }
        if ($runObject.PSObject.Properties['intent'] -and $runObject.intent.PSObject.Properties['untrusted'] -and $runObject.intent.untrusted) {
            $metaUntrusted = @($runObject.intent.untrusted | ForEach-Object { [string]$_ })
        }
    }
    'Text' { $armed = $Text }
}

if ($null -eq $armed) { Write-Error 'No armed prompt to guard.' -ErrorAction Continue; exit 3 }

$findings = [System.Collections.Generic.List[object]]::new()
$counts = [ordered]@{
    secret = 0; injection = 0; taint = 0; contract = 0
    placeholder = 0; armDelta = 0; budget = 0; portability = 0; mode = 0
}

# --- 1. SECRET: redact first, then report. Never return the raw form. -------
$protected = Protect-KaraviPromptText -Text $armed
$redactions = @($protected.Redactions)
$armedSafe = $protected.Text
if ($redactions.Count -gt 0) {
    $counts.secret = $redactions.Count
    Add-KaraviPromptFinding -Findings $findings -Id 'SECRET' -Severity 'block' `
        -Message "Credential-shaped content redacted to [REDACTED]: $($protected.Redactions -join ', '). Nothing may be dispatched." `
        -Evidence 'SECRET'
}

# --- 2. MODE ---------------------------------------------------------------
$modeValue = $metaMode.ToLowerInvariant()
if ($modeValue -eq 'secret') {
    $counts.mode = 1
    Add-KaraviPromptFinding -Findings $findings -Id 'MODE' -Severity 'block' `
        -Message 'target.mode is "secret". A prompt may never be armed for a credential boundary.' -Evidence 'MODE'
}
foreach ($p in (Get-KaraviPromptPatternSet -Name 'credentialRequest')) {
    $m = [regex]::Match($armedSafe, $p)
    if ($m.Success) {
        $counts.mode++
        Add-KaraviPromptFinding -Findings $findings -Id 'MODE' -Severity 'block' `
            -Message "Prompt requests credential access: $(($m.Value -replace '\s+', ' ').Trim())" `
            -Evidence (($m.Value -replace '\s+', ' ').Trim())
        break
    }
}

# --- 3. INJECTION inside declared untrusted spans ---------------------------
$spans = @(Get-KaraviPromptUntrustedSpans -Text $armedSafe)
foreach ($span in $spans) {
    foreach ($p in (Get-KaraviPromptPatternSet -Name 'injection')) {
        $m = [regex]::Match($span.Content, $p)
        if ($m.Success) {
            $counts.injection++
            Add-KaraviPromptFinding -Findings $findings -Id 'INJECTION' -Severity 'block' `
                -Message "Override phrasing inside <$($span.Tag)>: $(($m.Value -replace '\s+', ' ').Trim())" `
                -Evidence (($m.Value -replace '\s+', ' ').Trim())
            break
        }
    }
}

# --- 4. TAINT: declared untrusted content must sit in a labeled tag ---------
if ($metaUntrusted.Count -gt 0) {
    if ($spans.Count -eq 0) {
        $counts.taint = 1
        Add-KaraviPromptFinding -Findings $findings -Id 'TAINT' -Severity 'warn' `
            -Message "intent.untrusted lists $($metaUntrusted.Count) source(s) but the armed prompt has no untrusted tag. Untrusted content must be labeled." `
            -Evidence (($metaUntrusted -join ', '))
    }
    else {
        $undeclared = @($spans | Where-Object { -not $_.Declared })
        if ($undeclared.Count -gt 0) {
            $counts.taint = $undeclared.Count
            Add-KaraviPromptFinding -Findings $findings -Id 'TAINT' -Severity 'warn' `
                -Message "$($undeclared.Count) untrusted tag(s) lack trust=`"untrusted`". A tag without a data-only declaration is a label, not a boundary." `
                -Evidence (($undeclared | ForEach-Object { "<$($_.Tag)>" }) -join ', ')
        }
    }
}
$hasAcceptance = $armedSafe -match '(?i)acceptance|definition of done|done when|verify|when you are finished|before you finish'
# --- 5. CONTRACT: acceptance, output shape, termination ---------------------
$hasOutput = $armedSafe -match '(?i)output[_ -]?format|return\b|respond|emit\b|schema|respond with|produce\b'
$hasTermination = $armedSafe -match '(?i)do not ask|you are done|stop\b|halt\b|terminate|end when|do not continue'
if (-not $hasAcceptance) {
    $counts.contract++
    Add-KaraviPromptFinding -Findings $findings -Id 'CONTRACT' -Severity 'warn' `
        -Message 'No acceptance condition found. The armed prompt states no checkable definition of done.' -Evidence 'CONTRACT.acceptance'
}
if (-not $hasOutput) {
    $counts.contract++
    Add-KaraviPromptFinding -Findings $findings -Id 'CONTRACT' -Severity 'warn' `
        -Message 'No output shape found. The target will guess the response format.' -Evidence 'CONTRACT.output'
}
if (-not $hasTermination) {
    $counts.contract++
    Add-KaraviPromptFinding -Findings $findings -Id 'CONTRACT' -Severity 'warn' `
        -Message 'No termination rule found. The target has no observable stop condition.' -Evidence 'CONTRACT.termination'
}

# --- 6. PLACEHOLDER ---------------------------------------------------------
if (-not $AllowPlaceholders) {
    foreach ($p in (Get-KaraviPromptPatternSet -Name 'placeholder')) {
        $m = [regex]::Match($armedSafe, $p)
        if ($m.Success) {
            $counts.placeholder++
            Add-KaraviPromptFinding -Findings $findings -Id 'PLACEHOLDER' -Severity 'warn' `
                -Message "Unfilled placeholder survived arming: $(($m.Value -replace '\s+', ' ').Trim())" `
                -Evidence (($m.Value -replace '\s+', ' ').Trim())
            break
        }
    }
}

# --- 7. ARM_DELTA -----------------------------------------------------------
if ($null -ne $raw) {
    if ((ConvertTo-KaraviPromptNormalized -Text $raw) -eq (ConvertTo-KaraviPromptNormalized -Text $armedSafe)) {
        $counts.armDelta = 1
        Add-KaraviPromptFinding -Findings $findings -Id 'ARM_DELTA' -Severity 'warn' `
            -Message 'Armed text is identical to the raw text. No engineering was applied.' -Evidence 'ARM_DELTA'
    }
}

# --- 8. BUDGET --------------------------------------------------------------
$armedTokens = Get-KaraviPromptTokenEstimate -Text $armedSafe
$classBudget = Get-KaraviPromptBudget -ModelClass $metaModel
if ($armedTokens -gt $classBudget) {
    $counts.budget++
    Add-KaraviPromptFinding -Findings $findings -Id 'BUDGET' -Severity 'warn' `
        -Message "Armed prompt is ~$armedTokens tokens, over the $classBudget-token budget for model class '$((Get-KaraviPromptNormalizedModel -Model $metaModel))'. Split it or retrieve the detail." `
        -Evidence "BUDGET.$classBudget"
}

# --- 9. PORTABILITY ---------------------------------------------------------
$portableHit = $null
foreach ($p in (Get-KaraviPromptPatternSet -Name 'portable')) {
    $m = [regex]::Match($armedSafe, $p)
    if ($m.Success) { $portableHit = $m; break }
}
if ($null -ne $portableHit) {
    $hasFallback = $false
    foreach ($p in (Get-KaraviPromptPatternSet -Name 'fallback')) {
        if ($armedSafe -match $p) { $hasFallback = $true; break }
    }
    if (-not $hasFallback) {
        $counts.portability = 1
        Add-KaraviPromptFinding -Findings $findings -Id 'PORTABILITY' -Severity 'warn' `
            -Message "Provider-specific mechanism without a stated fallback: $(($portableHit.Value -replace '\s+', ' ').Trim())" `
            -Evidence (($portableHit.Value -replace '\s+', ' ').Trim())
    }
}
if (-not (Test-KaraviPromptKnownModel -Model $metaModel)) {
    $counts.portability++
    Add-KaraviPromptFinding -Findings $findings -Id 'PORTABILITY' -Severity 'warn' `
        -Message "target.model '$metaModel' is not one of frontier, mid-tier, small, reasoning. Treated as 'frontier'." `
        -Evidence "PORTABILITY.model=$metaModel"
}

# --- Verdict ---------------------------------------------------------------
$blocks = @($findings | Where-Object { $_.severity -eq 'block' })
$verdict = if ($blocks.Count -gt 0) { 'block' } elseif ($findings.Count -gt 0) { 'warn' } else { 'pass' }

$result = [ordered]@{
    verdict     = $verdict
    counts      = $counts
    findings    = @($findings)
    armedText   = $armedSafe
    rawTokens   = if ($null -ne $raw) { Get-KaraviPromptTokenEstimate -Text $raw } else { 0 }
    armedTokens = $armedTokens
    budget      = $classBudget
    modelClass  = (Get-KaraviPromptNormalizedModel -Model $metaModel)
    mode        = $modeValue
}
$json = ConvertTo-KaraviPromptJson -Object ([pscustomobject]$result)

if ($Format -eq 'Json') {
    Write-Output $json
}
else {
    Write-Output "VERDICT=$verdict"
    Write-Output "MODEL=$($result.modelClass) MODE=$modeValue TOKENS=$armedTokens/$classBudget"
    foreach ($f in $findings) { Write-Output ("{0}/{1}: {2}" -f $f.id, $f.severity.ToUpperInvariant(), $f.message) }
    Write-Output '--JSON--'
    Write-Output $json
}

switch ($verdict) {
    'block' { exit 1 }
    'warn' { exit 2 }
    default { exit 0 }
}
