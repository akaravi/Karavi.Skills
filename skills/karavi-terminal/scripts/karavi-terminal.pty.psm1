Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-KaraviPtyIdentity {
    param([Parameter(Mandatory = $true)][string]$RepoRoot)
    $root = (Resolve-Path -LiteralPath $RepoRoot).Path
    $hashBytes = [Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($root.ToLowerInvariant()))
    $hash = ([BitConverter]::ToString($hashBytes)).Replace('-', '').Substring(0, 16).ToLowerInvariant()
    return [pscustomobject]@{
        RepoRoot = $root
        PipeName = "karavi-pty-$hash"
        StartMutexName = "Local\karavi-pty-start-$hash"
        MetaPath = Join-Path $root 'karavi.temp.status/karavi-terminal-pty-host.json'
        HostScript = Join-Path $PSScriptRoot 'karavi-terminal.pty-host.ps1'
    }
}

function Get-KaraviPtyHostMeta {
    param($Identity)
    if (-not (Test-Path -LiteralPath $Identity.MetaPath)) { return $null }
    try { return Get-Content -LiteralPath $Identity.MetaPath -Raw | ConvertFrom-Json } catch { return $null }
}

function Test-KaraviPtyHostLive {
    param($Meta)
    if ($null -eq $Meta) { return $false }
    try {
        $process = Get-Process -Id ([int]$Meta.pid) -ErrorAction Stop
        $recorded = ([datetime]$Meta.processStartedAtUtc).ToUniversalTime().ToString('o')
        return $process.StartTime.ToUniversalTime().ToString('o') -eq $recorded -and [string]$Meta.pipeName
    } catch { return $false }
}

function Read-KaraviPtyLine {
    param([IO.Pipes.PipeStream]$Pipe, [int]$TimeoutMs)
    $buffer = New-Object System.Collections.Generic.List[byte]
    $chunk = New-Object byte[] 4096
    $deadline = [DateTime]::UtcNow.AddMilliseconds($TimeoutMs)
    while ([DateTime]::UtcNow -lt $deadline) {
        $remaining = [Math]::Max(1, [int]($deadline - [DateTime]::UtcNow).TotalMilliseconds)
        $async = $Pipe.BeginRead($chunk, 0, $chunk.Length, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne($remaining)) { throw 'Timed out reading the PTY response.' }
        $count = $Pipe.EndRead($async)
        if ($count -le 0) { break }
        for ($i = 0; $i -lt $count; $i++) {
            if ($chunk[$i] -eq 10) { return [Text.UTF8Encoding]::new($false).GetString($buffer.ToArray()) }
            if ($chunk[$i] -ne 13) { $buffer.Add($chunk[$i]) }
            if ($buffer.Count -gt 2000000) { throw 'PTY response exceeds 2000000 bytes.' }
        }
    }
    throw 'Timed out reading the PTY response.'
}

function Invoke-KaraviPtyRequest {
    param([Parameter(Mandatory = $true)][string]$RepoRoot, [Parameter(Mandatory = $true)]$Request, [int]$TimeoutMs = 20000)
    $identity = Initialize-KaraviPtyHost -RepoRoot $RepoRoot
    $meta = Get-KaraviPtyHostMeta $identity
    if (-not (Test-KaraviPtyHostLive $meta)) { throw 'PTY host is not live.' }
    $pipe = [IO.Pipes.NamedPipeClientStream]::new('.', [string]$meta.pipeName, [IO.Pipes.PipeDirection]::InOut, [IO.Pipes.PipeOptions]::Asynchronous)
    try {
        $pipe.Connect(8000)
        $payload = ConvertTo-Json -InputObject $Request -Compress -Depth 6
        $bytes = [Text.UTF8Encoding]::new($false).GetBytes($payload + "`n")
        $pipe.Write($bytes, 0, $bytes.Length)
        $pipe.Flush()
        $line = Read-KaraviPtyLine -Pipe $pipe -TimeoutMs $TimeoutMs
    } finally { $pipe.Dispose() }
    if ([string]::IsNullOrWhiteSpace($line)) { throw 'Empty PTY host response.' }
    $parsed = $line | ConvertFrom-Json
    if ($parsed.PSObject.Properties.Name -contains 'ok' -and -not $parsed.ok) {
        $message = $parsed.error
        if ([string]::IsNullOrWhiteSpace($message)) { $message = 'PTY host request failed.' }
        throw $message
    }
    return $parsed
}

