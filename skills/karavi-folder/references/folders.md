# Section 1 — Initialize, Scaffold & Migrate the `karavi/` Workspace

Mechanics behind `/karavi-folder init` and `/karavi-folder create`.

---

## Purpose & Scope

`karavi/` is the single focal point in **every** repository for the operator and AI agents:
planning, technical & business documentation, history, scripts, tools, logs, status, build, and deploy.

### Non-Negotiable Defaults
1. **Full Structure by Default:** Every initialization creates all **21 canonical folders & subfolders** (Core + Extended). Core-only is available only if explicitly requested (`--core`).
2. **Automatic Migration & Renaming:** If the repository already contains folders under `karavi/` with legacy or variant names, they are **automatically detected, renamed, and relocated** into the new standard structure without deleting or losing any files.
3. **Local to Current Repo:** Freshly scaffolded inside the current repository root. Never imports from or copies another project.

---

## Canonical Folder Structure (Full — Default: 21 Folders & Subfolders)
| # | Canonical Path | Description |
|---|---|---|
| 1 | `karavi/karavi.plans.prompt` | Prompts and Agent plans only; never canonical project rules for **all** assistants (Cursor, Claude, Antigravity, OpenCode, Codex, Cline) in one place. Store `Karavi.NNN.plan.md` flat here. |
| 2 | `karavi/karavi.history` | Change history of the project. One file per day: `history.YYYY-MM-DD.md`. Never deleted. |
| 3 | `karavi/karavi.deploy.config` | Deploy & FTP configuration for this repo: `production-hosts.json`, `deploy-targets.json`, `local-dev-ports.json`, `Deploy_FTP.info`, secrets. Public JSON tracked; real credentials gitignored. |
| 4 | `karavi/karavi.scripts.command` | Operator and agent **command entry points** (deploy, run all, clean, history.write, ...). |
| 5 | `karavi/karavi.scripts.tools` | Tooling **helpers** (verify structure, path resolvers, build pieces, `verify-gates.json`, ...). Reused by scripts.command. |
| 6 | `karavi/karavi.temp.logs` | **Temporary** local logs and captured run output (gitignored). Cleared by `clean`. |
| 7 | `karavi/karavi.temp.status` | **Temporary** execution/deploy status reports (HTML/JSON) (gitignored). Cleared by `clean`. |
| 8 | `karavi/karavi.temp.deploy` | **Temporary** release output staged, ready to deploy (gitignored). Cleared by `clean --deep`. |
| 9 | `karavi/karavi.temp.build` | **Temporary** build output (gitignored). Cleared by `clean --deep`. |
| 10 | `karavi/karavi.assets/brand` | Brand assets, logos, color palettes, and styling guidelines. |
| 11 | `karavi/karavi.assets/icons` | Project icon sets, SVGs, and favicon assets. |
| 12 | `karavi/karavi.assets/screenshots` | UI screenshots, design previews, and workflow captures. |
| 13 | `karavi/karavi.assets/templates` | Document and code templates for the workspace. |
| 14 | `karavi/karavi.mockup` | UI mockups, wireframes, and design reference files. |
| 15 | `karavi/karavi.doc` | General technical, architectural, and operator documentation. |
| 16 | `karavi/karavi.BusinessModel.Doc` | Business model, revenue plans, commercial strategy, and requirements. |
| 17 | `karavi/karavi.Customer.doc` | Customer personas, user research, feedback, and pre-execution planning. |
| 18 | `karavi/karavi.OnlineContent/SociaMediaContent` | Social media posts, banners, marketing materials, and campaign content. |
| 19 | `karavi/karavi.OnlineContent/WordPressContent` | WordPress posts, pages, and website content. |
| 20 | `karavi/karavi.OnlineContent/LinkedinConetnt` | LinkedIn articles, posts, and professional networking content. |
| 21 | `karavi/karavi.Rules` | Sole canonical, versioned source of all project-specific rules; required in Full and Core. |

---

## Legacy Folder Migration & Renaming (مهاجرت و تغییر نام فولدرها)

When `init` or `create` runs, the AI agent and the scripts scan `karavi/` for any legacy/variant directories and relocate them to the standard canonical paths.

### Migration Mapping Table

