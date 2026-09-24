# Windows Terminal and shell-channel reference

Windows Terminal is the visible host for shell profiles; it is not itself the remote
session. Always record the selected profile and distinguish the visible user tab from
the agent's execution channel.

## Supported channel map

| Channel | Typical executable | Use | Boundary |
|---|---|---|---|
| PowerShell 7 | `pwsh.exe` | automation and modern Windows APIs | `$LASTEXITCODE`, profiles, encoding |
| Windows PowerShell | `powershell.exe` | legacy modules and Windows-only tooling | profile side effects, older encoding |
| Command Prompt | `cmd.exe` | legacy batch tools | `%ERRORLEVEL%`, quoting rules |
| WSL | `wsl.exe` | Linux tools on the local machine | Windows/Linux path and exit-code boundary |
| SSH | `ssh.exe` | remote interactive shell | user owns login and host trust |
| Orca terminal | Orca-managed shell | supervised app/worktree terminal | use handle/request id, not PID guesses |

## Visible-terminal workflow

1. Resolve the repo root, shell profile, window/tab, and user-vs-agent channel.
2. Run local read-only sanity and capture shell, version, cwd, encoding, and process identity.
3. Let the user perform interactive login or MFA in the visible tab; never type credentials through the agent.
4. Wait for the exact `ready` response. A visible window alone is not proof of authentication.
5. Execute approved read-only checks in the agent channel or have the user paste a command into the shared tab.
6. For every mutation, present the approval block with the exact command, cwd, risk, and rollback.
7. Verify the effect through an independent read-only check and close/restore the session only when requested.

## GUI control boundary

Use the Computer Use bridge only when a visible Windows app, dialog, terminal tab, or
focus state cannot be reached through filesystem, shell, API, or CLI. Refresh UI state
before acting, target controls by accessible identity, use small actions, and verify a
visible result after each action. Do not assume a click or keystroke succeeded.