function Initialize-KaraviPtyHost {
    param([Parameter(Mandatory = $true)][string]$RepoRoot)
    $identity = Get-KaraviPtyIdentity $RepoRoot
    $startMutex = New-Object System.Threading.Mutex($false, $identity.StartMutexName)
    $locked = $false
    try {
        try { $locked = $startMutex.WaitOne(10000) } catch [System.Threading.AbandonedMutexException] { $locked = $true }
        if (-not $locked) { throw 'Timed out waiting for the PTY host start lock.' }
        $meta = Get-KaraviPtyHostMeta $identity
        if (-not (Test-KaraviPtyHostLive $meta)) {
            $exe = (Get-Process -Id $PID).Path
            Start-Process -FilePath $exe -ArgumentList @('-NoLogo', '-NoProfile', '-NonInteractive', '-File', $identity.HostScript, '-RepoRoot', $identity.RepoRoot) -WorkingDirectory $identity.RepoRoot -WindowStyle Hidden | Out-Null
        }
    } finally {
        if ($locked) { try { $startMutex.ReleaseMutex() } catch { } }
        $startMutex.Dispose()
    }
    $deadline = (Get-Date).AddSeconds(15)
    do {
        $meta = Get-KaraviPtyHostMeta $identity
        if (Test-KaraviPtyHostLive $meta) {
            try {
                $ping = Invoke-KaraviPtyPing -Identity $identity -Meta $meta
                if ($ping.ok) { return $identity }
            } catch { }
        }
        Start-Sleep -Milliseconds 200
    } while ((Get-Date) -lt $deadline)
    throw 'PTY host did not become ready.'
}

function Invoke-KaraviPtyPing {
    param($Identity, $Meta)
    $pipe = [IO.Pipes.NamedPipeClientStream]::new('.', [string]$Meta.pipeName, [IO.Pipes.PipeDirection]::InOut, [IO.Pipes.PipeOptions]::Asynchronous)
    try {
        $pipe.Connect(2000)
        $bytes = [Text.UTF8Encoding]::new($false).GetBytes('{"op":"ping"}' + "`n")
        $pipe.Write($bytes, 0, $bytes.Length)
        $pipe.Flush()
        $line = Read-KaraviPtyLine -Pipe $pipe -TimeoutMs 5000
    } finally { $pipe.Dispose() }
    if ([string]::IsNullOrWhiteSpace($line)) { throw 'Empty ping response.' }
    return $line | ConvertFrom-Json
}

function Start-KaraviPtySession {
    param([Parameter(Mandatory = $true)][string]$RepoRoot, [string]$Command = 'powershell.exe', [string[]]$ArgumentList = @('-NoLogo', '-NoProfile', '-NoExit', '-Command', 'Remove-Module PSReadLine -ErrorAction SilentlyContinue'), [string]$WorkingDirectory, [int]$Columns = 120, [int]$Rows = 30)
    $request = [ordered]@{ op = 'launch'; command = $Command; args = @($ArgumentList); cols = $Columns; rows = $Rows }
    if (-not [string]::IsNullOrWhiteSpace($WorkingDirectory)) { $request.cwd = $WorkingDirectory }
    return Invoke-KaraviPtyRequest -RepoRoot $RepoRoot -Request $request -TimeoutMs 20000
}

function Get-KaraviPtyScreen {
    param([Parameter(Mandatory = $true)][string]$RepoRoot, [Parameter(Mandatory = $true)][string]$SessionId)
    return Invoke-KaraviPtyRequest -RepoRoot $RepoRoot -Request ([ordered]@{ op = 'screenshot'; sessionId = $SessionId }) -TimeoutMs 10000
}

