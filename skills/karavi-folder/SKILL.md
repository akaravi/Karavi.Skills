---
name: karavi-folder
description: >
  Scaffold the standard `karavi/` workspace tree in a repository and safely
  remove temporary/interim data (logs, build/publish artifacts, caches, temp
  scripts) while preserving source, config, history, and READMEs.
  A two-section caretaker skill: (1) create the main karavi folders, (2) delete
  temporary files like caches and logs.
  TRIGGER when: user says "/karavi-folder", "karavi folder",
  "ایجاد فولدرهای اصلی karavi", "ساختار karavi را بساز", "درست کردن پوشه karavi",
  "پاکسازی karavi", "حذف اطلاعات موقت", "پاک کردن لاگ‌ها", "پاک کن کش",
  "clean karavi logs/cache", "clean karavi", or asks for the karavi skeleton
  to be created or tidied.
  DO NOT TRIGGER when: the user wants stored long-term memory (use skill:karavi-memory)
  or general (non-karavi) project scaffolding.
license: Apache-2.0
metadata:
  author: akaravi
  version: "0.1.0"
  category: workspace-caretaker
  tags: "karavi, folder, scaffold, cleanup, logs, cache, workspace, maintenance"
compatibility: Cross-tool (Cursor, Claude Code, Antigravity, OpenCode, Codex, Cline). Idempotent. Deletes only gitignored/temp paths; never source.
---

# karavi-folder

Create and maintain the standard `karavi/` workspace tree and keep it clean of
temporary data. Two independent operations:

| Section | Operation | Detail |
|---|---|---|
| 1 | Create the main `karavi/` folders | `references/folders.md` |
| 2 | Delete temporary info — caches, logs, build/publish artifacts | `references/cleanup.md` |

## Non-negotiable invariants

- **No cross-project import.** Create/clean **inside the current repo only**;
  never copy `karavi/` from another repository (global Karavi rule). Using the
  canonical `starter-kit` **template** is allowed; pasting another repo's lived-in
  files is not.
- **Preserve:** source code, config without secrets, `karavi.history/history.*.md`,
  and README files. These are never deleted.
- **Deletable:** gitignored output (`karavi.logs/`, `karavi.*.files/`), temp
  scripts (`_tmp-*`, `_fix-*`), process junk (`*.pid`, token dumps, stamp JSONs),
  caches (`bin/`, `obj/`, `.dart_tool/`, `node_modules/.cache`, `.next/`), and
  generated HTML reports.
- **Idempotent:** running twice yields the same state.
- **Dry-run first:** for anything destructive, run `--what-if` and show the plan
  unless the user explicitly approved deletion.

## Section 1 — Create main folders

Creates the canonical `karavi/` skeleton inside the repo root. Two scopes:

- **Core (default)** — every karavi workspace has these:
  `karavi.plans.prompt/{cursor,claude,other}`, `karavi.history`, `karavi.logs`,
  `karavi.status`, `karavi.build.config`, `karavi.build.files`,
  `karavi.deploy.config`, `karavi.deploy.files`, `karavi.publish.config`,
  `karavi.publish.files`, `karavi.scripts.command`, `karavi.scripts.tools`.
- **Full (`--full`)** — adds optional folders only when the project needs them:
  `karavi.assets/{brand,icons,screenshots,templates}`, `karavi.doc/workflows`,
  `karavi.BusinessModel.Doc`, `karavi.Customer.doc`, `karavi.plans.mockup`,
  `karavi.scripts`, `karavi.SociaMediaContent`, `karavi.grafana.config`.

Full mechanics (per-folder purpose, `.gitignore` wiring, `.gitkeep`, and
verification) are in `references/folders.md`.

## Section 2 — Delete temporary info

Removes temporary/interim data created by runs, builds, and diagnostics. Two levels:

- **Logs (default)** — the temp junk in `karavi.logs/` and run-stamp files:
  `*.out.txt`, `*.err.txt`, `_tmp-*.ps1`, `_tmp-*.py`, `_fix-*.py`,
  `*launch.ps1`, `*loop.ps1`, `*.pid`, token/state dumps
  (`.browser-check-state.json`, `*.token.txt`, ...), and old stamp JSONs.
- **Deep (`--deep`)** — everything in Logs plus build/publish artifacts and
  caches: `karavi.build.files/`, `karavi.deploy.files/`, `karavi.publish.files/`,
  `publish/`, `artifacts/`, `.run-logs/`, and per-stack caches
  (`**/bin/`, `**/obj/`, `**/.dart_tool/`, `.next/`, `dist/`, `out/`).

Honor an existing `karavi.build.config/clean-manifest.json` when present. The
full safe/unsafe matrix is in `references/cleanup.md`.

## Invocation

| Command | What it runs |
|---|---|
| `/karavi-folder create` | Section 1 — core skeleton |
| `/karavi-folder create --full` | Section 1 — core + optional folders |
| `/karavi-folder clean` | Section 2 — logs-level cleanup |
| `/karavi-folder clean --deep` | Section 2 — deep cleanup (artifacts + caches) |
| `/karavi-folder clean --what-if` | Dry-run preview (deletes nothing) |
| `/karavi-folder` (bare) | Ask which section, then run it |

Persian: `/karavi-folder ساخت` (ایجاد فولدر), `/karavi-folder پاکسازی`
(پاک کردن اطلاعات موقت؛ با `--عمیق` برای deep).

## Exit codes

| Code | Meaning |
|---|---|
| 0 | Success. |
| 1 | Precondition failed (no repo root found, or a required path/manifest is missing). |
| 2 | User declined the destructive step after the dry-run preview. |
| 3 | Refused: a target path is on the preserve list or resolves outside the repo. |

## Explicitly out of scope

- Creating or importing anything from a project other than the current repo.
- Deleting source, config, history, or README files.
- Multi-project memory (use `skill:karavi-memory`).
- Pushing, committing, or FTP — this skill only touches the local filesystem.