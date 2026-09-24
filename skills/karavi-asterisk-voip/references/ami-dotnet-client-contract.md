# AMI client contract for .NET

Use this reference when implementing or reviewing a C# ManagerConnection, AMI session registry, action client, or event consumer.

## Wire model

AMI is a line-oriented TCP protocol with CRLF-delimited headers and a blank line terminating a message. Preserve header names and unknown headers. Do not assume one ReadAsync equals one AMI message, and do not discard multiline Data content.

Separate connection state, action response correlation, unsolicited events, event-generating action aggregation, and terminal call state.

An action response may arrive before related events, after them, or without the expected event when the PBX rejects the action. Complete operations using an explicit state machine and timeout, not a single response callback.

## Action rules

- Generate a unique ActionID per logical operation and keep it stable across retries only when the retry is proven safe.
- Treat Originate, Redirect, Bridge, Hangup, QueuePause, and spying actions as state-changing operations requiring idempotency and concurrency policy.
- Do not retry an unknown-result originate without reconciliation by channel or call identity.
- Map AMI response, event, cause, and timeout into an application error taxonomy.

## Session registry

For multiple Asterisk servers, keep one isolated session per enabled server. Route every action by server ID, prevent secondary event streams from duplicating primary fan-out, and expose connection status from the live registry rather than probe-login loops. Legacy calls without a server ID may resolve to the configured default server only through an explicit compatibility rule.
## Version

Applicable to Asterisk 16 through 23; verify wire behavior on the target PBX.

## Security

Use least-privilege AMI users, restricted bind/ACL, secret injection, and redacted structured logs.

## Verification

Use parser, correlation, timeout, reconnect, duplicate-action, and shutdown tests.

## Primary References

Official AMI documentation and the target repository's ManagerConnection contract are authoritative.
