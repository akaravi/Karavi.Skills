# Development, modules, and extension points

## Version

Canonical: Asterisk 22 LTS. Keep module APIs, headers, build flags, and binary
compatibility assumptions tied to the release branch.

## Implementation decisions

Prefer supported dialplan, AMI, ARI, AGI, and configuration interfaces before
writing a core module. When a module is required, define ownership, threading,
memory lifetime, channel locking, callbacks, reload, unload, logging, and
shutdown behavior. Keep application/domain logic in an external service when
the module would otherwise become a hidden business layer.

Pin build inputs and test the exact module set and platform. Do not assume an
API from a different branch or a third-party wrapper's abstraction is stable.

## Security

Review module source and dependencies, compiler/build flags, privileges,
external command/database access, memory ownership, input validation, and log
redaction. Do not load unreviewed modules in production.

## Failure behavior

Handle module load failure, symbol mismatch, callback failure, channel teardown,
deadlock risk, memory/resource leak, reload, unload, and dependency outage.
Never swallow errors or continue with partially initialized state.

## Verification

Run compile/static checks, module load/unload, startup/reload/shutdown, channel
concurrency, cancellation, malformed input, dependency failure, ASAN/TSAN or
equivalent checks where available, AMI/ARI integration, and call/media smoke.

## Primary references

- <https://docs.asterisk.org/Development/>
- <https://docs.asterisk.org/Development/Reference-Information/>
- <https://github.com/asterisk/asterisk>
