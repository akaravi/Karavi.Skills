# External telecom and business integrations

Use this reference when Asterisk is connected to CRM, ERP, ticketing, SMS, speech, billing, identity, webhook, or analytics systems.

## Version

Integration contracts are independent of Asterisk version, but call/event fields must be verified on the target Asterisk release.

## Security

Use signed webhooks, mTLS or scoped tokens, secret injection, PII minimization, replay protection, rate limits, authorization, and redaction. Do not send full caller data to systems that do not need it.

## Integration pattern

Use a durable call identity composed of server ID, unique ID, linked ID, operation ID, and tenant where applicable. Publish normalized domain events instead of exposing raw AMI/ARI frames. Use an outbox or durable queue for callbacks and analytics so PBX control is not blocked by a slow dependency.

## Failure behavior

External CRM or speech failure must have a bounded timeout and a defined call fallback. Do not retry non-idempotent business actions without a key. Reconcile callbacks after restart and deduplicate by event identity.

## Common integrations

- click-to-call and CRM screen pop;
- call disposition and ticket creation;
- SMS or SIP MESSAGE notification;
- speech recognition and text-to-speech in IVR;
- billing and rated CDR;
- LDAP/OIDC user and queue authorization;
- recording indexing and search;
- webhook delivery and analytics streaming.

## Primary References

The external provider contract, repository API contract, privacy policy, and official Asterisk interface documentation are authoritative.

## Verification

Test authentication, idempotency, timeout, retry, replay, PII redaction, dependency outage, callback ordering, and eventual reconciliation.
