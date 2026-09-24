---
name: karavi-terminal
description: >
  Supervised Windows terminal sessions for agents: PowerShell, Windows Terminal,
  SSH, WSL, remote shells, Orca terminals, and visible Windows app control; let the
  user log in interactively, run read-only diagnostics without approval, require
  explicit approval before mutation, capture stdout/stderr/exit codes, and handle
  prompts safely without secrets in chat. TRIGGER when: user says
  "/karavi-terminal", "جلسه ترمینال", "ترمینال PowerShell نظارت‌شده",
  "Windows Terminal", "supervised terminal", "SSH login then agent", "readonly vs
  mutation terminal", "interactive terminal session", "Orca terminal", "Computer
  Use for Windows", or wants agent-driven shell work with permission gates on staging
  or production systems.
  DO NOT TRIGGER when: only editing code without a live shell session, or when
  karavi-folder init/clean is the actual need.
license: Apache-2.0
metadata:
  author: akaravi
  version: "0.4.0"
  category: operator-session
  tags: "karavi, terminal, powershell, pwsh, windows-terminal, ssh, wsl, orca, computer-use, readonly, mutation, approval, monitoring"
  compatibility: "Cross-tool (Cursor, Claude Code, Codex). Windows-first, with Linux/VoIP remote-shell support. Agent shell is not the user's interactive PID unless documented."
---

# karavi-terminal

Operate a **supervised terminal session** with a strict **read-only vs mutation**
permission model. PowerShell is the default Windows shell, but the same lifecycle
applies to Windows Terminal profiles, `cmd.exe`, WSL, SSH/Linux shells, and Orca
managed terminals. The user performs **interactive login** (SSH, RDP console, cloud
console, or a visible terminal tab); the agent runs commands in its **own** shell
tool session unless the user explicitly pastes into the shared terminal.

## Agent-controlled local session

For commands an agent must send and read itself, use `open-agent-session` to obtain
`sessionId` and PID, `invoke-agent-command` to run one bounded command in the same
process, `get-agent-session` to list verified-live sessions, and `close-agent-session`
to close one owned session. The local runtime registry is
`karavi.temp.status/karavi-terminal-sessions.json`; every operation reconciles stale
records using PID plus process start time. A PID alone is never a control channel.

## ConPTY session

For an interactive terminal an agent can launch, read as ASCII, and type into, use
the PTY scripts in [pty-sessions.md](references/pty-sessions.md). A hidden host owns
Windows ConPTY sessions for one repo root. `pty-launch` and `pty-send-keys` start
processes and inject input, so they are mutation. `pty-screenshot`, `pty-wait`, and
`pty-list` are read-only. `pty-close` and `pty-close-host` terminate owned processes.
Working directories must stay inside the repo root. Returned screens are bounded and
redacted.

## Quick start

1. Resolve the shell channel and open it in the **current repo root** (or path the user names).
2. Report: shell (`powershell.exe` / `pwsh`), **cwd**, console encoding, `$PSVersionTable.PSVersion`.
3. Tell the user: log in on the **authorized** host or service yourself; reply **`ready`** when the session is usable.
4. Until `ready`: only **local read-only** sanity (`Get-Location`, `$PSVersionTable`, `Test-Path` or equivalent).
5. After `ready`: follow [permission model](references/permission-model.md), [classification](references/command-classification.md), and [session lifecycle](references/session-lifecycle.md).

Optional session record: `.cursor/<alias>-terminal-session.json` — see [agent-terminals.md](references/agent-terminals.md).

## Non-negotiable rules

- Never collect or echo passwords, tokens, or connection strings in chat or logs.
- Never run mutation without explicit approval block answered.
- Never connect to remote or production targets before user **`ready`** (unless the user pre-configured non-interactive auth in the agent shell).
- FTP/SFTP/FTPS/deploy only on explicit user **Deploy** and current repo deploy rules.
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
| `scripts/karavi-terminal.open-interactive.ps1` | Open user PowerShell + optional SSH; write `.cursor/<alias>-terminal-session.json` |
| `scripts/karavi-terminal.open-agent-session.ps1` | Open a persistent local PowerShell session and return `sessionId` + PID JSON |
| `scripts/karavi-terminal.invoke-agent-command.ps1` | Execute one bounded command in an owned session and return JSON evidence |
| `scripts/karavi-terminal.get-agent-session.ps1` | List verified-live sessions from `karavi.temp.status` |
| `scripts/karavi-terminal.close-agent-session.ps1` | Close one owned session and remove its registry record |
| `scripts/karavi-terminal.agent-sanity.ps1` | Read-only report for agent shell (`SHELL`, `PS_VERSION`, `CWD`, `ENCODING`) |
| `scripts/karavi-terminal.pty-launch.ps1` | Start a ConPTY process and return `sessionId`, PID, and the screen |
| `scripts/karavi-terminal.pty-screenshot.ps1` | Return the current redacted ASCII screen |
| `scripts/karavi-terminal.pty-send-keys.ps1` | Write keys (`\r` Enter, `\t` Tab, `\x1b` Escape) and return the screen |
| `scripts/karavi-terminal.pty-wait.ps1` | Wait until output is stable, then return the screen |
| `scripts/karavi-terminal.pty-resize.ps1` | Resize the ConPTY |
| `scripts/karavi-terminal.pty-close.ps1` | Close one owned ConPTY session |
| `scripts/karavi-terminal.pty-list.ps1` | List sessions owned by the repo host |
| `scripts/karavi-terminal.pty-close-host.ps1` | Close every session and stop the host |
| `scripts/verify-karavi-terminal-skill.ps1` | Read-only structural and encoding verification |

**Interactive SSH (parameters supplied by user or repo-local wrapper, not hard-coded in skill):**

```powershell
& .agents/skills/karavi-terminal/scripts/karavi-terminal.open-interactive.ps1 `
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

## Operating references

- [command-classification.md](references/command-classification.md)
- [permission-model.md](references/permission-model.md)
- [agent-terminals.md](references/agent-terminals.md)
- [pty-sessions.md](references/pty-sessions.md)
- [powershell-core.md](references/powershell-core.md)
- [windows-terminal.md](references/windows-terminal.md)
- [computer-use-bridge.md](references/computer-use-bridge.md)
- [orca-terminal.md](references/orca-terminal.md)
- [session-lifecycle.md](references/session-lifecycle.md)
- [verification-and-capture.md](references/verification-and-capture.md)
- [windows-devops.md](references/windows-devops.md)
- [karavi-integration.md](references/karavi-integration.md)
- [discovery-and-install.md](references/discovery-and-install.md)
- [examples.md](references/examples.md)

## Starter

`/karavi-terminal` then wait for user `ready`.
