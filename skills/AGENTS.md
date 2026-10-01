# Skills (`skills/`)

Karavi skill definitions published from this repo. Agents fetch them by raw URL,
so treat every file here as a public API.

## The two kinds

**Reference skills** carry knowledge and are always available.

| Skill | Does |
|---|---|
| `karavi-terminal/` | Supervised Windows terminal sessions: user interactive login, agent read-only without approval, mutation only after explicit approval, terminal monitoring, and safe prompts/secrets. |
| `karavi-asterisk-voip/` | Guides Asterisk, FreePBX, SIP/PJSIP, RTP, AMI, ARI, AGI, dialplan, IVR, queues, CDR/CEL, testing, security, and troubleshooting work. |

**Pipeline / caretaker skills** run on demand and have side effects.

| Skill | Does |
|---|---|
| `karavi-prompt/` | Arms every prompt bound for an agent: engineers the raw text into a structured, grounded, bounded prompt, guards it for secrets and prompt injection, renders the user-visible "in execution" panel, then dispatches the armed text verbatim and records the run in a ledger. |
| `karavi-folder/` | Initializes and scaffolds the standard `karavi/` workspace tree, migrates/renames legacy folders, and removes temporary data and caches. |
| `karavi-council/` | Runs the technical council for consequential planning: context sweep, options, red-team, ADR, specification, plan, and readiness. |
| `karavi-judge/` | Issues the independent, evidence-based acceptance verdict against a relevance mask, failure scenario, and Completion Envelope. |
| `karavi-rule/` | Activates the canonical global rule source, installs the mandatory workflow skills, and delegates each procedure to its owning skill. |

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

`SKILL.md` is loaded in full every time the skill fires, so it is the expensive
file. Keep it **under 500 lines**. Everything past the decision-making core
belongs in `references/`, which the agent loads only when it needs that topic.

## Encoding

Text files are UTF-8 **without** BOM. Windows PowerShell 5.1 parses a BOM-less
`.ps1` as the system ANSI code page, so a literal box-drawing or arrow character
becomes mojibake and can break a string literal. Scripts here stay ASCII-only
and build non-ASCII glyphs from code points — see `Get-KaraviPromptGlyph` in
`karavi-prompt/scripts/karavi-prompt.common.psm1`.

## Conventions

- Skills target the current repository only — no cross-project import.
- Destructive skills declare **exit codes** in a table and mean them.
- Deletion skills are idempotent and always run a `--what-if` dry-run before
  deleting unless the user explicitly approved.
- Cross-references between files use relative paths so the skill works when
  vendored into another repo.
- A skill that gates a side effect states the gate in `SKILL.md`, in a table an
  agent can act on, and never delegates the decision to a script alone.
