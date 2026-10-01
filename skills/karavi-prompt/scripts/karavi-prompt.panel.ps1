[CmdletBinding(DefaultParameterSetName = 'Run')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Run')][string]$Run,
    [Parameter(Mandatory, ParameterSetName = 'Spec')][string]$Spec,
    [Parameter(Mandatory, ParameterSetName = 'Text')][AllowEmptyString()][string]$Text,
    [string]$Title,
    [ValidateSet('Auto', 'Box', 'Markdown', 'Json')][string]$Format = 'Auto',
    [int]$Width = 78,
    [int]$MaxPromptLines = 24,
    [switch]$Ascii,
    [switch]$Ansi,
    [switch]$NoColor,
    [string]$OutFile
)

# This file must stay ASCII. Windows PowerShell 5.1 reads a BOM-less script as
# the system ANSI code page, so a literal box-drawing or arrow character would
# be corrupted. Every non-ASCII glyph comes from Get-KaraviPromptGlyph.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'karavi-prompt.common.psm1') -Force

$asciiGlyphs = [bool]$Ascii
if (-not $asciiGlyphs) {
    # The panel is read in a terminal. Windows PowerShell defaults the console
    # to the system OEM code page, which cannot draw box glyphs, so ask for
    # UTF-8 and fall back to ASCII when the host refuses.
    try {
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        $OutputEncoding = [System.Text.Encoding]::UTF8
    } catch { }
    if ([Console]::OutputEncoding.CodePage -ne 65001) { $asciiGlyphs = $true }
}

$g = @{
    TL = Get-KaraviPromptGlyph -Name 'BoxTL' -Ascii:$asciiGlyphs
    TR = Get-KaraviPromptGlyph -Name 'BoxTR' -Ascii:$asciiGlyphs
    BL = Get-KaraviPromptGlyph -Name 'BoxBL' -Ascii:$asciiGlyphs
    BR = Get-KaraviPromptGlyph -Name 'BoxBR' -Ascii:$asciiGlyphs
    H = Get-KaraviPromptGlyph -Name 'BoxH' -Ascii:$asciiGlyphs
    ML = Get-KaraviPromptGlyph -Name 'BoxML' -Ascii:$asciiGlyphs
    MR = Get-KaraviPromptGlyph -Name 'BoxMR' -Ascii:$asciiGlyphs
    Rule = Get-KaraviPromptGlyph -Name 'Rule' -Ascii:$asciiGlyphs
    Ell = Get-KaraviPromptGlyph -Name 'Ellipsis' -Ascii:$asciiGlyphs
    Dot = Get-KaraviPromptGlyph -Name 'Middot' -Ascii:$asciiGlyphs
    Arrow = Get-KaraviPromptGlyph -Name 'Arrow' -Ascii:$asciiGlyphs
}
if (-not $Title) { $Title = "KARAVI $($g.Dot) PROMPT ARMED $($g.Dot) IN EXECUTION" }
$stagePath = "RAW $($g.Arrow) ENGINEER $($g.Arrow) GUARD $($g.Arrow) PANEL"

