# VoIP testing with Asterisk Test Suite, SIPp, and load tools

Use this reference when testing signaling, media, call flows, provider failures, concurrency, or long-running reliability.

## Version

Test suites must identify the Asterisk version, channel driver, codecs, transport, and client/tool versions. Do not reuse a passing scenario across releases without compatibility review.

## Security

Use isolated test accounts, masked numbers, synthetic recordings, restricted test trunks, and disposable credentials. Never run load or originate tests against production without explicit authorization.

## Test layers

1. Unit: AMI/ARI/AGI parsers, state machines, mapping, validation.
2. Contract: action/event fixtures, envelope, legacy client compatibility.
3. Integration: controlled PBX, dialplan, AMI, ARI, FastAGI, database.
4. Signaling: SIPp/PJSUA registration, INVITE, answer, busy, timeout, transfer.
5. Media: RTP direction, codec, DTMF, recording, WebRTC audio.
6. Load: concurrent calls, CPS, queue pressure, event fan-out, recording I/O.
7. Fault: disconnect, provider 503, packet loss, delayed events, process restart, disk full, dependency timeout.

## Evidence

Store scenario name, target version, configuration hash, timestamps in UTC, expected and observed SIP/AMI/ARI states, latency, media evidence, and cleanup result. A green HTTP health check is not a green call-flow test.

## Primary References

Official Asterisk Test Suite documentation, SIPp documentation, and the target PBX configuration are authoritative.

## Verification

Every new call flow needs positive, negative, timeout, cancellation, duplicate, hangup, and recovery scenarios. Repeat critical cases after reconnect and version changes.
