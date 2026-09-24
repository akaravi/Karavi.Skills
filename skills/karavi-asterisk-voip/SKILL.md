---
name: karavi-asterisk-voip
description: Use when designing, implementing, reviewing, testing, or troubleshooting Asterisk, FreePBX, VoIP, SIP/PJSIP, RTP, AMI, ARI, AGI, FastAGI, dialplan, IVR, queue, CDR, or CEL integrations.
license: Apache-2.0
metadata:
  author: akaravi
  version: "0.1.0"
  category: voip-telephony
  tags: "karavi, asterisk, freepbx, voip, sip, pjsip, rtp, ami, ari, agi, dialplan, ivr, cdr, cel"
---

# karavi-asterisk-voip

Use this skill as the domain guide for Asterisk-based telephony work. Keep the
application boundary explicit: Asterisk configuration and transport are not a
replacement for domain, authorization, persistence, or observability layers in
the calling application.

## Scope routing

Read only the references needed for the task:

- architecture, modules, CLI, lifecycle, or core concepts → [references/fundamentals.md](references/fundamentals.md)
- build, installation, deployment, upgrades, backups, rollback, or operations → [references/build-deployment-operation.md](references/build-deployment-operation.md)
- configuration loading, reloads, generated FreePBX files, or environment separation → [references/configuration-model.md](references/configuration-model.md)
- SIP, PJSIP, NAT, registration, codecs, TLS, or endpoint configuration → [references/pjsip-sip.md](references/pjsip-sip.md)
- RTP, SDP, media, AudioSocket, external media, WebRTC, or one-way audio → [references/rtp-media-codecs.md](references/rtp-media-codecs.md)
- extensions, contexts, dialplan, IVR, routing, or call flows → [references/dialplan-ivr.md](references/dialplan-ivr.md)
- queues, voicemail, parking, paging, conferences, recordings, or transfers → [references/queues-voicemail-conferencing.md](references/queues-voicemail-conferencing.md)
- AMI actions/events, originate, queues, bridges, reconnect, or event consumers → [references/ami.md](references/ami.md)
- ARI REST/WebSocket, Stasis, channels, bridges, playback, or recordings → [references/ari.md](references/ari.md)
- AGI/FastAGI, dialplan command/result framing, or channel cancellation → [references/agi-fastagi.md](references/agi-fastagi.md)
- CDR, CEL, realtime, call correlation, event reconciliation, or operational data → [references/cdr-cel-realtime.md](references/cdr-cel-realtime.md)
- logs, metrics, health, packet traces, event timelines, or diagnosis → [references/troubleshooting-observability.md](references/troubleshooting-observability.md)
- AMI/PJSIP/dialplan security, credentials, ACLs, injection, or hardening → [references/security-hardening.md](references/security-hardening.md)
- module development, build APIs, extension points, or core integration → [references/development-modules.md](references/development-modules.md)
- Asterisk Test Suite, integration, smoke, fault, or regression testing → [references/testing-asterisk-test-suite.md](references/testing-asterisk-test-suite.md)
- release behavior, deprecation, API/config drift, or 20/22/23 compatibility → [references/version-compatibility.md](references/version-compatibility.md)
- Asterisk 16, FreePBX/Issabel legacy behavior, or mixed-version fleets → [references/asterisk-16-legacy-compatibility.md](references/asterisk-16-legacy-compatibility.md)
- C#, ASP.NET Core, Worker, hosted service, DI, options, or adapter boundaries → [references/dotnet-asterisk-implementation.md](references/dotnet-asterisk-implementation.md)
- C# AMI sessions, ManagerConnection, ActionID, multi-server routing, or event aggregation → [references/ami-dotnet-client-contract.md](references/ami-dotnet-client-contract.md)
- C# ARI REST/WebSocket, Stasis, bridges, recordings, or legacy ARI clients → [references/ari-dotnet-websocket-stasis.md](references/ari-dotnet-websocket-stasis.md)
- FastAGI hosted by ASP.NET Core, Worker, Windows Service, or console → [references/fastagi-dotnet-hosted-service.md](references/fastagi-dotnet-hosted-service.md)
- browser softphone, SIP.js, SIP over WSS, WebRTC, ICE, or browser RTP → [references/sip-wss-webrtc-webphone.md](references/sip-wss-webrtc-webphone.md)
- FreePBX originate contracts, custom contexts, Call Files, MixMonitor, or recording-backed jobs → [references/dialplan-freepbx-callfile-recording.md](references/dialplan-freepbx-callfile-recording.md)
- queue panels, QueueStatus reconciliation, ChanSpy, ExtenSpy, Whisper, Barge, or live monitoring → [references/queue-chanspy-recording-monitoring.md](references/queue-chanspy-recording-monitoring.md)
- either Karavi Asterisk repository or its project-specific integration surface → [references/karavi-project-integration-matrix.md](references/karavi-project-integration-matrix.md)
- source inventory and coverage status → [references/coverage-matrix.md](references/coverage-matrix.md)
- concrete C#, dialplan, Call File, PJSIP, FastAGI, and ARI implementation examples → [references/code-examples.md](references/code-examples.md)
- selecting Dialplan applications, functions, and failure paths → [references/asterisk-application-catalog.md](references/asterisk-application-catalog.md)
- advanced PJSIP, provider trunks, SIP responses, transfers, and failover → [references/pjsip-advanced.md](references/pjsip-advanced.md)
- advanced RTP, SDP, WebRTC, AudioSocket, or ExternalMedia → [references/media-webrtc-advanced.md](references/media-webrtc-advanced.md)
- high availability, SBC, multi-node topology, capacity, or disaster recovery → [references/telecom-architecture-ha-scale.md](references/telecom-architecture-ha-scale.md)
- SIPp, Asterisk Test Suite, load, fault injection, or soak testing → [references/testing-sipp-load-faults.md](references/testing-sipp-load-faults.md)
- CRM, ERP, SMS, speech, billing, identity, webhook, or analytics integration → [references/external-telecom-integrations.md](references/external-telecom-integrations.md)
- repeatable diagnosis of AMI, ARI, SIP, RTP, FastAGI, WSS, queue, or recording failures → [references/troubleshooting-runbooks.md](references/troubleshooting-runbooks.md)
- Asterisk 24, release drift, or cross-version protocol fixtures → [references/asterisk-24-version-matrix.md](references/asterisk-24-version-matrix.md)
- AEAP, realtime/ODBC, distributed device state, calendaring, StatsD, SNMP, speech, messaging, presence, MWI, or BLF → [references/interfaces-advanced.md](references/interfaces-advanced.md)
- DAHDI, PRI/E1/T1, PSTN, SBC, carrier routing, emergency calling, or fraud controls → [references/telecom-carrier-dahdi-sbc.md](references/telecom-carrier-dahdi-sbc.md)
- adding or reviewing an application/function/module knowledge entry → [references/application-function-reference-schema.md](references/application-function-reference-schema.md)
- creating a runnable sample project rather than a code snippet → [references/example-projects.md](references/example-projects.md)
- Linux Asterisk CLI, systemd, journal, networking, TLS, packet capture, RTP, files, recordings, resources, or package diagnosis → [references/linux-asterisk-command-reference.md](references/linux-asterisk-command-reference.md)

