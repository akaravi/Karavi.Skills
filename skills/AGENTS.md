# Skills (`skills/`)

Karavi skill definitions published from this repo. Agents fetch them by raw URL,
so treat every file here as a public API.

## The two kinds

**Reference skills** carry knowledge and are always available.

**Pipeline / caretaker skills** run on demand and have side effects:

| Skill | Does |
|---|---|
| `karavi-folder/` | Scaffolds the standard `karavi/` workspace tree and removes temporary data (logs, caches, build/publish artifacts). Two sections: create main folders, then delete temp info. |

## File layout

```
skills/<name>/
├── SKILL.md          entry point, always loaded when the skill triggers
├── README.md         human-facing, GitHub renders this
├── LICENSE           Apache-2.0
├── references/       loaded on demand, one file per topic
└── scripts/          optional executables
```

## Size budget

`SKILL.md` is loaded in full every time the skill fires, so it is the expensive
file. Keep it **under 500 lines**. Everything past the decision-making core
belongs in `references/`, which the agent loads only when it needs that topic.

## Conventions

- Skills target the current repository only — no cross-project import.
- Destructive skills declare **exit codes** in a table and mean them.
- Deletion skills are idempotent and always run a `--what-if` dry-run before
  deleting unless the user explicitly approved.
- Cross-references between files use relative paths so the skill works when
  vendored into another repo.