# Safe implementation examples

## Read-only port check

```powershell
$target = '127.0.0.1'
$port = 5060
$result = Test-NetConnection -ComputerName $target -Port $port -InformationLevel Quiet
[pscustomobject]@{ host = $target; port = $port; reachable = [bool]$result }
```

## Structured session JSON

```powershell
$record = [ordered]@{
    schemaVersion = '1.0'
    status = 'ready'
    openedAtUtc = [DateTime]::UtcNow.ToString('o')
    host = 'example.invalid'
    secret = '[REDACTED]'
}
$json = $record | ConvertTo-Json -Depth 10
```

## `WhatIf` before a filesystem mutation

```powershell
Remove-Item -LiteralPath $candidatePath -WhatIf
```

`WhatIf` is a preview, not proof that the real mutation is safe. Present the exact
non-preview command in the approval block and verify the intended target first.

## Result envelope for an agent report

```powershell
[pscustomobject]@{
    commandClass = 'read-only'
    status = 'passed'
    exitCode = 0
    stdout = '[bounded and redacted]'
    stderr = ''
    verified = $true
}
```
