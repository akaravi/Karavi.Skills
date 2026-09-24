# .NET implementation profile

Use this reference when Asterisk is consumed from C#, ASP.NET Core, a Worker, a Windows Service, a console host, or a shared .NET library.

## Boundary

Keep the Asterisk adapter responsible for wire framing, authentication, action/event parsing, reconnect, cancellation, and protocol models. Keep domain state, authorization, persistence, API envelopes, SignalR messages, and UI models outside the adapter. Map protocol objects into application DTOs at the application boundary.

## Required .NET behaviors

- Use IOptions with environment-specific validation; never put AMI, ARI, SIP, or recording secrets in source-controlled base configuration.
- Use BackgroundService/IHostedService for persistent AMI, ARI, and FastAGI listeners. Propagate the host cancellation token to connect, read, write, retry, and shutdown.
- Use bounded connect/read/write/overall timeouts and jittered reconnect. Do not create unbounded reconnect tasks or one thread per event.
- Serialize writes per connection, correlate actions with a unique operation-scoped ActionID, and handle interleaved events and multi-part responses.
- Dispose sockets, subscriptions, timers, and channels on both normal stop and failed reconnect.
- Use structured UTC logging with server ID, connection state, action ID, call ID, operation, duration, result, and redaction.

## Verification

Test parser framing, unknown headers, interleaved events, timeout, cancellation, reconnect, duplicate action protection, shutdown, and partial failure. A unit test that only checks a successful login is not a sufficient adapter test.
## Version

Applicable to netstandard2.0 adapters and modern .NET hosts; reconcile with the repository target framework.

## Security

Validate configuration at startup and keep secrets, caller data, and recordings out of source and logs.

## Verification

Run adapter, lifecycle, cancellation, reconnect, and failure-path tests.

## Primary References

The target repository's project rules and official Asterisk interface documentation are authoritative.
