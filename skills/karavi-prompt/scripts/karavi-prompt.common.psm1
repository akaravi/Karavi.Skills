Set-StrictMode -Version Latest

# Shared helpers for the karavi-prompt arming pipeline.
# Nothing here mutates anything outside karavi.temp.status/karavi-prompt/.

$script:UntrustedTagNames = @(
    'untrusted-source', 'retrieved_document', 'user-file',
    'tool-result', 'agent-output', 'web-content', 'user_message'
)

$script:SecretPatterns = @(
    @{ id = 'SECRET.AWS_ACCESS_KEY'; pattern = '\bAKIA[0-9A-Z]{16}\b' },
    @{ id = 'SECRET.AWS_SECRET_KEY'; pattern = '(?i)aws_secret_access_key\s*[:=]\s*\S{20,}' },
    @{ id = 'SECRET.PRIVATE_KEY'; pattern = '-----BEGIN [A-Z ]*PRIVATE KEY-----' },
    @{ id = 'SECRET.AZURE_OPENAI'; pattern = '\bsk-[A-Za-z0-9]{32,}\b' },
    @{ id = 'SECRET.ANTHROPIC'; pattern = '\bsk-ant-[A-Za-z0-9_\-]{20,}\b' },
    @{ id = 'SECRET.GITHUB_TOKEN'; pattern = '\bgh[pousr]_[A-Za-z0-9]{30,}\b' },
    @{ id = 'SECRET.SLACK_TOKEN'; pattern = '\bxox[baprs]-[A-Za-z0-9\-]{10,}\b' },
    @{ id = 'SECRET.BEARER'; pattern = '(?i)\bauthorization\s*[:=]\s*bearer\s+[A-Za-z0-9._\-]{16,}' },
    @{ id = 'SECRET.JWT'; pattern = '\beyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\b' },
    @{ id = 'SECRET.ASSIGNMENT'; pattern = '(?i)\b(password|passwd|secret|api[_\-]?key|apikey|access[_\-]?token|auth[_\-]?token|client[_\-]?secret)\b\s*[:=]\s*["'']?[^\s"'']{8,}' },
    @{ id = 'SECRET.CONNECTION_STRING'; pattern = '(?i)\b[a-z][a-z0-9+.\-]*://[^\s:@/]+:[^\s:@/]+@[^\s/]+' }
)

$script:InjectionPatterns = @(
    '(?i)ignore\s+(?:all\s+)?(?:the\s+)?(?:previous|prior|above|earlier|preceding)\s+(?:instructions?|prompts?|rules?|messages?)',
    '(?i)disregard\s+(?:all\s+)?(?:the\s+)?(?:previous|prior|above|earlier)\s+',
    '(?i)forget\s+(?:everything|all)\s+(?:you|above|before)',
    '(?i)you\s+are\s+now\s+(?:a|an|the|in)\b',
    '(?i)act\s+as\s+(?:if\s+you\s+are\s+)?(?:a|an|the)\b',
    '(?i)pretend\s+(?:you|to\s+be)\b',
    '(?i)developer\s+mode',
    '(?i)reveal\s+(?:your|the)\s+(?:system\s+)?(?:prompt|instructions)',
    '(?i)print\s+(?:your|the)\s+(?:system\s+)?(?:prompt|instructions)',
    '(?i)repeat\s+(?:everything|all)\s+(?:above|before)',
    '(?i)(?:do\s+)?anything\s+now',
    '(?i)no\s+longer\s+bound\s+by',
    '(?i)without\s+any\s+(?:restrictions|limitations|filters)',
    '(?i)jailbreak|dan\s+mode|do\s+anything\s+now',
    '(?i)<\|im_(?:start|end)\|>',
    '(?i)<\|system\|>',
    '(?i)<\|endoftext\|>',
    '(?i)\[/?INST\]',
    '(?i)<<SYS>>',
    '(?i)\bbypass\s+(?:the\s+)?(?:safety|security|filter|guard\w*)\b'
)

