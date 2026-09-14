---
name: karavi-folder
description: >
  Scaffold the standard `karavi/` workspace tree in a repository and safely
  remove temporary/interim data (logs, status, build/deploy output, caches, temp
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
  version: "0.2.0"
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
| 2 | Delete temporary info — temp folders, caches, logs | `references/cleanup.md` |

## Non-negotiable invariants

- **No cross-project import.** Create/clean **inside the current repo only**;
  never copy `karavi/` from another repository (global Karavi rule). Using the
  canonical `starter-kit` **template** is allowed; pasting another repo's lived-in
  files is not.
- **Preserve:** source code, config without secrets, `karavi.history/history.*.md`,
  and README files. These are never deleted.
- **Deletable:** the four `karavi.temp.*` output folders and their contents —
  logs, status reports, build output, deploy output — plus temp scripts
  (`_tmp-*`, `_fix-*`), process junk (`*.pid`, token dumps, stamp JSONs), and
  caches (`bin/`, `obj/`, `.dart_tool/`, `node_modules/.cache`, `.next/`).
- **Git-clean:** the four `karavi.temp.*` folders are gitignored; their contents
  are never committed, and `git status` stays clean of temp/generated files
  under `karavi/`.
- **Idempotent:** running twice yields the same state.
- **Dry-run first:** for anything destructive, run `--what-if` and show the plan
  unless the user explicitly approved deletion.

## Section 1 — Create main folders

Creates the canonical `karavi/` skeleton inside the repo root. Two scopes:

- **Core (default)** — every karavi workspace has these **9 folders**:
  `karavi.plans.prompt`, `karavi.history`, `karavi.deploy.config`,
  `karavi.scripts.command`, `karavi.scripts.tools`, `karavi.temp.logs`,
  `karavi.temp.status`, `karavi.temp.deploy`, `karavi.temp.build`.
- **Full (`--full`)** — adds optional folders only when the project uses them:
  `karavi.assets/{brand,icons,screenshots,templates}`, `karavi.mockup`,
  `karavi.doc`, `karavi.BusinessModel.Doc`, `karavi.Customer.doc`,
  `karavi.SociaMediaContent`.

Complete per-folder descriptions and the recurring usage command are in
`references/folders.md`.

## Section 2 — Delete temporary info

The four `karavi.temp.*` folders hold temporary data. Two levels:

- **Logs (default)** — clear `karavi.temp.logs/` and `karavi.temp.status/`
  (zero or old run-stamp junk: `*.out.txt`, `*.err.txt`, `_tmp-*`, `_fix-*`,
  `*.pid`, token/state dumps, old HTML reports).
- **Deep (`--deep`)** — everything above **plus** `karavi.temp.deploy/`,
  `karavi.temp.build/`, repo-level output (`publish/`, `artifacts/`,
  `.run-logs/`), and per-stack caches (`**/bin/`, `**/obj/`, `**/.dart_tool/`,
  `.next/`, `dist/`, `out/`).

The full safe/unsafe matrix is in `references/cleanup.md`.

## Always-use command (دستور بکارگیری همیشگی)

Keep the karavi structure present in **every** repository. This is the standing
command to run when a repo is (re)initialized or the tree is missing:

    /karavi-folder create --full

Equivalent direct call (PowerShell, from the repo root after installing the skill):

    & "karavi/karavi.scripts.command/karavi-folder.create.ps1" -Full

Persian: `/karavi-folder ساخت --کامل`. Re-running is always safe and idempotent —
it never deletes or overwrites existing content. See `references/folders.md`
→ "Recurring usage" for the full habit.

## Invocation

| Command | What it runs |
|---|---|
| `/karavi-folder create` | Section 1 — core skeleton (9 folders) |
| `/karavi-folder create --full` | Section 1 — core + optional folders |
| `/karavi-folder clean` | Section 2 — clear temp.logs + temp.status |
| `/karavi-folder clean --deep` | Section 2 — deep cleanup (temp.deploy + temp.build + caches) |
| `/karavi-folder clean --what-if` | Dry-run preview (deletes nothing) |
| `/karavi-folder` (bare) | Ask which section, then run it |
| `/karavi-folder help` | Show the complete user guide (`HELP.md`) |

For the full user guide (folder catalog, walkthrough, troubleshooting, FAQ), run
`/karavi-folder help` or open [`HELP.md`](./HELP.md).

Persian: `/karavi-folder ساخت` (ایجاد فولدر), `/karavi-folder پاکسازی`
(پاک کردن اطلاعات موقت؛ با `--عمیق` برای deep).

## Exit codes

| Code | Meaning |
|---|---|
| 0 | Success. |
| 1 | Precondition failed (no repo root found, or a required path could not be created). |
| 2 | User declined the destructive step after the dry-run preview. |
| 3 | Refused: a target path is on the preserve list or resolves outside the repo. |

## Explicitly out of scope

- Creating or importing anything from a project other than the current repo.
- Deleting source, config, history, or README files.
- Multi-project memory (use `skill:karavi-memory`).
- Pushing, committing, or FTP — this skill only touches the local filesystem.