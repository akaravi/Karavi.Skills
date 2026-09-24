# PowerShell engineering reference

Use this reference for robust Windows automation. Commands remain subject to the
read-only/mutation classification and approval gate.

## Safe baseline

```powershell
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = (Get-Location).ProviderPath
$configPath = Join-Path $repoRoot 'config\session.json'

try {
    $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    if ($null -eq $config) { throw 'Configuration is empty.' }
    Write-Output ([pscustomobject]@{ status = 'ok'; path = $configPath })
    exit 0
}
catch {
    Write-Error $_
    exit 1
}
```

## High-value rules

- Use `Join-Path` and `-LiteralPath`; do not concatenate Windows paths or trust wildcard expansion for a target.
- Wrap potentially empty command output in `@(...)` when an array is required. Prefer `[System.Collections.Generic.List[string]]` for repeated appends.
- Parenthesize cmdlet calls used as operands in `-and`, `-or`, or comparisons: `if ((Test-Path -LiteralPath $p) -and $enabled) { ... }`.
- Use `$?` for the last PowerShell pipeline status and `$LASTEXITCODE` for native process exit status; capture both when invoking SSH, Git, Docker, or WSL.
- Use `ConvertFrom-Json` for input and `ConvertTo-Json -Depth 10` (or a justified larger depth) for structured output. Do not truncate nested session state accidentally.
- Check `$null` explicitly (`$null -eq $value`) before property access. Do not rely on truthiness for empty collections or numeric zero.
- Prefer `-LiteralPath`, `-NoProfile`, `-NonInteractive` for automation, and bounded output (`Select-Object -First`, `-Tail`) for logs.
- Use UTF-8 without BOM for skill/repository text. Preserve the target file's required encoding only when a tool or legacy format explicitly requires it.
- Do not put passwords, tokens, private keys, connection strings, or secrets in command lines, URLs, transcripts, JSON, or error summaries.

## Native process capture

```powershell
$stdout = [System.IO.Path]::GetTempFileName()
$stderr = [System.IO.Path]::GetTempFileName()
try {
    & ssh @sshArgs 1> $stdout 2> $stderr
    $exitCode = $LASTEXITCODE
    $out = Get-Content -LiteralPath $stdout -Raw -ErrorAction SilentlyContinue
    $err = Get-Content -LiteralPath $stderr -Raw -ErrorAction SilentlyContinue
    [pscustomobject]@{ exitCode = $exitCode; stdout = $out; stderr = $err }
}
finally {
    Remove-Item -LiteralPath $stdout, $stderr -Force -ErrorAction SilentlyContinue
}
```

Use this only for bounded, approved commands. For a read-only check, retain the
evidence and exit code; for mutation, retain only redacted evidence required by the
acceptance criteria.

## Common failure classes

`CommandNotFoundException` means the executable is absent or not on `PATH`; a native
non-zero exit is a command failure, not a PowerShell exception; `Access is denied`
requires an authorization decision; a prompt for credentials pauses the workflow and
must be handled by the user in the visible interactive channel.
