# CDR, CEL, realtime, and operational data

## Version

Canonical: Asterisk 22 LTS. Confirm backend schema, event fields, and realtime
modules for the target version.

## Implementation decisions

Use CDR for call-detail summaries and CEL for event-level chronology; neither
alone is a complete application state machine. Correlate channel, linked ID,
unique ID, application operation ID, SIP Call-ID, AMI ActionID, and ARI resource
IDs explicitly. Store and transmit instants in UTC ISO 8601.

Define late-event, duplicate-event, failed-write, retention, reconciliation,
tenant isolation, and export policies. Realtime configuration is an external
dependency with timeout, cache, and failure behavior; it is not a substitute
for validated local configuration.

## Security

Use least-privilege database roles, parameterized queries, redacted logs,
tenant isolation, restricted reports, and retention/deletion controls. Do not
store secrets, recordings, or unmasked caller PII in CDR/CEL fields.

## Failure behavior

Handle missing identifiers, late hangup, partial writes, database outage,
timezone mismatch, duplicate events, and inconsistent CDR/CEL records as
observable reconciliation findings rather than silently repairing them.

## Verification

Test inbound/outbound, transfer, bridge, queue, hangup, timeout, abandon,
duplicate event, late event, database outage, UTC serialization, retention,
redaction, and consumer compatibility.

## Primary references

- <https://docs.asterisk.org/Configuration/Reporting/Call-Detail-Records-CDR/>
- <https://docs.asterisk.org/Configuration/Reporting/Channel-Event-Logging-CEL/>
- <https://docs.asterisk.org/Configuration/Realtime/>
