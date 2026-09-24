# Skill discovery and installation

Use the repository's supported Skills CLI to discover or install skills. Discovery is
read-only; install/update changes the local skill catalog and requires the user's
scope.

```powershell
npx skills find powershell
npx skills find windows-terminal
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-terminal
npx skills update
```

Before using a discovered skill, inspect its `SKILL.md`, trigger description, scripts,
permissions, and validation path. Prefer a narrowly scoped skill and compose domain
skills rather than copying overlapping instructions. Verify the installed path, name,
frontmatter, and references after installation; never treat an unverified remote skill
as trusted code.
