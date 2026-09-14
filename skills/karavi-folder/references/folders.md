# Section 1 — Create the main `karavi/` folders

Mechanics behind `/karavi-folder create`. Loaded only when this section runs.

## Purpose

`karavi/` is the single focal point in **every** repo for the operator/agent:
planning, technical & business docs, logs, status, build, publish, and deploy.
This skill creates the tree **fresh inside the current repo** — it never imports
from, or copies, another project.

## Where it goes

The skeleton is created under the **repository root** (the folder that contains
`.git` or that already owns a `karavi/`). Resolve the root with
`karavi.scripts.tools/workspace.paths.ps1` (`Get-RepoRootFromKaraviScript`) when
present; otherwise the agent locates the repo root itself (walk up from CWD until
it finds `.git`).

## Core folders (always create)

| Folder | Purpose |
|---|---|
| `karavi/karavi.plans.prompt/cursor` | Cursor plans — `Karavi.NNN.plan.md` |
| `karavi/karavi.plans.prompt/claude` | Claude plans |
| `karavi/karavi.plans.prompt/other` | Generic plans (JSON Prompt) |
| `karavi/karavi.history` | Change history (`history.YYYY-MM-DD.md`) |
| `karavi/karavi.logs` | Local logs (gitignored) |
| `karavi/karavi.status` | Execution/deploy status reports |
| `karavi/karavi.build.config` | Build settings, manifests |
| `karavi/karavi.build.files` | Temporary build output (gitignored) |
| `karavi/karavi.deploy.config` | Deploy & FTP configuration |
| `karavi/karavi.deploy.files` | Release output ready to deploy (gitignored) |
| `karavi/karavi.publish.config` | Publish settings |
| `karavi/karavi.publish.files` | Publish/ZIP output (gitignored) |
| `karavi/karavi.scripts.command` | Operator commands (deploy, run all, clean, ...) |
| `karavi/karavi.scripts.tools` | Tooling helpers (verify, paths, build pieces, ...) |

## Optional folders (only with `--full`, and only if the project needs them)

| Folder | Purpose |
|---|---|
| `karavi/karavi.assets/{brand,icons,screenshots,templates}` | Static assets |
| `karavi/karavi.doc/workflows` | General project docs (technical/operator) |
| `karavi/karavi.BusinessModel.Doc` | Business model & commercial docs |
| `karavi/karavi.Customer.doc` | Planning docs (before execution) |
| `karavi/karavi.plans.mockup` | Mockups / UI reference |
| `karavi/karavi.scripts` | Script index: README, naming, maps |
| `karavi/karavi.SociaMediaContent` | Social-media content (optional) |
| `karavi/karavi.grafana.config` | Grafana check config (when used) |

Create optional folders only when the project actually uses them — do not create
every optional folder blindly.

## `.gitkeep` convention

Add a `.gitkeep` inside output/temp folders (`karavi.*.files/`, `karavi.logs/`,
`karavi.status/`, `karavi.history/`, `karavi.assets/**`) so empty directories are
tracked, and drop `.gitkeep` once real content exists.

## `.gitignore` wiring

Append a `# --- karavi ---` block to the repo's `.gitignore`:

```
karavi/karavi.logs/
karavi/karavi.deploy.files/
karavi/karavi.build.files/
karavi/karavi.publish.files/
karavi/karavi.status/*.html
karavi/karavi.deploy.config/Deploy_FTP.info
karavi/karavi.deploy.config/Deploy_TestUsers.info
karavi/karavi.deploy.config/deploy.secrets.json
```

Never commit local-only config overlays (`Deploy_FTP.info`,
`appsettings.Development.json`, `appsettings.Local.json`).

## Per-project config to wire after creation

| Config | Where |
|---|---|
| Names / assembly / version | `karavi.build.config/version-manifest.json`, `build-profiles.json` |
| Hosts, URLs, ports | `karavi.deploy.config/production-hosts.json`, `deploy-targets.json`, `local-dev-ports.json` |
| Clean paths | `karavi.build.config/clean-manifest.json` |
| Agent rule paths | `karavi.scripts.tools/workspace.paths.ps1`, `.cursor/rules/` |

## Verification

- Confirm each expected folder exists (`Test-Path`), no folder on the list is
  missing.
- Confirm `.gitignore` got the `# --- karavi ---` block.
- Confirm no path points outside the repo root.
- If `karavi.scripts.tools/verify.karavi-structure.ps1` exists in the repo, run it.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | Tree created / verified. |
| 1 | Repo root not found, or a required path could not be created. |
| 3 | A requested path resolves outside the repo root. |
