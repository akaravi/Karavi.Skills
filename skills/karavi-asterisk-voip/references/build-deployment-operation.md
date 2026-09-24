# Build, deployment, and operation

## Version

Canonical: Asterisk 22 LTS. Pin the source branch, package, modules, codecs,
OS distribution, and build flags used by the deployment.

## Implementation decisions

Treat build, configuration, data, and runtime as separate release inputs.
Record enabled modules, external libraries, compiler/runtime versions, codec
licenses, configuration provenance, and migration order. Prefer immutable
artifacts and a controlled configuration overlay per environment.

Upgrades require compatibility review for dialplan, PJSIP, AMI/ARI clients,
CDR/CEL consumers, database schemas, codecs, and generated FreePBX content.
Use expand/contract migration where data or consumers span releases. Define
backup, restore test, rollback application version, and call-drain behavior.

Operational changes should be observable and bounded: health, readiness,
registration, trunk, queue, channel, bridge, RTP, error, and capacity checks.
Never treat reload or process health as functional call health.

## Security

Keep credentials and environment-specific endpoints outside source and image
layers. Restrict management ports, harden the host, pin packages, verify
artifact hashes, and protect backups and recordings.

## Failure behavior

Abort on version mismatch, missing module, failed migration, invalid config,
unhealthy trunk, failed restore test, or incomplete smoke. Preserve the prior
artifact and a documented containment/rollback action.

## Verification

Run config validation, module inventory, migration dry-run, backup restore,
registration/trunk checks, inbound/outbound call smoke, bidirectional RTP,
AMI/ARI connectivity, CDR/CEL reconciliation, and rollback rehearsal where
the environment permits.

## Primary references

- <https://docs.asterisk.org/Deployment/>
- <https://docs.asterisk.org/Operation/>
- <https://docs.asterisk.org/Getting-Started/>
