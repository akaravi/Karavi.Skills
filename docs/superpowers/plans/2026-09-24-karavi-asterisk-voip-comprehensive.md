# Comprehensive `karavi-asterisk-voip` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade `karavi-asterisk-voip` into a version-aware, implementation-oriented reference covering the official Asterisk 22 LTS documentation domains, with compatibility notes for Asterisk 20 and 23.

**Architecture:** Keep `SKILL.md` as a short router and safety gate. Store original, concise engineering guidance in focused reference files, track every official documentation domain in a coverage matrix, and use offline-capable Python scripts to verify source coverage and reference integrity.

**Tech Stack:** Markdown, Python 3 standard library only, official Asterisk documentation links, Codex skill frontmatter, PowerShell validation commands.

**Spec:** `docs/superpowers/specs/2026-09-24-karavi-asterisk-voip-comprehensive-design.md`

## Global Constraints

- Canonical implementation target is `Asterisk 22 LTS`.
- Preserve compatibility notes for `Asterisk 20 LTS` and `Asterisk 23 Standard`.
- Do not copy the entire Asterisk documentation repository into `Karavi.Skills`.
- Protocol summaries must be original concise explanations with canonical links.
- The skill must not authorize live PBX, production, firewall, credential, reload, restart, or originate-call changes.
- Examples use synthetic identifiers and contain no secrets, caller PII, recordings, or real credentials.
- `SKILL.md` remains under 500 lines and routes every reference correctly.
- Scripts use Python standard library only and are offline-capable when given a local source tree.
- Do not commit, push, deploy, or install runtime dependencies without a separate explicit user request.

## Review Focus

- Version drift: a reference must identify whether a behavior is Asterisk 22, 20, 23, legacy, or unknown; test: coverage validation rejects missing version metadata.
- Source completeness: every eleven implementation domains defined by the spec must map to a reference and official source; test: coverage validation reports missing domain/reference/source rows.
- Broken progressive disclosure: every reference link in `SKILL.md` must resolve to a file; test: link validation enumerates all relative links.
- Unsafe operational guidance: examples must not imply production mutation or contain secrets; test: secret scan and forbidden-operation scan run over all skill files.
- Stale or duplicated guidance: existing AMI/PJSIP/dialplan/testing material must be preserved or intentionally superseded; test: final diff review compares old topic coverage with the new references.

### Task 1: Build the documentation coverage contract

**Files:**
- Create: `skills/karavi-asterisk-voip/references/coverage-matrix.md`
- Create: `skills/karavi-asterisk-voip/scripts/build-doc-index.py`
- Create: `skills/karavi-asterisk-voip/scripts/verify-doc-coverage.py`

**Interfaces:**
- `build-doc-index.py --source <path> --output <path>` reads a local official documentation tree and emits deterministic JSON with `path`, `title`, `domain`, and `sourceRoot` fields.
- `verify-doc-coverage.py --skill <path> --matrix <path>` exits `0` only when all required domains, references, official URLs, version metadata, and linked files are present; it prints machine-readable failure lines and a summary.
- `coverage-matrix.md` is the human-readable source map consumed by the verifier.

- [ ] **Step 1: Write the failing verifier test fixture**

Create `skills/karavi-asterisk-voip/scripts/test_verify_doc_coverage.py` using `unittest` with a temporary skill containing one missing domain row and one missing referenced file. Assert that the verifier returns non-zero and names both failures.

- [ ] **Step 2: Run the fixture to verify it fails correctly**

Run: `python -m unittest skills/karavi-asterisk-voip/scripts/test_verify_doc_coverage.py -v`  
Expected: FAIL because `verify-doc-coverage.py` does not exist yet.

- [ ] **Step 3: Add the eleven-domain coverage matrix**

