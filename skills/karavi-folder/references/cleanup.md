# Section 2 — Delete temporary info (caches, logs, artifacts)

Mechanics behind `/karavi-folder clean`. Loaded only when this section runs.

## Purpose

Runs, builds, deploy checks, and diagnostics litter the repo with temporary
files — capture logs, `_tmp-*`/`_fix-*` scripts, dumps, and build/publish
artifacts. This section removes them safely while **never touching source,
config, history, or READMEs**.

## Safety rules (never violated)

- **Preserve whitelist (never delete):**
  - `karavi/karavi.history/` (all `history.*.md`)
  - `karavi/karavi.deploy.config/`, `karavi/karavi.build.config/`, `karavi/karavi.publish.config/`
  - `karavi/karavi.scripts/` (and `scripts.command`, `scripts.tools`)
  - `karavi/karavi.doc/`, `karavi/karavi.assets/`, `karavi/karavi.plans.prompt/`
  - All `README.md`, all `.gitkeep`, all committed source.
- **Travel guard:** resolve every deletion path and refuse anything that
  resolves outside the repo root, or to a preserved path, with exit code 3.
- **Dry-run first:** `--what-if` lists every target and deletes nothing. The
  agent shows this plan and proceeds to real deletion only with explicit
  approval (or when the user already approved on the invocation).

## Logs-level cleanup (default)

Targets temporary junk that accumulates in `karavi.logs/` and run-stamp files.
Delete files matching:

- `*.out.txt`, `*.err.txt` (captured run output)
- `_tmp-*.ps1`, `_tmp-*.py`, `_fix-*.py` (one-off polish/temp scripts)
- `*launch.ps1`, `*loop.ps1`, `*run.ps1` (throwaway runner scripts)
- `*.pid` (process liveness markers)
- Token/state dumps: `.browser-check-state.json`, `*.token.txt`,
  `http-*.json`, `*-state.json`, `*-smoke-*.json`
- Old stamp/debug files: `*-2026*.json`, `*-2026*.txt` where clearly transient

**Preserve inside `karavi.logs/`:** any tracked/`.gitkeep` sentinel, plus files
named like a real audit record (e.g. a `browser-check-YYYYMMDD-HHMMSS/` folder if
it is meant to be kept — check before deleting folders).

## Deep cleanup (`--deep`)

Everything in Logs **plus** build/publish artifacts and caches:

- `karavi/karavi.build.files/`, `karavi/karavi.deploy.files/`,
  `karavi/karavi.publish.files/`
- Repo-level output: `publish/`, `artifacts/`, `.run-logs/`
- Generated HTML reports: `LastRunInfo.html`, `Deploy_Summary.html`
- Per-stack caches: `**/bin/`, `**/obj/`, `**/.dart_tool/`, `.next/`,
  `dist/`, `out/`, `node_modules/.cache/`

## Honor `clean-manifest.json` when present

`karavi.build.config/clean-manifest.json` may already define repo-specific paths
(`pathsRelativeToRepoRoot`, `deepExtra`, `preserve`). When present, merge it into
the above rule set — its `preserve` entries extend the whitelist.

## Per-stack cache notes

| Stack | Cache/build dirs to clean (deep) |
|---|---|
| .NET | `**/bin/`, `**/obj/` |
| Dart/Flutter | `**/.dart_tool/`, `**/build/` |
| Next.js / Node | `.next/`, `node_modules/.cache/`, `dist/`, `out/` |
| Vite / web | `dist/`, `out/` |

Never delete `node_modules/` itself, package-lock/yarn.lock, or committed source.

## Procedure

1. Resolve repo root (same as Section 1).
2. Load `clean-manifest.json` if present.
3. Build the target set for the requested level (Logs or Deep).
4. Generate a `--what-if` plan; remove any preserved/out-of-root targets.
5. Show the plan; require explicit approval before real deletion (unless
   pre-approved).
6. Execute deletion with `Remove-Item -Recurse -Force`, skipping with
   `-ErrorAction SilentlyContinue` on locked files.
7. Report counts: `X files, Y dirs removed`.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | Cleanup complete. |
| 1 | Repo root not found, or clean-manifest unreadable. |
| 2 | User declined after the dry-run preview. |
| 3 | A target was on the preserve list / resolved outside the repo — refused. |
