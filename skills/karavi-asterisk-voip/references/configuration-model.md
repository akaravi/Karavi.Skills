# Configuration model

## Version

Canonical: Asterisk 22 LTS. Verify option names and reload semantics against
the target version and module documentation.

## Implementation decisions

Separate base configuration, environment overlay, secrets, generated content,
and local test configuration. Document load order and reload scope for every
changed file. Keep endpoint, authentication, AOR, identify, registration,
transport, codec, dialplan, queue, CDR, and logging concerns in their native
sections rather than duplicating state across files.

Prefer additive changes and supported custom contexts. For FreePBX, do not edit
generated files when a supported custom include or GUI setting is available.
Validate configuration syntax before reload and inventory the effective
configuration after reload.

## Security

Use least-privilege filesystem permissions, protected secret injection, narrow
network binds and ACLs. Never commit SIP/AMI passwords, private keys, tokens,
recordings, or local production endpoints.

## Failure behavior

Parse errors, missing includes, duplicate objects, invalid references, failed
reloads, and stale generated output must be visible and block a green release.
Do not guess a fallback configuration that changes call routing or trust.

## Verification

Compare intended and effective configuration, run syntax/module checks, verify
reload scope, inspect endpoint/transport/dialplan state, and execute targeted
call/media smoke tests. Record version, file source, timestamp, and redacted
evidence.

## Primary references

- <https://docs.asterisk.org/Configuration/>
- <https://docs.asterisk.org/Configuration/Core-Configuration/>
- <https://docs.asterisk.org/Configuration/Channel-Drivers/>
