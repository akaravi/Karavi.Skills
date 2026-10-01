[CmdletBinding()]
param(
    [string]$SkillRoot
)

# $PSScriptRoot is not populated inside a param() default on every host, so the
# fallback is resolved in the body.
if (-not $SkillRoot) { $SkillRoot = Split-Path -Parent $PSScriptRoot }

$ErrorActionPreference = 'Stop'
$failures = [System.Collections.Generic.List[string]]::new()

function Require-File([string]$RelativePath) {
    $path = Join-Path $SkillRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $failures.Add("Missing file: $RelativePath")
    }
}

if (-not (Test-Path -LiteralPath $SkillRoot -PathType Container)) {
    throw "Skill root does not exist: $SkillRoot"
}

$required = @(
    'SKILL.md', 'README.md', 'LICENSE',
    'references/arming-pipeline.md', 'references/panel-and-dispatch.md',
    'references/prompt-architecture.md', 'references/optimization-playbook.md',
    'references/anti-patterns.md', 'references/constraints-and-guardrails.md',
    'references/security-and-injection.md', 'references/grounding-and-context.md',
    'references/agent-and-tool-prompts.md', 'references/reasoning-and-chaining.md',
    'references/evaluation-and-scoring.md', 'references/templates.md',
    'scripts/karavi-prompt.common.psm1', 'scripts/karavi-prompt.guard.ps1',
    'scripts/karavi-prompt.panel.ps1', 'scripts/karavi-prompt.arm.ps1',
    'scripts/karavi-prompt.ledger.ps1', 'scripts/karavi-prompt.auto.ps1',
    'scripts/verify-karavi-prompt-skill.ps1',
    'tests/karavi-prompt.guard.Tests.ps1', 'tests/karavi-prompt.pipeline.Tests.ps1',
    'tests/fixtures/rtl-armed-prompt.txt'
)
$required | ForEach-Object { Require-File $_ }

$skillText = Get-Content -LiteralPath (Join-Path $SkillRoot 'SKILL.md') -Raw -Encoding UTF8
if ($skillText -notmatch '(?m)^name:\s*karavi-prompt\s*$') { $failures.Add('SKILL.md name is not karavi-prompt') }
if ($skillText -notmatch '(?m)^description:\s*>') { $failures.Add('SKILL.md description block is missing') }
if ($skillText -notmatch 'TRIGGER when') { $failures.Add('SKILL.md trigger guidance is missing') }
if ($skillText -notmatch 'DO NOT TRIGGER when') { $failures.Add('SKILL.md non-trigger guidance is missing') }
if ($skillText -notmatch 'Never dispatch a raw prompt') { $failures.Add('SKILL.md is missing the arm-before-dispatch rule') }
if ($skillText -notmatch 'panel is mandatory') { $failures.Add('SKILL.md is missing the mandatory panel rule') }
if ($skillText -notmatch 'fail-closed') { $failures.Add('SKILL.md is missing the fail-closed guard rule') }

$lineCount = ($skillText -split "`r?`n").Count
if ($lineCount -gt 500) { $failures.Add("SKILL.md is $lineCount lines; the budget is 500") }

# Every reference and script the SKILL.md points at must exist on disk.
$linked = [regex]::Matches($skillText, '\]\((references/[^)]+|scripts/[^)]+)\)')
foreach ($m in $linked) {
    $rel = $m.Groups[1].Value
    if (-not (Test-Path -LiteralPath (Join-Path $SkillRoot $rel) -PathType Leaf)) {
        $failures.Add("SKILL.md links a missing file: $rel")
    }
}

# Every file is UTF-8 without BOM and parses as PowerShell where applicable.
$allTextFiles = Get-ChildItem -LiteralPath $SkillRoot -Recurse -File -Include *.md, *.ps1, *.psm1, *.txt
foreach ($file in $allTextFiles) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $failures.Add("UTF-8 BOM found: $($file.FullName)")
    }
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    if ($file.Extension -in @('.ps1', '.psm1')) {
        # A BOM-less script is read as the ANSI code page by Windows PowerShell
        # 5.1, so a literal non-ASCII glyph is corrupted at parse time.
        $offender = [regex]::Match($text, '[^\x00-\x7F]')
        if ($offender.Success) {
            $failures.Add("Non-ASCII character U+{0:X4} in $($file.Name); build glyphs with Get-KaraviPromptGlyph" -f [int][char]$offender.Value)
        }
        $errors = $null
        $tokens = $null
        [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors) | Out-Null
        foreach ($e in $errors) {
            $failures.Add("PowerShell parse error in $($file.Name): $($e.Message)")
        }
    }
}

# No armed run may persist a credential: the guard redacts, and this asserts
# the redaction path is wired into every artifact writer.
$guardText = Get-Content -LiteralPath (Join-Path $SkillRoot 'scripts/karavi-prompt.guard.ps1') -Raw -Encoding UTF8
if ($guardText -notmatch 'Protect-KaraviPromptText') { $failures.Add('guard.ps1 does not redact before reporting') }
if ($guardText -notmatch '\$armedSafe') { $failures.Add('guard.ps1 does not scan the redacted text') }

$armText = Get-Content -LiteralPath (Join-Path $SkillRoot 'scripts/karavi-prompt.arm.ps1') -Raw -Encoding UTF8
if ($armText -notmatch "guard\.armedText") { $failures.Add('arm.ps1 does not dispatch the guard-redacted text') }
if ($armText -notmatch "guard.verdict -eq 'block'") { $failures.Add('arm.ps1 does not stop on a block verdict') }

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "PASS: $SkillRoot"
Write-Output "FILES=$($allTextFiles.Count)"
Write-Output "SKILL_LINES=$lineCount"
Write-Output 'BOM=absent'
Write-Output 'PARSE=clean'
exit 0
