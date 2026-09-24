# AGI and FastAGI

## Version

Canonical: Asterisk 22 LTS. Verify AGI variables, applications, result codes,
and supported transports against the deployed release.

## Implementation decisions

Use AGI for bounded synchronous dialplan interaction and FastAGI only when the
network boundary is explicit. Parse the AGI environment through its blank-line
terminator, send one command at a time, flush, and read its corresponding
result. Keep business rules in the application layer and map channel variables
through a thin adapter.

Set connect, command, read, and overall deadlines. Cancel on hangup. Never
retry a side effect without an operation guard and current channel state.

## Security

Validate channel variables, digits, destinations, language, tenant, and file
names. Do not interpolate untrusted values into shell, database, file, or
dialplan fragments. Protect FastAGI sockets and redact variables and results.

## Failure behavior

Handle malformed environment, missing result, non-zero result, channel gone,
network timeout, reconnect, process crash, and cancellation separately. Always
return control to dialplan or terminate the call according to an explicit safe
policy.

## Verification

Test framing over partial reads, command/result sequencing, invalid input,
timeout, hangup cancellation, remote process outage, duplicate action, secret
redaction, and successful dialplan continuation against Asterisk 22.

## Primary references

- <https://docs.asterisk.org/Configuration/Interfaces/Asterisk-Gateway-Interface-AGI/>
- <https://docs.asterisk.org/Configuration/Interfaces/FastAGI/>
