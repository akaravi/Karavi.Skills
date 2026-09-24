# Troubleshooting and observability

## Version

Canonical: Asterisk 22 LTS. Record the exact release, module set, topology,
and client versions in every diagnostic result.

## Implementation decisions

Use structured UTC logs with service, environment, version, correlation ID,
call/channel ID, SIP Call-ID, AMI ActionID or ARI resource ID, operation,
duration, result, and sanitized error category. Correlate identifiers explicitly;
do not assume they are interchangeable.

Diagnose in layers: registration/authentication, SIP/SDP, dialplan/channel,
AMI/ARI/AGI, bridge, RTP/media, queue, CDR/CEL, and external dependencies.
Collect local evidence first and preserve timestamps and commands.

## Security

Redact credentials, SIP authorization, tokens, full numbers, recordings, caller
PII, and sensitive topology from logs, traces, packet captures, and support
bundles. Restrict access and retention.

## Failure behavior

Classify registration failure, rejected call, no-answer, one-way audio, DTMF
failure, duplicate/missing event, CDR mismatch, timeout, overload, and
dependency outage. Do not make a production mutation or remote log transfer
while merely diagnosing unless separately authorized.

## Verification

Use versioned CLI output, masked SIP/SDP evidence, RTP direction, channel/bridge
state, AMI/ARI timeline, CDR/CEL identifiers, latency, and cleanup evidence.
A health endpoint or AMI login alone is not functional or media health.

## Primary references

- <https://docs.asterisk.org/Operation/Logging/>
- <https://docs.asterisk.org/Operation/CLI/>
- <https://docs.asterisk.org/Configuration/Reporting/>
