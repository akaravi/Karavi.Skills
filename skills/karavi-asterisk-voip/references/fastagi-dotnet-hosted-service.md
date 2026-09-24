# FastAGI in .NET hosted services

Use this reference when FastAGI is hosted by ASP.NET Core, a Worker, a Windows Service, or a console process.

## Protocol and lifecycle

FastAGI receives an AGI environment header block over TCP, terminated by a blank line, then exchanges command and reply lines with the channel. Parse framing independently from business routing. Validate the requested script name and reject unknown routes deterministically.

For a hosted listener:

- bind only to the configured interface and port;
- bound concurrent calls with an explicit limit;
- pass cancellation through accept, channel read/write, command execution, and shutdown;
- close the channel when the PBX hangs up or the host stops;
- keep command ordering deterministic;
- redact caller data and credentials from logs.

Do not treat a TCP accept or successful Answer command as proof that the downstream route succeeded. Record command results, channel variables, timeout, hangup, and final route decision.

## Verification

Test malformed headers, unknown script, partial read, PBX hangup during command, slow command, concurrent calls, cancellation, listener restart, and graceful host shutdown.
## Version

Applicable to FastAGI integrations on Asterisk 16 through 23 and modern .NET hosted services.

## Security

Restrict listener exposure, validate script routes, redact caller data, and enforce bounded concurrency.

## Verification

Test framing, hangup, timeout, cancellation, concurrency, restart, and shutdown.

## Primary References

Official AGI documentation and the target FastAGI library contract are authoritative.
