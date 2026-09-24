# Command classification

Classify **intent**, not only the verb. When unsure → **mutation**.

## Read-only (no approval)

- PowerShell: `Get-*`, `Select-*`, `Test-Path`, `Get-ChildItem`, `Get-Content` / `Select-String` (mask secrets in summary)
- Network: `Test-NetConnection`, `ping`, `tracert`, `nslookup`
- Processes/services: `Get-Process`, `Get-Service`, `Get-CimInstance` (query)
- Git read: `status`, `log`, `diff`, `show`, `branch -vv`
- Containers/K8s read: `docker ps`, `docker logs` (bounded), `kubectl get`, `describe`, `logs` (bounded)
- HTTP read: `Invoke-WebRequest -Method Get` / `curl` GET without side effects

## Mutation (approval required)

- Files: `Set-Content`, `Remove-Item`, `Move-Item`, `Copy-Item` with overwrite, `New-Item`
- Services/processes: `Start/Stop/Restart-Service`, `Stop-Process`, `taskkill`
- Network, firewall, DNS, registry writes
- Packages: `npm install`, `dotnet publish`, `choco install`, etc.
- Git write: `commit`, `push`, `reset`, `checkout` that discards work
- Docker/K8s: `run`, `exec`, `apply`, `delete`, `scale`, `rollout restart`
- DB: DML/DDL, migrations
- Application daemons: config edits, `reload`, `restart`, job triggers, message publish with side effects

Pipelines: if any stage mutates, the whole pipeline is **mutation**.

## Forbidden without separate explicit override

- `format`, `diskpart`, volume wipe, `Remove-Computer`
- `git push --force`, destructive `git reset --hard` on shared branches
- `DROP DATABASE`, truncate production tables
- Secrets on the command line or in URLs
- Bulk destructive ops (one approval per scope)
