# Verification and evidence

Every command result should be summarized as:

```text
command class → exit code/status → bounded stdout → bounded stderr → redaction result
→ independent verification → next action
```

## PowerShell evidence

- Native tools: `$LASTEXITCODE` is authoritative for process exit; `$?` describes the last PowerShell operation.
- Cmdlets: use `try/catch` with `$ErrorActionPreference = 'Stop'`; do not swallow exceptions.
- Timeout: bound the process or job; a timeout is a failure/blocker, not a pass.
- Redaction: mask credentials, bearer values, private keys, connection strings, PII,
  and sensitive host details before chat or artifacts.
- Output: use `Out-String -Width 240`, `Select-Object -First/Last`, or structured JSON
  for bounded evidence; do not dump unbounded logs.

## Independent verification examples

| Action | Read-only proof |
|---|---|
| service restart | `Get-Service` status plus bounded event/log check |
| file change | hash, size, timestamp, and a targeted content check |
| package/build | version/query plus test/build exit code |
| port/service | `Get-NetTCPConnection`/`Test-NetConnection` and service status |
| Docker/Kubernetes | bounded `ps/get`, health, logs, and rollout status |
| Asterisk change | CLI/config readback plus SIP/RTP/AMI/ARI smoke appropriate to scope |

Do not report success from a command's absence of output alone.
