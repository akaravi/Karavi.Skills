# Section 1 — Create the main `karavi/` folders

Mechanics behind `/karavi-folder create`. Loaded only when this section runs.

## Purpose

`karavi/` is the single focal point in **every** repo for the operator/agent:
planning, technical & business docs, history, logs, status, build, and deploy.
This skill creates the tree **fresh inside the current repo** — it never imports
from, or copies, another project.

## Where it goes

The skeleton is created under the **repository root** (the folder that contains
`.git` or that already owns a `karavi/`). Resolve the root with
`karavi.scripts.tools/workspace.paths.ps1` (`Get-RepoRootFromKaraviScript`) when
present; otherwise the agent locates the repo root itself (walk up from CWD until
it finds `.git`).

## Core folders (always create) — with complete description

| Folder | Purpose |
|---|---|
| `karavi/karavi.plans.prompt` | Prompts, reusable JSON rules, and Agent plans for **all** assistants (Cursor, Claude, other) in one place. No per-tool subfolders — put `Karavi.NNN.plan.md` files here flat. |
| `karavi/karavi.history` | Change history of the project. One file per day: `history.YYYY-MM-DD.md`. Never deleted. |
| `karavi/karavi.deploy.config` | Deploy & FTP configuration for **this** repo: `production-hosts.json`, `deploy-targets.json`, `local-dev-ports.json`, `Deploy_FTP.info`, secrets. `*.example` and public JSON are tracked; real credentials are gitignored. |
| `karavi/karavi.scripts.command` | Operator/agent **commands** (deploy, run all, clean, history.write, ...). Invoked as the working entry points the agent runs. |
| `karavi/karavi.scripts.tools` | Tooling **helpers** (verify structure, path resolvers, build pieces, `verify-gates.json`, ...). Reused by scripts.command — not invoked directly by the user. |
| `karavi/karavi.temp.logs` | **Temporary** local logs and captured run output. Gitignored. Cleared by `clean` (Section 2). |
| `karavi/karavi.temp.status` | **Temporary** execution/deploy status reports (HTML/JSON), e.g. `Deploy_Summary.html`, `BrowserCheck.html`. Gitignored. Cleared by `clean`. |
| `karavi/karavi.temp.deploy` | **Temporary** release output staged, ready to deploy. Gitignored. Cleared by `clean --deep`. |
| `karavi/karavi.temp.build` | **Temporary** build output. Gitignored. Cleared by `clean --deep`. |

> The four `karavi.temp.*` folders are the only deletable ones. Every other core
> folder is preserved.

## Optional folders (only with `--full`, and only if the project needs them)

| Folder | Purpose |
|---|---|
| `karavi/karavi.assets/{brand,icons,screenshots,templates}` | Static assets for docs/UI. |
| `karavi/karavi.mockup` | Mockups / UI reference images and files. |
| `karavi/karavi.doc` | General technical/operator documentation for this project (planning, technical & operator). |
| `karavi/karavi.BusinessModel.Doc` | Business model and commercial documentation. |
| `karavi/karavi.Customer.doc` | Customer / planning documentation (before execution). |
| `karavi/karavi.SociaMediaContent` | Social-media content (optional). |

Create optional folders only when the project actually uses them — do not create
every optional folder blindly.

## Recurring usage (دستور بکارگیری همیشگی)

The karavi tree must exist in **every** repository the operator touches. Make
this a standing habit:

1. On repo (re)initialization, when `karavi/` is missing or incomplete, run:

   ```
   /karavi-folder create --full
   ```

   Persian: `/karavi-folder ساخت --کامل`.

2. Direct script (from the repo root, if the skill's script is copied into the
   repo under `karavi/karavi.scripts.command/`):

   ```powershell
   & "karavi/karavi.scripts.command/karavi-folder.create.ps1" -Full
   ```

   Or on a specific target:

   ```powershell
   & "karavi/karavi.scripts.command/karavi-folder.create.ps1" -RepoRoot D:\path\to\repo
   ```

3. The command is **idempotent**: it creates only missing folders and never
   deletes or overwrites. Run it any time the structure is doubtful.

> Reference this skill in each repo's operating rules (e.g. a `karavi`
> README or `.cursor/rules`) so every agent re-creates the structure on demand.

## `.gitkeep` convention

Add a `.gitkeep` inside output/temp folders (`karavi.temp.*/`,
`karavi.history/`, `karavi.assets/**`) so empty directories are tracked, and
drop `.gitkeep` once real content exists.

## `.gitignore` wiring

Append a `# --- karavi ---` block to the repo's `.gitignore`:

```
karavi/karavi.temp.logs/
karavi/karavi.temp.status/
karavi/karavi.temp.deploy/
karavi/karavi.temp.build/
karavi/karavi.deploy.config/Deploy_FTP.info
karavi/karavi.deploy.config/Deploy_TestUsers.info
karavi/karavi.deploy.config/deploy.secrets.json
```

Never commit local-only config overlays (`Deploy_FTP.info`,
`appsettings.Development.json`, `appsettings.Local.json`).

**Security / git-clean:** never commit secrets or local-only config. The
`karavi.temp.*` folders stay gitignored, and before commit/done `git status`
must show no generated or temporary files under `karavi/`.

## Per-project config to wire after creation

| Config | Where |
|---|---|
| Hosts, URLs, ports | `karavi.deploy.config/production-hosts.json`, `deploy-targets.json`, `local-dev-ports.json` |
| Agent rule paths | `karavi.scripts.tools/workspace.paths.ps1`, `.cursor/rules/` |
| Verify gates | `karavi.scripts.tools/verify-gates.json` |

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