| Existing / Legacy Folder Name in `karavi/` | Target Canonical Folder |
|---|---|
| `rules`, `rule`, `project-rules`, `agent-rules`, `coding-rules`, `karavi.rules`, `karavi.project.rules` | `karavi/karavi.Rules` |
| `plans`, `prompt`, `prompts`, `karavi.plans`, `karavi.prompt`, `karavi.prompts`, `plans.prompt`, `prompts.plan` | `karavi/karavi.plans.prompt` |
| `history`, `histories`, `karavi.histories`, `change-history`, `log-history` | `karavi/karavi.history` |
| `deploy`, `config`, `deploy.config`, `karavi.deploy`, `karavi.config`, `deploy-config` | `karavi/karavi.deploy.config` |
| `commands`, `scripts.command`, `karavi.commands`, `karavi.scripts.command`, `scripts/command` | `karavi/karavi.scripts.command` |
| `tools`, `scripts.tools`, `karavi.tools`, `karavi.scripts.tools`, `scripts/tools` | `karavi/karavi.scripts.tools` |
| `scripts` (general/unsplit) | Contents moved into `karavi/karavi.scripts.command` & `karavi/karavi.scripts.tools` |
| `logs`, `log`, `temp.logs`, `karavi.logs`, `temp/logs` | `karavi/karavi.temp.logs` |
| `status`, `temp.status`, `karavi.status`, `temp/status` | `karavi/karavi.temp.status` |
| `temp.deploy`, `karavi.deploy.temp`, `temp/deploy` | `karavi/karavi.temp.deploy` |
| `build`, `temp.build`, `karavi.build`, `temp/build` | `karavi/karavi.temp.build` |
| `assets`, `karavi.asset`, `assets/{brand,icons,...}` | `karavi/karavi.assets/{brand,icons,screenshots,templates}` |
| `mockup`, `mockups`, `karavi.mockups`, `ui-mockups` | `karavi/karavi.mockup` |
| `doc`, `docs`, `karavi.docs`, `documentation`, `karavi.documentation` | `karavi/karavi.doc` |
| `BusinessModel`, `business`, `businessmodel`, `karavi.business`, `karavi.businessmodel`, `BusinessModel.Doc` | `karavi/karavi.BusinessModel.Doc` |
| `customer`, `customers`, `karavi.customer`, `Customer`, `Customer.doc` | `karavi/karavi.Customer.doc` |
| `social`, `socialmedia`, `karavi.social`, `karavi.socialmedia`, `SocialMediaContent`, `karavi.SociaMediaContent`, `SociaMediaContent` | `karavi/karavi.OnlineContent/SociaMediaContent` |
| `wordpress`, `WordPressContent`, `wordpresscontent` | `karavi/karavi.OnlineContent/WordPressContent` |
| `linkedin`, `LinkedinContent`, `LinkedinConetnt`, `linkedincontent` | `karavi/karavi.OnlineContent/LinkedinConetnt` |

---

## AI Execution Procedure (گام‌های اجرایی هوش مصنوعی)

When executing `/karavi-folder init` or `/karavi-folder create`:

1. **Locate Repo Root:**
   Find the root containing `.git` or `karavi/`.
2. **Scan Existing `karavi/`:**
   Inspect all child directories under `karavi/`.
3. **Execute Migration:**
   - For each legacy directory found, check if the canonical target exists.
   - If the canonical target does not exist, rename/move the directory directly.
   - If the canonical target already exists, move each item inside the legacy directory into the canonical target, preserving all files. If a filename collision occurs, rename the incoming file with a `.legacy-*` suffix rather than overwriting.
   - Remove the empty legacy folder once emptied.
4. **Scaffold Missing Folders (Full by default):**
   Ensure all 21 canonical folders/subfolders exist. Create any folder that is missing.
5. **Place Sentinel `.gitkeep`:**
   Add `.gitkeep` inside empty tracking/temp folders so git tracks directory structure.
6. **Wire `.gitignore`:**
   Ensure the `# --- karavi ---` block is present in the repo's `.gitignore`.
7. **Report:**
   Output migrated folders, newly created paths, and every collision with source and actual `.legacy-*` destination. Label previews as planned, not completed.

---

## `.gitignore` Specification

Every karavi workspace must have this block in the root `.gitignore`:

```gitignore
# --- karavi ---
karavi/karavi.temp.logs/
karavi/karavi.temp.status/
karavi/karavi.temp.deploy/
karavi/karavi.temp.build/
karavi/karavi.deploy.config/Deploy_FTP.info
karavi/karavi.deploy.config/Deploy_TestUsers.info
karavi/karavi.deploy.config/deploy.secrets.json
```

---

