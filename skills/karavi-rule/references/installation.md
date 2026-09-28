# Mandatory installation contract

`karavi-rule` depends on three personal skills. The dependency check is part
of activation, not an optional recommendation.

## Commands

Run each command separately so its result is attributable:

```powershell
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-council
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-folder
npx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-judge
```

## Verification

For each dependency, verify:

1. the command completed successfully;
2. the installed directory is discoverable by the active agent runtime;
3. `SKILL.md` exists, is UTF-8, and has the expected `name`;
4. the skill description is available for routing.

If a dependency is unavailable, classify the state as `decision-required` and
continue only with safe, non-destructive work that does not depend on it. Do
not fabricate a result or claim the dependency is installed. A hard safety or
authorization issue remains the only reason to stop.
