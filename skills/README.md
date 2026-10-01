# Karavi Skills

Skill definitions published from this repo. Agents fetch them by raw URL, and
they install with `npx skills add`, so treat every file here as a public API.

## Skills

| Skill | Category | Does |
|---|---|---|
| [`karavi-prompt`](./karavi-prompt/) | Prompt pipeline | Arms every agent prompt before it runs: engineers it, guards it for secrets/injection, shows the user an "in execution" panel, then dispatches it verbatim. |
| [`karavi-terminal`](./karavi-terminal/) | Operator session | Supervised Windows terminal: PowerShell, Windows Terminal, SSH, WSL, read-only auto-run, mutation approval, and monitoring. |
| [`karavi-folder`](./karavi-folder/) | Pipeline / caretaker | Initializes & scaffolds the standard `karavi/` workspace tree, migrates and renames legacy folder trees, and safely removes temporary data and caches. |
| [`karavi-asterisk-voip`](./karavi-asterisk-voip/) | VoIP / telephony reference | Guides development and troubleshooting for Asterisk, FreePBX, SIP/PJSIP, RTP, AMI, ARI, AGI, dialplan, IVR, queues, and CDR/CEL with security, reliability, observability, and testing boundaries. |
| [`karavi-council`](./karavi-council/) | Planning / architecture | Technical council for context sweep, options, red-team, ADR, specification, plan, and readiness before execution. |
| [`karavi-judge`](./karavi-judge/) | Quality / acceptance | Independent evidence-based acceptance gate: seven-domain relevance mask, failure scenario, Completion Envelope, and the final verdict. |
| [`karavi-rule`](./karavi-rule/) | Global rule router | Activates the canonical rule source, installs the mandatory workflow skills, and routes work to the skill that owns each procedure. |

## Choosing a Skill

- **Writing or sending a prompt to an agent?** → `/karavi-prompt arm "<request>"`
- **Supervised Windows terminal / SSH then agent commands?** → `/karavi-terminal`
- **Need the `karavi/` skeleton initialized, migrated, or created?** → `/karavi-folder init` (or `/karavi-folder create`)
- **Need to clear temp logs / caches / build artifacts?** → `/karavi-folder clean`
- **Architecture, ADR, or consequential planning?** → `/karavi-council`
- **Final acceptance of a delivery?** → `/karavi-judge`
- **Activate the global rules and install the mandatory skills?** → `/karavi-rule`

Ordering when several apply: arm the prompt first (`karavi-prompt`), then plan
(`karavi-council`), then execute under the terminal permission model
(`karavi-terminal`), then accept (`karavi-judge`).

## File layout

```
skills/<name>/
├── SKILL.md          entry point, always loaded when the skill triggers
├── README.md         human-facing, GitHub renders this
├── LICENSE           Apache-2.0
├── references/       loaded on demand, one file per topic
├── scripts/          optional executables
└── tests/            optional Pester suites
```

## Size budget

`SKILL.md` is loaded in full every time the skill fires, so keep it **under 500
lines**. Everything past the decision-making core lives in `references/`, which
the agent loads only when it needs that topic.

## Encoding

Text files are UTF-8 **without** BOM. Windows PowerShell 5.1 reads a BOM-less
`.ps1` as the system ANSI code page, so scripts in this repo stay ASCII-only and
build any non-ASCII glyph from its code point. `karavi-prompt` demonstrates this
with `Get-KaraviPromptGlyph`; `verify-karavi-prompt-skill.ps1` enforces it.

## License

Apache-2.0
