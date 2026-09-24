# PJSIP WSS/WebRTC and browser softphones

Use this reference when a browser softphone, SIP.js, SIP over WebSocket, WebRTC, or an Asterisk WSS endpoint is involved.

## Configuration contract

Keep these values distinct and environment-specific: WSS URL and path, SIP domain and realm, TLS certificate and private key, PJSIP transport, endpoint/auth/AOR identity, codecs and WebRTC flags, ICE/STUN/TURN policy, and API provisioning and credential rotation.

Use wss:// in production, validate certificate and origin policy, and do not expose SIP passwords through logs, GET responses, browser source, or committed configuration. The WebPhone talks to Asterisk for SIP/WebSocket/media; an application API may provision settings but is not a substitute for the PBX transport.

## Media verification

Verify REGISTER, INVITE/200/ACK, SDP codec agreement, ICE candidates, DTLS-SRTP, RTP direction, hold/resume, hangup, and browser permission behavior. HTTP health and SIP registration alone do not prove two-way audio.

For SIP.js or another client library, pin and test the actual version used by the repository. Treat browser, WSS, PJSIP, NAT, certificate, and media failures as separate layers.
## Version

Applicable to Asterisk 16 through 23; verify PJSIP WebRTC and HTTP/TLS module behavior on the target release.

## Security

Use WSS, certificate validation, origin policy, credential isolation, and secure browser provisioning.

## Verification

Verify SIP signaling, SDP, ICE, DTLS-SRTP, RTP direction, browser permissions, and hangup.

## Primary References

Official PJSIP, HTTP, WebSocket, and RTP documentation plus the pinned client version are authoritative.
