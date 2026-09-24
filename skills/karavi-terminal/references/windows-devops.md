# Windows development and operations map

Use the smallest read-only command that answers the question, then request approval
for mutation. Examples below are classifications, not permission to execute.

| Area | Read-only examples | Mutation examples |
|---|---|---|
| Files/config | `Get-Item`, `Get-Content`, `Select-String`, `Get-FileHash` | `New-Item`, `Set-Content`, `Move-Item`, `Remove-Item` |
| Processes/services | `Get-Process`, `Get-Service`, `Get-CimInstance` | `Start/Stop/Restart-Service`, `Stop-Process`, taskkill |
| Networking | `Test-NetConnection`, `Get-NetTCPConnection`, `Resolve-DnsName` | firewall/DNS/route/registry writes |
| Git | `status`, `log`, `diff`, `show`, `branch -vv` | commit, push, reset, checkout/discard, merge/rebase |
| .NET/pnpm | `dotnet --info`, `dotnet test --no-restore`, `pnpm --version`, inspect lockfiles | restore/install/update/publish or generated-file overwrite |
| Containers | `docker ps/logs/inspect`, `kubectl get/describe/logs` | `docker exec/run`, `kubectl apply/delete/scale/restart` |
| IIS/Event Log | `Get-Website`, `Get-WinEvent -MaxEvents`, `Get-ItemProperty` | app-pool/site/config/firewall changes |
| WSL/SSH | `wsl --list --verbose`, `ssh -G`, bounded remote `uname` | package/config/service/restart/remote writes |

`cmd.exe`, WSL, Docker, Kubernetes, database clients, and remote shells inherit the
same rule: pipelines containing any mutating stage are mutation requests.
