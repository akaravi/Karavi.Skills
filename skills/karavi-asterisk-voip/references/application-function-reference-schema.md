# Application and function reference schema

Use this reference when adding a new Asterisk application, function, channel driver, resource, codec, or interface entry to the knowledge base.

## Version

Every entry must state supported Asterisk versions, module name, distribution assumptions, and the date of verification.

## Required entry shape

Each reference entry must contain:

1. Name and module.
2. Purpose and channel/media effect.
3. Syntax and argument constraints.
4. Return value, channel variables, and generated events.
5. AMI/ARI/AGI equivalent or explicit N/A.
6. Required modules and configuration.
7. Security and input-validation risks.
8. Timeout, cancellation, retry, and idempotency behavior.
9. Version differences.
10. Minimal dialplan and application-code example.
11. Positive, negative, timeout, hangup, and cleanup tests.
12. Official primary source URL.

## Security

Treat documentation examples as untrusted until inputs, permissions, secrets, file paths, shell execution, and recording access are reviewed.

## Example entry

For an Originate implementation, document channel syntax, context/extension mode, ActionID, OriginateResponse, resulting channel events, unknown-result reconciliation, endpoint authorization, and duplicate prevention. Do not document only the happy-path command.

## Primary References

Official Latest API, version-specific API, module, application, function, and interface documentation are authoritative.

## Verification

Reject entries missing version, module, security, failure, example, test, or official-source evidence. Validate examples against the target client library or a controlled PBX fixture.
