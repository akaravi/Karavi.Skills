# Security hardening

## Version

Canonical: Asterisk 22 LTS. Track security advisories and release-specific
hardening changes for 20 and 23 separately.

## Implementation decisions

Apply least privilege across host, modules, AMI, ARI, SIP/PJSIP, dialplan,
databases, recordings, and external applications. Bind management interfaces
privately, use narrow ACLs, TLS/SRTP where required, rotate credentials, and
separate test/staging/production configuration.

Treat caller input, SIP headers, channel variables, AMI data, ARI parameters,
recording paths, SQL values, shell arguments, and HTTP callbacks as untrusted.
Use typed allowlists and parameterized queries; never build executable
fragments from raw input.

## Security

Never commit or log AMI/SIP/ARI credentials, private keys, tokens, recordings,
full phone numbers, or PII. Redact before traces, metrics, CDR/CEL exports,
support bundles, and chat. Protect backups and audit privileged actions.

## Failure behavior

Fail closed on authentication failure, ACL mismatch, certificate failure,
invalid input, cross-tenant target, exposed bind, secret finding, unsafe
dialplan fragment, or missing audit event. Do not weaken security to make a
test pass.

## Verification

Test manager classes, ACLs, TLS/SRTP, invalid credentials, unauthorized action,
dialplan injection, SQL/command/path injection, tenant isolation, recording
access, secret redaction, rate limits, audit logging, and security advisory
status.

## Primary references

- <https://docs.asterisk.org/About-the-Project/Asterisk-Security-Vulnerabilities/>
- <https://docs.asterisk.org/Configuration/Interfaces/Asterisk-Manager-Interface-AMI/AMI-Configuration/>
- <https://docs.asterisk.org/Configuration/Channel-Drivers/Configuring-res_pjsip/>