$script:PlaceholderPatterns = @(
    '(?i)\[(?:paste|insert|your|placeholder|fill\s+in)[^\]]{0,40}\]',
    '\{\{[^}]{1,40}\}\}',
    '(?i)<your[_ ][a-z0-9_\- ]{1,30}>',
    '(?m)^\s*(?:\.\.\.|_{4,})\s*$',
    '(?i)\b(?:TODO|FIXME|XXX)\s*:\s*(?:fill|prompt|write|add)\b'
)

$script:PortableMechanisms = @(
    '(?i)response_format', '(?i)responseMimeType', '(?i)cache_control', '(?i)system_instruction',
    '(?i)tool_choice', '(?i)responseFormat', '(?i)"role"\s*:\s*"assistant"', '(?i)json_object',
    '(?i)structured\s+outputs?'
)

# Windows PowerShell 5.1 reads a BOM-less script as the system ANSI code page,
# so any literal box-drawing or arrow character in a .ps1 becomes mojibake and
# can even break a string literal. Every non-ASCII glyph is therefore built
# from its code point. Keep this table, and keep the scripts ASCII-only.
$script:Glyph = @{
    BoxTL    = 0x2554; BoxTR = 0x2557; BoxBL = 0x255A; BoxBR = 0x255D
    BoxH     = 0x2550; BoxV  = 0x2551
    BoxML    = 0x2560; BoxMR = 0x2563
    Rule     = 0x2500
    Ellipsis = 0x2026
    Middot   = 0x00B7
    Arrow    = 0x2192
}

function Get-KaraviPromptGlyph {
    <#
    .SYNOPSIS
    Returns one non-ASCII panel glyph as a [char], or its ASCII fallback when
    -Ascii is passed. A terminal that cannot render UTF-8 gets a readable
    panel instead of a broken one.
    #>
    param([Parameter(Mandatory)][string]$Name, [switch]$Ascii)
    if ($Ascii) { return [string]$script:GlyphAscii[$Name] }
    if (-not $script:Glyph.ContainsKey($Name)) { throw "Unknown glyph: $Name" }
    return [char]$script:Glyph[$Name]
}

$script:GlyphAscii = @{
    BoxTL    = '+'; BoxTR = '+'; BoxBL = '+'; BoxBR = '+'
    BoxH     = '-'; BoxV  = '|'
    BoxML    = '+'; BoxMR = '+'
    Rule     = '-'
    Ellipsis = '...'
    Middot   = '-'
    Arrow    = '->'
}

$script:FallbackMarkers = @(
    '(?i)fallback', '(?i)otherwise', '(?i)if\s+unavailable', '(?i)if\s+not\s+supported',
    '(?i)degrade', '(?i)portable', '(?i)another\s+provider', '(?i)other\s+providers'
)

$script:CredentialRequestPatterns = @(
    '(?im)^(?![^\r\n]*\b(?:do\s+not|don''t|never|must\s+not|no\s+)\b)[^\r\n]{0,60}\b(?:cat|type|echo|print|show|reveal|read|dump|list|export|output)\b[^\r\n]{0,40}\b(?:api[_ -]?key|secret|password|token|credential|private\s+key|\.env)\b',
    '(?im)^(?![^\r\n]*\b(?:do\s+not|don''t|never|must\s+not|no\s+)\b)[^\r\n]{0,60}\b(?:show|print|reveal|repeat)\b[^\r\n]{0,30}\byour\s+(?:system\s+prompt|instructions|api\s+key|credentials?)\b'
)

$script:BudgetByClass = @{
    frontier  = 2000
    'mid-tier' = 1000
    small      = 300
    reasoning  = 1500
}

function Get-KaraviPromptUntrustedTagNames {
    return $script:UntrustedTagNames
}

