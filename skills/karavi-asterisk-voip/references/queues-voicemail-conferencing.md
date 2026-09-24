# Queues, voicemail, parking, and conferencing

## Version

Canonical: Asterisk 22 LTS. Confirm queue, voicemail, parking, and conference
application options against the target release and any FreePBX generator.

## Implementation decisions

Model queue/member state, strategy, penalties, wrap-up, timeout, abandon,
callback, transfer, voicemail, parking, paging, conference, recording, and
agent availability as separate state machines. Define ownership and terminal
cleanup for every channel and bridge.

Use bounded retries and deterministic operation IDs for callback, transfer,
recording, and external notification. Keep tenant, queue, destination, and
feature-code allowlists outside arbitrary dialplan input.

## Security

Protect voicemail, recordings, conference access codes, caller identifiers,
agent state, and queue reports. Enforce authorization at the application and
dialplan boundaries; do not expose recordings or queue data by guessable IDs.

## Failure behavior

Define invalid input, timeout, no-agent, abandon, transfer failure, recording
failure, bridge failure, dependency outage, and hangup behavior. Ensure CDR/CEL
and application state converge after late events or channel loss.

## Verification

Test queue join/leave, member pause, timeout, abandon, callback, voicemail,
parking, transfer, conference join/leave, DTMF, recording, agent failure,
dependency outage, duplicate action, and cleanup with synthetic callers.

## Primary references

- <https://docs.asterisk.org/Configuration/Applications/Queues/>
- <https://docs.asterisk.org/Configuration/Applications/Voicemail/>
- <https://docs.asterisk.org/Configuration/Applications/ConfBridge/>
