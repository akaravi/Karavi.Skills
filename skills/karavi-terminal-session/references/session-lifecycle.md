# Session lifecycle and state machine

```text
resolve → sanity → interactive-login → ready-gate → classify → execute → capture
        → independent-verify → handoff/close
```

## State rules

| State | Allowed work | Exit condition |
|---|---|---|
| `resolve` | identify repo, shell, host scope, channel, and permissions | target and channel recorded |
| `sanity` | local read-only checks only | shell/version/cwd/encoding evidence |
| `interactive-login` | user types SSH/MFA/password in visible channel | user replies `ready` |
| `ready-gate` | compare requested host with authorized scope | exact host/channel accepted |
| `classify` | classify command and risk | read-only or approval block |
| `execute` | run one bounded command | process completed or timed out |
| `capture` | collect redacted stdout/stderr/status | evidence record written |
| `independent-verify` | read-only proof of result | expected state observed or finding opened |
| `handoff/close` | release/focus/close only in scope | handle and metadata reconciled |

## Session record

An optional record may contain `schemaVersion`, `alias`, `channel`, `host`, `port`,
`user`, `shell`, `pid`, `openedAtUtc`, `status`, and `note`. It must never contain a
password, token, private key, cookie, connection string, or raw login output. Use UTC
timestamps and mark unknown fields as unknown rather than inventing values.
