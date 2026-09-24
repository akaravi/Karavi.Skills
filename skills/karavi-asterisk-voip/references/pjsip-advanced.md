# Advanced SIP and PJSIP engineering

Use this reference for provider trunks, endpoint templates, registration failures, SIP response diagnosis, transfers, NAT, TLS, and multi-trunk routing.

## Version

Applicable to Asterisk 16 through 23. Resolve channel driver, res_pjsip modules, and provider requirements before changing configuration.

## Security

Use TLS/SRTP where required, least-privilege endpoint identities, ACLs, secure auth storage, SIP message redaction, and strict inbound identity validation. Never log Authorization headers or full caller data.

## Configuration layers

Keep transport, endpoint, auth, AOR, identify, registration, ACL, codec, NAT, and dialplan concerns separate. Endpoint names are not automatically trunk names. Use templates for shared policy and explicit overrides for provider quirks.

## Diagnosis matrix

| Symptom | First evidence | Likely layer |
|---|---|---|
| no REGISTER | pjsip show registrations, SIP trace | registration/TLS/network |
| 401 then failure | auth username/realm and retry | credentials/realm |
| 403 | provider policy and From/identity | authorization/identity |
| 404 | Request-URI and endpoint routing | dialplan/provider |
| 408 | packet capture and qualify | network/provider |
| 480/486 | endpoint state and destination | availability/call state |
| 488 | SDP offer/answer and codecs | media negotiation |
| 503 | provider response and trunk state | capacity/route |
| answer but no audio | RTP ports, NAT, SDP addresses | media path |

## Transfers and identity

Design attended/blind transfer, REFER, re-INVITE, UPDATE, P-Asserted-Identity, Remote-Party-ID, and caller ID policy explicitly. A transfer that returns a SIP success can still fail at dialplan or media level.

## Primary References

Official res_pjsip, SIP, RTP, and TLS documentation plus the trunk provider specification are authoritative.

## Verification

Test registration, inbound/outbound calls, busy/no-answer, transfer, hold/resume, DTMF, codec fallback, NAT, TLS expiry, provider failure, and failover trunk selection.
