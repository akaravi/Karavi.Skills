# Carrier, DAHDI, PSTN, SBC, and fraud controls

Use this reference when Asterisk connects to PSTN, E1/T1/PRI, analog devices, a carrier trunk, an SBC, or a multi-provider routing system.

## Version

Resolve Asterisk, DAHDI, libpri, channel-driver, SBC, and provider versions independently. Do not assume a PJSIP-only design applies to DAHDI or carrier signaling.

## Architecture

Define the boundary between endpoint, Asterisk, SBC, carrier, and PSTN. Keep number normalization, E.164 policy, caller identity, emergency routing, codec policy, and provider failover explicit.

## Security and fraud

Apply AMI/ARI restrictions, trunk ACLs, dial-pattern allowlists, destination cost limits, per-user/tenant quotas, rate limits, anomaly detection, emergency-call safeguards, and audit trails. Never expose carrier credentials or full call records in logs.

## DAHDI and PSTN concerns

Validate spans, signaling, clock source, channel availability, echo cancellation, hangup cause mapping, caller ID, DTMF, fax requirements, and alarm state. Map carrier cause codes into a stable application taxonomy without losing the original evidence.

## SBC and failover

Use session affinity for signaling, deterministic trunk selection, bounded failover, circuit breaking, health checks that test real call capability, and reconciliation of calls created during a provider outage.

## Primary References

Official Asterisk deployment, PSTN, channel-driver, DAHDI/libpri, security, and provider/SBC documentation are authoritative.

## Verification

Test inbound/outbound calls, emergency policy, caller ID, DTMF, busy/congestion, provider failover, span alarm, fraud limits, and recovery without duplicate origination.
