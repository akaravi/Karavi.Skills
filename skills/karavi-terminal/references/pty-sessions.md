# ConPTY sessions

Windows interactive terminal control for this skill. The behavior follows the
`agent-terminal` session model (launch, ASCII screen, keys, wait, resize, close,
list) and is implemented with the Windows pseudoconsole API. It does not vendor
that Node package or `node-pty`.

The command-marker session (`open-agent-session`) remains the channel for one
PowerShell command at a time. Use ConPTY when the program expects a real terminal.

## Host

`karavi-terminal.pty-host.ps1` is one hidden process per repo root. Clients talk to
it over a local named pipe. The host record is
`karavi.temp.status/karavi-terminal-pty-host.json` and is reconciled with PID plus
process start time. Sessions live in that process. If the host stops, its sessions
stop with it.

## Commands

| Script | Class | Result |
|---|---|---|
| `pty-launch` | mutation | `sessionId`, child PID, screen |
| `pty-send-keys` | mutation | screen after the keys |
| `pty-resize` | mutation | new size |
| `pty-close` | mutation | owned session closed |
| `pty-close-host` | mutation | host and every session closed |
| `pty-screenshot` | read-only | current screen |
| `pty-wait` | read-only | screen after output settles |
| `pty-list` | read-only | owned sessions |

`pty-launch` starts an executable with an argument array. It does not pass the
command through `cmd /c`. The default child is `powershell.exe -NoLogo -NoProfile
-NoExit` after unloading `PSReadLine`, so prediction text is not mixed into the
screen.

Keys use the same escapes as the reference model: `\r` Enter, `\n` newline, `\t`
Tab, `\x1b` Escape.

## Limits

- At most 20 live sessions for a repo.
- `cwd` must be an existing directory inside the repo root.
- Columns 20–500, rows 5–200.
- Keys are limited to 10000 characters. Screens returned to the client are capped
  and redacted (`password`, `token`, `secret`, and common key prefixes).
- Environment variables whose names look like secrets are not copied into the child.
- A PID is not accepted as a way to attach to an unrelated console.

## Example

```powershell
$launch = & .\scripts\karavi-terminal.pty-launch.ps1 -RepoRoot . | ConvertFrom-Json
& .\scripts\karavi-terminal.pty-send-keys.ps1 -RepoRoot . -SessionId $launch.sessionId -Keys "Get-Location\r"
& .\scripts\karavi-terminal.pty-close.ps1 -RepoRoot . -SessionId $launch.sessionId
```

Launch and send-keys still require the skill mutation approval block before an
agent runs them.