function Get-KaraviPromptBudget {
    param([string]$ModelClass)
    $key = (Get-KaraviPromptModelClass -Model $ModelClass)
    return $script:BudgetByClass[$key]
}

function Get-KaraviPromptModelClass {
    <#
    .SYNOPSIS
    Normalizes a model descriptor to one of: frontier, mid-tier, small, reasoning.
    #>
    param([string]$Model)

    if ([string]::IsNullOrWhiteSpace($Model)) { return 'frontier' }
    $m = $Model.ToLowerInvariant()
    if ($m -match 'reason|thinking|o[0-9]|extended') { return 'reasoning' }
    if ($m -match 'small|local|mini|nano|haiku|flash|lite|tiny|8b|20b') { return 'small' }
    if ($m -match 'mid|mini\b|haiku|flash|sonnet|4o-mini|balanced') { return 'mid-tier' }
    return 'frontier'
}

function Get-KaraviPromptTokenEstimate {
    <#
    .SYNOPSIS
    Approximate token count. Four characters per token; a coarse estimate
    for budgeting, not a billing figure. Non-Latin scripts pack more
    information per character, so the estimate is an over-count for them.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text)

    if ($null -eq $Text -or $Text.Length -eq 0) { return 0 }
    $hasCjk = $Text -match '[\u4E00-\u9FFF\u3040-\u30FF\uAC00-\uD7AF]'
    $perToken = if ($hasCjk) { 1.5 } else { 4.0 }
    return [int][math]::Ceiling($Text.Length / $perToken)
}

function Get-KaraviPromptDigest {
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text, [int]$Length = 16)

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes([string]$Text)
        $hash = $sha.ComputeHash($bytes)
    } finally {
        $sha.Dispose()
    }
    $hex = -join ($hash | ForEach-Object { $_.ToString('x2') })
    if ($Length -gt 0 -and $Length -lt $hex.Length) { $hex = $hex.Substring(0, $Length) }
    return "sha256:$hex"
}

function New-KaraviPromptRunId {
    param([Parameter(Mandatory)][string]$Digest, [datetime]$Timestamp = [datetime]::UtcNow)

    $compact = $Timestamp.ToUniversalTime().ToString('yyyyMMddTHHmmssZ', [cultureinfo]::InvariantCulture)
    $hex = ($Digest -replace '^sha256:', '')
    if ($hex.Length -gt 6) { $hex = $hex.Substring(0, 6) }
    return "kp-$compact-$hex"
}

function Get-KaraviPromptRoot {
    param([string]$RepoRoot)

    if ([string]::IsNullOrWhiteSpace($RepoRoot)) { $RepoRoot = (Get-Location).Path }
    return (Join-Path $RepoRoot 'karavi.temp.status/karavi-prompt')
}

function Get-KaraviPromptRunsRoot {
    param([string]$RepoRoot)
    return (Join-Path (Get-KaraviPromptRoot -RepoRoot $RepoRoot) 'runs')
}

function Get-KaraviPromptLedgerPath {
    param([string]$RepoRoot)
    return (Join-Path (Get-KaraviPromptRoot -RepoRoot $RepoRoot) 'karavi-prompt.jsonl')
}

function Write-KaraviPromptFile {
    <#
    .SYNOPSIS
    Writes UTF-8 without BOM, creating the parent directory.
    #>
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][AllowEmptyString()][string]$Content
    )

    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

function ConvertTo-KaraviPromptJson {
    <#
    .SYNOPSIS
    ConvertTo-Json plus readability fixups. Windows PowerShell escapes
    < > ' & ` + as \uXXXX, which makes a prompt envelope unreadable. Only
    characters that are safe inside a JSON string literal are restored, so the
    output stays valid JSON.
    #>
    param([Parameter(Mandatory)]$Object, [int]$Depth = 12)

    $json = ConvertTo-Json -InputObject $Object -Depth $Depth
    $map = [ordered]@{
        '\u003c' = '<'; '\u003e' = '>'; '\u0027' = "'"
        '\u0026' = '&'; '\u0060' = '`'; '\u002b' = '+'
    }
    foreach ($key in $map.Keys) { $json = $json.Replace($key, $map[$key]) }
    return $json
}

