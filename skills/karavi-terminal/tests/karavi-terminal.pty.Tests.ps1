$skillRoot = Split-Path -Parent $PSScriptRoot
$scripts = Join-Path $skillRoot 'scripts'

Describe 'karavi-terminal pty session' {
    It 'launches sends keys captures and closes a ConPTY session' {
        $root = Join-Path ([IO.Path]::GetTempPath()) ('karavi-pty-' + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $root | Out-Null
        try {
            $launch = & (Join-Path $scripts 'karavi-terminal.pty-launch.ps1') -RepoRoot $root | ConvertFrom-Json
            $launch.ok | Should Be $true
            $launch.alive | Should Be $true
            $sent = & (Join-Path $scripts 'karavi-terminal.pty-send-keys.ps1') -RepoRoot $root -SessionId $launch.sessionId -Keys "Write-Output karavi-pty-marker\r" | ConvertFrom-Json
            $sent.buffer | Should Match 'karavi-pty-marker'
            $screen = & (Join-Path $scripts 'karavi-terminal.pty-screenshot.ps1') -RepoRoot $root -SessionId $launch.sessionId | ConvertFrom-Json
            $screen.buffer | Should Match 'karavi-pty-marker'
            $secret = & (Join-Path $scripts 'karavi-terminal.pty-send-keys.ps1') -RepoRoot $root -SessionId $launch.sessionId -Keys "Write-Output password=supersecretvalue\r" | ConvertFrom-Json
            $secret.buffer | Should Match 'password=\[REDACTED\]'
            $secret.buffer | Should Not Match 'supersecretvalue'
            $resized = & (Join-Path $scripts 'karavi-terminal.pty-resize.ps1') -RepoRoot $root -SessionId $launch.sessionId -Columns 100 -Rows 40 | ConvertFrom-Json
            $resized.cols | Should Be 100
            $resized.rows | Should Be 40
            $list = & (Join-Path $scripts 'karavi-terminal.pty-list.ps1') -RepoRoot $root | ConvertFrom-Json
            @($list.sessions).sessionId | Should Be $launch.sessionId
            $closed = & (Join-Path $scripts 'karavi-terminal.pty-close.ps1') -RepoRoot $root -SessionId $launch.sessionId | ConvertFrom-Json
            $closed.status | Should Be 'closed'
        } finally {
            & (Join-Path $scripts 'karavi-terminal.pty-close-host.ps1') -RepoRoot $root | Out-Null
            Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'rejects a working directory outside the repo root' {
        $root = Join-Path ([IO.Path]::GetTempPath()) ('karavi-pty-' + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $root | Out-Null
        try {
            $failed = $false
            try {
                & (Join-Path $scripts 'karavi-terminal.pty-launch.ps1') -RepoRoot $root -WorkingDirectory ([IO.Path]::GetTempPath()) | Out-Null
            } catch { $failed = $true }
            $failed | Should Be $true
        } finally {
            & (Join-Path $scripts 'karavi-terminal.pty-close-host.ps1') -RepoRoot $root | Out-Null
            Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
