# karavi-deploy-github-plesk

Reusable procedure for a reproducible GitHub Actions to Plesk deployment.

The entry point is [SKILL.md](SKILL.md). Use this skill for a repository and one authoritative Plesk domain: CI/workflow creation, Plesk Git configuration, push webhook integration, and release verification. It is not an FTP-only deployment tool, a runtime installer, or authorization to change production. DNS, certificates, database migrations, and unrelated refactors are outside the default scope.

## Prerequisites and installation

- Local repository, canonical GitHub owner/repository, domain, deployment profile, and project instructions.
- GitHub Actions access and approved repository authentication; a least-privilege workflow token with the required `contents: write` permission for the dedicated deployment branch.
- Plesk subscription access, Git extension, network access to GitHub, and a deploy key configured through provider UI or approved vault.
- Server OS/runtime read back from Plesk; Windows ASP.NET requires a compatible .NET Hosting Bundle already available. Node/pnpm and .NET SDK versions come from the project, not this skill.
- `karavi-council` for consequential release decisions and `karavi-judge` for independent acceptance.

With Node.js and pnpm already available, the optional skill installation is:

```bash
pnpm dlx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-deploy-github-plesk
```

Installation changes the local skill catalog and requires that scope. Inspect the installed `SKILL.md` and references before activation. This package supplies instructions/checklists, not a bundled deploy executable, Actions workflow, runtime, or credentials.

## Supported release contract

- Release trigger: exact tag `publish`.
- Build input: immutable published tag.
- Plesk branch: dedicated `plesk/<site-slug>` branch.
- Target path: the directory selected and read back from Plesk UI.
- Windows ASP.NET payload: framework-dependent `win-x64` unless the server contract proves otherwise.
- Server-owned files: `appsettings*.json`, `NLog.config`, `nlog*.config`, `web.config`, and `.env*`.

The workflow may additionally support `workflow_dispatch` as described in [SKILL.md](SKILL.md); this GitHub contract does **not** require GitLab's three-stage graph or its Swagger/Health probe contract. Windows payloads use `SelfContained: false` and `UseAppHost: false` unless the server contract proves otherwise. Filter every case-insensitive `nlog*.config` variant. A managed-file manifest must preserve server-owned files during stale-file cleanup, not just copy.

## Usage and authorization

Example agent request (replace project context from canonical configuration):

```text
Use karavi-deploy-github-plesk to inspect this repository and prepare its
GitHub Actions/Plesk release configuration. Discover the runtime, test/build
commands, target domain and dedicated branch. Limit this request to local
documentation/workflow edits; do not commit, push, move publish, or Deploy.
Return the remaining access and live-verification prerequisites.
```

Before executing a release, record in/out scope, owner, acceptance, and verification method. Commits/pushes, creating or moving `publish`, Plesk changes, and live deployment each require applicable explicit authorization. FTP/SFTP/FTPS or other remote transfer requires the standalone user command token `Deploy`; it is not a silent fallback. Do not execute the release examples in `SKILL.md` merely because installation or workflow editing was requested. Rollback needs an identified known-good commit and separate authorization.

## Procedure

1. Inspect the repository, project instructions, manifests, existing workflows, and Git status.
2. Record scope, owner, domain, repository, runtime, branch, acceptance, and verification method.
3. Add or repair CI and publish workflows; use `pnpm` for Node projects.
4. Build and test locally before any release mutation.
5. Filter server-owned files from the release payload and preserve them during deployment.
6. Configure Plesk Git under the target domain. When outbound port 22 is blocked, use `ssh://git@ssh.github.com:443/<owner>/<repo>.git` with the Plesk deploy key.
7. Select the release branch and directory through Plesk UI; never infer a server path.
8. Enable automatic deployment, pull once, and read back the deployment result.
9. Configure a GitHub `push` webhook using Plesk's generated URL; keep URL, UUID, secret, and credentials redacted.
10. Verify GitHub Actions, branch SHA, webhook delivery, Plesk log, and public smoke checks.
11. Obtain an independent `karavi-judge` verdict before claiming completion.

## Outputs and verification

Return changed workflow/helper/profile paths, discovered test/build commands and actual results, GitHub run ID/conclusion and source SHA, deployment branch SHA, Plesk branch/path/mode/latest-commit read-back, webhook delivery, server-owned-file scan, public smoke results, findings and residual risk. Keep the project's release metadata in its deployment profile under `karavi/`. Do not invent profile names, endpoint paths, or successful outcomes.

After an authorized release, this read-only GitHub CLI example requires `gh` already installed and authenticated. First set `RUN_ID` to the actual workflow run ID and `GITHUB_REPOSITORY` to the canonical `owner/repository` from project configuration:

```bash
gh run view "$RUN_ID" --repo "$GITHUB_REPOSITORY" --json status,conclusion,headSha
```

For branch SHA lookup, use the API example in [workflow-contract.md](references/workflow-contract.md), accounting for the slash in a `plesk/*` branch when constructing an API path. Inspect the actual generated payload: `.gitignore` alone does not exclude server-owned files from packaging or protect them from cleanup.

CI/build success does not prove deployment. Read back Plesk's selected branch and directory-selector path, the matching commit, automatic mode, corresponding deployment notification/log, successful push-only webhook delivery, and canonical public smoke endpoints. A click or an old success banner is not fresh evidence.

Before packaging, publishing, deploying, or reporting completion, scan diff/staged files, artifacts, logs and workflow output for secrets, PII and server-owned configuration. Never publish webhook URLs/UUIDs, private keys, tokens, connection strings, or raw sensitive logs. Record unavailable live checks as not run, with a precise resume condition. Completion requires the scope/cross-section/seven-domain Completion Envelope and independent Judge verdict `accept`; generic instructions are not deployment evidence.

## References and failure handling

- [SKILL.md](SKILL.md): complete safety gates, failure-response table, release/rollback examples, exit states.
- [Workflow contract](references/workflow-contract.md): tag checkout, runtime/payload requirements and validation examples.
- [Plesk UI checklist](references/plesk-ui-checklist.md): key registration, branch/path and deployment read-back.
- [Evidence record](references/evidence-record.md): redacted per-project report template; fill only observed outcomes.

For port-22 timeout, inspect the documented GitHub SSH-over-443 option before changing keys. For missing branches or path mismatch, read GitHub and Plesk state back before another deploy. For overwritten configuration, restore from the server-owned source and fix payload filtering/preservation before retrying. Never mask a workflow or smoke failure as success.

## License

[Apache-2.0](LICENSE)
