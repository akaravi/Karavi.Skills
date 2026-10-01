$skillRoot = Split-Path -Parent $PSScriptRoot
$scripts = Join-Path $skillRoot 'scripts'
$arm = Join-Path $scripts 'karavi-prompt.arm.ps1'
$panel = Join-Path $scripts 'karavi-prompt.panel.ps1'
$ledger = Join-Path $scripts 'karavi-prompt.ledger.ps1'
$auto = Join-Path $scripts 'karavi-prompt.auto.ps1'
Import-Module (Join-Path $scripts 'karavi-prompt.common.psm1') -Force

# The scripts are documented as shell entry points, and they terminate with
# `exit`. Invoking them in-process from a Pester block would tear down the
# test scope, so every call goes through a child PowerShell exactly as a user
# would run it.
function Invoke-SkillScript {
    param([string]$Script, [string[]]$Arguments = @())
    $argv = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $Script) + $Arguments
    $out = & powershell.exe @argv 2>&1
    return [pscustomobject]@{ Text = ($out | Out-String); Exit = $LASTEXITCODE }
}

$ArmedGood = @'
<mission>Rewrite docs/retention.md so it matches karavi-folder's current cleanup rules.</mission>
<scope>Do: edit that one file. Do not: touch scripts or tests.</scope>
<output_format>Return the full file content in one fenced block.</output_format>
<acceptance>- The stale karavi.temp.* list is gone.
- verify by running verify-karavi-prompt-skill.ps1</acceptance>
You are done when the file is written. Do not ask follow-up questions.
'@

