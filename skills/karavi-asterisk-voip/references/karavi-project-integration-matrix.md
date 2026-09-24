# Karavi Asterisk project routing

Use this reference when the task touches either of the Karavi Asterisk repositories. It maps repository surfaces to the domain references; it is not a replacement for reading the relevant source and project documentation.

## NTK.Asterisk.Assistant

Typical surfaces:

- Ntk.AsterNet.AMI: AMI TCP/actions/events and FastAGI primitives
- NTK.AsteriskAssistant.Core: AMI session, FastAGI, SmartRoute, Call2Call, telemetry, SQLite
- Worker.SmartRoute: hosted services, Quartz, retry and route execution
- WebApi: API contracts, health, SignalR, settings and authorization
- AdminPanel: operational configuration and live status

Read ami-dotnet-client-contract.md, fastagi-dotnet-hosted-service.md, dialplan-freepbx-callfile-recording.md, dotnet-asterisk-implementation.md, and troubleshooting-observability.md for a Call2Call or SmartRoute change.

## Ntk.Asterisk

Typical surfaces:

- Ntk.AsterNet.AMI and Ntk.Asterisk.AMI: AMI adapters and multi-server sessions
- Ntk.AsterNet.ARI and Ntk.Asterisk.ARI: ARI REST/WebSocket/Stasis
- Console.AMI / Console.ARI: executable scenarios and FastAGI hosting
- WebApi: CallJobs, Call Files, MixMonitor, queues, SignalR, settings
- WebPhone: SIP.js, WSS, WebRTC and browser media
- AdminPanel / UserPanel: operational and user-facing consumers

For this repository, resolve the Asterisk version first; the repository README identifies Asterisk 16. Read asterisk-16-legacy-compatibility.md for every protocol change, and add ari-dotnet-websocket-stasis.md or sip-wss-webrtc-webphone.md when those surfaces are involved.

## Boundary

The skill provides Asterisk and integration guidance. Repository-specific API envelopes, authentication, persistence, UI conventions, version manifests, and deployment rules remain authoritative in the target repository.
## Version

The Ntk.Asterisk repository identifies Asterisk 16; NTK.Asterisk.Assistant uses a shared adapter and must resolve its deployed PBX version.

## Security

Repository-specific authentication, secret, authorization, and deployment rules remain binding.

## Verification

Read the target repository's source, configuration, tests, and operational documentation before changing a protocol surface.

## Primary References

The target repository, its AGENTS.md/rules, and official Asterisk documentation are authoritative.
