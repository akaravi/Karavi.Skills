# FreePBX dialplan, Call Files, and recording

Use this reference for FreePBX/Issabel integration, AMI originate contracts, pbx_spool, MixMonitor, or recording-backed call jobs.

## Dialplan boundary

Do not overwrite generated FreePBX files. Use custom contexts or documented hooks. Resolve the exact channel technology and trunk endpoint from the PBX, because PJSIP/{number}@{endpoint} and legacy SIP/{trunk}/{number} are different contracts.

For Local/ originate flows, distinguish Local channel stubs from the actual media channels. Reconcile BRIDGEPEER, answer, hangup, cause, and bridge state before declaring two-way audio.

## Call File invariant

Write the .call file to staging on the same volume as Asterisk outgoing, use the encoding required by the target Asterisk version (commonly ASCII), validate that exactly one execution model is present (Application or Context/Extension/Priority), then atomically move it into outgoing. Never write directly into outgoing or perform an unverified cross-volume copy.

## Recording invariant

Treat recording as an asynchronous lifecycle. Correlate MixMonitor start/stop, channel/call identity, CDR/CEL, file availability, retention, and access authorization. A successful recording command does not prove that the final file exists or is readable.
## Version

Applicable to FreePBX/Issabel and Asterisk 16 through 23; verify spool and application behavior on the target release.

## Security

Protect dialplan inputs, spool paths, recording files, caller data, and privileged control actions.

## Verification

Verify originate, bridge/media, atomic spool submission, recording finalization, and authorized retrieval.

## Primary References

Official dialplan, application, and recording documentation plus the repository contract are authoritative.