## Operating rules

1. Establish the Asterisk version, deployment topology, channel driver (`PJSIP` or legacy `chan_sip`), transport, codec policy, application language, and repository adapter before changing code or configuration. Asterisk 16 is a supported compatibility target; do not hide it under an unnamed `legacy` label.
2. Prefer official Asterisk documentation and repository patterns. Record the exact action, event, dialplan application, configuration section, and version assumptions that matter to the change.
3. Treat AMI, ARI, AGI, SIP, and RTP as separate contracts. Validate authentication, authorization, framing/serialization, timeout, reconnect, cancellation, correlation, and error mapping at each boundary.
4. Keep credentials, AMI secrets, SIP passwords, tokens, full phone numbers, recordings, and caller PII out of source control, logs, traces, test fixtures, and chat. Use masked test data and secure configuration injection.
5. Make state-changing call operations idempotent where possible. Use a caller/tenant/operation-scoped idempotency key, concurrency protection, bounded retry, and deterministic handling of duplicate `Originate`, hangup, transfer, bridge, or queue actions.
6. Use UTC ISO 8601 instants in application data, events, logs, CDR/CEL processing, and tests. Keep date-only business values separate from call timestamps.
7. Use asynchronous, cancellable I/O for AMI/ARI clients, HTTP callbacks, database access, and media pipelines. Set explicit connect, read, write, and overall deadlines; retry only transient and safe/idempotent operations.
8. Keep transport adapters thin. Map AMI/ARI/AGI/SIP results into application DTOs and the host project's error/envelope contract; do not expose Asterisk frames or persistence models directly to UI/API consumers.
9. Verify both call-control and media paths. A successful AMI action or HTTP health response does not prove registration, dialplan routing, RTP flow, audio direction, bridge state, or hangup cleanup.
10. Never apply a configuration reload, restart, call origination, credential change, firewall change, or production operation without explicit user authorization for that environment and action. Local tests, dry-runs, config validation, and masked traces are the default.
11. In the Karavi repositories, keep protocol adapters separate from application/API/UI contracts. Read the project integration matrix and the target repository's own rules before relying on a generic Asterisk example.

