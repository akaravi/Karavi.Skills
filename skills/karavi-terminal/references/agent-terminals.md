# Agent vs user terminals

| Channel | Who types | Agent monitoring |
|---------|-----------|------------------|
| User PowerShell (`powershellPid` in JSON) | User | User pastes output unless integrated terminal capture exists |
| Agent Shell tool | Agent | stdout/stderr/exit via tool |
| ConPTY host | Agent | ASCII screen via `pty-screenshot` / `pty-send-keys` |

The ConPTY channel is documented in [pty-sessions.md](pty-sessions.md). It is a real
pseudoconsole, separate from the command-marker session.

Session file: `.cursor/<alias>-terminal-session.json` — fields: `host`, `port`, `user`, `powershellPid`, `openedAt`, `note`, `skill`.

Never store secrets in JSON. `<alias>` is a short label the user or repo chooses (e.g. `prod-db`, `staging-api`) — not defined by this skill.

## Workflow

1. Agent runs `karavi-terminal.agent-sanity.ps1` (read-only).
2. User or approved mutation runs `karavi-terminal.open-interactive.ps1` with **user-supplied** host/port/user, or a **repo-local** wrapper script.
3. User types `ready` after interactive login succeeds.
4. Agent runs read-only on agent Shell (e.g. SSH with keys) or asks user to paste from the user tab.

## Repo-local wrappers

Hosts, ports, and account names are **environment-specific**. Keep them in the consuming repository (for example `karavi/karavi.scripts.command/*.ps1` or `scripts/*.ps1`). This skill stays host-agnostic.
