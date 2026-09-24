# Advanced RTP, SDP, WebRTC, and media services

Use this reference for one-way audio, codec negotiation, browser media, AudioSocket, ExternalMedia, recording formats, and media troubleshooting.

## Version

Applicable to Asterisk 16 through 23. Verify module and codec availability on the target host.

## Security

Protect RTP ranges, TLS keys, recording files, external media endpoints, and browser permissions. Do not publish packet captures containing credentials or personal data.

## Media path model

Trace the complete path: endpoint to Asterisk, Asterisk to trunk, bridge membership, SDP addresses, NAT translation, RTP port range, codec, and transcoding. Separate signaling success from media success.

## WebRTC checklist

- WSS certificate chain and hostname
- browser origin and microphone permission
- SIP REGISTER and authentication
- SDP offer/answer and opus/G.711 agreement
- ICE candidate gathering and STUN/TURN reachability
- DTLS-SRTP fingerprint and handshake
- RTP direction, packet loss, jitter, and symmetric NAT
- hold/resume, DTMF, transfer, and hangup

## External media

For AudioSocket or ARI ExternalMedia, define codec, sample rate, framing, flow control, reconnect, backpressure, and shutdown. Bound buffers and never let a slow speech/media service block the Asterisk channel indefinitely.

## Primary References

Official RTP, SDP, PJSIP, WebRTC-related configuration, AudioSocket, and ARI documentation are authoritative.

## Verification

Use packet capture and RTP statistics alongside SIP/AMI/ARI events. Verify both directions, codec agreement, bridge state, timing, and terminal cleanup.
