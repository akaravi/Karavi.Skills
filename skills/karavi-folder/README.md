# karavi-folder

Pipeline / caretaker skill that initializes, migrates, and maintains the standard
**`karavi/` workspace** in a repository.

It performs two primary operations:

1. **Initialize & Create main folders** (`init` / `create`) — Scaffold the canonical
   `karavi/` tree (**Full by default: 21 folders & subfolders**) and automatically **detect, rename,
   and migrate** any existing or legacy folders inside `karavi/` to the new standard.
2. **Delete temporary info** (`clean`) — Remove temporary logs, status reports, build/deploy
   output, and stack caches while strictly preserving source, history, and configs.

> **This is a pipeline skill, not a reference skill.** Invoke it as
> `/karavi-folder init` when you want the assistant to initialize or migrate the `karavi/`
> folder in the *current* repository.

---

## Canonical Folders (Full Structure by Default — 21 Folders & Subfolders)

| Folder | Purpose |
|---|---|
| `karavi.Rules` | Sole canonical, versioned source of all project-specific rules |
| `karavi.plans.prompt` | Prompts and plans only; never canonical project rules |
| `karavi.history` | Daily change history (`history.YYYY-MM-DD.md`) |
| `karavi.deploy.config` | Deploy & FTP configuration for this repository |
| `karavi.scripts.command` | Operator/agent commands (deploy, run all, clean, ...) |
| `karavi.scripts.tools` | Tooling helpers (verify gates, paths, ...) |
| `karavi.temp.logs` | Temporary local logs (gitignored) |
| `karavi.temp.status` | Temporary status reports (gitignored) |
| `karavi.temp.deploy` | Temporary release staging output (gitignored) |
| `karavi.temp.build` | Temporary build output (gitignored) |
| `karavi.assets/{brand,icons,screenshots,templates}` | Brand assets, icons, screenshots, and templates |
| `karavi.mockup` | Mockups and design reference files |
| `karavi.doc` | Technical, architectural, and operator docs |
| `karavi.BusinessModel.Doc` | Business model and commercial documentation |
| `karavi.Customer.doc` | Customer feedback and pre-execution planning |
| `karavi.OnlineContent/SociaMediaContent` | Social media content and campaign assets |
| `karavi.OnlineContent/WordPressContent` | WordPress posts, pages, and website content |
| `karavi.OnlineContent/LinkedinConetnt` | LinkedIn articles, posts, and professional networking content |


## Mandatory artifact placement

All agents and tools MUST store project artifacts in their matching canonical
`karavi/` folder. Documentation, plans, prompts, reports, notes, rules, history,
logs, screenshots, mockups, scripts, tooling, deploy configuration, online content,
and generated output MUST NOT be created at the repository root or in ad-hoc folders
such as `docs/`, `plans/`, `reports/`, `artifacts/`, or `publish/`.

Permitted outside-`karavi/` files are limited to application source, dependency
manifests/lockfiles, required runtime/build configuration, and root tool integration
loaders that only reference `karavi/karavi.Rules`. When classification is ambiguous,
do not invent a destination; use the ownership matrix in
[`references/folders.md`](./references/folders.md).
---

## Legacy Folder Migration

When running `init` or `create`, any existing folders inside `karavi/` with legacy or variant names
(e.g., `docs`, `prompts`, `history`, `deploy`, `scripts/command`, `logs`, `status`, `build`, `assets`,
`mockup`, `business`, `customer`, `social`, `karavi.SociaMediaContent`, `OnlineContent`, `wordpress`, `linkedin`) are **automatically detected, renamed, and relocated**
into the canonical structure. File collisions are preserved under unused
`.legacy-N` names and must be listed in the report; inspect content inventories
instead of treating a successful script exit as proof that migration is complete.

---

## Always-Use Habit

Initialize or update the karavi structure in **every** repository:

```bash
/karavi-folder init
```

Persian: `/karavi-folder شروع` یا `/karavi-folder ایجاد و بازسازی`. Initialization
is intended to be idempotent; verify migration, collision handling, and rule loaders.

---

## Installation

```bash
pnpm dlx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-folder
```
---

Use an agent with access to the current repository and permission for the requested
workspace changes. PowerShell is needed only for the supplied automation helpers.
Do not import another repository's `karavi/` tree. This is not general application
scaffolding, long-term memory, or authorization to deploy or mutate Git.

## Invocation

