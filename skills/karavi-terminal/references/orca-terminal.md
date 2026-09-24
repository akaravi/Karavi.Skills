# Orca terminal and worktree reference

When the repository is managed by Orca, prefer its CLI and handles over ad-hoc PTYs,
raw `git worktree`, Playwright, or GUI automation. Resolve the current Orca skill and
CLI help before using commands because subcommands can evolve.

## Capability map

| Area | Required operations |
|---|---|
| Discovery | resolve the `orca` executable, inspect status/help, load the current `orca-cli` skill |
| Worktrees | create, list, inspect current/show, set context, and remove an explicitly selected worktree |
| Terminals | list/show, create, split, rename, focus/switch, send input, read output, wait, and close by handle |
| Handoffs | hand off or receive a task with a request/operation id; wait for status and follow-up completion |
| Artifacts | list/share/remove supported artifacts; never publish secrets or local-only config |
| Browser | open or inspect an Orca-managed browser tab only when the task requires visible browser state |
| Sessions | search or inspect task/session state and preserve the user/agent channel boundary |
| Automation | view/create/update/delete scheduled work only when explicitly requested |

## Operating rules

- Prefer `--json` output for machine parsing and retain the handle/request id, not a
  window title or PID guess.
- Read output before sending input. Send one bounded command or response at a time.
- A terminal `send` is a mutation when the command itself mutates; the Orca transport
  does not remove the approval requirement.
- Handoff interrupts a running task; inspect the returned operation status before
  assuming the destination is active.
- Worktree removal, artifact sharing, task archival, and automation changes are
  explicit state changes and require the user's scope.
- Never pass secrets in CLI arguments, environment dumps, terminal transcripts, or
  artifact payloads.

## Fallback

If Orca is unavailable, use the agent shell tool for read-only checks and the visible
user terminal for interactive login. Record the unavailable capability as a blocker
instead of silently switching to an unverified PID/window.
