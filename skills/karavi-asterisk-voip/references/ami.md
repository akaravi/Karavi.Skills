# Asterisk Manager Interface (AMI)

Use this reference for TCP AMI clients, manager users, actions, events,
origination, queue/bridge control, and event-driven call state.

## Version

Canonical: Asterisk 22 LTS. Verify action/event fields and manager behavior in
the target release before implementing a client contract.

## Wire and session contract

- Confirm the target Asterisk release and AMI protocol behavior before coding.
- AMI is a text protocol with fields separated by `: ` and messages terminated
  by a blank line. Do not assume one TCP read equals one AMI message; buffer,
  frame, and parse incrementally.
- Preserve repeated fields and multi-line `Data` according to the action/event
  contract. Never split an unbounded `Data` field using an arbitrary delimiter.
- Correlate action responses with `ActionID`. Do not infer that an event is the
  response to the most recent action.
- Treat `Response: Error`, authentication failure, socket close, malformed
  frames, and timeout as separate error classes.
- Handle `FullyBooted`, `Shutdown`, reconnect, and server-generated events as
  lifecycle signals, not ordinary call events.

## Authentication and authorization

- Bind AMI to a private interface or protected management network. Use ACLs,
  TLS where supported by the deployment, and a dedicated least-privilege user.
- Do not use `admin`, wildcard ACLs, public exposure, or credentials embedded in
  source, container images, examples, test fixtures, or logs.
- Grant only the manager classes required by the application. Review whether an
  action can originate calls, read channels, execute commands, or expose caller
  information.
- Redact `Secret`, `Username`, SIP credentials, full numbers, and caller data
  before storing or displaying frames.

## Security

Keep AMI private, use least-privilege manager classes and narrow ACLs, and
redact credentials, numbers, and caller data. Never enable broad command access
just to make a client test pass.

## Action design

For each action define:

| Concern | Required decision |
|---|---|
| Identity | tenant/user/operation-scoped `ActionID` and application correlation ID |
| Timeout | connect, write, response, and overall deadline |
| Retry | transient-only; never blindly retry originate, hangup, bridge, or transfer |
| Duplicate | idempotency record or call-state guard and deterministic replay result |
| Result | response, relevant events, terminal state, and cleanup condition |
| Authorization | manager class, target channel/endpoint scope, and audit record |

`Originate` must carry a stable application operation ID and a bounded timeout.
Persist the operation state before sending it when possible, and reconcile the
result with `Newchannel`, `Newstate`, `DialBegin`/`DialEnd`, `Hangup`, and the
application's own terminal event policy. A successful `Response: Success` means
the action was accepted, not that the call was answered.

## Event consumer rules

- Expect out-of-order, duplicate, late, and missing events during reconnects.
- Keep a durable or bounded state machine keyed by call/channel/linked ID as
  appropriate. Make transitions monotonic where the domain permits.
- Deduplicate using event identity plus a bounded retention window; do not use
  wall-clock ordering as the sole ordering guarantee.
- Reconcile state after reconnect with explicit queries such as channel, bridge,
  queue, or endpoint status rather than replaying every old command.
- Stop consumers cleanly, cancel pending requests, close the socket, and avoid
  orphaned tasks on shutdown.

## Testing targets

At minimum test framing across partial reads, multiple messages in one read,
multi-line data, malformed fields, action timeout, auth failure, reconnect,
duplicate events, unknown events, duplicate originate, and graceful shutdown.
Use a real Asterisk/container integration test for the final action/event
contract; parser-only tests cannot prove manager permissions or call behavior.

## Verification

Use the testing targets above as the minimum AMI verification matrix and record
version, manager permissions, action result, related events, timeout, cleanup,
and redacted evidence.

## Primary references

Primary reference: <https://docs.asterisk.org/Configuration/Interfaces/Asterisk-Manager-Interface-AMI/>

## Primary references

- <https://docs.asterisk.org/Configuration/Interfaces/Asterisk-Manager-Interface-AMI/>
- <https://docs.asterisk.org/Configuration/Interfaces/Asterisk-Manager-Interface-AMI/AMI-Libraries-and-Frameworks/>
