# Karavi project integration

`karavi-terminal` owns the shell/session boundary: opening a terminal,
interactive login, command risk, output capture, and verification. It does not replace
domain-specific skills.

For Asterisk/VoIP work, compose it with `karavi-asterisk-voip`:

1. Use this skill to establish the authorized Windows/SSH/WSL/Orca channel and `ready` gate.
2. Use `karavi-asterisk-voip` for Asterisk, SIP/PJSIP, RTP, AMI, ARI, AGI, dialplan,
   queues, CDR/CEL, Linux service commands, configuration semantics, and VoIP smoke tests.
3. Classify Linux commands using this skill's permission model; domain knowledge does
   not make a mutating command read-only.
4. Capture Asterisk evidence without passwords, AMI secrets, SIP credentials, or raw
   production topology. Verify with the domain skill's relevant CLI/config/network test.

The same composition applies to other Karavi domain skills: terminal lifecycle here,
domain contract in the specialist skill, and repository-specific commands in the
consuming project rather than in this reusable skill.
