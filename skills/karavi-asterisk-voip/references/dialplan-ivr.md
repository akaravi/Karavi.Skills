# Dialplan, IVR, queues, and call flows

Use this reference for contexts, extensions, priorities, variables, IVR,
queues, transfers, hangups, and routing changes.

## Version

Canonical: Asterisk 22 LTS. Confirm application and function names against the
target release; generated FreePBX behavior is an additional compatibility layer.

## Model the call flow first

Write the inbound, outbound, transfer, failure, timeout, and hangup paths as a
small state diagram or table before editing `extensions.conf` or generated
FreePBX configuration. Identify the entry context, trust boundary, expected
channels, caller/tenant scope, and terminal behavior.

Keep contexts least-privileged. Do not route untrusted input into an internal
context, arbitrary `Dial()` target, `System()` command, shell expression,
database query, or file path. Use typed allowlists for destinations, queue
names, feature codes, and dynamic variables.

## Security

Treat channel variables, caller digits, headers, and external data as
untrusted. Prevent dialplan injection, command execution, arbitrary dialing,
file access, database fragments, and cross-tenant context escape.

## Dialplan invariants

- Every path has an explicit timeout, invalid-input path, failure path, and
  hangup cleanup policy.
- Use unique, meaningful labels and preserve existing priorities/labels when
  adding an additive path. Understand generated FreePBX output before editing
  it; do not modify generated files when a supported custom context exists.
- Treat channel variables as untrusted input. Normalize and validate phone
  numbers, extension identifiers, language, tenant, and feature code before
  using them.
- Separate call-control decisions from business data access. Use an application
  adapter or AGI/ARI boundary for complex rules rather than embedding a second
  business service in dialplan expressions.
- Make transfers, retries, queue joins, and external calls bounded and auditable.
- Ensure `h`/hangup handling and CDR/CEL correlation cannot run duplicate
  destructive cleanup or lose the terminal call state.

## IVR and queue UX

Define prompt language, digit timeout, response timeout, maximum retries,
invalid/empty input behavior, accessibility/audio quality, escape keys,
business-hours and holiday policy, queue overflow, callback behavior, and
privacy announcements. Test caller abandonment, agent unavailable, transfer
failure, recording failure, and dependency outage.

## Verification

Test every reachable route with valid, invalid, empty, delayed, repeated, and
unexpected input. Verify call recording, CDR/CEL, queue/member state, transfer,
hangup, and cleanup. Use `dialplan show`, targeted channel/event traces, and a
controlled test endpoint; redact caller data and credentials in evidence.

Primary reference: <https://docs.asterisk.org/Configuration/Dialplan/>

## Primary references

- <https://docs.asterisk.org/Configuration/Dialplan/>
- <https://docs.asterisk.org/Configuration/Applications/>
