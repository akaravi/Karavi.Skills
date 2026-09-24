# ARI, AGI, FastAGI, and media applications

Use this reference when application code controls channels, bridges, playback,
recording, Stasis applications, or dialplan-to-application execution.

## Version

Canonical: Asterisk 22 LTS. Verify ARI resource fields, AGI result behavior,
and media interfaces against the deployed release.

## Choose the interface deliberately

- Use ARI for an application-owned call-control state machine using channels,
  bridges, media, recordings, and Stasis. Define ownership and recovery when
  the WebSocket disconnects.
- Use AGI for synchronous dialplan interaction when the dialplan remains the
  primary owner of the call. Keep execution bounded and return control on every
  error path.
- Use FastAGI only when the network boundary and timeout/retry behavior are
  explicit. Avoid turning a call into an unbounded dependency on a remote
  process.
- Use AMI for manager-level actions and events; do not replace an ARI channel
  state machine with loosely correlated AMI commands.

## ARI lifecycle

Model channel, bridge, playback, recording, and WebSocket state explicitly.
Handle Stasis start/end, hangup, bridge destruction, playback completion,
recording failure, reconnect, and application shutdown. A successful REST
response confirms request acceptance, not completed media or call outcome.

Use a stable call correlation ID and operation ID. Make retries safe by checking
current resource state first. Do not issue a second originate, bridge, answer,
or recording action merely because the first HTTP response timed out.

## AGI/FastAGI rules

- Parse the AGI environment until the blank-line terminator before reading the
  command result.
- Write one command at a time, flush it, and read the corresponding result.
- Set connect, command, and overall deadlines; cancel on channel hangup.
- Treat non-zero results, missing results, malformed responses, and channel
  disappearance as distinct outcomes.
- Never include secrets, raw caller data, or unbounded user input in commands.
- Keep business logic in the application layer and make the AGI adapter a thin
mapper for channel variables and results.

## Security

Protect ARI credentials and WebSocket endpoints, validate channel variables and
media inputs, restrict recording access, and redact caller data and tokens.

## Media safety

For AudioSocket, external media, recording, or streaming integrations, define
sample rate, signedness, endianness, channel count, frame size, codec, jitter,
backpressure, cancellation, and shutdown behavior. Verify both directions and
barge-in/DTMF behavior when applicable. Bound buffers and fail closed on media
or dependency overload rather than accumulating unbounded audio in memory.

## Verification

Test ARI lifecycle, AGI framing, cancellation, reconnect, duplicate action,
media negotiation, backpressure, recording, hangup, timeout, and cleanup.

## Primary references

Primary reference: <https://docs.asterisk.org/Configuration/Interfaces/Asterisk-REST-Interface-ARI/>