function Send-KaraviPtyKeys {
    param([Parameter(Mandatory = $true)][string]$RepoRoot, [Parameter(Mandatory = $true)][string]$SessionId, [Parameter(Mandatory = $true)][string]$Keys)
    return Invoke-KaraviPtyRequest -RepoRoot $RepoRoot -Request ([ordered]@{ op = 'sendKeys'; sessionId = $SessionId; keys = $Keys }) -TimeoutMs 15000
}

function Wait-KaraviPtySession {
    param([Parameter(Mandatory = $true)][string]$RepoRoot, [Parameter(Mandatory = $true)][string]$SessionId, [int]$TimeoutMs = 1000)
    return Invoke-KaraviPtyRequest -RepoRoot $RepoRoot -Request ([ordered]@{ op = 'wait'; sessionId = $SessionId; timeoutMs = $TimeoutMs }) -TimeoutMs ($TimeoutMs + 5000)
}

function Resize-KaraviPtySession {
    param([Parameter(Mandatory = $true)][string]$RepoRoot, [Parameter(Mandatory = $true)][string]$SessionId, [Parameter(Mandatory = $true)][int]$Columns, [Parameter(Mandatory = $true)][int]$Rows)
    return Invoke-KaraviPtyRequest -RepoRoot $RepoRoot -Request ([ordered]@{ op = 'resize'; sessionId = $SessionId; cols = $Columns; rows = $Rows }) -TimeoutMs 10000
}

function Close-KaraviPtySession {
    param([Parameter(Mandatory = $true)][string]$RepoRoot, [Parameter(Mandatory = $true)][string]$SessionId)
    return Invoke-KaraviPtyRequest -RepoRoot $RepoRoot -Request ([ordered]@{ op = 'close'; sessionId = $SessionId }) -TimeoutMs 10000
}

function Get-KaraviPtySessionList {
    param([Parameter(Mandatory = $true)][string]$RepoRoot)
    return Invoke-KaraviPtyRequest -RepoRoot $RepoRoot -Request ([ordered]@{ op = 'list' }) -TimeoutMs 10000
}

function Stop-KaraviPtyHost {
    param([Parameter(Mandatory = $true)][string]$RepoRoot)
    $identity = Get-KaraviPtyIdentity $RepoRoot
    $meta = Get-KaraviPtyHostMeta $identity
    if (-not (Test-KaraviPtyHostLive $meta)) { return [pscustomobject]@{ ok = $true; op = 'shutdown'; status = 'closed' } }
    $closed = $false
    $pipe = [IO.Pipes.NamedPipeClientStream]::new('.', [string]$meta.pipeName, [IO.Pipes.PipeDirection]::InOut, [IO.Pipes.PipeOptions]::Asynchronous)
    try {
        $pipe.Connect(3000)
        $bytes = [Text.UTF8Encoding]::new($false).GetBytes('{"op":"shutdown"}' + "`n")
        $pipe.Write($bytes, 0, $bytes.Length)
        $pipe.Flush()
        $line = Read-KaraviPtyLine -Pipe $pipe -TimeoutMs 5000
        if (-not [string]::IsNullOrWhiteSpace($line)) { $closed = $true }
    } catch { } finally { $pipe.Dispose() }
    if (-not $closed) {
        $process = Get-CimInstance Win32_Process -Filter ("ProcessId=" + [int]$meta.pid) -ErrorAction SilentlyContinue
        if ($process -and [string]$process.CommandLine -like '*karavi-terminal.pty-host.ps1*') {
            Stop-Process -Id ([int]$meta.pid) -Force -ErrorAction SilentlyContinue
        }
    }
    return [pscustomobject]@{ ok = $true; op = 'shutdown'; status = 'closed' }
}

Export-ModuleMember -Function Initialize-KaraviPtyHost, Start-KaraviPtySession, Get-KaraviPtyScreen, Send-KaraviPtyKeys, Wait-KaraviPtySession, Resize-KaraviPtySession, Close-KaraviPtySession, Get-KaraviPtySessionList, Stop-KaraviPtyHost
