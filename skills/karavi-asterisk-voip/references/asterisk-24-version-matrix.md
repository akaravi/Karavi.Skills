# Asterisk 24 and version compatibility matrix

Use this reference whenever a task targets Asterisk 24 or must run across several supported Asterisk releases.

## Version

The supported comparison set is Asterisk 16, 18, 20, 22, 23, and 24. The target release, distribution, loaded modules, and channel driver must be recorded before implementation. Asterisk 22 remains the canonical skill baseline; Asterisk 24 is an active compatibility target and must not be inferred from 22 behavior.

## Compatibility method

Use capability detection and protocol fixtures instead of branching on a version string in domain code. Record whether the feature is:

- available with identical wire behavior;
- available with optional fields or changed defaults;
- module-dependent;
- distribution-dependent;
- unavailable and requiring a fallback.

Preserve unknown AMI/ARI headers and JSON fields. Make event consumers tolerant of optional fields and event ordering changes.

## Security

Do not expose version probes, credentials, topology, or module inventories to untrusted callers. Version checks must use least-privilege access and redacted evidence.

## Primary References

The official Asterisk version documentation and target-release API/configuration pages are authoritative.

## Verification

Run the same contract fixtures on every supported release. Verify login, selected action/event, dialplan application, channel/media path, recording, and terminal cleanup. A successful compile is not compatibility evidence.