## Required implementation checklist

Before completion, cover the applicable items and report evidence:

- Contract: version, endpoint/channel driver, action/event schema, status/error mapping, and compatibility with existing consumers.
- Security: AMI bind address and ACL, least-privilege manager account, SIP/TLS policy, secret handling, PII/recording policy, and injection-safe dynamic dialplan/query values.
- Reliability: timeout taxonomy, reconnect/backoff, event ordering and deduplication, cancellation, idempotency, concurrency, backpressure, and cleanup after partial failure.
- Observability: UTC timestamp, correlation/call ID, service and environment, operation, duration, result, and redaction in structured logs and metrics.
- Verification: unit/contract tests for parsing and mapping; integration or container tests for AMI/ARI/dialplan; registration and RTP smoke checks where available; negative cases for auth, timeout, duplicate action, dependency outage, and malformed events.
- Documentation: record assumptions, Asterisk version, required modules, configuration keys, rollback/recovery, and any unresolved limitation.
- Repository integration: record the adapter project, .NET hosting model, API/event consumer, and any compatibility behavior that is not portable across Asterisk versions.
- Examples: adapt examples only after reconciling version, channel driver, repository library, security policy, and application envelope; examples are patterns, not permission to run a PBX action.
- Linux verification: run the structural example verifier and use read-only Linux commands first; distinguish unavailable tools, permission failures, and environment blockers from product defects.

## Safe completion boundary

If an item cannot be verified because a PBX, trunk, test account, network path,
or version-specific dependency is unavailable, report it as a blocker or
accepted limitation with a concrete resume condition. Do not mark a call flow
healthy from static inspection alone.

## Common mistakes

- Treating AMI TCP connection success as proof that actions are authorized or effective.
- Retrying non-idempotent call control without deduplication or operation state.
- Parsing AMI by assuming every message is a single line or ignoring multi-line `Data` fields.
- Debugging a silent call from dialplan logs alone without checking RTP, codec negotiation, NAT, and bridge state.
- Binding AMI to a public interface or placing manager credentials in source/config committed to Git.
- Mixing wall-clock locale time with UTC event timestamps or using CDR duration as the sole source of call state.

## Reference policy

Use the official Asterisk documentation as the primary protocol reference:

- <https://docs.asterisk.org/Configuration/Interfaces/Asterisk-Manager-Interface-AMI/>
- <https://docs.asterisk.org/Configuration/Interfaces/Asterisk-REST-Interface-ARI/>
- <https://docs.asterisk.org/Configuration/Channel-Drivers/SIP/>
- <https://docs.asterisk.org/Configuration/Channel-Drivers/Configuring-res_pjsip/>

Third-party libraries are implementation dependencies, not protocol authority.
Pin versions, inspect their security and maintenance posture, and test their
actual wire behavior against the target Asterisk release.