function Add-KaraviPromptFinding {
    <#
    .SYNOPSIS
    Appends one finding. Findings are the guard's only output shape.
    #>
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][System.Collections.Generic.List[object]]$Findings,
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][ValidateSet('block', 'warn', 'info')][string]$Severity,
        [Parameter(Mandatory)][string]$Message,
        [string]$Evidence = ''
    )

    $f = [ordered]@{ id = $Id; severity = $Severity; message = $Message }
    if ($Evidence) { $f['evidence'] = $Evidence }
    $Findings.Add([pscustomobject]$f)
}

function Protect-KaraviPromptText {
    <#
    .SYNOPSIS
    Replaces every secret match with [REDACTED] and reports each one.
    The caller must use the returned text, never the input.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text)

    $redactions = [System.Collections.Generic.List[string]]::new()
    $out = [string]$Text

    foreach ($rule in $script:SecretPatterns) {
        $matches = [regex]::Matches($out, $rule.pattern)
        if ($matches.Count -eq 0) { continue }
        $redactions.Add("$($rule.id)x$($matches.Count)")
        $out = [regex]::Replace($out, $rule.pattern, '[REDACTED]')
    }

    return [pscustomobject]@{ Text = $out; Redactions = $redactions }
}

function Get-KaraviPromptUntrustedSpans {
    <#
    .SYNOPSIS
    Returns the text of every declared untrusted tag in a prompt, plus the
    tag names and whether each tag was declared data-only.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text)

    $spans = [System.Collections.Generic.List[object]]::new()
    foreach ($tag in $script:UntrustedTagNames) {
        $open = [regex]::Match($Text, "(?is)<$([regex]::Escape($tag))(\s[^>]*)?>")
        $pattern = "(?is)<$([regex]::Escape($tag))(\s[^>]*)?>(.*?)</$([regex]::Escape($tag))\s*>"
        foreach ($m in [regex]::Matches($Text, $pattern)) {
            $attrs = $m.Groups[1].Value
            $declared = ($attrs -match '(?i)trust\s*=\s*"untrusted"') -or ($attrs -match '(?i)trust\s*=\s*''untrusted''')
            $spans.Add([pscustomobject]@{
                    Tag      = $tag
                    Declared = $declared
                    Content  = $m.Groups[2].Value
                })
        }
    }
    return $spans
}

function Test-KaraviPromptRtl {
    <#
    .SYNOPSIS
    True when the text contains RTL script. RTL content cannot be right-padded
    inside a box-drawing frame without breaking the frame in a bidi terminal.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text)
    return ($Text -match '[\u0590-\u05FF\u0600-\u06FF\u0700-\u074F\u0750-\u077F\u08A0-\u08FF\uFB1D-\uFB4F\uFB50-\uFDFF\uFE70-\uFEFF]')
}

function Measure-KaraviPromptDisplayWidth {
    <#
    .SYNOPSIS
    Column width of a string: East Asian Wide and Fullwidth count 2,
    combining marks and zero-width joiners count 0, everything else 1.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text)

    $width = 0
    foreach ($ch in $Text.ToCharArray()) {
        $code = [int]$ch
        if ($code -eq 0x200D -or $code -eq 0xFEFF) { continue }
        if ($code -ge 0x0300 -and $code -le 0x036F) { continue }
        if (($code -ge 0x1100 -and $code -le 0x115F) -or
            ($code -ge 0x2E80 -and $code -le 0xA4CF) -or
            ($code -ge 0xAC00 -and $code -le 0xD7A3) -or
            ($code -ge 0xF900 -and $code -le 0xFAFF) -or
            ($code -ge 0xFE30 -and $code -le 0xFE6F) -or
            ($code -ge 0xFF00 -and $code -le 0xFF60) -or
            ($code -ge 0xFFE0 -and $code -le 0xFFE6)) { $width += 2; continue }
        $width += 1
    }
    return $width
}

