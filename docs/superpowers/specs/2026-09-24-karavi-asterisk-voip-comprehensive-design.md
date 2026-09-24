# Design Spec: Comprehensive `karavi-asterisk-voip` Reference

**Date:** 2026-09-24  
**Status:** Design ready for review  
**Canonical version:** Asterisk 22 LTS  
**Repository:** `Karavi.Skills`

## Goal

Upgrade `skills/karavi-asterisk-voip` from a compact domain guide into a
complete implementation-oriented reference for building, integrating,
testing, operating, and troubleshooting Asterisk-based systems.

“Complete” means coverage of the official Asterisk documentation domains that
affect implementation decisions, with version-aware summaries and canonical
source links. It does not mean copying the entire documentation website into
the skill.

## Source of truth

Primary sources:

- <https://docs.asterisk.org/>
- <https://github.com/asterisk/documentation>
- Asterisk 22 documentation tree
- Official Latest API and Test Suite documentation where the implementation
  requires current API or test behavior

The skill will record source URL, domain, version, last-reviewed date, and
coverage status in `references/coverage-matrix.md`. Third-party libraries will
be treated as adapters and implementation dependencies, not protocol authority.

## Scope

The reference set will cover:

1. Fundamentals, architecture, channels, modules, configuration model, CLI,
   logging, file layout, and lifecycle.
2. Getting started, build/install, supported platforms, package/container
   deployment, upgrades, migrations, backups, and rollback considerations.
3. Core configuration: `pjsip`, transports, endpoints, AOR/auth/identify,
   registrations, trunks, codecs, RTP, NAT, TLS/SRTP, DTMF, fax, and timing.
4. Dialplan: contexts, extensions, priorities, expressions, functions,
   variables, applications, pattern matching, macros/gosub, IVR, queues,
   parking, voicemail, transfers, conferences, paging, and call recording.
5. Interfaces and APIs: AMI, ARI, AGI/FastAGI, Asterisk Manager actions and
   events, WebSocket lifecycle, REST resources, authentication, error mapping,
   framing, timeouts, reconnect, idempotency, and concurrency.
6. Channel and media technologies: SIP/PJSIP, RTP, WebRTC where applicable,
   IAX2, DAHDI, Local channels, bridges, external media, AudioSocket, codecs,
   media negotiation, and one-way-audio diagnosis.
7. Data and operations: CDR, CEL, realtime/config backends, database access,
   queue/member state, metrics, structured logs, health, CLI diagnostics,
   packet traces, and event correlation.
8. Security: manager users/ACLs, transport protection, credential handling,
   injection boundaries, dialplan trust boundaries, privacy/recording policy,
   hardening, security advisories, and least privilege.
9. Development and testing: module/build concepts, API/client patterns,
   parser/state-machine tests, Asterisk Test Suite, container integration,
   SIP/RTP smoke tests, fault injection, and compatibility verification.
10. Version compatibility: Asterisk 22 as canonical, with explicit notes for
    20 LTS and 23 Standard where behavior or API differs. Asterisk 18 and
    historical material will be marked legacy and not treated as current.

## Information architecture

`SKILL.md` remains a concise router and implementation gate. The detailed
references are split by domain so an agent reads only the material needed for
the current task:

```text
references/
├── coverage-matrix.md
├── fundamentals.md
├── build-deployment-operation.md
├── configuration-model.md
├── pjsip-sip.md
├── rtp-media-codecs.md
├── dialplan-ivr.md
├── queues-voicemail-conferencing.md
├── ami.md
├── ari.md
├── agi-fastagi.md
├── cdr-cel-realtime.md
├── security-hardening.md
├── development-modules.md
├── testing-asterisk-test-suite.md
├── troubleshooting-observability.md
└── version-compatibility.md
```

Each reference uses the same structure: applicability and version, key
implementation decisions, contract/API details, secure patterns, failure
behavior, verification matrix, common mistakes, and official links.

## Documentation ingestion and maintenance

Add deterministic scripts:

- `scripts/build-doc-index.py`: builds a source inventory from a checked-out
  or downloaded official documentation tree without copying raw docs into the
  skill.
- `scripts/verify-doc-coverage.py`: verifies that every required domain has a
  coverage row, a linked reference, an official source, version metadata, and
  no unresolved placeholder.

The scripts must be offline-capable when given a local source tree. Network
fetching is optional and must never silently replace a pinned local source.
They must not collect credentials or write outside the skill workspace.

## Safety and implementation boundaries

- The skill must not imply authorization to modify live PBX, production,
  firewall, trunk, credential, reload, restart, or originate-call state.
- Configuration examples use placeholders and synthetic identifiers; secrets,
  caller PII, recordings, and real credentials are prohibited.
- Version-sensitive behavior must name its version and source. Unknown behavior
  is a documented uncertainty, not a guessed rule.
- Protocol summaries are original concise explanations with links, not copied
  documentation passages.
- Application guidance keeps transport adapters separate from domain,
  persistence, authorization, and public API layers.

## Acceptance criteria

- `SKILL.md` stays under 500 lines and routes every reference correctly.
- All references use the canonical `karavi-` skill context and contain no
  `TBD`, vague placeholder, secret, or unbounded production instruction.
- Coverage matrix includes all ten scope domains and identifies Asterisk 22 as
  canonical.
- AMI, ARI, AGI/FastAGI, PJSIP, RTP/media, dialplan, CDR/CEL, security,
  testing, operations, development, and compatibility each have actionable
  implementation guidance and negative/failure cases.
- Every reference links to an official Asterisk source and states the relevant
  version assumptions.
- Indexes and README installation instructions remain consistent.
- `quick_validate.py`, coverage verification, markdown/link checks, encoding
  checks, `git diff --check`, and secret scan pass.
- Existing skill guidance is preserved or intentionally superseded with a
  documented reason; no unrelated skill is changed.

## Out of scope

- Copying the entire Asterisk documentation repository into `Karavi.Skills`.
- Treating FreePBX GUI behavior as identical to upstream Asterisk behavior.
- Supporting every historical release as a first-class current target.
- Installing third-party runtime packages, creating a PBX, changing a live
  server, deploying, committing, or pushing without a separate explicit user
  request.

## Decision

Proceed with Asterisk 22 LTS as the canonical implementation target, preserve
compatibility notes for 20 and 23, and maintain the reference through the
coverage matrix plus deterministic validation scripts.
