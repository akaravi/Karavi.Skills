# Advanced Asterisk interfaces

Use this reference for AEAP, database/realtime, distributed device state, calendaring, StatsD, SNMP, speech, SIP messaging, presence, or MWI/BLF integrations.

## Version

Verify interface and module support on Asterisk 16 through 24. Feature names and available modules are installation-specific.

## Interfaces

| Interface | Use | Engineering concern |
|---|---|---|
| AEAP | speech or external media service protocol | framing, timeout, backpressure, privacy |
| ODBC/realtime | external configuration or call data | schema, cache, transaction, outage behavior |
| distributed device state | state across PBX nodes | ownership, convergence, split-brain |
| calendaring | business-hours and schedule logic | timezone, DST, provider failure |
| StatsD | dialplan metrics | cardinality, sampling, UDP loss |
| SNMP | infrastructure monitoring | community/transport security, metric mapping |
| speech API | recognition and grammars | latency, confidence, fallback, consent |
| SIP MESSAGE | text signaling | authorization, size, encoding, delivery status |
| presence/MWI/BLF | device state and notifications | subscription lifecycle and stale state |

## Security

Use TLS or protected network paths where supported, least-privilege database and monitoring credentials, bounded payloads, PII minimization, and explicit authorization for message and state changes.

## Failure behavior

External interface failure must not block a live channel indefinitely. Define bounded timeout, fallback prompt/route, retry policy, stale-state expiry, and reconciliation after reconnect.

## Primary References

Official Asterisk Interfaces, Database/Realtime, Speech, WebRTC, Messaging, Monitoring, and module documentation are authoritative.

## Verification

Test module availability, authentication, malformed payload, timeout, dependency outage, reconnect, stale-state recovery, timezone behavior, delivery status, and privacy redaction.