Create rows for Fundamentals, Build/Deployment/Operation, Configuration, SIP/PJSIP, RTP/Media, Dialplan/IVR/Queues, AMI/ARI/AGI, Data/Operations, Security, Development/Testing, and Version Compatibility. Every row must contain `domain`, `reference`, `officialSources`, `canonicalVersion`, `compatibilityVersions`, `lastReviewedUtc`, and `status`.

- [ ] **Step 4: Implement deterministic source indexing**

Implement `build-doc-index.py` with `argparse`, `pathlib`, `re`, `json`, and `hashlib`; sort paths lexicographically, derive titles from Markdown headings, never fetch the network, and fail clearly when `--source` is not a directory.

- [ ] **Step 5: Implement coverage verification**

Implement `verify-doc-coverage.py` to parse the matrix and `SKILL.md`, verify the exact required domain set, check that each listed reference exists, require `https://docs.asterisk.org/` or `https://github.com/asterisk/` URLs, reject `TBD`/`TODO`/`FIXME` in coverage rows, and return exit code `1` with actionable diagnostics on failure.

- [ ] **Step 6: Run the fixture and script checks**

Run: `python -m unittest skills/karavi-asterisk-voip/scripts/test_verify_doc_coverage.py -v` and `python skills/karavi-asterisk-voip/scripts/verify-doc-coverage.py --skill skills/karavi-asterisk-voip --matrix skills/karavi-asterisk-voip/references/coverage-matrix.md`  
Expected: fixture passes and the real matrix reports all required domains.

### Task 2: Expand foundational, configuration, and media references

**Files:**
- Create: `skills/karavi-asterisk-voip/references/fundamentals.md`
- Create: `skills/karavi-asterisk-voip/references/build-deployment-operation.md`
- Create: `skills/karavi-asterisk-voip/references/configuration-model.md`
- Modify: `skills/karavi-asterisk-voip/references/pjsip-sip.md`
- Create: `skills/karavi-asterisk-voip/references/rtp-media-codecs.md`

**Interfaces:**
- Each reference uses the common sections: applicability/version, implementation decisions, security, failure behavior, verification, and official sources.
- `pjsip-sip.md` retains its existing troubleshooting sequence while gaining explicit Asterisk 22 assumptions and 20/23 compatibility callouts.

- [ ] **Step 1: Add a reference-structure check**

Extend `test_verify_doc_coverage.py` to assert each reference contains headings for `Version`, `Security`, `Verification`, and `Primary references` (case-insensitive). Run it and verify it fails for the not-yet-created files.

- [ ] **Step 2: Write the foundational reference content**

Document process/module architecture, configuration load order, CLI and logging, file layout, channel lifecycle, startup/shutdown, supported platform assumptions, build/install, package/container deployment, upgrade/rollback, backups, and operational boundaries. Link each decision to official Asterisk 22 documentation.

- [ ] **Step 3: Write configuration and media content**

Document configuration sections and reload boundaries, PJSIP object relationships, transports, endpoint/AOR/auth/identify/registration, codec and DTMF policy, NAT/TLS/SRTP, RTP/SDP negotiation, external media, AudioSocket, WebRTC where applicable, timing, and one-way-audio verification. Keep deployment-specific values out of examples.

- [ ] **Step 4: Add compatibility annotations**

For each version-sensitive behavior, label `22`, `20`, `23`, `legacy`, or `unknown`, and link to the versioned official page. Do not assert compatibility where the source does not establish it.

- [ ] **Step 5: Run reference structure and coverage checks**

Run: `python -m unittest skills/karavi-asterisk-voip/scripts/test_verify_doc_coverage.py -v` and `python skills/karavi-asterisk-voip/scripts/verify-doc-coverage.py --skill skills/karavi-asterisk-voip --matrix skills/karavi-asterisk-voip/references/coverage-matrix.md`  
Expected: all new references satisfy the common structure and no coverage row is missing.

### Task 3: Expand call-control and application API references

