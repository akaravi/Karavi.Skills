# ARI REST/WebSocket and Stasis in .NET

Use this reference when a .NET application uses ARI actions, the ARI event WebSocket, Stasis applications, bridges, playback, recording, or channel lifecycle.

## Connection model

ARI has two coupled surfaces: HTTP actions and a WebSocket event stream. Authenticate and configure them independently, then correlate actions with events and resource IDs. A REST success is not proof that the channel entered Stasis or that media is flowing.

The adapter should own endpoint and TLS validation, REST timeout/cancellation, WebSocket lifecycle and bounded reconnect, event deserialization with unknown-field tolerance, dispatch ordering and backpressure, and resource cleanup on StasisEnd, hangup, and shutdown.

## Stasis lifecycle

Model StasisStart, channel answer, bridge membership, playback or recording completion, StasisEnd, and hangup as a state machine. Do not leave bridges, recordings, subscriptions, or in-memory call state alive after terminal events.

When using a legacy ARI client library, verify its actual wire behavior against the target Asterisk version. Do not infer support from a type name or an old generated model.

## Verification

Cover REST failure, WebSocket disconnect, event replay or duplication, out-of-order terminal events, cancellation, bridge cleanup, playback failure, recording completion, and application shutdown.
## Version

Applicable to ARI deployments on Asterisk 16 through 23; verify modules and event behavior.

## Security

Use TLS where required, least-privilege ARI credentials, secret injection, and resource authorization.

## Verification

Test REST, WebSocket, Stasis lifecycle, reconnect, cleanup, and terminal event handling.

## Primary References

Official ARI documentation and the target repository's ARI adapter are authoritative.
