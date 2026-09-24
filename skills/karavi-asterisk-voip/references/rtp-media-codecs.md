# RTP, media, codecs, and external media

## Version

Canonical: Asterisk 22 LTS. Confirm module availability and media API behavior
for the exact release and build.

## Implementation decisions

Treat SIP/SDP signaling, RTP transport, codec negotiation, bridge state, and
application media as separate contracts. Record sample rate, packetization,
channels, payload type, direction, jitter policy, DTMF mode, transcoding, and
whether media is anchored or direct. For external media or AudioSocket, bound
buffers, define backpressure, cancellation, framing, and shutdown.

## Security

Restrict RTP ranges and management/media interfaces, use SRTP/TLS where
required, and protect recordings and audio streams. Do not log raw audio,
authorization headers, or unmasked caller identifiers.

## Failure behavior

Classify codec mismatch, invalid SDP, NAT address failure, blocked RTP, bridge
failure, jitter/overload, media dependency outage, and one-way audio
separately. Fail bounded and release channels, sockets, buffers, and files.

## Verification

Inspect SDP offer/answer, negotiated codec and direction, RTP packet flow on
both legs, bridge state, DTMF, hold/re-INVITE, recording, external-media
framing, timeout, and cleanup. A `200 OK` or connected AMI action alone is not
media verification.

## Primary references

- <https://docs.asterisk.org/Configuration/Channel-Drivers/>
- <https://docs.asterisk.org/Configuration/Applications/>
- <https://docs.asterisk.org/Configuration/Interfaces/Asterisk-REST-Interface-ARI/>
