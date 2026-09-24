# SIP, PJSIP, RTP, and media

Use this reference for endpoint registration, trunks, transports, NAT, codecs,
TLS, call setup, and one-way/no-audio diagnosis.

## Version

Canonical: Asterisk 22 LTS. Check 20/23 versioned documentation before using
option names or defaults that may differ.

## Establish the media contract

Record the target topology before editing configuration: phones, PBX, proxy,
SBC, trunk, public/private addresses, NAT direction, transport, Asterisk
version, and whether media is direct or anchored at Asterisk. A signaling path
can succeed while the RTP path is unreachable.

Prefer `res_pjsip` and the project's current configuration pattern. Do not
silently convert a deployment from `chan_sip` to PJSIP or change codecs and
transports as a side effect of an application change.

## Configuration review

- Keep endpoint, authentication, AOR, contact, identify, transport, and
  registration responsibilities distinct.
- Use explicit `allow`/`disallow` codec policy, ordered by the intended
  preference. Verify both sides actually negotiate the selected codec.
- Configure `external_signaling_address`, `external_media_address`, and local
  network ranges from environment-specific configuration when NAT requires it.
- Use TLS/SRTP only with a documented certificate and trust policy. Validate
  hostname, certificate chain, expiry, and supported protocol versions.
- Limit registrations and contacts to the expected endpoint behavior. Review
  qualify/keepalive, rewrite options, symmetric RTP, and direct-media policy
  for the topology rather than copying a generic recipe.
- Protect SIP credentials and avoid logging full `Authorization` headers,
  passwords, tokens, or complete caller identifiers.

## Security

Use private management binds, narrow ACLs, TLS/SRTP where required, rotated
credentials, and redacted SIP traces. Never place endpoint passwords or full
authorization headers in source, fixtures, or logs.

## Troubleshooting order

1. Confirm endpoint/AOR/authentication and registration state.
2. Inspect SIP signaling and response codes (`401`, `403`, `404`, `488`, `503`)
   with sensitive headers redacted.
3. Verify SDP offer/answer: address, port, codec, direction (`sendrecv`,
   `sendonly`, `recvonly`), payload type, and telephone-event.
4. Verify RTP reachability and packet direction on both legs; check NAT,
   firewall, symmetric RTP, and direct media.
5. Confirm bridge/channel state and dialplan application behavior.
6. Test hold, transfer, early media, DTMF, re-INVITE, and hangup cleanup if
   those flows are in scope.

Do not conclude “SIP is fine” from a `200 OK`; inspect SDP and RTP evidence.

## Verification

Use deterministic test endpoints and a controlled trunk. Cover registration,
inbound and outbound call setup, busy/no-answer, invalid destination, DTMF,
hold/transfer, codec mismatch, NAT, one-way audio, timeout, and cleanup.
Record Asterisk version, transport, codec, response code, masked trace source,
RTP direction, and timestamp in UTC.

## Primary references

Primary references:

- <https://docs.asterisk.org/Configuration/Channel-Drivers/Configuring-res_pjsip/>
- <https://docs.asterisk.org/Configuration/Channel-Drivers/SIP/>
