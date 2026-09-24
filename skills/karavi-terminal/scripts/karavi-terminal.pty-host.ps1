param([Parameter(Mandatory = $true)][string]$RepoRoot)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path -LiteralPath $RepoRoot).Path
$hashBytes = [Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($root.ToLowerInvariant()))
$hash = ([BitConverter]::ToString($hashBytes)).Replace('-', '').Substring(0, 16).ToLowerInvariant()
$pipeName = "karavi-pty-$hash"
$mutexName = "Local\karavi-pty-$hash"
$metaPath = Join-Path $root 'karavi.temp.status/karavi-terminal-pty-host.json'
$logPath = Join-Path $root 'karavi.temp.status/karavi-terminal-pty-host.log'
$maxSessions = 20
$maxRawChars = 2000000
$sessions = @{}

function Write-HostLog([string]$Message) {
    try {
        $dir = Split-Path -Parent $logPath
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
        $line = ((Get-Date).ToUniversalTime().ToString('o') + ' ' + $Message + [Environment]::NewLine)
        [IO.File]::AppendAllText($logPath, $line, [Text.UTF8Encoding]::new($false))
    } catch { }
}

function Write-Meta {
    $dir = Split-Path -Parent $metaPath
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $process = Get-Process -Id $PID
    $meta = [ordered]@{
        schemaVersion = '1.0'
        pid = $PID
        processStartedAtUtc = $process.StartTime.ToUniversalTime().ToString('o')
        pipeName = $pipeName
        repoRoot = $root
    }
    $temp = "$metaPath.$([guid]::NewGuid().ToString('N')).tmp"
    [IO.File]::WriteAllText($temp, ((ConvertTo-Json -InputObject $meta -Compress) + [Environment]::NewLine), [Text.UTF8Encoding]::new($false))
    Move-Item -LiteralPath $temp -Destination $metaPath -Force
}

function Remove-MetaIfOwned {
    if (-not (Test-Path -LiteralPath $metaPath)) { return }
    try {
        $meta = Get-Content -LiteralPath $metaPath -Raw | ConvertFrom-Json
        if ([int]$meta.pid -eq $PID) { Remove-Item -LiteralPath $metaPath -Force }
    } catch { }
}

function Read-PipeLine([IO.Pipes.PipeStream]$Pipe, [int]$TimeoutMs) {
    $buffer = New-Object System.Collections.Generic.List[byte]
    $chunk = New-Object byte[] 4096
    $deadline = [DateTime]::UtcNow.AddMilliseconds($TimeoutMs)
    while ([DateTime]::UtcNow -lt $deadline) {
        $remaining = [Math]::Max(1, [int]($deadline - [DateTime]::UtcNow).TotalMilliseconds)
        $async = $Pipe.BeginRead($chunk, 0, $chunk.Length, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne($remaining)) { throw 'Timed out reading the PTY request.' }
        $count = $Pipe.EndRead($async)
        if ($count -le 0) { break }
        for ($i = 0; $i -lt $count; $i++) {
            if ($chunk[$i] -eq 10) { return [Text.UTF8Encoding]::new($false).GetString($buffer.ToArray()) }
            if ($chunk[$i] -ne 13) { $buffer.Add($chunk[$i]) }
            if ($buffer.Count -gt 200000) { throw 'Request exceeds 200000 bytes.' }
        }
    }
    throw 'Timed out reading the PTY request.'
}

function Write-PipeLine([IO.Pipes.PipeStream]$Pipe, $Object) {
    $json = ConvertTo-Json -InputObject $Object -Compress -Depth 8
    $bytes = [Text.UTF8Encoding]::new($false).GetBytes($json + "`n")
    $Pipe.Write($bytes, 0, $bytes.Length)
    $Pipe.Flush()
}

