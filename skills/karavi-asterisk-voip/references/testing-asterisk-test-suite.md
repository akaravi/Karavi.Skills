# Asterisk Test Suite and implementation verification

## Version

Canonical: Asterisk 22 LTS. Pin the Test Suite revision, Asterisk image,
modules, endpoints, trunk simulator, and network topology.

## Implementation decisions

Separate unit/parser/state tests, protocol contract tests, Asterisk integration,
media smoke, and failure/recovery tests. Use deterministic synthetic callers,
test numbers, endpoint credentials, and timeouts. A parser pass does not prove
manager authorization, dialplan routing, or RTP.

Cover AMI/ARI/AGI framing and schemas, PJSIP registration and SDP, dialplan
paths, queue/bridge lifecycle, DTMF, recordings, CDR/CEL, reconnect, duplicate
actions, malformed events, overload, cancellation, and shutdown.

## Security

Use isolated test credentials and networks. Redact traces, SIP headers,
recordings, caller data, tokens, and packet captures; never use production
credentials or destinations in fixtures.

## Failure behavior

Classify test environment failure separately from product failure: unavailable
PBX, missing trunk simulator, invalid version, flaky endpoint, timeout, and
tooling failure must not become a false green result.

## Verification

Record command, version, environment, timestamp UTC, attempt, expected status,
payload evidence, latency, and cleanup. Re-run failed scenarios after the fix
and execute the full relevant suite before completion.

## Primary references

- <https://docs.asterisk.org/Test-Suite/>
- <https://github.com/asterisk/testsuite>
- <https://docs.asterisk.org/Development/Testing/>
