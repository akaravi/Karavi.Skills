# Asterisk fundamentals

## Version

Canonical: Asterisk 22 LTS. Confirm the deployed release before relying on
module names, CLI output, channel behavior, or configuration options.

## Implementation decisions

Asterisk is a modular telephony runtime. Channels represent call legs,
bridges join media/control paths, dialplan drives execution, modules provide
applications and protocols, and external interfaces observe or control state.
Keep application business rules outside dialplan and transport adapters.

Understand startup, module loading, configuration reload, channel creation,
bridge membership, hangup, and shutdown as separate lifecycle events. A reload
does not prove that every module or existing channel adopted new configuration.

Use the CLI and official configuration reference to verify loaded modules,
active channels, endpoint state, dialplan, bridges, queues, and logging before
changing a file. Treat generated FreePBX output as a managed boundary.

## Security

Run the PBX with least privilege, protected management access, restricted
module loading, and environment-specific configuration. Do not expose CLI,
AMI, ARI, SIP credentials, recordings, or caller PII in logs or source.

## Failure behavior

Separate startup failure, module failure, configuration parse failure, channel
failure, media failure, and external dependency failure. Preserve correlation
IDs and terminal call state when a module, trunk, or application disappears.

## Verification

Verify the target version, loaded modules, configuration source, active
transports, dialplan context, endpoint registration, bridge/media state, and
graceful shutdown. A process being alive is not proof that calls or media work.

## Primary references

- <https://docs.asterisk.org/Fundamentals/>
- <https://docs.asterisk.org/Getting-Started/>
