# Queue, spying, recording, and live monitoring

Use this reference when building queue panels, member control, ChanSpy/ExtenSpy, whisper/barge, live events, or recording monitoring.

## Control and authorization

Treat queue control and spying as privileged state-changing actions. Apply authentication, queue-level authorization, audit logging, idempotency, rate limits, and safe target validation before sending AMI actions.

Keep the AMI queue name separate from a display name. A whitelist or hidden list must filter REST snapshots and real-time events consistently. Do not let a UI label become an AMI identifier without a validated mapping.

## Live state

QueueStatus is a snapshot, while member and caller events are deltas. Reconcile snapshots and deltas by server ID and queue identity, tolerate duplicate and out-of-order events, and expire stale state. SignalR or another live transport is a consumer of the reconciled domain state, not the source of truth.

For ChanSpy, Whisper, and Barge, verify the exact spy mode, target channel, authorization, bridge/media behavior, hangup cleanup, and audit record. Never equate an accepted AMI action with successful monitoring audio.
## Version

Applicable to Asterisk 16 through 23; verify action/event availability and spy application behavior.

## Security

Require least privilege, queue ACL, target validation, audit, rate limiting, and recording privacy controls.

## Verification

Test snapshot/delta reconciliation, authorization, duplicate events, spy cleanup, and live consumer state.

## Primary References

Official AMI, queue, channel, and application documentation plus the repository contract are authoritative.
