---
name: karavi-folder
description: >
  Use when initializing, creating, migrating, or cleaning the current repository's
  karavi workspace (/karavi-folder init, create, clean). Full defaults to 21
  canonical paths, including karavi/karavi.Rules as the versioned project-rule
  source. Not for general scaffolding or long-term memory.
license: Apache-2.0
metadata:
  author: akaravi
  version: "0.4.0"
  category: workspace-caretaker
  tags: "karavi, folder, init, scaffold, migration, cleanup, logs, cache, workspace, maintenance"
  compatibility: Cross-tool (Cursor, Claude Code, Antigravity, OpenCode, Codex, Cline). Idempotent. Migrates legacy paths safely. Deletes only gitignored/temp paths; never source.
---

# karavi-folder

Initialize, migrate, and maintain the standard `karavi/` workspace tree and keep it clean of
temporary data. Two primary operations:

| Section | Operation | Detail |
|---|---|---|
| 1 | **Initialize & Create main folders** (`init` / `create`) — Full by default + Migrate legacy folders | `references/folders.md` |
| 2 | **Delete temporary info** (`clean`) — temp folders, caches, logs | `references/cleanup.md` |

---

## AI Directive (دستورالعمل هوش مصنوعی — نظارت شدید)

When the user requests `/karavi-folder init`, `/karavi-folder create`, or asks to set up/rebuild the `karavi/` workspace:

1. **Default to the FULL structure (21 canonical folders/subfolders):**
   Unless the user explicitly specifies `--core`, always scaffold all core and extended folders.
2. **Detect & Migrate Existing/Legacy Folders:**
   Actively scan `karavi/` for any existing folders or legacy naming/locations (e.g. `doc`, `docs`, `prompts`, `plans`, `history`, `deploy`, `scripts`, `tools`, `logs`, `status`, `build`, `assets`, `mockup`, `business`, `customer`, `social`, `karavi.SociaMediaContent`, `OnlineContent`, etc.).
3. **Rename & Relocate to Canonical Names:**
   Rename and move existing legacy folders and their contents into the new canonical standard locations without deleting or losing any content or history.
4. **Wire Gitignore & Gitkeep:**
   Ensure `.gitignore` contains the `# --- karavi ---` block and sentinel `.gitkeep` files exist in empty/temp folders.

---

## Mandatory project-rule ownership

Every `init` and `create`, including `--core`, MUST create `karavi/karavi.Rules`.
It is the **only canonical, versioned source** of all project-specific rules:
agent behavior, coding, architecture and system design, workflow, testing,
quality and acceptance gates, security, resilience, observability, UI/UX,
i18n, accessibility, contracts, standards, and project constraints.
Every new rule for agents or the development team MUST be written directly
there. Scattered, temporary, or ad-hoc rule sources are prohibited.

