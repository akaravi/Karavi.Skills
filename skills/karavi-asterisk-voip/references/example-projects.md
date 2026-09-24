# Buildable example project plan

Use this reference when a future implementation needs a runnable sample instead of a prose snippet.

## Version

Examples must pin their target .NET runtime, Asterisk version, client library version, and SIP tool version. A sample that depends on an unpinned PBX behavior is not buildable evidence.

## Example set

Maintain isolated examples with no production credentials:

- dotnet-ami-client: login, ActionID, event stream, reconnect, and cancellation;
- dotnet-ari-client: REST action, WebSocket events, Stasis lifecycle, and cleanup;
- dotnet-fastagi-host: listener, command/reply parser, bounded concurrency, and shutdown;
- dialplan-call-flow: custom context, IVR, queue, recording, and hangup cause;
- pjsip-wss-webrtc: endpoint, TLS, SIP.js registration, and media smoke;
- audiosocket-server: packet framing, UUID, PCM, DTMF, backpressure, and hangup;
- callfile-producer: ASCII staging, validation, atomic move, retry, and archive;
- sipp-scenarios: registration, originate, answer, busy, timeout, transfer, and RTP assertions.

## Security

Examples must use synthetic numbers, local-only credentials, environment injection, no real trunks, no committed recordings, and no external runtime CDN.

## Acceptance

Each example needs a README, pinned versions, configuration template without secrets, build command, test command, failure scenarios, cleanup command, and a statement of what it does not prove.

## Primary References

Official Asterisk documentation and the repository's actual adapter/library contracts are authoritative.

## Verification

Build samples with clean dependencies, run parser and contract tests, and execute PBX smoke tests only in an explicitly authorized isolated environment.