function New-Workspace {
    $dir = Join-Path ([IO.Path]::GetTempPath()) ('kp-run-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $dir | Out-Null
    $spec = [ordered]@{
        rawPrompt   = 'fix the retention doc'
        armedPrompt = $ArmedGood
        techniques  = @('xml-structuring', 'scoped-constraint')
        language    = 'en'
        notes       = 'added scope, output contract, acceptance and stop rule'
        intent      = [ordered]@{
            goal         = 'Rewrite docs/retention.md'
            scope        = @('docs/retention.md')
            outOfScope   = @('scripts', 'tests')
            constraints  = @('no script changes')
            acceptance   = @('stale list removed')
            verifyMethod = 'run verify script'
            untrusted    = @()
        }
        target      = [ordered]@{ host = 'omp'; agent = 'task'; model = 'frontier'; mode = 'read-only' }
    }
    $path = Join-Path $dir 'spec.json'
    ($spec | ConvertTo-Json -Depth 8) | Set-Content -LiteralPath $path -Encoding UTF8
    return [pscustomobject]@{ Root = $dir; Spec = $path }
}

function Set-ArmedPrompt {
    param([string]$Root, [string]$SpecPath, [string]$Armed, [string[]]$Untrusted = @())
    $spec = Get-Content -LiteralPath $SpecPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $spec.armedPrompt = $Armed
    $spec.intent.untrusted = @($Untrusted)
    ($spec | ConvertTo-Json -Depth 8) | Set-Content -LiteralPath $SpecPath -Encoding UTF8
}

function Invoke-Arm {
    param([string]$Root, [string]$SpecPath, [string[]]$Extra = @())
    return Invoke-SkillScript -Script $arm -Arguments (@('-Spec', $SpecPath, '-RepoRoot', $Root) + $Extra)
}

function Get-RunEnvelope {
    param([string]$Root)
    $runs = Join-Path $Root 'karavi.temp.status/karavi-prompt/runs'
    return (Get-ChildItem -LiteralPath $runs -Filter '*.json' | Select-Object -First 1).FullName
}

function Split-ArmOutput {
    param([string]$Text)
    $marker = '---DISPATCH---'
    $i = $Text.IndexOf($marker)
    if ($i -lt 0) { return [pscustomobject]@{ Panel = $Text; Dispatch = '' } }
    return [pscustomobject]@{
        Panel    = $Text.Substring(0, $i)
        Dispatch = $Text.Substring($i + $marker.Length).Trim()
    }
}

Describe 'karavi-prompt arming pipeline' {
    It 'arms, guards, panels, ledgers, and returns the verbatim dispatch text' {
        $w = New-Workspace
        try {
            $r = Invoke-Arm -Root $w.Root -SpecPath $w.Spec
            $parts = Split-ArmOutput -Text $r.Text

            $r.Exit | Should Be 0
            $parts.Panel | Should Match 'KARAVI'
            $parts.Panel | Should Match 'IN EXECUTION'
            $r.Text | Should Match 'VERDICT=pass'
            $parts.Panel | Should Match 'host=omp agent=task model=frontier mode=read-only'
            $parts.Panel | Should Match 'sha256:'
            $parts.Panel | Should Match 'raw=6 tok'
            $parts.Dispatch | Should Match '<mission>'

            $envelopePath = Get-RunEnvelope -Root $w.Root
            $envelopePath | Should Not BeNullOrEmpty
            $envelope = Get-Content -LiteralPath $envelopePath -Raw -Encoding UTF8 | ConvertFrom-Json
            $envelope.stage | Should Be 'armed'
            $envelope.guard.verdict | Should Be 'pass'
            # The persisted artifact is the source of truth; stdout may carry
            # CRLF from the console, which is not a content difference.
            $envelope.dispatch.Replace("`r`n", "`n") | Should Be $parts.Dispatch.Replace("`r`n", "`n")
            $envelope.digest | Should Match '^sha256:[0-9a-f]{16}$'
            $envelope.id | Should Match '^kp-\d{8}T\d{6}Z-[0-9a-f]{6}$'
            $envelope.rawDigest | Should Not Be $envelope.digest

            $ledgerPath = Join-Path $w.Root 'karavi.temp.status/karavi-prompt/karavi-prompt.jsonl'
            Test-Path -LiteralPath $ledgerPath -PathType Leaf | Should Be $true
            $entry = (Get-Content -LiteralPath $ledgerPath -Encoding UTF8 | Select-Object -First 1) | ConvertFrom-Json
            $entry.event | Should Be 'armed'
            $entry.id | Should Be $envelope.id
            $entry.digest | Should Be $envelope.digest
        } finally { Remove-Item -LiteralPath $w.Root -Recurse -Force -ErrorAction SilentlyContinue }
    }

    It 'blocks a run before a panel exists and never persists the credential' {
        $w = New-Workspace
        try {
            Set-ArmedPrompt -Root $w.Root -SpecPath $w.Spec -Armed 'Use AKIAIOSFODNN7EXAMPLE for the call. <output_format>text</output_format><acceptance>done</acceptance>You are done. Do not ask follow-up questions.'
            $r = Invoke-Arm -Root $w.Root -SpecPath $w.Spec

            $r.Exit | Should Be 1
            $r.Text | Should Match 'VERDICT=block'
            $r.Text | Should Match 'PANEL=none'
            $r.Text | Should Not Match 'IN EXECUTION'
            $r.Text | Should Not Match 'AKIAIOSFODNN7EXAMPLE'

            $runsRoot = Join-Path $w.Root 'karavi.temp.status/karavi-prompt/runs'
            foreach ($f in (Get-ChildItem -LiteralPath $runsRoot -File)) {
                (Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8) | Should Not Match 'AKIAIOSFODNN7EXAMPLE'
            }
        } finally { Remove-Item -LiteralPath $w.Root -Recurse -Force -ErrorAction SilentlyContinue }
    }

    It 'renders a closed box whose right border lines up for LTR content' {
        $w = New-Workspace
        try {
            Invoke-Arm -Root $w.Root -SpecPath $w.Spec | Out-Null
            $r = Invoke-SkillScript -Script $panel -Arguments @('-Run', (Get-RunEnvelope -Root $w.Root), '-Format', 'Box', '-Width', '78', '-Ascii')
            $box = $r.Text.TrimEnd()
            $box | Should Match 'IN EXECUTION'

            $widths = @(($box -split "`r?`n") | ForEach-Object { Measure-KaraviPromptDisplayWidth -Text $_ })
            ($widths | Measure-Object -Minimum).Minimum | Should Be 80
            ($widths | Measure-Object -Maximum).Maximum | Should Be 80
        } finally { Remove-Item -LiteralPath $w.Root -Recurse -Force -ErrorAction SilentlyContinue }
    }

    It 'truncates a long prompt and points at the full file' {
        $w = New-Workspace
        try {
            Set-ArmedPrompt -Root $w.Root -SpecPath $w.Spec -Armed (($ArmedGood) + ("`n<line>extra content line</line>" * 200))
            $r = Invoke-Arm -Root $w.Root -SpecPath $w.Spec -Extra @('-MaxPromptLines', '10')
            $r.Text | Should Match '\+1\d\d more lines'
            $r.Text | Should Match '\.armed\.txt'
        } finally { Remove-Item -LiteralPath $w.Root -Recurse -Force -ErrorAction SilentlyContinue }
    }

    It 'falls back to the markdown panel for RTL content' {
        $w = New-Workspace
        try {
            $rtl = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'fixtures/rtl-armed-prompt.txt') -Raw -Encoding UTF8
            Set-ArmedPrompt -Root $w.Root -SpecPath $w.Spec -Armed $rtl
            $r = Invoke-Arm -Root $w.Root -SpecPath $w.Spec

            $r.Text | Should Match '> \*\*KARAVI'
            $r.Text | Should Match '> ```text'
            $r.Text | Should Not Match ([string](Get-KaraviPromptGlyph -Name 'BoxTL'))
        } finally { Remove-Item -LiteralPath $w.Root -Recurse -Force -ErrorAction SilentlyContinue }
    }

    It 'closes a run into the ledger with an outcome and a score' {
        $w = New-Workspace
        try {
            Invoke-Arm -Root $w.Root -SpecPath $w.Spec | Out-Null
            Invoke-SkillScript -Script $ledger -Arguments @(
                '-Id', 'kp-test-run', '-Event', 'closed', '-Outcome', 'accept',
                '-Score', '4.2', '-Note', 'rubric', '-RepoRoot', $w.Root) | Out-Null
            $list = Invoke-SkillScript -Script $ledger -Arguments @('-List', '-RepoRoot', $w.Root)
            $list.Text | Should Match 'ENTRIES=2'
            $list.Text | Should Match '"outcome":"accept"'
            $list.Text | Should Match '"score":4.2'
        } finally { Remove-Item -LiteralPath $w.Root -Recurse -Force -ErrorAction SilentlyContinue }
    }

    It 'reports a missing spec as an input error' {
        $r = Invoke-Arm -Root ([IO.Path]::GetTempPath()) -SpecPath (Join-Path ([IO.Path]::GetTempPath()) 'kp-nope.json')
        $r.Exit | Should Be 3
    }

    It 'measures display width by code point rather than char count' {
        Measure-KaraviPromptDisplayWidth -Text 'abc' | Should Be 3
        Measure-KaraviPromptDisplayWidth -Text ([string][char]0x4E2D) | Should Be 2
        Measure-KaraviPromptDisplayWidth -Text ('a' + [char]0x200D + 'b') | Should Be 2
        Measure-KaraviPromptDisplayWidth -Text '' | Should Be 0
    }

    It 'toggles auto on, status, and auto off correctly' {
        $w = New-Workspace
        try {
            # 1. Initial status should be OFF
            $s0 = Invoke-SkillScript -Script $auto -Arguments @('-Status', '-Format', 'Json', '-RepoRoot', $w.Root)
            $s0.Exit | Should Be 0
            $json0 = $s0.Text | ConvertFrom-Json
            $json0.enabled | Should Be $false

            # 2. Turn auto ON
            $s1 = Invoke-SkillScript -Script $auto -Arguments @('-On', '-Targets', 'task,pm-builder', '-Format', 'Json', '-RepoRoot', $w.Root)
            $s1.Exit | Should Be 0
            $json1 = $s1.Text | ConvertFrom-Json
            $json1.enabled | Should Be $true
            $json1.targets.Count | Should Be 2

            # 3. Status should now report ON
            $s2 = Invoke-SkillScript -Script $auto -Arguments @('-Status', '-RepoRoot', $w.Root)
            $s2.Text | Should Match 'AUTO ON'
            $s2.Text | Should Match 'Targets: task, pm-builder'

            # 4. Turn auto OFF
            $s3 = Invoke-SkillScript -Script $auto -Arguments @('-Off', '-Format', 'Json', '-RepoRoot', $w.Root)
            $s3.Exit | Should Be 0
            $json3 = $s3.Text | ConvertFrom-Json
            $json3.enabled | Should Be $false

            # 5. Status should now report OFF
            $s4 = Invoke-SkillScript -Script $auto -Arguments @('-Status', '-RepoRoot', $w.Root)
            $s4.Text | Should Match 'AUTO OFF'
        } finally { Remove-Item -LiteralPath $w.Root -Recurse -Force -ErrorAction SilentlyContinue }
    }
}
