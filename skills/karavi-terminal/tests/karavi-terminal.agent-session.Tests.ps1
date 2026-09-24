$skillRoot = Split-Path -Parent $PSScriptRoot
$scripts = Join-Path $skillRoot 'scripts'

Describe 'karavi-terminal agent session' {
    It 'opens invokes lists and closes an owned session' {
        $root = Join-Path ([IO.Path]::GetTempPath()) ('karavi-terminal-' + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $root | Out-Null
        try {
            $open = & (Join-Path $scripts 'karavi-terminal.open-agent-session.ps1') -RepoRoot $root | ConvertFrom-Json
            $open.status | Should Be 'ready'
            (Get-Process -Id $open.pid -ErrorAction Stop) | Should Not BeNullOrEmpty
            $result = & (Join-Path $scripts 'karavi-terminal.invoke-agent-command.ps1') -RepoRoot $root -SessionId $open.sessionId -Command 'Write-Output test-output' | ConvertFrom-Json
            $result.status | Should Be 'completed'
            $result.stdout | Should Match 'test-output'
            $live = @(& (Join-Path $scripts 'karavi-terminal.get-agent-session.ps1') -RepoRoot $root | ConvertFrom-Json)
            $live.sessionId | Should Be $open.sessionId
            $close = & (Join-Path $scripts 'karavi-terminal.close-agent-session.ps1') -RepoRoot $root -SessionId $open.sessionId | ConvertFrom-Json
            $close.status | Should Be 'closed'
        } finally { Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue }
    }
}
