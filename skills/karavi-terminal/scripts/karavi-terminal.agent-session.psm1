Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-KaraviTerminalRegistryPath { param([string]$RepoRoot) Join-Path $RepoRoot 'karavi.temp.status/karavi-terminal-sessions.json' }
function Get-KaraviTerminalStateDir { param([string]$RepoRoot) Join-Path $RepoRoot '.cursor/karavi-terminal' }
function Write-KaraviTerminalJson { param($Value) $Value | ConvertTo-Json -Depth 8 -Compress }
function Get-KaraviTerminalRegistry {
    param([string]$RepoRoot)
    $path = Get-KaraviTerminalRegistryPath $RepoRoot
    if (-not (Test-Path -LiteralPath $path)) { return @() }
    try { return @((Get-Content -LiteralPath $path -Raw | ConvertFrom-Json)) } catch { return @() }
}
function Save-KaraviTerminalRegistry {
    param([string]$RepoRoot, [array]$Sessions)
    $path = Get-KaraviTerminalRegistryPath $RepoRoot; $dir = Split-Path -Parent $path
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $temp = "$path.$([guid]::NewGuid().ToString('N')).tmp"
    [System.IO.File]::WriteAllText($temp, (Write-KaraviTerminalJson @($Sessions)), [System.Text.UTF8Encoding]::new($false))
    Move-Item -LiteralPath $temp -Destination $path -Force
}
function Test-KaraviTerminalLive {
    param($Session)
    try { $p = Get-Process -Id ([int]$Session.pid) -ErrorAction Stop; $recorded = ([datetime]$Session.processStartedAtUtc).ToUniversalTime().ToString('o'); return $p.StartTime.ToUniversalTime().ToString('o') -eq $recorded } catch { return $false }
}
function Sync-KaraviTerminalRegistry {
    param([string]$RepoRoot)
    $live = @(Get-KaraviTerminalRegistry $RepoRoot | Where-Object { Test-KaraviTerminalLive $_ })
    Save-KaraviTerminalRegistry $RepoRoot $live
    return $live
}
function Get-KaraviTerminalSession {
    param([string]$RepoRoot, [string]$SessionId)
    $session = @(Sync-KaraviTerminalRegistry $RepoRoot | Where-Object { $_.sessionId -eq $SessionId })[0]
    if ($null -eq $session) { throw "Session '$SessionId' is not live or is not owned by this registry." }
    return $session
}
function New-KaraviTerminalSession {
    param([string]$RepoRoot, [string]$Shell = 'pwsh.exe')
    $root = (Resolve-Path -LiteralPath $RepoRoot).Path
    $sessionId = [guid]::NewGuid().ToString('N'); $pipeBase = "karavi-terminal-$sessionId"
    $wrapper = @'
param([string]$PipeBase)
while ($true) {
  $request = [System.IO.Pipes.NamedPipeServerStream]::new("$PipeBase-request", [System.IO.Pipes.PipeDirection]::In)
  $request.WaitForConnection(); $reader = [System.IO.StreamReader]::new($request); $payload = $reader.ReadLine(); $reader.Dispose(); $request.Dispose()
  if ($payload -eq '__close__') { break }
  $result = [ordered]@{ status='completed'; stdout=''; stderr=''; nativeExitCode=$null; powerShellSucceeded=$true; timedOut=$false }
  try { $items = & ([scriptblock]::Create([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload)))) 2>&1; foreach ($item in $items) { if ($item -is [System.Management.Automation.ErrorRecord]) { $result.stderr += ($item.ToString()+[Environment]::NewLine) } else { $result.stdout += ($item | Out-String) } }; $result.nativeExitCode=$global:LASTEXITCODE } catch { $result.status='failed'; $result.powerShellSucceeded=$false; $result.stderr=$_.ToString() }
  $response = [System.IO.Pipes.NamedPipeServerStream]::new("$PipeBase-response", [System.IO.Pipes.PipeDirection]::Out)
  $response.WaitForConnection(); $writer = [System.IO.StreamWriter]::new($response); $writer.AutoFlush=$true; $writer.WriteLine(($result | ConvertTo-Json -Compress)); $writer.Dispose(); $response.Dispose()
}
'@
    $stateDir = Get-KaraviTerminalStateDir $root
    New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
    $wrapperPath = Join-Path $stateDir ("$sessionId-wrapper.ps1")
    [System.IO.File]::WriteAllText($wrapperPath, $wrapper, [System.Text.UTF8Encoding]::new($false))
    $process = Start-Process -FilePath $Shell -ArgumentList @('-NoLogo','-NoProfile','-NonInteractive','-File',$wrapperPath,'-PipeBase',$pipeBase) -PassThru -WindowStyle Hidden -WorkingDirectory $root
    Start-Sleep -Milliseconds 150
    if ($process.HasExited) { throw 'Persistent terminal process exited during startup.' }
    $record = [pscustomobject]@{ schemaVersion='1.0'; sessionId=$sessionId; pid=$process.Id; processStartedAtUtc=$process.StartTime.ToUniversalTime().ToString('o'); shell=$Shell; cwd=$root; pipeBase=$pipeBase; wrapperPath=$wrapperPath; status='ready'; openedAtUtc=(Get-Date).ToUniversalTime().ToString('o'); lastSeenAtUtc=(Get-Date).ToUniversalTime().ToString('o') }
    $sessions = @(Sync-KaraviTerminalRegistry $root) + $record; Save-KaraviTerminalRegistry $root $sessions
    return $record
}
function Invoke-KaraviTerminalCommand {
    param([string]$RepoRoot, [string]$SessionId, [string]$Command, [int]$TimeoutSeconds = 30)
    $session = Get-KaraviTerminalSession $RepoRoot $SessionId; $base=$session.pipeBase
    $request = [System.IO.Pipes.NamedPipeClientStream]::new('.', "$base-request", [System.IO.Pipes.PipeDirection]::Out)
    $request.Connect(3000); $writer=[System.IO.StreamWriter]::new($request); $writer.AutoFlush=$true; $writer.WriteLine([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Command))); $writer.Dispose(); $request.Dispose()
    $response = [System.IO.Pipes.NamedPipeClientStream]::new('.', "$base-response", [System.IO.Pipes.PipeDirection]::In)
    try { $response.Connect($TimeoutSeconds * 1000); $reader=[System.IO.StreamReader]::new($response); $result=$reader.ReadLine() | ConvertFrom-Json; $reader.Dispose() } catch { $result=[pscustomobject]@{status='timedOut';stdout='';stderr='Timed out waiting for terminal response.';nativeExitCode=$null;powerShellSucceeded=$false;timedOut=$true} } finally { $response.Dispose() }
    $result | Add-Member -NotePropertyName sessionId -NotePropertyValue $SessionId; $result | Add-Member -NotePropertyName commandId -NotePropertyValue ([guid]::NewGuid().ToString('N')); return $result
}
function Close-KaraviTerminalSession {
    param([string]$RepoRoot, [string]$SessionId)
    $session=Get-KaraviTerminalSession $RepoRoot $SessionId; $pipe=[System.IO.Pipes.NamedPipeClientStream]::new('.', "$($session.pipeBase)-request", [System.IO.Pipes.PipeDirection]::Out)
    try { $pipe.Connect(2000); $writer=[System.IO.StreamWriter]::new($pipe); $writer.AutoFlush=$true; $writer.WriteLine('__close__'); $writer.Dispose() } catch {} finally { $pipe.Dispose() }
    Start-Sleep -Milliseconds 100; $p=Get-Process -Id $session.pid -ErrorAction SilentlyContinue; if ($p) { Stop-Process -Id $session.pid -Force }
    Save-KaraviTerminalRegistry $RepoRoot (@(Get-KaraviTerminalRegistry $RepoRoot | Where-Object { $_.sessionId -ne $SessionId }))
    return [pscustomobject]@{sessionId=$SessionId;status='closed'}
}
Export-ModuleMember -Function New-KaraviTerminalSession,Get-KaraviTerminalSession,Invoke-KaraviTerminalCommand,Close-KaraviTerminalSession,Sync-KaraviTerminalRegistry