function Format-KaraviPromptBoxLine {
    <#
    .SYNOPSIS
    One content line padded to the panel's inner width.
    #>
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string]$Text,
        [Parameter(Mandatory)][int]$InnerWidth,
        [switch]$NoPad,
        [switch]$Ascii
    )

    $v = Get-KaraviPromptGlyph -Name 'BoxV' -Ascii:$Ascii
    if ($NoPad) { return "$v  $Text" }
    $pad = $InnerWidth - 2 - (Measure-KaraviPromptDisplayWidth -Text $Text)
    if ($pad -lt 0) { $pad = 0 }
    return "$v  $Text$(' ' * $pad)$v"
}

function ConvertTo-KaraviPromptNormalized {
    <#
    .SYNOPSIS
    Case- and whitespace-insensitive form, for equality comparison only.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text)
    return ([regex]::Replace($Text.Trim().ToLowerInvariant(), '\s+', ' '))
}

function Get-KaraviPromptNormalizedModel {
    <#
    .SYNOPSIS
    Returns the model class string, and $false when the input was a value
    this module does not recognize, so the caller can raise PORTABILITY.
    #>
    param([string]$Model)

    if ([string]::IsNullOrWhiteSpace($Model)) { return 'frontier' }
    $known = @('frontier', 'mid-tier', 'small', 'reasoning')
    $m = $Model.ToLowerInvariant()
    if ($known -contains $m) { return $m }
    return Get-KaraviPromptModelClass -Model $Model
}

function Test-KaraviPromptKnownModel {
    param([string]$Model)
    if ([string]::IsNullOrWhiteSpace($Model)) { return $true }
    $known = @('frontier', 'mid-tier', 'small', 'reasoning')
    return ($known -contains $Model.ToLowerInvariant())
}

function Get-KaraviPromptPatternSet {
    <#
    .SYNOPSIS
    Returns the regex list for a named check. One place owns every pattern so
    the guard, the armer, and the tests cannot drift apart.
    #>
    param(
        [Parameter(Mandatory)]
        [ValidateSet('secret', 'injection', 'placeholder', 'portable', 'fallback', 'credentialRequest', 'untrustedTag')]
        [string]$Name
    )

    switch ($Name) {
        'secret' { return @($script:SecretPatterns | ForEach-Object { $_.pattern }) }
        'injection' { return $script:InjectionPatterns }
        'placeholder' { return $script:PlaceholderPatterns }
        'portable' { return $script:PortableMechanisms }
        'fallback' { return $script:FallbackMarkers }
        'credentialRequest' { return $script:CredentialRequestPatterns }
        'untrustedTag' { return $script:UntrustedTagNames }
    }
}

Export-ModuleMember -Function `
    Get-KaraviPromptUntrustedTagNames,
    Get-KaraviPromptBudget,
    Get-KaraviPromptModelClass,
    Get-KaraviPromptTokenEstimate,
    Get-KaraviPromptDigest,
    New-KaraviPromptRunId,
    Get-KaraviPromptRoot,
    Get-KaraviPromptRunsRoot,
    Get-KaraviPromptLedgerPath,
    Write-KaraviPromptFile,
    ConvertTo-KaraviPromptJson,
    Add-KaraviPromptFinding,
    Protect-KaraviPromptText,
    Get-KaraviPromptUntrustedSpans,
    Test-KaraviPromptRtl,
    Measure-KaraviPromptDisplayWidth,
    Format-KaraviPromptBoxLine,
    ConvertTo-KaraviPromptNormalized,
    Get-KaraviPromptNormalizedModel,
    Test-KaraviPromptKnownModel,
    Get-KaraviPromptPatternSet,
    Get-KaraviPromptGlyph
