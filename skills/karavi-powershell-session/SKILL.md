---
name: karavi-powershell-session
description: >
  Supervised Windows PowerShell (pwsh) terminal sessions for agents: open and monitor
  the agent shell, let the user log in interactively on remote hosts, run read-only
  diagnostics without approval, require explicit approval before mutating commands,
  capture stdout/stderr/exit codes, and handle prompts safely (no secrets in chat).
  TRIGGER when: user says "/karavi-powershell-session", "جلسه ترمینال",
  "ترمینال PowerShell نظارت‌شده", "supervised PowerShell", "SSH login then agent",
  "readonly vs mutation terminal", "s91 terminal", or wants agent-driven shell work
  with permission gates on production/VoIP servers.
  DO NOT TRIGGER when: only editing code without a live shell session, or when
  karavi-folder init/clean is the actual need.
license: Apache-2.0
metadata:
  author: akaravi
  version: "0.1.0"
  category: operator-session
  tags: "karavi, powershell, pwsh, terminal, ssh, readonly, mutation, approval, monitoring, cursor"
compatibility: Cross-tool (Cursor, Claude Code, Codex). Windows-first. Agent shell is not the user's interactive PID unless documented.
---

# karavi-powershell-session

Operate a **supervised PowerShell session** with a strict **read-only vs mutation**
permission model. The user performs **interactive login** (SSH, RDP console, or a
terminal tab the agent cannot type into); the agent runs commands in its **own**
shell tool session unless the user explicitly pastes into the shared terminal.

## Quick start

1. Open PowerShell in the **current repo root** (or path the user names).
2. Report: shell (`powershell.exe` / `pwsh`), **cwd**, UTF-8, `$PSVersionTable.PSVersion`.
3. Tell the user: log in on the **authorized** host/service yourself; reply **`ready`** when the session is usable.
4. Until `ready`: only **local read-only** sanity (`Get-Location`, `$PSVersionTable`, `Test-Path`).
5. After `ready`: follow [permission model](references/permission-model.md) and [classification](references/command-classification.md).

Optional session record: `.cursor/<host>-terminal-session.json` — see [agent-terminals.md](references/agent-terminals.md).

## Non-negotiable rules

- Never collect or echo passwords, tokens, or connection strings in chat or logs.
- Never run mutation without explicit approval block answered.
- Never connect to production/remote before user **`ready`** (unless keys pre-configured by user).
- FTP/deploy only on explicit user **Deploy** and repo deploy rules.
- One atomic action per turn during live troubleshooting unless user approves a batch.
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

## References

- [command-classification.md](references/command-classification.md)
- [permission-model.md](references/permission-model.md)
- [agent-terminals.md](references/agent-terminals.md)

## Starter

`/karavi-powershell-session` then wait for user `ready`.
