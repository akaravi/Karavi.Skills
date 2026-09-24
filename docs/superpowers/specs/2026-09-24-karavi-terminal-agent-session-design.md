# Karavi Terminal Agent-Controllable Session Design

## Goal

Rename the public skill from `karavi-terminal-session` to `karavi-terminal` and
provide a local, persistent PowerShell session that an agent can open, address by
`sessionId`, send commands to, and read bounded command-correlated results from.

## Scope and boundaries

The implementation supports local `powershell.exe` or `pwsh.exe` processes. It
does not automate password, MFA, host-key confirmation, or interactive remote login.
The existing visible user terminal remains a separate channel for those actions.
The controller never accepts a secret through its command-line parameters, session
metadata, result JSON, or generated evidence.

The rename is complete: the directory, Skill front matter, documentation, examples,
verifier, repository indexes, and script names use `karavi-terminal`. The prior name
is not retained as an implicit compatibility alias because installed skills are
discovered by their directory and front-matter name; consumers must reinstall or
update their invocation to `/karavi-terminal`.

## Public command contract

All controller scripts use UTF-8 JSON on stdout and return non-zero for controller
errors. Their parameters do not include secret fields.

| Command | Inputs | Result |
|---|---|---|
| `open-agent-session` | repo root, alias, shell executable, optional visibility | `sessionId`, `pid`, `metadataPath`, shell, cwd, status |
| `invoke-agent-command` | `sessionId`, command text, timeout seconds | command id, stdout, stderr, native exit code, PowerShell success, timeout/status |
| `get-agent-session` | `sessionId` | live process and session state without sending input |
| `close-agent-session` | `sessionId` | deterministic cleanup result; force requires explicit caller intent |

`open-agent-session` starts a wrapper process with redirected standard input, output,
and error. It stores process-local capture files under `.cursor/karavi-terminal/` and
a schema-versioned metadata record under `.cursor/<alias>-terminal.json`. A random
`sessionId` links metadata to the controller state but is not a credential.

`invoke-agent-command` serializes access with a per-session lock. It writes a
begin/end marker unique to the command, executes the supplied command in the same
PowerShell process, captures `$LASTEXITCODE` and `$?`, and waits only until the end
marker or the configured timeout. It reads just the bytes associated with that
command, redacts known secret-shaped values before returning, and always releases the
lock. A timeout reports `timedOut`; it never reports success and does not silently
reuse incomplete output.

## Lifecycle and error handling

```text
open -> ready -> invoke* -> status -> close
                 |             |
                 +-> timeout --+-> failed/closed
```

The session state is `ready`, `busy`, `timedOut`, `failed`, or `closed`. A missing,
dead, malformed, or mismatched session record is a controller error. The controller
does not guess a PID or attach to an arbitrary console. Closing removes only the
state and capture files owned by the identified session; it never recursively removes
the enclosing `.cursor` directory.

Commands retain the existing policy: read-only may run after the appropriate ready
gate; mutation still requires the approval block defined by the Skill. The transport
does not weaken command classification, remote/deploy, or secret rules.

## File design

`scripts/karavi-terminal.agent-session.psm1` owns metadata validation, locking,
process lifecycle, protocol markers, redaction, and bounded capture. Thin command
scripts expose each public command so agents do not need to construct PowerShell
objects themselves. Tests call the public scripts against an isolated temporary repo
and use harmless local PowerShell commands only.

The old `open-interactive` script is retained as a renamed user-channel command
(`karavi-terminal.open-interactive.ps1`). Its explicit boundary stays intact: it
opens a terminal for human login and does not claim that its PID is agent-controlled.

## Acceptance criteria

1. `/karavi-terminal` is the sole documented public skill name and the skill folder
   has the same name.
2. Opening an agent session returns a live PID plus stable `sessionId` and metadata.
3. Two sequential commands run in the same process and return their own stdout,
   stderr, exit code, and status without output bleed.
4. A non-zero native exit, a PowerShell error, a dead process, and a timeout are
   surfaced as non-success states.
5. The close command terminates only its owned process and removes only its owned
   controller state.
6. Session records and result JSON contain no raw secrets; bounded redacted capture
   is used for returned evidence.
7. Existing user-interactive guidance remains explicit and the mutation-approval
   policy is unchanged.
8. Automated tests first demonstrate the missing behavior, then pass; the skill
   structural verifier and repository-local checks pass.

## Non-goals

- Attaching to an already-running terminal solely by PID.
- Feeding credentials, MFA responses, or SSH host trust prompts.
- Remote connection, deployment, or configuration of consuming repositories.
- A GUI terminal emulator or cross-platform Unix PTY implementation in this change.
