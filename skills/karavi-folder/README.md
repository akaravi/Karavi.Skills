# karavi-folder

Pipeline / caretaker skill that maintains the standard **`karavi/` workspace**
in a repository. It has two sections:

1. **Create main folders** — scaffold the canonical `karavi/` tree.
2. **Delete temporary info** — remove caches, logs, and build/publish artifacts.

> **This is a pipeline skill, not a reference skill.** Invoke it as
> `/karavi-folder` when you want the assistant to create or tidy the `karavi/`
> folder in the *current* repository.

## Installation

```bash
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-folder
```

## Invocation

| Command | What it runs |
|---|---|
| `/karavi-folder create` | Create core `karavi/` skeleton |
| `/karavi-folder create --full` | Create core + optional folders |
| `/karavi-folder clean` | Remove temp logs / run-stamp junk |
| `/karavi-folder clean --deep` | Also remove build/publish artifacts and caches |
| `/karavi-folder clean --what-if` | Dry-run preview, deletes nothing |

## When to Use

- "ایجاد فولدرهای اصلی karavi را بساز" → create the skeleton
- "پاک کن اطلاعات موقت / لاگ‌ها / کش karavi" → clean
- "Creat the karavi folder structure"
- "Clean the karavi logs and caches"

## Safety

This skill **never deletes** source, config without secrets, `karavi.history/`,
or README files. It is idempotent and always previewed (`--what-if`) before a
destructive pass unless the user explicitly approved.

## Reference

- [`SKILL.md`](./SKILL.md) — entry point / decision core
- [`references/folders.md`](./references/folders.md) — Section 1 mechanics
- [`references/cleanup.md`](./references/cleanup.md) — Section 2 mechanics
- [`scripts/`](./scripts/) — optional PowerShell helpers

## License

Apache-2.0