# Karavi Skills

Skill definitions published from this repo. Agents fetch them by raw URL, and
they install with `npx skills add`, so treat every file here as a public API.

## Skills

| Skill | Category | Does |
|---|---|---|
| [`karavi-terminal-session`](./karavi-terminal-session/) | Operator session | Supervised Windows terminal: PowerShell, Windows Terminal, SSH, WSL, read-only auto-run, mutation approval, and monitoring. |
| [`karavi-folder`](./karavi-folder/) | Pipeline / caretaker | Initializes & scaffolds the standard `karavi/` workspace tree (Full structure by default: 18 folders), migrates and renames legacy folder trees (Section 1), and safely removes temporary data — the four `karavi.temp.*` folders and caches (Section 2). |
| [`karavi-asterisk-voip`](./karavi-asterisk-voip/) | VoIP / telephony reference | Guides development and troubleshooting for Asterisk, FreePBX, SIP/PJSIP, RTP, AMI, ARI, AGI, dialplan, IVR, queues, and CDR/CEL with security, reliability, observability, and testing boundaries. |

## Choosing a Skill

- **Supervised Windows terminal / SSH then agent commands?** → `/karavi-terminal-session`
- **Need the `karavi/` skeleton initialized, migrated, or created?** → `/karavi-folder init` (or `/karavi-folder create`, Full by default)
- **Need to clear temp logs / caches / build artifacts?** → `/karavi-folder clean`
  (add `--deep` for full artifact+cache cleanup)

## File layout

```
skills/<name>/
├── SKILL.md          entry point, always loaded when the skill triggers
├── README.md         human-facing, GitHub renders this
├── LICENSE           Apache-2.0
├── references/       loaded on demand, one file per topic
└── scripts/          optional executables
```

## Size budget

`SKILL.md` is loaded in full every time the skill fires, so keep it **under 500
lines**. Everything past the decision-making core lives in `references/`, which
the agent loads only when it needs that topic.

## License

Apache-2.0