function Get-Field($Object, [string]$Name, $Default) {
    if ($null -eq $Object) { return $Default }
    if ($Object -is [System.Collections.IDictionary]) {
        if ($Object.Contains($Name)) {
            $value = $Object[$Name]
            if ($null -ne $value) { return $value }
        }
        return $Default
    }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) { return $Default }
    return $property.Value
}

function Test-UnderRoot([string]$Candidate) {
    $base = [IO.Path]::GetFullPath($root).TrimEnd('\') + '\'
    $full = [IO.Path]::GetFullPath($Candidate).TrimEnd('\') + '\'
    return $full.StartsWith($base, [StringComparison]::OrdinalIgnoreCase)
}

function Quote-WinArg([string]$Value) {
    if ($Value -notmatch '[\s"]') { return $Value }
    return '"' + ($Value.Replace('"', '\"')) + '"'
}

function Resolve-CommandPath([string]$Command) {
    if ([string]::IsNullOrWhiteSpace($Command)) { throw 'Command is required.' }
    if ($Command -match '[\r\n\0]') { throw 'Command contains invalid characters.' }
    if ($Command.Length -gt 260) { throw 'Command exceeds 260 characters.' }
    if ([IO.Path]::IsPathRooted($Command)) {
        if (-not (Test-Path -LiteralPath $Command -PathType Leaf)) { throw "Command not found: $Command" }
        return (Resolve-Path -LiteralPath $Command).Path
    }
    $found = @(Get-Command -Name $Command -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1)
    if ($found.Count -eq 0) { throw "Command not found: $Command" }
    return $found[0].Source
}

function New-SafeEnvironmentBlock {
    $deny = '(?i)SECRET|PASSWORD|TOKEN|API[_-]?KEY|CONNECTIONSTRING|CREDENTIAL|PRIVATE'
    $builder = New-Object Text.StringBuilder
    foreach ($entry in [Environment]::GetEnvironmentVariables().GetEnumerator()) {
        $name = [string]$entry.Key
        if ($name -match $deny -or $name.Contains('=')) { continue }
        [void]$builder.Append($name).Append('=').Append([string]$entry.Value).Append([char]0)
    }
    [void]$builder.Append([char]0)
    return $builder.ToString()
}

function Convert-Keys([string]$Keys) {
    $decoded = [regex]::Replace($Keys, '\\x1b', ([char]27).ToString(), 'IgnoreCase')
    return $decoded.Replace('\r', "`r").Replace('\n', "`n").Replace('\t', "`t")
}

function Limit-Text([string]$Text) {
    if ([string]::IsNullOrEmpty($Text)) { return '' }
    $redacted = [regex]::Replace($Text, '(?i)(password|token|secret|api[_-]?key|connectionstring)\s*[=:]\s*\S+', '$1=[REDACTED]')
    $redacted = [regex]::Replace($redacted, '\b(sk-|ghp_|xoxb-|AKIA)[A-Za-z0-9_\-]{8,}', '[REDACTED]')
    if ($redacted.Length -le 16000) { return $redacted }
    return $redacted.Substring($redacted.Length - 16000)
}

function Get-Session([string]$SessionId) {
    if ([string]::IsNullOrWhiteSpace($SessionId) -or $SessionId -notmatch '^[a-f0-9]{16}$') { throw 'sessionId is invalid.' }
    if (-not $sessions.ContainsKey($SessionId)) { throw "Session '$SessionId' was not found." }
    return $sessions[$SessionId]
}

function Remove-DeadSessions {
    foreach ($id in @($sessions.Keys)) {
        $session = $sessions[$id]
        if (-not $session.IsAlive) {
            try { $session.Dispose() } catch { }
            $sessions.Remove($id)
        }
    }
}

function Get-SessionView($Session, [bool]$IncludeBuffer) {
    $view = [ordered]@{
        ok = $true
        sessionId = $Session.Id
        command = $Session.Command
        pid = $Session.ProcessId
        alive = [bool]$Session.IsAlive
        exitCode = $(if ($Session.IsAlive) { $null } else { $Session.ExitCode })
        cols = $Session.Columns
        rows = $Session.Rows
        cwd = $Session.WorkingDirectory
    }
    if ($IncludeBuffer) { $view.buffer = Limit-Text $Session.GetBuffer($true) }
    return $view
}

function Wait-Stable($Session, [int]$TimeoutMs) {
    $watch = [Diagnostics.Stopwatch]::StartNew()
    $last = $Session.RawLength
    $stable = 0
    $slice = [Math]::Max(20, [int]($TimeoutMs / 10))
    while ($watch.ElapsedMilliseconds -lt $TimeoutMs) {
        Start-Sleep -Milliseconds $slice
        $length = $Session.RawLength
        if ($length -eq $last) {
            $stable++
            if ($stable -ge 3) { return }
        } else {
            $last = $length
            $stable = 0
        }
    }
}

function Invoke-Launch($Request) {
    Remove-DeadSessions
    if ($sessions.Count -ge $maxSessions) { throw "Maximum sessions limit reached ($maxSessions)." }
    $command = [string](Get-Field $Request 'command' '')
    $cwd = [string](Get-Field $Request 'cwd' $root)
    $cols = [int](Get-Field $Request 'cols' 120)
    $rows = [int](Get-Field $Request 'rows' 30)
    if ($cols -lt 20 -or $cols -gt 500) { throw 'cols must be between 20 and 500.' }
    if ($rows -lt 5 -or $rows -gt 200) { throw 'rows must be between 5 and 200.' }
    if (-not (Test-Path -LiteralPath $cwd -PathType Container)) { throw "Working directory not found: $cwd" }
    $cwdFull = (Resolve-Path -LiteralPath $cwd).Path
    if (-not (Test-UnderRoot $cwdFull)) { throw "Path traversal denied: $cwdFull is outside $root" }
    $argValues = @(Get-Field $Request 'args' @())
    if ($argValues.Count -gt 50) { throw 'args exceeds 50 items.' }
    $exe = Resolve-CommandPath $command
    $quoted = New-Object System.Collections.Generic.List[string]
    $quoted.Add((Quote-WinArg $exe))
    foreach ($arg in $argValues) {
        $text = [string]$arg
        if ($text.Length -gt 1000) { throw 'An argument exceeds 1000 characters.' }
        $quoted.Add((Quote-WinArg $text))
    }
    $session = [KaraviTerminal.PtySession]::Start($exe, ($quoted -join ' '), $cwdFull, $cols, $rows, (New-SafeEnvironmentBlock), $maxRawChars)
    try {
        $session.Id = [guid]::NewGuid().ToString('N').Substring(0, 16)
        $session.Command = $exe
        $session.WorkingDirectory = $cwdFull
        $sessions[$session.Id] = $session
        $readyBy = (Get-Date).AddSeconds(5)
        do {
            Wait-Stable $session 400
            if (-not [string]::IsNullOrWhiteSpace($session.GetBuffer($true))) { break }
        } while ((Get-Date) -lt $readyBy)
        $view = Get-SessionView $session $true
        $view.op = 'launch'
        return $view
    } catch {
        try { $session.Dispose() } catch { }
        if ($session.Id) { [void]$sessions.Remove($session.Id) }
        throw
    }
}

function Invoke-Request([string]$Line) {
    if ([string]::IsNullOrWhiteSpace($Line)) { throw 'Empty request.' }
    $request = $Line | ConvertFrom-Json
    $op = [string](Get-Field $request 'op' '')
    switch ($op) {
        'ping' { return [ordered]@{ ok = $true; op = 'ping'; pid = $PID } }
        'launch' { return Invoke-Launch $request }
        'screenshot' {
            $session = Get-Session ([string](Get-Field $request 'sessionId' ''))
            $view = Get-SessionView $session $true
            $view.op = 'screenshot'
            return $view
        }
        'sendKeys' {
            $keys = [string](Get-Field $request 'keys' '')
            if ([string]::IsNullOrEmpty($keys) -or $keys.Length -gt 10000) { throw 'keys must be 1 to 10000 characters.' }
            $session = Get-Session ([string](Get-Field $request 'sessionId' ''))
            $session.Write((Convert-Keys $keys))
            Wait-Stable $session 2000
            $view = Get-SessionView $session $true
            $view.op = 'sendKeys'
            return $view
        }
        'wait' {
            $timeoutMs = [int](Get-Field $request 'timeoutMs' 1000)
            if ($timeoutMs -lt 100 -or $timeoutMs -gt 30000) { throw 'timeoutMs must be between 100 and 30000.' }
            $session = Get-Session ([string](Get-Field $request 'sessionId' ''))
            Wait-Stable $session $timeoutMs
            $view = Get-SessionView $session $true
            $view.op = 'wait'
            return $view
        }
        'resize' {
            $cols = [int](Get-Field $request 'cols' 0)
            $rows = [int](Get-Field $request 'rows' 0)
            if ($cols -lt 20 -or $cols -gt 500 -or $rows -lt 5 -or $rows -gt 200) { throw 'resize is outside the allowed range.' }
            $session = Get-Session ([string](Get-Field $request 'sessionId' ''))
            $session.Resize($cols, $rows)
            $view = Get-SessionView $session $false
            $view.op = 'resize'
            return $view
        }
        'close' {
            $sessionId = [string](Get-Field $request 'sessionId' '')
            $session = Get-Session $sessionId
            $session.Dispose()
            $sessions.Remove($sessionId)
            return [ordered]@{ ok = $true; op = 'close'; sessionId = $sessionId; status = 'closed' }
        }
        'list' {
            Remove-DeadSessions
            $items = @($sessions.Values | ForEach-Object { Get-SessionView $_ $false })
            return [ordered]@{ ok = $true; op = 'list'; sessions = @($items) }
        }
        'shutdown' { return [ordered]@{ ok = $true; op = 'shutdown'; status = 'closed' } }
        default { throw "Unknown op '$op'." }
    }
}

Add-Type -Path (Join-Path $PSScriptRoot 'KaraviPtySession.cs')
$mutex = New-Object System.Threading.Mutex($false, $mutexName)
$owned = $false
try {
    try { $owned = $mutex.WaitOne(0) } catch [System.Threading.AbandonedMutexException] { $owned = $true }
    if (-not $owned) { exit 0 }
    Write-Meta
    $shutdown = $false
    while (-not $shutdown) {
        $server = [IO.Pipes.NamedPipeServerStream]::new($pipeName, [IO.Pipes.PipeDirection]::InOut, 1, [IO.Pipes.PipeTransmissionMode]::Byte, [IO.Pipes.PipeOptions]::Asynchronous)
        try {
            $server.WaitForConnection()
            $line = Read-PipeLine $server 20000
            $response = Invoke-Request $line
            if ((Get-Field $response 'op' '') -eq 'shutdown' -and (Get-Field $response 'ok' $false)) { $shutdown = $true }
            Write-PipeLine $server $response
            try { $server.WaitForPipeDrain() } catch { }
            try { $server.Disconnect() } catch { }
        } catch {
            Write-HostLog $_.Exception.Message
            try {
                if ($server.IsConnected) { Write-PipeLine $server ([ordered]@{ ok = $false; error = $_.Exception.Message }) }
            } catch { }
        } finally {
            $server.Dispose()
        }
    }
} finally {
    foreach ($session in @($sessions.Values)) { try { $session.Dispose() } catch { } }
    $sessions.Clear()
    Remove-MetaIfOwned
    if ($owned) { try { $mutex.ReleaseMutex() } catch { } }
    $mutex.Dispose()
}
