# Enterprise VoIP architecture, HA, and scale

Use this reference when a solution spans multiple PBX nodes, SBCs, SIP providers, high call volume, disaster recovery, or regulated recordings.

## Version

Architecture patterns apply across Asterisk 16 through 23, but module and deployment details require target-version validation.

## Security

Place Asterisk behind a firewall/SBC, segment signaling and media, restrict AMI/ARI, rotate credentials, apply rate limits, audit privileged actions, and encrypt recordings and backups.

## Topology decisions

Resolve whether the system needs:

- one PBX with application redundancy;
- active/standby PBX with shared configuration and controlled ownership;
- multiple active PBX nodes with deterministic call distribution;
- SBC and provider failover;
- separate media, recording, and analytics services.

Do not load-balance a stateful AMI or ARI WebSocket without session affinity and event ownership. A call must have one authoritative control session and a durable correlation identity.

## Capacity model

Measure concurrent channels, calls per second, RTP ports, CPU from transcoding, memory, file descriptors, disk I/O for recordings, AMI event rate, database write rate, and SignalR fan-out. Establish p95/p99 latency and saturation thresholds from a repeatable workload.

## Recovery

Define what happens to active calls, registrations, queued callers, recordings, pending Call Files, and in-flight AMI actions during node failure. Reconciliation after restart must be idempotent and must not originate duplicate calls.

## Primary References

Official Asterisk deployment/security documentation and the provider/SBC design are authoritative.

## Verification

Run capacity, failover, reconnect, split-brain prevention, recording durability, backup/restore, and recovery drills before production acceptance.