`karavi.plans.prompt` holds prompts and plans only, never project-rule authority.
Root `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and tool-specific rule files may remain
only as loaders/integration entrypoints that reference and obey canonical rules;
they MUST NOT define independent or contradictory project policy.

For `init`/`create`, read and execute the **Project-rule consolidation** procedure
and the entire verification checklist in [references/folders.md](references/folders.md).
The scripts automate folders and named legacy migrations; the agent MUST inspect
rule content, consolidate existing rules, repair loaders, and verify versioning.
Script success alone does not complete this skill. Preserve canonical rules during
cleanup. Repeating initialization must neither lose files nor duplicate rules.

---

## Non-negotiable invariants

- **Default is Full structure:** All 21 canonical folders/subfolders are scaffolded by default.
- **Safe migration & renaming:** Existing folders and files under `karavi/` are detected, renamed, and migrated into the canonical structure without data loss.
- **No cross-project import:** Create/clean **inside the current repo only**; never copy `karavi/` from another repository.
- **Preserve whitelist:** Source code, config without secrets, `karavi.history/history.*.md`, and README files are never deleted.
- **Deletable:** Only the four `karavi.temp.*` output folders and their contents (logs, status reports, build output, deploy output), temp scripts, process junk, and caches (`bin/`, `obj/`, `.dart_tool/`, `node_modules/.cache`, `.next/`).
- **Git-clean:** The four `karavi.temp.*` folders and local secrets are gitignored.
- **Idempotent:** Running twice yields the same state.
- **Dry-run available:** Supports `--what-if` for safe previews.

---

## Section 1 — Initialize & Create main folders

Scaffolds the canonical `karavi/` skeleton inside the repo root and migrates any existing legacy folders.

### Canonical Folder Structure (Full — Default: 21 Folders & Subfolders)

| Folder | Purpose |
|---|---|
| `karavi.Rules` | Sole canonical, versioned source of all project-specific rules |
| `karavi.plans.prompt` | Prompts and Agent plans only; never canonical project rules for all assistants |
| `karavi.history` | Change history of the project (`history.YYYY-MM-DD.md`) |
| `karavi.deploy.config` | Deploy & FTP configuration for this repo |
| `karavi.scripts.command` | Operator/agent commands (deploy, run all, clean, history.write, ...) |
| `karavi.scripts.tools` | Tooling helpers (verify structure, path resolvers, build pieces, ...) |
| `karavi.temp.logs` | Temporary local logs and captured run output (gitignored) |
| `karavi.temp.status` | Temporary execution/deploy status reports (HTML/JSON) (gitignored) |
| `karavi.temp.deploy` | Temporary release output staged, ready to deploy (gitignored) |
| `karavi.temp.build` | Temporary build output (gitignored) |
| `karavi.assets/brand` | Brand assets and logos |
| `karavi.assets/icons` | Icon assets |
| `karavi.assets/screenshots` | Screenshot assets |
| `karavi.assets/templates` | Document and UI templates |
| `karavi.mockup` | Mockups / UI reference images and design files |
| `karavi.doc` | General technical and operator documentation |
| `karavi.BusinessModel.Doc` | Business model and commercial documentation |
| `karavi.Customer.doc` | Customer and pre-execution planning documentation |
| `karavi.OnlineContent/SociaMediaContent` | Social media content and campaign assets |
| `karavi.OnlineContent/WordPressContent` | WordPress posts, pages, and website content |
| `karavi.OnlineContent/LinkedinConetnt` | LinkedIn articles, posts, and professional content |
Complete per-folder descriptions, legacy migration mapping, and step-by-step rules are in `references/folders.md`.

---

## Section 2 — Delete temporary info

The four `karavi.temp.*` folders hold temporary data. Two levels:

- **Logs (default)** — clear `karavi.temp.logs/` and `karavi.temp.status/` (zero or old run-stamp junk: `*.out.txt`, `*.err.txt`, `_tmp-*`, `_fix-*`, `*.pid`, token/state dumps, old HTML reports).
- **Deep (`--deep`)** — everything above **plus** `karavi.temp.deploy/`, `karavi.temp.build/`, repo-level output (`publish/`, `artifacts/`, `.run-logs/`), and per-stack caches (`**/bin/`, `**/obj/`, `**/.dart_tool/`, `.next/`, `dist/`, `out/`).

The full safe/unsafe matrix is in `references/cleanup.md`.

---

## Always-use command (دستور بکارگیری همیشگی)

Keep the karavi structure present and up to date in **every** repository. Standing command:

    /karavi-folder init

Equivalent direct calls (PowerShell, from repo root):

    & "karavi/karavi.scripts.command/karavi-folder.init.ps1"
    & "karavi/karavi.scripts.command/karavi-folder.create.ps1"

Persian: `/karavi-folder شروع` یا `/karavi-folder ایجاد و بازسازی`. Re-running is always safe, idempotent, and automatically repairs/migrates legacy structures.

---

## Invocation

| Command | What it runs |
|---|---|
| `/karavi-folder init` | **Section 1 — Full initialization (21 folders/subfolders) + migrate legacy folders** (Default) |
| `/karavi-folder init --core` | Section 1 — Core initialization (10 folders) + migrate legacy folders |
| `/karavi-folder create` | Section 1 — Full structure creation & migration (Default) |
| `/karavi-folder create --core` | Section 1 — Core skeleton only |
| `/karavi-folder clean` | Section 2 — Clear temp.logs + temp.status |
| `/karavi-folder clean --deep` | Section 2 — Deep cleanup (temp.deploy + temp.build + caches) |
| `/karavi-folder clean --what-if` | Dry-run preview (deletes nothing) |
| `/karavi-folder` (bare) | Ask which section (init/clean), then run it |
| `/karavi-folder help` | Show the complete user guide (`HELP.md`) |

Persian:
```text
/karavi-folder شروع               # مقداردهی اولیه کامل و مهاجرت فولدرها
/karavi-folder ساخت               # ساخت اسکلت کامل (پیش‌فرض Full)
/karavi-folder پاکسازی             # پاک کردن لاگ‌ها و وضعیت موقت
/karavi-folder پاکسازی --عمیق      # پاک‌سازی کامل تمام tempها و کش‌ها
```

---

## Exit codes

| Code | Meaning |
|---|---|
| 0 | Success. |
| 1 | Precondition failed (no repo root found, or a required path could not be created). |
| 2 | User declined the destructive step after the dry-run preview. |
| 3 | Refused: a target path is on the preserve list or resolves outside the repo. |

---

## Explicitly out of scope

- Creating or importing anything from a project other than the current repo.
- Deleting source, config, history, or README files during migration or cleanup.
- Multi-project memory (use `skill:karavi-memory`).
- Pushing, committing, or FTP — this skill only touches the local filesystem.
