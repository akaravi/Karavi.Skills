# karavi-deploy-github-plesk

Reusable procedure for a reproducible GitHub Actions to Plesk deployment.

## Supported release contract

- Release trigger: exact tag `publish`.
- Build input: immutable published tag.
- Plesk branch: dedicated `plesk/<site-slug>` branch.
- Target path: the directory selected and read back from Plesk UI.
- Windows ASP.NET payload: framework-dependent `win-x64` unless the server contract proves otherwise.
- Server-owned files: `appsettings*.json`, `NLog.config`, `nlog*.config`, `web.config`, and `.env*`.

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

See `SKILL.md` for the full gates and `references/` for checklists.