## Verification Checklist

- [ ] All 21 canonical folders & subfolders exist under `karavi/`.
- [ ] `karavi/karavi.Rules` exists with exact canonical spelling (also in Core).
- [ ] All existing project-specific agent and coding rules reside there; all other project rules do too. If no rules exist yet, record that fact instead of inventing policy.
- [ ] Every new rule was written directly in `karavi/karavi.Rules`; none was created elsewhere, including temporary/ad-hoc files.
- [ ] `karavi.plans.prompt` contains prompts/plans only and is not used as a project-rule source.
- [ ] Root `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and tool-specific rule files are loaders/integrations with valid canonical references, not independent sources of truth.
- [ ] Canonical rules are version-control eligible (not ignored); existing tracked rules retain their content/history through a reviewable move. Do not stage or commit without explicit authorization.
- [ ] Every collision is reported with source and unused `.legacy-*` destination; original bytes are preserved, including nested and file/directory collisions.
- [ ] A second run changes neither file inventory nor content hashes and creates no duplicate rules/loaders.
- [ ] No old/legacy unmapped folders remain in `karavi/`.
- [ ] Existing history, documentation, prompts, and configs have been migrated intact.
- [ ] `.gitignore` contains the `# --- karavi ---` block.
- [ ] `git status` is clean of temporary/generated files under `karavi/`.

## Project-rule consolidation (mandatory agent procedure)

The Full count is the 21 listed canonical paths, not a recursive directory count:
the grouping parents `karavi.assets` and `karavi.OnlineContent` are not extra entries.
Core contains 10 paths, including `karavi.Rules`. The PowerShell scripts handle
folder creation and alias migration; they cannot decide which prose is normative.
The invoking agent must complete the following content review before reporting success.

1. Inventory project-specific rules in `karavi/`, root agent files, and active
   tool integrations. Include rule content embedded in prompts/plans and mixed
   documents, not just files whose name contains `rules`. Preserve scope,
   precedence, tool applicability, links, and existing text while consolidating.
2. Move whole rule documents into `karavi/karavi.Rules`; extract normative sections
   from mixed documents into a canonical file there and replace those sections
   with a relative reference. Keep actual prompts/plans in `karavi.plans.prompt`.
   Architecture/docs elsewhere may explain decisions but must reference canonical
   requirements instead of defining a second rule authority. New rules belong
   directly in `karavi.Rules`, never in a staging/temp rule file.
3. For `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and tool rule files, preserve required
   integration syntax/frontmatter and discovery scope, move project-policy text
   to canonical files, and retain only loader instructions or supported imports.
   Do not replace unrelated content, global user instructions, or generated
   integrations by hand; update their project-owned source/generator instead.
   If that source is unavailable, report the unresolved loader explicitly and
   do not claim the checklist passed. Follow referenced rules according to each
   tool's supported loading mechanism. Example root loader:

   ```markdown
   Project-specific instructions are maintained in `karavi/karavi.Rules/`.
   Read and follow the applicable rules there before changing this project.
   ```

4. Never overwrite an existing destination during migration. Merge directories
   recursively; for file/file or file/directory collisions, preserve the incoming
   item under the first unused `.legacy-N` name and record the original and final
   paths. Check suffix availability, including existing `.legacy-*` entries.
   Preserve differing rules and explicitly resolve their precedence in the
   canonical source; a legacy copy is evidence, not a competing authority.
   Reuse an already consolidated identical rule and its reference on reruns;
   do not repeatedly append imports, duplicate text, or allocate legacy copies.
5. Normalize `karavi.rules` to `karavi.Rules` safely on case-insensitive systems;
   when both directories exist on case-sensitive systems, merge without loss.
   Refuse linked/out-of-repository migration paths. An existing file occupying
   the canonical directory path must be reported rather than replaced.
6. Verify Git ignore rules, including parent patterns and tool ignores. Make
   narrowly scoped exceptions if required so canonical project rules and their
   directory can be versioned. Empty canonical rules directories retain a
   `.gitkeep`. Versioned means maintained as repository source; this skill does
   not authorize `git add`, commit, or push. Never store secrets in rules.
7. Compare pre/post inventories and content, verify loader targets, and rerun
   initialization to establish idempotency. Report every collision and all
   checklist results. `-WhatIf` reports planned changes only; `-NoMigrate` skips
   alias moves but still creates `karavi.Rules` and does not waive outstanding
   content verification. Never describe these partial runs as full acceptance.
