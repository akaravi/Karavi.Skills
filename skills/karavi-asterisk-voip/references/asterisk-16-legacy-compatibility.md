# Asterisk 16 compatibility profile

Use this reference when the repository or PBX targets Asterisk 16, FreePBX/Issabel based on 16, or a mixed fleet containing 16 and newer releases.

## Compatibility contract

Resolve the actual PBX version before selecting an action, event, channel syntax, or ARI behavior. Treat Asterisk 16 as a first-class target, not as an unnamed `legacy` bucket. Record:

- Asterisk version and distribution
- `chan_pjsip` versus `chan_sip`
- enabled modules and HTTP/WebSocket/TLS endpoints
- AMI and ARI user permissions
- the exact action/event fields observed on the wire

Prefer capability detection and a versioned adapter over comparing version strings in business code. Keep 16-specific behavior behind a transport or feature policy so a 20/22/23 client is not silently changed.

## High-risk differences

- Do not assume every modern AMI event field exists on 16; deserialize optional fields and preserve unknown headers.
- Do not assume ARI resource operations or WebSocket behavior are identical across versions; verify the target module and event sequence.
- `chan_sip` and `PJSIP` channel names are not interchangeable.
- FreePBX-generated dialplan must not be overwritten; use custom contexts and documented hooks.
- A successful AMI login does not prove that the required action class or application is available.

## Required verification

For a change targeting 16, run a protocol fixture or PBX integration check for login, the selected action, its response/event pair, hangup cleanup, and the relevant dialplan/media path. Record unsupported features as an explicit compatibility finding rather than silently falling back.
## Version

Primary compatibility profile for Asterisk 16 and mixed 16/20/22/23 fleets.

## Security

Do not expose manager, ARI, SIP, or TLS credentials while probing compatibility.

## Verification

Use a version-specific protocol fixture or controlled PBX integration check.

## Primary References

Official Asterisk versions and interface documentation are authoritative.
