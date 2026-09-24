---
name: karavi-powershell-session
description: >
  Supervised Windows PowerShell (pwsh) terminal sessions for agents: open and monitor
  the agent shell, let the user log in interactively on remote hosts, run read-only
  diagnostics without approval, require explicit approval before mutating commands,
  capture stdout/stderr/exit codes, and handle prompts safely (no secrets in chat).
  TRIGGER when: user says "/karavi-powershell-session", "جلسه ترمینال",
  "ترمینال PowerShell نظارت‌شده", "supervised PowerShell", "SSH login then agent",
  "readonly vs mutation terminal", "interactive terminal session", or wants agent-driven
  shell work with permission gates on staging or production systems.
  DO NOT TRIGGER when: only editing code without a live shell session, or when
  karavi-folder init/clean is the actual need.
license: Apache-2.0
metadata:
  author: akaravi
  version: "0.3.0"
  category: operator-session
  tags: "karavi, powershell, pwsh, terminal, ssh, readonly, mutation, approval, monitoring, cursor"
compatibility: Cross-tool (Cursor, Claude Code, Codex). Windows-first. Agent shell is not the user's interactive PID unless documented.
---

# karavi-powershell-session

Operate a **supervised PowerShell session** with a strict **read-only vs mutation**
permission model. The user performs **interactive login** (SSH, RDP console, cloud
console, or a terminal tab the agent cannot type into); the agent runs commands in
its **own** shell tool session unless the user explicitly pastes into the shared
terminal.

## Quick start

1. Open PowerShell in the **current repo root** (or path the user names).
2. Report: shell (`powershell.exe` / `pwsh`), **cwd**, console encoding, `$PSVersionTable.PSVersion`.
3. Tell the user: log in on the **authorized** host or service yourself; reply **`ready`** when the session is usable.
4. Until `ready`: only **local read-only** sanity (`Get-Location`, `$PSVersionTable`, `Test-Path`).
5. After `ready`: follow [permission model](references/permission-model.md) and [classification](references/command-classification.md).

Optional session record: `.cursor/<alias>-terminal-session.json` — see [agent-terminals.md](references/agent-terminals.md).

## Non-negotiable rules

- Never collect or echo passwords, tokens, or connection strings in chat or logs.
- Never run mutation without explicit approval block answered.
- Never connect to remote or production targets before user **`ready`** (unless the user pre-configured non-interactive auth in the agent shell).
- FTP/deploy only on explicit user **Deploy** and current repo deploy rules.
- One atomic action per turn during live troubleshooting unless the user approves a batch.
- Mask secrets in summaries (`[REDACTED]`).

## Mutation approval block

```text
[درخواست اجرا — MUTATION]
دسته: <...>
دستور: <exact line>
cwd: <path>
ریسک: <short>
اثر برگشت‌ناپذیر: <بله/خیر>
تأیید: «اجرا کن» / «نه» / «اصلاح: ...»
```

## Turn template

Session status → last command class → result + exit code → evidence → next step.

## Scripts (bundled with skill)

| Script | Purpose |
|--------|---------|
| `scripts/karavi-powershell-session.open-interactive.ps1` | Open user PowerShell + optional SSH; write `.cursor/<alias>-terminal-session.json` |
| `scripts/karavi-powershell-session.agent-sanity.ps1` | Read-only report for agent Shell (`SHELL`, `PS_VERSION`, `CWD`, `ENCODING`) |

**Interactive SSH (parameters supplied by user or repo-local wrapper, not hard-coded in skill):**

```powershell
& .agents/skills/karavi-powershell-session/scripts/karavi-powershell-session.open-interactive.ps1 `
  -RepoRoot (Get-Location) `
  -HostAlias <short-name> `
  -RemoteHost <hostname-or-ip> `
  -Port <ssh-port> `
  -User <ssh-user>
```

Opening a new window or starting SSH is **mutation** — require approval unless the user already ran it.

Repo-specific shortcuts (hosts, ports, users) belong in **that repository** under `karavi/karavi.scripts.command/` or `scripts/` — not in this skill.

## Acceptance checklist

- [ ] Agent reported shell/cwd/version/encoding
- [ ] User logged in interactively; agent did not handle passwords
- [ ] Read-only ran without approval; mutations blocked without block
- [ ] Exit codes and masked evidence each turn
- [ ] Channel documented (user tab vs agent Shell)

## References

- [command-classification.md](references/command-classification.md)
- [permission-model.md](references/permission-model.md)
- [agent-terminals.md](references/agent-terminals.md)

## Starter

`/karavi-powershell-session` then wait for user `ready`.
