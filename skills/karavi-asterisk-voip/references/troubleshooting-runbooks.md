# VoIP troubleshooting runbooks

Use this reference for diagnosis of connection, signaling, dialplan, media, recording, queue, and WebPhone failures.

## Version

Start every runbook with Asterisk version, distribution, channel driver, deployment host, and affected call IDs.

## Security

Collect masked logs and packet evidence. Never copy passwords, Authorization headers, tokens, full phone numbers, or unredacted recordings into tickets or chat.

## Runbook order

1. Confirm scope and reproduce with a synthetic/test call.
2. Correlate server ID, unique ID, linked ID, ActionID, channel, SIP Call-ID, and timestamp.
3. Separate connectivity, authentication, action acceptance, dialplan, signaling, media, persistence, and UI symptoms.
4. Capture the narrowest relevant AMI/ARI/SIP/RTP evidence.
5. Apply one bounded fix, then repeat the same scenario and verify cleanup.

## Fast diagnosis

| Failure | Evidence to collect |
|---|---|
| AMI refused | bind address, firewall, port, process, route |
| AMI login failed | manager ACL/classes and masked login response |
| originate reason 0 | channel, context, endpoint/trunk, PBX CLI result |
| ARI disconnected | HTTP status, WebSocket close, reconnect state, Stasis events |
| FastAGI timeout | listener port, script name, command/reply timeline, cancellation |
| no audio | SDP, NAT addresses, RTP packets, codec, bridge members |
| recording missing | MixMonitor state, CDR/CEL, file path, permissions, finalization |
| queue drift | QueueStatus snapshot, deltas, server ID, stale expiration |
| WSS failure | certificate chain, origin, browser console, SIP registration |

## Primary References

Official Asterisk CLI, AMI, ARI, SIP, RTP, and logging documentation plus the repository runbook are authoritative.

## Verification

A diagnosis is complete only when the cause is evidenced, the fix is scoped, the original failure is reproduced as passing, and terminal state/cleanup is verified.
