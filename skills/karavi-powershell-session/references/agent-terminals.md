# Agent vs user terminals

| Channel | Who types | Agent monitoring |
|---------|-----------|------------------|
| User PowerShell (`powershellPid` in JSON) | User | User pastes output or agent reads only if integrated capture exists |
| Agent Shell tool | Agent | Full stdout/stderr/exit via tool |

Session file: `.cursor/<alias>-terminal-session.json` — fields: `host`, `port`, `user`, `powershellPid`, `openedAt`, `note`, `skill`.

Never store secrets in JSON.

## Workflow

1. Agent runs `agent-sanity.ps1` (read-only).
2. User runs `open-interactive.ps1` or existing `scripts/open-s91-powershell.ps1` (mutation — needs approval).
3. User types `ready` after SSH login.
4. Agent runs read-only on agent Shell (`ssh` with keys) or asks user to paste from user tab.
