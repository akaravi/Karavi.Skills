# Workflow contract

A publish workflow must satisfy all of these requirements:

```yaml
on:
  push:
    tags:
      - publish

permissions:
  contents: write
```

The workflow must:

- check out the exact published tag;
- restore, build, and test every relevant backend project;
- install the declared Node and `pnpm` versions;
- build the production frontend;
- publish for the Plesk operating system and runtime;
- use `SelfContained: false` and `UseAppHost: false` for a framework-dependent Windows payload unless evidence says otherwise;
- remove `appsettings*.json`, every case-insensitive `nlog*.config` variant,
  `web.config`, and `.env*` from the release payload;
- reject unsupported runtime trees and accidental PHP files when the target is Windows ASP.NET;
- force-update only the dedicated Plesk branch;
- avoid local credentials, workstation state, and server-owned configuration;
- leave a verifiable commit subject and release metadata in the payload.

The deployment helper, if present, must maintain a managed-file manifest and
must never delete or overwrite server-owned files during stale-file cleanup.

## Minimal validation examples

Use repository-specific paths and names from evidence; do not copy placeholders
as real values.

```bash
gh run view <RUN_ID> --repo <OWNER>/<REPO> --json status,conclusion,headSha
gh api repos/<OWNER>/<REPO>/branches/<PLESK_BRANCH> --jq '.commit.sha'
git ls-tree -r --name-only <PLESK_BRANCH> | grep -Ei '(^|/)(appsettings.*\.json|nlog.*\.config|web\.config|\.env.*)$'
```

The last command must return no server-owned files in the generated branch
payload. Save command output as redacted evidence; never include secrets or raw
webhook data.