# --- Resolve the envelope ---------------------------------------------------
$envelope = $null
switch ($PSCmdlet.ParameterSetName) {
    'Run' {
        if (-not (Test-Path -LiteralPath $Run -PathType Leaf)) { Write-Error "Run envelope not found: $Run" -ErrorAction Continue; exit 3 }
        try { $envelope = Get-Content -LiteralPath $Run -Raw -Encoding UTF8 | ConvertFrom-Json }
        catch { Write-Error "Run envelope is not valid JSON: $Run" -ErrorAction Continue; exit 3 }
    }
    'Spec' {
        if (-not (Test-Path -LiteralPath $Spec -PathType Leaf)) { Write-Error "Spec not found: $Spec" -ErrorAction Continue; exit 3 }
        try { $envelope = Get-Content -LiteralPath $Spec -Raw -Encoding UTF8 | ConvertFrom-Json }
        catch { Write-Error "Spec is not valid JSON: $Spec" -ErrorAction Continue; exit 3 }
    }
    'Text' {
        $digest = Get-KaraviPromptDigest -Text $Text
        $envelope = [pscustomobject]@{
            id          = (New-KaraviPromptRunId -Digest $digest)
            createdUtc  = [datetime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
            stage       = 'armed'
            target      = [pscustomobject]@{ host = 'unknown'; agent = 'unknown'; model = 'frontier'; mode = 'read-only' }
            guard       = [pscustomobject]@{ verdict = 'unknown'; counts = [pscustomobject]@{}; findings = @() }
            rawTokens   = 0
            armedTokens = (Get-KaraviPromptTokenEstimate -Text $Text)
            digest      = $digest
            techniques  = @()
            dispatch    = $Text
        }
    }
}

$armedText = [string]$envelope.dispatch
$digest = [string]$envelope.digest
$shortDigest = $digest
if ($shortDigest -match '^sha256:([0-9a-f]{6})') { $shortDigest = "sha256:$($Matches[1])$($g.Ell)" }

$target = $envelope.target
$verdict = [string]$envelope.guard.verdict
$counts = $envelope.guard.counts
$mode = [string]$target.mode

# Growth of the armed prompt over the raw one. Relative to raw, because the
# question the panel answers is "how much did arming add", not "what share of
# the final prompt is new".
$sizeDelta = 'new'
if ($envelope.armedTokens -gt 0) {
    if ($envelope.rawTokens -gt 0) {
        $pct = [int][math]::Round((($envelope.armedTokens - $envelope.rawTokens) / [double]$envelope.rawTokens) * 100)
        $sizeDelta = '{0:+#;-#;0}%' -f $pct
    }
    else { $sizeDelta = 'new' }
}

# --- Guard summary ----------------------------------------------------------
function Format-CountField {
    param([string]$Name)
    if ($null -eq $counts) { return 'n/a' }
    $prop = $counts.PSObject.Properties[$Name]
    if ($null -eq $prop) { return 'n/a' }
    $v = [int]$prop.Value
    if ($v -eq 0) { return 'ok' }
    return [string]$v
}

$guardShort = "$verdict  secret=$(Format-CountField 'secret') injection=$(Format-CountField 'injection') " +
"taint=$(Format-CountField 'taint') contract=$(Format-CountField 'contract')"
$guardLong = "budget=$(Format-CountField 'budget') placeholder=$(Format-CountField 'placeholder') " +
"armDelta=$(Format-CountField 'armDelta') portability=$(Format-CountField 'portability') mode=$(Format-CountField 'mode')"

$modeNote = switch ($mode.ToLowerInvariant()) {
    'mutating' { 'mutating: this run may change the workspace. karavi-terminal mutation approval is still required before execution.' }
    'network' { 'network: outbound calls are permitted. Confirm the host list before dispatch.' }
    'secret' { 'secret: a credential boundary. This panel must not exist; the guard should have blocked.' }
    default { 'read-only: no workspace mutation is authorized by this run.' }
}

# --- Format resolution ------------------------------------------------------
$resolvedFormat = $Format
if ($Format -eq 'Auto') {
    $resolvedFormat = if (Test-KaraviPromptRtl -Text $armedText) { 'Markdown' } else { 'Box' }
}

# --- Truncation -------------------------------------------------------------
$allLines = @($armedText -split "`r?`n")
$truncated = $false
$shownLines = $allLines
if ($MaxPromptLines -gt 0 -and $allLines.Count -gt $MaxPromptLines) {
    $truncated = $true
    $shownLines = $allLines[0..($MaxPromptLines - 1)]
}

$fullPath = ''
$art = $envelope.PSObject.Properties['artifacts']
if ($art) { $fullPath = [string]$envelope.artifacts.prompt }

if ($resolvedFormat -eq 'Json') {
    $payload = [ordered]@{
        run          = [string]$envelope.id
        stage        = 'DISPATCH'
        createdUtc   = [string]$envelope.createdUtc
        target       = [ordered]@{ host = $target.host; agent = $target.agent; model = $target.model; mode = $mode }
        guard        = [ordered]@{ verdict = $verdict; findings = @($envelope.guard.findings) }
        size         = [ordered]@{ rawTokens = $envelope.rawTokens; armedTokens = $envelope.armedTokens; deltaPercent = $envelope.deltaPercent }
        digest       = $digest
        techniques   = @($envelope.techniques)
        mode         = $mode
        modeNote     = $modeNote
        truncated    = $truncated
        totalLines   = $allLines.Count
        fullPromptPath = $fullPath
        panel        = ''
        dispatch     = $armedText
    }
    $rendered = ConvertTo-KaraviPromptJson -Object $payload
}
elseif ($resolvedFormat -eq 'Markdown') {
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("> **$Title**")
    $lines.Add('>')
    $lines.Add('> | field | value |')
    $lines.Add('> |---|---|')
    $lines.Add("> | RUN | ``$($envelope.id)`` |")
    $lines.Add("> | STAGE | ``DISPATCH`` ($stagePath) |")
    $lines.Add("> | TARGET | ``host=$($target.host) agent=$($target.agent) model=$($target.model) mode=$mode`` |")
    $lines.Add("> | GUARD | ``$verdict`` secret=$(Format-CountField 'secret') injection=$(Format-CountField 'injection') taint=$(Format-CountField 'taint') contract=$(Format-CountField 'contract') budget=$(Format-CountField 'budget') placeholder=$(Format-CountField 'placeholder') armDelta=$(Format-CountField 'armDelta') portability=$(Format-CountField 'portability') mode=$(Format-CountField 'mode') |")
    $lines.Add("> | SIZE | raw=$($envelope.rawTokens) tok $($g.Arrow) armed=$($envelope.armedTokens) tok ($sizeDelta) |")
    $lines.Add("> | DIGEST | ``$shortDigest`` |")
    $lines.Add('>')
    $lines.Add('> **ARMED PROMPT**')
    $lines.Add('>')
    $lines.Add('> ```text')
    foreach ($l in $shownLines) { $lines.Add("> $l") }
    if ($truncated) {
        $more = $allLines.Count - $shownLines.Count
        $suffix = if ($fullPath) { " -> $fullPath" } else { '' }
        $lines.Add("> $($g.Ell) +$more more lines$suffix")
    }
    $lines.Add('> ```')
    $lines.Add('>')
    $lines.Add("> **MODE NOTE** - $modeNote")
    $rendered = ($lines -join "`n")
}
else {
    $inner = [math]::Max(60, [math]::Min(120, $Width))
    $lines = [System.Collections.Generic.List[string]]::new()
    $hBar = [string]::new($g.H, $inner)
    $rule = [string]::new($g.Rule, 12)
    $lines.Add($g.TL + $hBar + $g.TR)
    $lines.Add((Format-KaraviPromptBoxLine -Text $Title -InnerWidth $inner -Ascii:$asciiGlyphs))
    $lines.Add($g.ML + $hBar + $g.MR)
    $lines.Add((Format-KaraviPromptBoxLine -Text "  RUN     : $($envelope.id)" -InnerWidth $inner -Ascii:$asciiGlyphs))
    $lines.Add((Format-KaraviPromptBoxLine -Text "  STAGE   : DISPATCH   ($stagePath)" -InnerWidth $inner -Ascii:$asciiGlyphs))
    $lines.Add((Format-KaraviPromptBoxLine -Text "  TARGET  : host=$($target.host) agent=$($target.agent) model=$($target.model) mode=$mode" -InnerWidth $inner -Ascii:$asciiGlyphs))
    $lines.Add((Format-KaraviPromptBoxLine -Text "  GUARD   : $guardShort" -InnerWidth $inner -Ascii:$asciiGlyphs))
    $lines.Add((Format-KaraviPromptBoxLine -Text "            $guardLong" -InnerWidth $inner -Ascii:$asciiGlyphs))
    $sizeText = "  SIZE    : raw=$($envelope.rawTokens) tok -> armed=$($envelope.armedTokens) tok ($sizeDelta)"
    $lines.Add((Format-KaraviPromptBoxLine -Text $sizeText -InnerWidth $inner -Ascii:$asciiGlyphs))
    $tech = @($envelope.techniques) -join ', '
    if ($tech) { $lines.Add((Format-KaraviPromptBoxLine -Text "  TECH    : $tech" -InnerWidth $inner -Ascii:$asciiGlyphs)) }
    $lines.Add((Format-KaraviPromptBoxLine -Text "  DIGEST  : $shortDigest" -InnerWidth $inner -Ascii:$asciiGlyphs))
    $lines.Add($g.ML + $hBar + $g.MR)
    $lines.Add((Format-KaraviPromptBoxLine -Text '  ARMED PROMPT' -InnerWidth $inner -Ascii:$asciiGlyphs))
    $lines.Add((Format-KaraviPromptBoxLine -Text "  $rule" -InnerWidth $inner -Ascii:$asciiGlyphs))
    $noPad = (Test-KaraviPromptRtl -Text $armedText)
    # A truncated line must still occupy exactly the panel's inner width, so
    # the cut is computed in display columns with the ellipsis counted.
    $ellTail = "$($g.Ell) "
    $maxText = $inner - 4
    foreach ($l in $shownLines) {
        if ((Measure-KaraviPromptDisplayWidth -Text $l) -gt $maxText) {
            $keep = $maxText - (Measure-KaraviPromptDisplayWidth -Text $ellTail)
            if ($keep -lt 1) { $keep = 1 }
            $l = $l.Substring(0, [math]::Min($keep, $l.Length)) + $ellTail
        }
        $lines.Add((Format-KaraviPromptBoxLine -Text "  $l" -InnerWidth $inner -NoPad:$noPad -Ascii:$asciiGlyphs))
    }
    if ($truncated) {
        $more = $allLines.Count - $shownLines.Count
        $suffix = if ($fullPath) { " -> $fullPath" } else { '' }
        $lines.Add((Format-KaraviPromptBoxLine -Text "  $($g.Ell) +$more more lines$suffix" -InnerWidth $inner -NoPad:$noPad -Ascii:$asciiGlyphs))
    }
    $lines.Add($g.ML + $hBar + $g.MR)
    $offset = 0
    while ($offset -lt $modeNote.Length) {
        $take = [math]::Min($inner - 4, $modeNote.Length - $offset)
        $chunk = $modeNote.Substring($offset, $take)
        $prefix = if ($offset -eq 0) { '  MODE     : ' } else { '            ' }
        $lines.Add((Format-KaraviPromptBoxLine -Text "$prefix$chunk" -InnerWidth $inner -NoPad:$noPad -Ascii:$asciiGlyphs))
        $offset += $take
    }
    $lines.Add($g.BL + $hBar + $g.BR)
    $rendered = ($lines -join "`n")
}

# --- Color, only when asked -------------------------------------------------
if ($Ansi -and -not $NoColor) {
    $color = switch ($verdict) {
        'block' { '31' }
        'warn' { '33' }
        default { '32' }
    }
    $esc = [char]27
    $rendered = (($rendered -split "`r?`n") | ForEach-Object { "$esc[${color}m$_$esc[0m" }) -join "`n"
}

if ($OutFile) {
    Write-KaraviPromptFile -Path $OutFile -Content $rendered
    Write-Output "PANEL=$OutFile"
    exit 0
}

Write-Output $rendered
exit 0
