# Karavi Skills

Skill definitions published from this repository. Each skill's `SKILL.md` is
the agent entry point; its README is the human-facing guide. Treat both as a
public API. Skills are instructions and optional helpers, not a universal app
or a ready-to-run deployment for an arbitrary project.

## Install and activate

For CLI installation, provide Node.js, `pnpm`, and access to GitHub. Choose a
skill name from the table below:

```bash
pnpm dlx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-prompt
```

The same `--skill` option selects any listed skill. Confirm the installer
result, that the active assistant discovers the installed directory, and that
its `SKILL.md` has the expected `name`. Installation paths and slash-command
support depend on the host. With manual loading, provide the selected
`SKILL.md` and its linked references; do not claim automatic activation.

Activating `karavi-rule` additionally requires installing and verifying
`karavi-council`, `karavi-folder`, and `karavi-judge` separately. Follow the
[canonical dependency installation contract](./karavi-rule/references/installation.md).
Installing a skill does not install PowerShell, Pester, Asterisk, Docker, or
provider credentials.

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
| [`karavi-deploy-github-plesk`](./karavi-deploy-github-plesk/) | Deployment / CI-CD | Automates exact-tag GitHub Actions releases into a Plesk domain with branch, path, webhook, and smoke verification. |
| [`karavi-deploy-gitlab-plesk`](./karavi-deploy-gitlab-plesk/) | Deployment / CI-CD | Zero-zip GitLab-to-Plesk releases from an exact `publish` tag push, with `test -> build -> health`, direct branch publishing, and Health plus Swagger UI/document checks. |

## Choosing a Skill

- **Writing or sending a prompt to an agent?** → `/karavi-prompt arm "<request>"`
- **Supervised Windows terminal / SSH then agent commands?** → `/karavi-terminal`
- **Need the `karavi/` skeleton initialized, migrated, or created?** → `/karavi-folder init` (or `/karavi-folder create`)
- **Need to clear temp logs / caches / build artifacts?** → `/karavi-folder clean`
- **Architecture, ADR, or consequential planning?** → `/karavi-council`
- **Final acceptance of a delivery?** → `/karavi-judge`
- **Activate global rules and required dependencies?** → `/karavi-rule`
- **Asterisk / FreePBX / SIP or RTP troubleshooting?** → `/karavi-asterisk-voip`
- **GitHub Actions to Plesk deployment?** → `/karavi-deploy-github-plesk`
- **GitLab CI/CD to Plesk deployment (no zip, webhook)?** → `/karavi-deploy-gitlab-plesk`

Ordering when several apply: arm the prompt first (`karavi-prompt`), then plan
(`karavi-council`), then execute under the terminal permission model
(`karavi-terminal`), then accept (`karavi-judge`).

These are requests to the assistant, not shell executables. When a host has no
slash commands, name the skill in the request and provide scope and acceptance.
Invoke only the relevant workflow: Council is for consequential planning, not
every tiny edit; Judge does not implement the work it evaluates.

## Usage, outputs, and authorization

1. Open the selected README for prerequisites, supported inputs, and examples.
2. Load its `SKILL.md`, then only the references needed by the task.
3. Supply the target repository/path, intended outcome, explicit exclusions,
   and an observable verification method. Derive owner, domain, and runtime
   from canonical project configuration rather than examples.
4. Collect the skill's actual output and evidence. Prompt arming produces an
   armed prompt and ledger; Council produces planning artifacts and ends at
   readiness; Judge produces a verdict; operational skills have their own
   explicit changes and acceptance gates.

Reading, installing, or invoking a skill does not authorize deletion, Git
mutation, infrastructure changes, production access, or deployment. Obtain the
required permissions independently. Remote FTP/SFTP/FTPS transfer requires the
explicit `Deploy` authorization. Do not put credentials, private keys, customer
data, or secret-bearing webhook URLs into examples, Git, reports, or chat.
Use read-only inspection and documented dry runs before destructive work.

GitHub and GitLab deployment skills have distinct contracts. Do not assume the
GitLab stage graph applies to GitHub Actions. For Git hosted at `git.ntk.ir`,
use scp-style SSH repository URLs, never HTTP(S) Git remotes; this does not
prohibit HTTPS API or webhook calls.

## Verification and maintenance

No single build or test command covers every skill. Each README identifies
its actual verifier/test entry points, when present, and their prerequisites.
Static document checks do not prove live provider access, browser behavior,
healthy infrastructure, or successful deployment.

When changing a skill:

- Ground examples and CLI flags in its current `SKILL.md`, references, and
  script signatures; never document a future capability as implemented.
- Keep the root [project overview](../README.md), this index, and the skill's
  README consistent with the entry point.
- Check relative links, UTF-8/no-BOM encoding, and fenced examples. Run only
  relevant authorized validation and report skipped runtime checks explicitly.
- Follow [AGENTS.md](./AGENTS.md) and the
  [integration guide](./CLAUDE.md); do not rewrite unrelated skill contracts.

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

[Apache-2.0](../LICENSE). Each skill also includes its own `LICENSE` file.