| Command | What it runs |
|---|---|
| `/karavi-folder init` | Full initialization (21 folders/subfolders) + migrate legacy folders (Default) |
| `/karavi-folder init --core` | Core initialization (10 folders) + migrate legacy folders |
| `/karavi-folder create` | Full structure creation & migration (Default) |
| `/karavi-folder clean` | Remove matching temporary junk in temp.logs + temp.status, not every file |
| `/karavi-folder clean --deep` | Also clear temp.deploy + temp.build + stack caches |
| `/karavi-folder clean --what-if` | Dry-run preview, deletes nothing |

---

## When to Use

- "شروع اولیه ساختار karavi" / "مقداردهی اولیه karavi" → `init`
- "تغییر نام و انتقال فولدرهای قدیمی karavi به ساختار جدید" → `init`
- "ایجاد فولدرهای اصلی karavi" → `init` / `create`
- "پاک کن اطلاعات موقت / لاگ‌ها / کش karavi" → `clean`
- "Initialize standard karavi workspace" → `init`
- "Migrate legacy karavi folders to new standard" → `init`

---

## Safety

The required preservation policy protects source, canonical rules, configuration,
history, documentation, README files and `.gitkeep` sentinels. This policy must be
enforced by the agent; the cleanup helper does not guarantee it recursively.
In deep mode, the helper recursively removes children of temporary build/deploy
directories and repo-level output targets without checking every descendant
against the preserve list. Inspect all descendants before deletion; if a target
contains protected content, do not run the helper against that unsafe target.

Cleanup under `karavi/` is limited by policy to the four temporary folders; deep
mode additionally considers generated repo-level outputs and stack caches listed
in [cleanup.md](references/cleanup.md), never all of `node_modules/`. Resolve
targets inside the current repository and reject preserved or out-of-root paths.

Run `/karavi-folder clean --what-if` first, show the exact target list, and require
explicit deletion approval unless already authorized in the invocation. A dry-run
does not prove that deletion occurred. Default logs/status filtering is
non-recursive; nested prompt run artifacts require the
[`karavi-prompt` purge workflow](../karavi-prompt/README.md).

## Outputs and verification

Initialization creates the requested canonical paths, `.gitkeep` sentinels and the
managed `.gitignore` block, and reports legacy moves and collisions. Automation
does not consolidate rule semantics: the agent must inspect rules, repair loaders
and verify versionability using the
[project-rule procedure](references/folders.md#project-rule-consolidation-mandatory-agent-procedure).
Compare pre/post inventories and content, check all requested paths and loader
targets, and establish idempotency without duplicating rules. A preview or
`-NoMigrate` run is not full migration acceptance.

The cleanup contract calls for removed file/directory counts, but the helper
prints completion and some per-target messages, not aggregate counters. The agent
must collect actual counts independently and inspect skipped or locked targets
before claiming the requested cleanup completed. Its documented exit codes are:

| Code | Cleanup meaning |
|---|---|
| `0` | Cleanup complete |
| `1` | Repository root not found |
| `2` | User declined the preview |
| `3` | Preserved or out-of-repository target refused |

These are the cleanup contract, not generic codes for every script. Consult the
actual helper parameters before direct invocation; chat `--what-if` and `--deep`
are not PowerShell argument spelling.

---

## Reference

- [`HELP.md`](./HELP.md) — complete user guide (Persian/English, FAQ, troubleshooting)
- [`SKILL.md`](./SKILL.md) — entry point / decision core & AI directives
- [`references/folders.md`](./references/folders.md) — Section 1 mechanics & migration map
- [`references/cleanup.md`](./references/cleanup.md) — Section 2 mechanics
- [`scripts/`](./scripts/) — PowerShell helpers (`karavi-folder.init.ps1`, `karavi-folder.create.ps1`, `karavi-folder.clean.ps1`)

---

## License

Apache-2.0

## Project rules are canonical and versioned

`init` and `create` always create `karavi/karavi.Rules`, including Core (10 paths).
All project rules and every new agent/development rule belong directly there:
agent, coding, architecture, design, workflow, testing/quality/acceptance,
security/resilience/observability, UI/UX/i18n/accessibility, contracts and constraints.
Do not create scattered or temporary rule sources. `karavi.plans.prompt` is only
for prompts and plans. Root `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` and tool rule files
are loaders/integrations referencing canonical policy, never independent sources.

All seven aliases (`rules`, `rule`, `project-rules`, `agent-rules`, `coding-rules`,
`karavi.rules`, `karavi.project.rules`) inside `karavi/` migrate to `karavi.Rules`.
Collisions preserve existing files and move incoming content to unused `.legacy-*`
names, listed in the final report. Repeated runs preserve file contents and do not
duplicate rules. The agent must also consolidate rule content and verify loaders;
see the mandatory [procedure and checklist](references/folders.md).
