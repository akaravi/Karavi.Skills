# Official Asterisk Documentation Coverage Matrix

Canonical target: **Asterisk 22 LTS**. Compatibility targets: **Asterisk 16
LTS**, **Asterisk 20 LTS**, and **Asterisk 23 Standard**. The matrix tracks implementation guidance,
not copied source documentation. `lastReviewedUtc` records the review date for
the current skill revision.

| domain | reference | officialSources | canonicalVersion | compatibilityVersions | lastReviewedUtc | status |
|---|---|---|---|---|---|---|
| Fundamentals | fundamentals.md | https://docs.asterisk.org/Fundamentals/ | 22 | 20,23,legacy | 2026-09-24 | covered |
| Build/Deployment/Operation | build-deployment-operation.md; telecom-carrier-dahdi-sbc.md; linux-asterisk-command-reference.md | https://docs.asterisk.org/Deployment/ | 22 | 16,20,23,24 | 2026-09-24 | covered |
| Configuration | configuration-model.md | https://docs.asterisk.org/Configuration/ | 22 | 20,23,legacy | 2026-09-24 | covered |
| SIP/PJSIP | pjsip-sip.md; pjsip-advanced.md; sip-wss-webrtc-webphone.md | https://docs.asterisk.org/Configuration/Channel-Drivers/Configuring-res_pjsip/ | 22 | 16,20,23,legacy | 2026-09-24 | covered |
| RTP/Media | rtp-media-codecs.md; media-webrtc-advanced.md | https://docs.asterisk.org/Configuration/Channel-Drivers/ | 22 | 16,20,23 | 2026-09-24 | covered |
| Dialplan/IVR/Queues | dialplan-ivr.md; asterisk-application-catalog.md; dialplan-freepbx-callfile-recording.md; queue-chanspy-recording-monitoring.md | https://docs.asterisk.org/Configuration/Dialplan/ | 22 | 16,20,23,legacy | 2026-09-24 | covered |
| AMI/ARI/AGI | ami.md; ari.md; agi-fastagi.md; ami-dotnet-client-contract.md; ari-dotnet-websocket-stasis.md; fastagi-dotnet-hosted-service.md; interfaces-advanced.md | https://docs.asterisk.org/Configuration/Interfaces/ | 22 | 16,20,23,24 | 2026-09-24 | covered |
| Data/Operations | cdr-cel-realtime.md; troubleshooting-observability.md; troubleshooting-runbooks.md; external-telecom-integrations.md | https://docs.asterisk.org/Configuration/Reporting/ | 22 | 16,20,23 | 2026-09-24 | covered |
| Security | security-hardening.md | https://docs.asterisk.org/About-the-Project/Asterisk-Security-Vulnerabilities/ | 22 | 20,23 | 2026-09-24 | covered |
| Development/Testing | development-modules.md; testing-asterisk-test-suite.md; testing-sipp-load-faults.md; dotnet-asterisk-implementation.md; code-examples.md; example-projects.md; application-function-reference-schema.md; karavi-project-integration-matrix.md; linux-asterisk-command-reference.md | https://docs.asterisk.org/Development/; https://docs.asterisk.org/Test-Suite/ | 22 | 16,20,23,24,netstandard2.0,modern-.NET | 2026-09-24 | covered |
| Version Compatibility | version-compatibility.md; asterisk-16-legacy-compatibility.md; asterisk-24-version-matrix.md | https://docs.asterisk.org/About-the-Project/Asterisk-Versions/ | 22 | 16,18,20,22,23,24,historical | 2026-09-24 | covered |

## Source policy

Official Asterisk documentation and the official documentation repository are
the protocol and version authorities. A third-party client library may be
referenced only as an adapter and must be checked against the target release.