**Files:**
- Modify: `skills/karavi-asterisk-voip/references/ami.md`
- Create: `skills/karavi-asterisk-voip/references/ari.md`
- Create: `skills/karavi-asterisk-voip/references/agi-fastagi.md`
- Modify: `skills/karavi-asterisk-voip/references/dialplan-ivr.md`
- Create: `skills/karavi-asterisk-voip/references/queues-voicemail-conferencing.md`

**Interfaces:**
- AMI guidance must preserve the existing framing, `ActionID`, lifecycle, security, and duplicate-event rules.
- ARI guidance covers REST/WebSocket resources and Stasis ownership; AGI guidance covers environment framing and command/result lifecycle.
- Dialplan and queue guidance must identify trust boundaries and terminal cleanup.

- [ ] **Step 1: Add API failure-case assertions**

Extend the verifier fixture to require each API reference to mention timeout, authentication/authorization, error, reconnect or lifecycle, and a negative test. Run the fixture and verify the new assertions fail before the content exists.

- [ ] **Step 2: Complete AMI and add ARI**

Add action/event categories, event ordering and deduplication, manager permissions, originate/bridge/queue semantics, ARI resource ownership, WebSocket reconnect, Stasis lifecycle, REST error handling, cancellation, and idempotent recovery. Include official 22 API links and compatibility notes.

- [ ] **Step 3: Complete AGI/FastAGI and dialplan**

Document AGI environment/command framing, FastAGI network failure, channel hangup cancellation, safe variable handling, dialplan expression boundaries, contexts, applications, functions, Gosub/Macro, pattern matching, and custom-vs-generated FreePBX configuration.

- [ ] **Step 4: Add queues, voicemail, parking, and conferencing**

Cover queue/member state, penalties, strategy, timeout, abandon, callback, voicemail, parking, conferences, paging, transfer, recording, and CDR/CEL correlation. Every flow needs invalid, timeout, failure, hangup, and cleanup behavior.

- [ ] **Step 5: Run API verification**

Run the fixture, coverage verifier, and `git diff --check`. Expected: every API reference has an explicit failure/verification section and all relative links resolve.

### Task 4: Add data, security, development, testing, and compatibility references

**Files:**
- Create: `skills/karavi-asterisk-voip/references/cdr-cel-realtime.md`
- Create: `skills/karavi-asterisk-voip/references/security-hardening.md`
- Create: `skills/karavi-asterisk-voip/references/development-modules.md`
- Create: `skills/karavi-asterisk-voip/references/testing-asterisk-test-suite.md`
- Modify: `skills/karavi-asterisk-voip/references/testing-troubleshooting.md`
- Create: `skills/karavi-asterisk-voip/references/version-compatibility.md`

**Interfaces:**
- CDR/CEL guidance defines correlation and timezone rules used by troubleshooting and API references.
- Security guidance defines the hardening and redaction gates used by every other reference.
- Testing guidance defines the verification vocabulary and failure matrix used by the final skill router.

- [ ] **Step 1: Add data/security test assertions**

Extend the fixture to require CDR/CEL/realtime references to mention UTC/correlation, security references to mention least privilege/secret redaction, and testing references to mention unit/contract/integration/failure layers. Run it and verify the new assertions fail before implementation.

- [ ] **Step 2: Write CDR/CEL and operations content**

Document CDR versus CEL semantics, channel/linked/call identifiers, late events, timezone normalization, realtime configuration boundaries, queue state, structured logging, metrics, health, CLI evidence, packet capture redaction, and reconciliation limits.

- [ ] **Step 3: Write security and development content**

Document manager ACLs, bind exposure, TLS/SRTP, PJSIP credential handling, dialplan injection boundaries, command/database/file safety, recordings/PII, security advisories, module lifecycle, build APIs, coding boundaries, and supported extension points.

- [ ] **Step 4: Write Test Suite and compatibility content**

