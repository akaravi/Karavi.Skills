# Asterisk REST Interface (ARI)

## Version

Canonical: Asterisk 22 LTS. Verify resource fields, WebSocket events, and
authentication against the target version's API reference.

## Implementation decisions

Use ARI when an application owns a channel/bridge/media state machine. Define
Stasis application ownership, REST resource lifecycle, WebSocket event flow,
playback/recording completion, bridge membership, hangup, and reconnect recovery.
REST acceptance is not completion; reconcile the resulting events and resource
state before reporting success.

Use stable call and operation IDs. Check current state before retrying answer,
originate, bridge, playback, recording, or hangup. Bound HTTP/WebSocket
timeouts, cancellation, backpressure, event queue size, and shutdown cleanup.

## Security

Protect HTTP and WebSocket endpoints with TLS and least-privilege credentials,
restrict origins and network access, and redact tokens, caller data, recordings,
and resource details from logs.

## Failure behavior

Distinguish HTTP error, WebSocket close, Stasis end, channel hangup, resource
not-found, media failure, timeout, duplicate action, and dependency outage.
Recover by querying current resource state rather than blindly replaying commands.

## Verification

Test authentication, channel creation, Stasis start/end, answer, bridge,
playback, recording, DTMF, transfer, hangup, reconnect, duplicate action,
malformed event, timeout, cancellation, and cleanup using a controlled Asterisk
22 instance.

## Primary references

- <https://docs.asterisk.org/Configuration/Interfaces/Asterisk-REST-Interface-ARI/>
- <https://docs.asterisk.org/Configuration/Interfaces/Asterisk-REST-Interface-ARI/Introduction-to-ARI-and-REST/>
