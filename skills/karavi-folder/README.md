# karavi-folder

Pipeline / caretaker skill that maintains the standard **`karavi/` workspace**
in a repository. It has two sections:

1. **Create main folders** — scaffold the canonical `karavi/` tree.
2. **Delete temporary info** — remove the four `karavi.temp.*` folders (logs,
   status, build, deploy output) plus caches.

> **This is a pipeline skill, not a reference skill.** Invoke it as
> `/karavi-folder` when you want the assistant to create or tidy the `karavi/`
> folder in the *current* repository.

## Folders it creates

### Core — `/karavi-folder create` (9 folders)

| Folder | Purpose |
|---|---|
| `karavi.plans.prompt` | Prompts, rules, and plans for all agents |
| `karavi.history` | Change history (`history.YYYY-MM-DD.md`) |
| `karavi.deploy.config` | Deploy & FTP config for this repo |
| `karavi.scripts.command` | Operator commands (deploy, run all, clean, ...) |
| `karavi.scripts.tools` | Tooling helpers (verify, paths, ...) |
| `karavi.temp.logs` | Temporary logs (gitignored) |
| `karavi.temp.status` | Temporary status reports (gitignored) |
| `karavi.temp.deploy` | Temporary staged release output (gitignored) |
| `karavi.temp.build` | Temporary build output (gitignored) |

### Optional — `/karavi-folder create --full` (adds 8)

`karavi.assets/{brand,icons,screenshots,templates}` · `karavi.mockup` ·
`karavi.doc` · `karavi.BusinessModel.Doc` · `karavi.Customer.doc` ·
`karavi.SociaMediaContent`

## Always-use command (دستور بکارگیری همیشگی)

Keep the karavi structure in **every** repo. Standing command:

```
/karavi-folder create --full
```

Persian: `/karavi-folder ساخت --کامل`. Idempotent and never destructive.

## Installation

```bash
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-folder
```

## Invocation

| Command | What it runs |
|---|---|
| `/karavi-folder create` | Create core skeleton (9 folders) |
| `/karavi-folder create --full` | Create core + optional folders |
| `/karavi-folder clean` | Clear temp.logs + temp.status |
| `/karavi-folder clean --deep` | Also clear temp.deploy + temp.build + caches |
| `/karavi-folder clean --what-if` | Dry-run preview, deletes nothing |

## When to Use

- "ایجاد فولدرهای اصلی karavi را بساز" → create the skeleton
- "پاک کن اطلاعات موقت / لاگ‌ها / کش karavi" → clean
- "Create the karavi folder structure"
- "Clean the karavi logs and caches"

## Safety

This skill **never deletes** source, config without secrets, `karavi.history/`,
`karavi.deploy.config/`, or README files. Only the four `karavi.temp.*` folders
are deletable. It is idempotent and always previewed (`--what-if`) before a
destructive pass unless the user explicitly approved.

## Reference

- [`HELP.md`](./HELP.md) — complete user guide (Persian/English, FAQ, troubleshooting)
- [`SKILL.md`](./SKILL.md) — entry point / decision core
- [`references/folders.md`](./references/folders.md) — Section 1 mechanics
- [`references/cleanup.md`](./references/cleanup.md) — Section 2 mechanics
- [`scripts/`](./scripts/) — optional PowerShell helpers

## License

Apache-2.0