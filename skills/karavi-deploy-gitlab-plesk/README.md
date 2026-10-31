# karavi-deploy-gitlab-plesk

Reusable procedure for a reproducible, automated GitLab CI/CD to Plesk deployment without zip archives, utilizing direct branch pushes and native Plesk webhooks.

## Supported release contract

- **Release trigger:** Only a Git push of the exact, case-sensitive tag `publish`; no branch, arbitrary/version tag, MR, schedule, web, or API trigger.
- **Pipeline stages:** Exactly `test -> build -> health`. Publishing happens inside `build`; no separate `publish` or `health_check` stage.
- **Health gate:** After every build succeeds, validate each API's configured Health response, Swagger UI, and Swagger/OpenAPI JSON using bounded GET probes. Any failure fails the pipeline.
- **CI/CD Host:** GitLab (cloud or self-hosted, e.g. `git.ntk.ir`).
- **Runner architecture:** GitLab Runner configured with `executor = "docker"` and registry mirrors (`docker.iranserver.com`, `docker.arvancloud.ir`).
- **Plesk branch:** Dedicated orphan deployment branches, e.g. `plesk/<site-slug>`.
- **Target path:** The directory selected and read back from Plesk UI (e.g. `\httpdocs`, `\httpdocs.api`).
- **No Zip Artifacts:** Built files are pushed directly to the dedicated branch and Plesk's Webhook is called with `POST -d ""`.
- **Server-owned files:** `appsettings*.json`, `NLog.config`, `nlog*.config`, `web.config`, and `.env*` are preserved on server and never overwritten by deployment payloads.

## Procedure

1. **Verify GitLab Runner:** Ensure the runner uses `executor = "docker"`, has Docker installed via `docker.io`, registry mirrors configured in `/etc/docker/daemon.json`, and untagged jobs enabled.
2. **Setup Git Credentials:** For `git.ntk.ir`, provision approved SSH deploy credentials with repository write permission and verified host keys through protected CI configuration; never embed credentials in Git URLs.
3. **Configure .gitlab-ci.yml:** Apply the exact-tag workflow and stage barriers from [workflow-contract.md](references/workflow-contract.md). All required tests gate build; build jobs compile, push the clean payload to dedicated `plesk/*` branches, and require webhook HTTP 204. All builds gate health.
4. **Configure Plesk Git:** Under the target domain, connect to the GitLab repository, select the dedicated `plesk/*` branch, enable Automatic deployment, and retrieve the Webhook URL. For `git.ntk.ir`, Git URLs must use `git@git.ntk.ir:<namespace>/<repository>.git` with approved SSH credentials.
5. **Configure GitLab Webhooks:** Register Plesk's Webhook URL in GitLab (`Settings > Webhooks`) for `Push events` on `plesk/*` branches.
6. **Authorized Release & Health:** Only with explicit push/tag/Deploy authorization, push the exact `publish` tag. Verify the three-stage graph, webhook HTTP 204, deployed commit, and every configured Swagger/Health probe. Never move an existing tag implicitly.

See `SKILL.md` for full gates and `references/` for detailed contracts, checklists, and runner setup.

## Changes in 1.1.0

- Added a binding agent prompt, exact `publish` tag-push rules, and migration instructions for `test -> build -> health`.
- Added Swagger UI/document and Health response validation, bounded readiness handling, trigger/failure scenarios, and per-target evidence fields.
- Removed project-specific deployment URLs from the reusable workflow reference.
