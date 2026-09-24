# Version compatibility

## Version

Canonical: Asterisk 22 LTS. Asterisk 20 is an LTS compatibility target;
Asterisk 23 is a Standard compatibility target. Asterisk 18 and historical
material are legacy references only.

## Implementation decisions

Before implementation, record the exact Asterisk version, module set, channel
driver, API surface, configuration generator, OS, codecs, and client library.
Use versioned official pages for option names, default changes, API fields,
module availability, security policy, and deprecations. Treat an unverified
cross-version assumption as an uncertainty requiring test evidence.

Keep public application contracts additive. If a version changes an event,
field, action, dialplan application, or configuration option, use an adapter,
feature detection, compatibility alias, or explicit migration rather than a
silent breaking change.

## Security

Check security support status and advisories for the deployed series. Do not
keep an EOL release as a security baseline or copy legacy insecure examples.

## Failure behavior

Block release on unsupported version, missing module, incompatible event/schema,
changed default, failed migration, or untested client behavior. Report the
exact version boundary and recovery path.

## Verification

Run contract tests against the canonical version and every declared compatible
version. Compare AMI/ARI/AGI schemas, PJSIP behavior, dialplan applications,
CDR/CEL fields, media negotiation, security settings, and failure behavior.

## Primary references

- <https://docs.asterisk.org/About-the-Project/Asterisk-Versions/>
- <https://docs.asterisk.org/Asterisk-20-Documentation/>
- <https://docs.asterisk.org/Asterisk-22-Documentation/>
- <https://docs.asterisk.org/Asterisk-23-Documentation/>
