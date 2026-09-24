# Testing, observability, and troubleshooting

Use this reference for verification planning, local/container integration,
health checks, CDR/CEL reconciliation, logs, traces, and incident diagnosis.

## Version

Canonical: Asterisk 22 LTS. Record the exact release, modules, transport, and
test image for every integration result.

## Test layers

1. Unit-test parsers, validators, state transitions, idempotency decisions, and
   transport-to-DTO mappings with malformed and boundary inputs.
2. Contract-test AMI/ARI/AGI framing, action/event schemas, authentication
   failure, error mapping, timeout, cancellation, and version assumptions.
3. Integration-test against a pinned Asterisk image or controlled instance with
   deterministic endpoints, a test trunk, and synthetic caller data.
4. Smoke-test registration, inbound/outbound routing, answer, media in both
   directions, DTMF, bridge/queue state, transfer, hangup, and CDR/CEL output.
5. Failure-test dependency outage, reconnect, duplicate action, delayed event,
   malformed event, codec mismatch, NAT/one-way audio, overload, and shutdown.

Do not call a parser test an end-to-end call test. State which layer each result
proves and which external prerequisites remain unverified.

## Evidence and observability

Use structured UTC logs with service, environment, version, correlation ID,
call/channel ID, operation, duration, result, and sanitized error category.
Never log passwords, tokens, full SIP authorization headers, recordings, or
unmasked caller PII. Keep packet captures and recordings access-controlled and
time-limited.

## Security

Redact secrets and caller data before analysis, restrict packet captures and
recordings, and collect remote or production evidence only with explicit
authorization for that exact action.

Correlate application logs with AMI `ActionID`, ARI resource IDs, SIP Call-ID,
linked channel IDs, and CDR/CEL identifiers without assuming they are
interchangeable. Document the mapping used by the integration.

## Failure diagnosis

Classify the symptom before changing configuration:

| Symptom | First evidence |
|---|---|
| Cannot register | endpoint/AOR/auth, transport, SIP response, clock/certificate |
| Call rejected | dialplan context, destination, permissions, SIP response, AMI/ARI result |
| Ringing but no answer | channel/event timeline, dial timeout, endpoint state, queue/member state |
| One-way or no audio | SDP, negotiated codec, RTP packet direction, NAT/firewall, bridge |
| DTMF failure | negotiated telephone-event, framing, application/ARI handling |
| Duplicate or missing action | operation ID, `ActionID`, event dedupe, reconnect and current state |
| CDR mismatch | call/channel/linked IDs, hangup path, timezone, late event handling |

Collect local evidence first. Stop before remote log collection, production
changes, restart, reload, credential rotation, or traffic impact unless the
user explicitly authorizes that exact operation.

## Completion gate

Report the exact Asterisk version, test environment, commands/checks, masked
evidence, passed/failed/skipped cases, and remaining blocker. A `/health` or
AMI login alone is not functional or media health.

## Verification

Use the test layers and symptom matrix above; record exact version, command,
environment, masked evidence, latency, result, and remaining blocker.

## Primary references

Primary references:

- <https://docs.asterisk.org/Configuration/Interfaces/Asterisk-Manager-Interface-AMI/>
- <https://docs.asterisk.org/Configuration/Interfaces/Asterisk-REST-Interface-ARI/>
