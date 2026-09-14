# Karavi Skills

Skill definitions published from this repo. Agents fetch them by raw URL, and
they install with `npx skills add`, so treat every file here as a public API.

## Skills

| Skill | Category | Does |
|---|---|---|
| [`karavi-folder`](./karavi-folder/) | Pipeline / caretaker | Scaffolds the standard `karavi/` workspace tree (Section 1) and safely removes temporary data — logs, caches, build/publish artifacts (Section 2). |

## Choosing a Skill

- **Need the `karavi/` skeleton created in a repo?** → `/karavi-folder create`
- **Need to clear temp logs / caches / build artifacts?** → `/karavi-folder clean`
  (add `--deep` for full artifact+cache cleanup)

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

`SKILL.md` is loaded in full every time the skill fires, so keep it **under 500
lines**. Everything past the decision-making core lives in `references/`, which
the agent loads only when it needs that topic.

## License

Apache-2.0