Document Asterisk Test Suite organization, test layers, deterministic containers/endpoints, SIP/RTP smoke tests, fault injection, malformed events, overload, reconnect, and release compatibility. Make 22 canonical and explicitly classify 20/23, 18, and historical guidance.

- [ ] **Step 5: Run the complete content checks**

Run the full unittest fixture, coverage verifier, `python -m py_compile skills/karavi-asterisk-voip/scripts/*.py`, and `git diff --check`. Expected: all checks pass with no unresolved placeholder or missing required section.

### Task 5: Wire the router, indexes, and deterministic validation

**Files:**
- Modify: `skills/karavi-asterisk-voip/SKILL.md`
- Modify: `skills/karavi-asterisk-voip/README.md`
- Modify: `README.md`
- Modify: `skills/README.md`
- Modify: `skills/AGENTS.md`
- Modify: `skills/karavi-asterisk-voip/scripts/test_verify_doc_coverage.py`

**Interfaces:**
- `SKILL.md` must route all references by task intent and state Asterisk 22/20/23 version policy.
- Installation/index entries must use exactly `karavi-asterisk-voip`.
- The test fixture must be self-contained and pass without network access.

- [ ] **Step 1: Write router-link tests**

Add tests that parse `SKILL.md` relative Markdown links and assert every linked local file exists, `SKILL.md` is under 500 lines, and the description starts with `Use when...`. Run them and verify they fail for any missing new router link.

- [ ] **Step 2: Update the router**

Replace the five-reference routing list with grouped routes for fundamentals/configuration, SIP/media, dialplan/call flows, AMI/ARI/AGI, data/operations, security, development/testing, and compatibility. Keep safety boundaries and the common completion checklist concise.

- [ ] **Step 3: Update human-facing indexes**

Add the comprehensive scope and source policy to the skill README and keep root/index/AGENTS entries consistent. Do not modify unrelated skill documentation.

- [ ] **Step 4: Run repository-level validation**

Run:

```powershell
python skills/karavi-asterisk-voip/scripts/verify-doc-coverage.py --skill skills/karavi-asterisk-voip --matrix skills/karavi-asterisk-voip/references/coverage-matrix.md
python -m unittest discover -s skills/karavi-asterisk-voip/scripts -p 'test_*.py' -v
python -m py_compile skills/karavi-asterisk-voip/scripts/*.py
python C:\Users\karavi\.codex\skills\.system\skill-creator\scripts\quick_validate.py skills/karavi-asterisk-voip
git diff --check
```

Expected: all commands exit `0`; `SKILL.md` remains below 500 lines.

### Task 6: Final security, encoding, source, and acceptance review

**Files:**
- Inspect: all files under `skills/karavi-asterisk-voip/`
- Inspect: `README.md`, `skills/README.md`, `skills/AGENTS.md`
- Inspect: `docs/superpowers/specs/2026-09-24-karavi-asterisk-voip-comprehensive-design.md`

**Interfaces:**
- Final acceptance consumes the coverage verifier, router tests, source inventory, and all documentation references.

- [ ] **Step 1: Run encoding and secret scans**

Read all changed text files as bytes and reject UTF-8 BOM, UTF-16, NUL, or mojibake. Run `rg` for known secret patterns (`AKIA`, `ghp_`, `sk-`, `xox`, private-key headers) and fail on any match.

- [ ] **Step 2: Validate source links and version claims**

Check every official URL is HTTPS, every reference has at least one official Asterisk source, every version claim is labeled, and no third-party URL is used as protocol authority.

- [ ] **Step 3: Review the complete diff**

Run `git status --short`, `git diff --check`, and inspect the full diff including untracked skill files. Confirm only the approved skill, indexes, scripts, references, and spec/plan files changed.

- [ ] **Step 4: Produce the completion envelope**

Report scope, coverage domains, validation commands/results, security scan result, known limitations, unverified external prerequisites, and next actions. Do not claim runtime PBX health because this task has no live Asterisk environment.
