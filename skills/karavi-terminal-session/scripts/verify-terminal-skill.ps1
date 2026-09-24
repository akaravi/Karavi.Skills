[CmdletBinding()]
param(
    [string]$SkillRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$failures = [System.Collections.Generic.List[string]]::new()
$legacyName = 'karavi-' + 'powershell-session'

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
    'SKILL.md', 'README.md',
    'references/agent-terminals.md', 'references/command-classification.md',
    'references/permission-model.md', 'references/powershell-core.md',
    'references/windows-terminal.md', 'references/computer-use-bridge.md',
    'references/orca-terminal.md', 'references/session-lifecycle.md',
    'references/verification-and-capture.md', 'references/windows-devops.md',
    'references/karavi-integration.md', 'references/discovery-and-install.md',
    'references/examples.md', 'scripts/karavi-terminal-session.agent-sanity.ps1',
    'scripts/karavi-terminal-session.open-interactive.ps1', 'scripts/verify-terminal-skill.ps1'
)
$required | ForEach-Object { Require-File $_ }

$skillText = Get-Content -LiteralPath (Join-Path $SkillRoot 'SKILL.md') -Raw
if ($skillText -notmatch '(?m)^name:\s*karavi-terminal-session\s*$') { $failures.Add('SKILL.md name is not karavi-terminal-session') }
if ($skillText -notmatch '(?m)^description:\s*>') { $failures.Add('SKILL.md description block is missing') }
if ($skillText -notmatch 'Use when|TRIGGER when') { $failures.Add('SKILL.md trigger guidance is missing') }
if ($skillText.Contains($legacyName)) { $failures.Add('Legacy skill name remains in SKILL.md') }

$allTextFiles = Get-ChildItem -LiteralPath $SkillRoot -Recurse -File -Include *.md,*.ps1
foreach ($file in $allTextFiles) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $failures.Add("UTF-8 BOM found: $($file.FullName)")
    }
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    if ($text.Contains($legacyName)) {
        $failures.Add("Legacy skill name remains: $($file.FullName)")
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "PASS: $SkillRoot"
Write-Output "FILES=$($allTextFiles.Count)"
Write-Output 'LEGACY_NAME=absent'
Write-Output 'BOM=absent'
exit 0
