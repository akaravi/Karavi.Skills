#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$scripts = Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts'
$sandbox = Join-Path ([IO.Path]::GetTempPath()) ('karavi-folder-tests-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $sandbox | Out-Null
$failures = @()
function Assert($Condition, $Message) { if (-not $Condition) { throw $Message } }
function Put($Path, $Text) {
    [IO.Directory]::CreateDirectory((Split-Path $Path -Parent)) | Out-Null
    [IO.File]::WriteAllText($Path, $Text, [Text.UTF8Encoding]::new($false))
}
function Snapshot($Root) {
    @(Get-ChildItem -LiteralPath $Root -Recurse -Force | Sort-Object FullName | ForEach-Object {
        $relative = $_.FullName.Substring($Root.Length)
        if ($_.PSIsContainer) { "D:$relative" } else { "F:${relative}:$((Get-FileHash -LiteralPath $_.FullName).Hash)" }
    }) -join "`n"
}
function Case($Name, [scriptblock]$Body) {
    try { & $Body; Write-Output "PASS $Name" } catch { $script:failures += "$Name : $($_.Exception.Message)"; Write-Output "FAIL $Name : $($_.Exception.Message)" }
}
try {
    foreach ($entry in @('init', 'create')) {
        foreach ($core in @($false, $true)) {
            Case "$entry Core=$core creates rules and reruns unchanged" {
                $root = Join-Path $sandbox "$entry-$core"
                [IO.Directory]::CreateDirectory($root) | Out-Null
                $output = (& (Join-Path $scripts "karavi-folder.$entry.ps1") -RepoRoot $root -Core:$core 6>&1 | Out-String)
                Assert (Test-Path -LiteralPath "$root/karavi/karavi.Rules" -PathType Container) 'Missing canonical rules'
                $sentinels = @(Get-ChildItem -LiteralPath "$root/karavi" -Recurse -Force -Filter .gitkeep)
                Assert ($sentinels.Count -eq $(if ($core) { 10 } else { 21 })) 'Wrong canonical path count'
                $before = Snapshot $root
                & (Join-Path $scripts "karavi-folder.$entry.ps1") -RepoRoot $root -Core:$core 6>&1 | Out-Null
                Assert ((Snapshot $root) -ceq $before) 'Rerun changed tree or bytes'
            }
        }
    }
    Case 'all seven aliases preserve files, report collisions, and rerun unchanged' {
        $root = Join-Path $sandbox 'aliases'
        $aliases = @('rules','rule','project-rules','agent-rules','coding-rules','karavi.rules','karavi.project.rules')
        foreach ($alias in $aliases) { Put "$root/karavi/$alias/coding.md" $alias }
        Put "$root/karavi/karavi.rules/nested/agent.md" 'nested'
        $output = (& "$scripts/karavi-folder.init.ps1" -RepoRoot $root 6>&1 | Out-String)
        $canonical = Get-ChildItem -LiteralPath "$root/karavi" -Directory | Where-Object Name -CEQ 'karavi.Rules'
        Assert ($null -ne $canonical) 'Canonical spelling not normalized'
        $contents = @(Get-ChildItem -LiteralPath $canonical.FullName -File -Recurse | ForEach-Object { [IO.File]::ReadAllText($_.FullName) })
        foreach ($alias in $aliases) { Assert ($contents -ccontains $alias) "Lost data from $alias" }
        Assert ($output -match 'Collisions: [1-9]') 'Missing final collision report'
        $before = Snapshot $root
        & "$scripts/karavi-folder.create.ps1" -RepoRoot $root 6>&1 | Out-Null
        Assert ((Snapshot $root) -ceq $before) 'Alias rerun duplicated rules'
    }
    Case 'file-directory collisions preserve both types' {
        $root = Join-Path $sandbox 'types'
        Put "$root/karavi/karavi.Rules/group" 'existing file'
        Put "$root/karavi/rules/group/child.md" 'incoming directory'
        Put "$root/karavi/karavi.Rules/other/child.md" 'existing directory'
        Put "$root/karavi/rules/other" 'incoming file'
        & "$scripts/karavi-folder.init.ps1" -RepoRoot $root 6>&1 | Out-Null
        $contents = @(Get-ChildItem -LiteralPath "$root/karavi/karavi.Rules" -Recurse -File | ForEach-Object { [IO.File]::ReadAllText($_.FullName) })
        foreach ($value in @('existing file','incoming directory','existing directory','incoming file')) { Assert ($contents -contains $value) "Lost $value" }
    }
    Case 'WhatIf preserves all bytes and reports planned collision' {
        $root = Join-Path $sandbox 'preview'
        Put "$root/karavi/karavi.Rules/coding.md" 'canonical'
        Put "$root/karavi/rules/coding.md" 'legacy'
        $before = Snapshot $root
        $output = (& "$scripts/karavi-folder.init.ps1" -RepoRoot $root -WhatIf 6>&1 | Out-String)
        Assert ((Snapshot $root) -ceq $before) 'WhatIf mutated files'
        Assert ($output -match '\.legacy-') 'WhatIf omitted collision destination'
    }
    Case 'existing suffix is never overwritten' {
        $root = Join-Path $sandbox 'suffix'
        Put "$root/karavi/karavi.Rules/coding.md" 'canonical'
        Put "$root/karavi/karavi.Rules/coding.legacy-1.md" 'previous collision'
        Put "$root/karavi/rules/coding.md" 'new collision'
        & "$scripts/karavi-folder.init.ps1" -RepoRoot $root 6>&1 | Out-Null
        Assert ([IO.File]::ReadAllText("$root/karavi/karavi.Rules/coding.legacy-1.md") -eq 'previous collision') 'Suffix overwritten'
        Assert ([IO.File]::ReadAllText("$root/karavi/karavi.Rules/coding.legacy-2.md") -eq 'new collision') 'Incoming collision missing'
    }
    Case 'existing empty rules directory remains versionable' {
        $root = Join-Path $sandbox 'empty'
        [IO.Directory]::CreateDirectory("$root/karavi/karavi.Rules") | Out-Null
        & "$scripts/karavi-folder.init.ps1" -RepoRoot $root -NoMigrate 6>&1 | Out-Null
        Assert (Test-Path -LiteralPath "$root/karavi/karavi.Rules/.gitkeep") 'Missing existing-directory sentinel'
    }
    Case 'canonical file refuses migration without losing bytes' {
        $root = Join-Path $sandbox 'occupied'
        Put "$root/karavi/karavi.Rules" 'occupied'
        Put "$root/karavi/rules/coding.md" 'legacy'
        $before = Snapshot $root
        $refused = $false
        try { & "$scripts/karavi-folder.init.ps1" -RepoRoot $root 6>&1 | Out-Null } catch { $refused = $true }
        Assert $refused 'Canonical file was not refused'
        Assert ((Snapshot $root) -ceq $before) 'Refusal changed source'
    }
    Case 'deep cleanup preserves canonical rule files in cache-named directories' {
        $root = Join-Path $sandbox 'cleanup'
        Put "$root/karavi/karavi.Rules/bin/coding.md" 'preserved rule'
        $before = Snapshot $root
        & "$scripts/karavi-folder.clean.ps1" -RepoRoot $root -Deep 6>&1 | Out-Null
        Assert ((Snapshot $root) -ceq $before) 'Cleanup removed canonical rules'
    }
    Case 'mixed-case canonical folders do not migrate into themselves' {
        $root = Join-Path $sandbox 'mixed-case'
        Put "$root/karavi/KARAVI.RULES/coding.md" 'unchanged'
        Put "$root/karavi/karavi.ONLINECONTENT/content.md" 'unchanged'
        & "$scripts/karavi-folder.init.ps1" -RepoRoot $root 6>&1 | Out-Null
        Assert (Test-Path -LiteralPath "$root/karavi/karavi.Rules/coding.md") 'Case-only migration renamed a rule file'
        $before = Snapshot $root
        & "$scripts/karavi-folder.init.ps1" -RepoRoot $root 6>&1 | Out-Null
        Assert ((Snapshot $root) -ceq $before) 'Case-only rerun changed files'
    }
    Case 'existing UTF8 gitignore content survives append' {
        $root = Join-Path $sandbox 'ignore-encoding'
        $original = '# ' + [char]0x0642 + [char]0x0648 + [char]0x0627 + [char]0x0646 + [char]0x06CC + [char]0x0646 + "`nexisting/`n"
        Put "$root/.gitignore" $original
        & "$scripts/karavi-folder.init.ps1" -RepoRoot $root 6>&1 | Out-Null
        Assert ([IO.File]::ReadAllText("$root/.gitignore").StartsWith($original)) 'Existing UTF8 text changed'
    }
} finally {
    $resolved = [IO.Path]::GetFullPath($sandbox)
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
    if (-not $resolved.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase) -or (Split-Path $resolved -Leaf) -notlike 'karavi-folder-tests-*') { throw 'Unsafe test cleanup path' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
if ($failures.Count) { throw "$($failures.Count) scenario(s) failed" }
