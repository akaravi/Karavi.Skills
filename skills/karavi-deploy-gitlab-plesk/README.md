# karavi-deploy-gitlab-plesk

Reusable procedure for a reproducible, automated GitLab CI/CD to Plesk deployment without zip archives, utilizing direct branch pushes and native Plesk webhooks.

Start with [SKILL.md](SKILL.md). This skill covers GitLab CI/CD, Docker runners, direct deployment-branch pushes and Plesk Git/webhook integration for SPAs, .NET backends and static sites. It is not an FTP-only uploader or a generic server provisioning tool; DNS changes, certificate purchases, destructive database changes and unrelated refactors are outside the default scope.

## Prerequisites and installation

- Local project and its canonical GitLab repository, owner profile, domain, runtime, test/build commands, deployment branches and target URL configuration.
- An online Docker-executor GitLab Runner able to pull the project's SDK images; its job tags or untagged-job policy must match the jobs.
- Plesk subscription/admin access with Git extension and network access to the GitLab repository. Verify the actual OS/runtime rather than assuming a Windows path.
- Approved CI SSH write credentials and verified host keys for branch pushes; Plesk's own service account must also have noninteractive repository access. Never change repository visibility to bypass authentication.
- For every API, configured Health, Swagger UI and specification URLs, the canonical healthy-body contract, and any existing authorized authentication.
- `karavi-council` for consequential decisions and `karavi-judge` for independent acceptance.

Optional skill installation, with Node.js and pnpm already present:

```bash
pnpm dlx skills add https://github.com/akaravi/Karavi.Skills --skill karavi-deploy-gitlab-plesk
```

This changes the local skill catalog, not GitLab Runner, Docker, Plesk, or application runtimes. Inspect the installed entry point and references. The skill contains procedure/reference files, not a ready-to-run project pipeline or bundled deploy script.

## Supported release contract

- **Release profiles:**
  - **Profile A (Monorepo Multi-Target DAG):** `validate -> test -> build -> deploy -> health-check` with matrix parallelism, DAG dependencies, client package release separation (Flutter), and per-target health checks.
  - **Profile B (Lean Strict Publish):** Exactly `test -> build -> health` triggered on exact tag `publish`.
- **Master Prompt & Engineering Prompts:** Complete armed prompt catalog in [references/prompts.md](references/prompts.md).
- **Health gate:** After deployment succeeds, validate each API's configured Health response, Swagger UI, and Swagger/OpenAPI JSON using bounded GET probes. Any failure fails the pipeline.
- **CI/CD Host:** GitLab (cloud or self-hosted, e.g. `git.ntk.ir`).
- **Runner architecture:** GitLab Runner with `executor = "docker"`; registry mirrors in the runner reference are restricted-network setup examples, not a universal prerequisite or availability guarantee.
- **Plesk branch:** Dedicated orphan deployment branches, e.g. `plesk/<site-slug>`.
- **Target path:** The directory selected and read back from Plesk UI (e.g. `\httpdocs`, `\httpdocs.api`).
- **No Zip Artifacts:** Built files are pushed directly to the dedicated branch and Plesk's Webhook is called with `POST -d ""`.
- **Server-owned files:** `appsettings*.json`, `NLog.config`, `nlog*.config`, `web.config`, and `.env*` are preserved on server and never overwritten by deployment payloads.

Git transport to `git.ntk.ir` must use `git@git.ntk.ir:<namespace>/<repository>.git`, including CI pushes and Plesk remotes. HTTPS remains valid for APIs and webhooks. Use the higher-priority SSH contract even where an older generic Plesk checklist illustrates an HTTPS Git URL.

## Usage and permission boundary

Example agent request:

```text
Use karavi-deploy-gitlab-plesk to inspect this project's CI and prepare a local
migration to exact publish-tag-push release rules and test -> build -> health.
Discover all required tests/builds and each API's configured Health/Swagger
mapping. Preserve server-owned files and existing deployment targets.
Do not install runners, change Plesk, push branches/tags, trigger CI or Deploy.
Report missing prerequisites and validation still requiring access.
```

Record scope, owner, acceptance and verification before changes. Editing CI or installing the skill does not authorize Git mutation, tag creation/movement, pipeline execution, server changes or deployment. Obtain explicit applicable push/tag/`Deploy` authorization before side effects; FTP/SFTP/FTPS or any remote transfer requires the standalone user command token `Deploy`. Existing tag reuse, stale clone deletion, Docker/runner restarts and credential changes must never happen implicitly.

## Procedure

1. **Verify GitLab Runner:** Confirm Docker executor, approved SDK images and matching job selection. For an authorized Ubuntu restricted-network setup, follow the separate [runner guide](references/runner-docker-setup.md); adapt mirrors/DNS to approved infrastructure rather than blindly copying them.
2. **Setup Git Credentials:** For `git.ntk.ir`, provision approved SSH deploy credentials with repository write permission and verified host keys through protected CI configuration; never embed credentials in Git URLs.
3. **Configure .gitlab-ci.yml:** Apply the exact-tag workflow and stage barriers from [workflow-contract.md](references/workflow-contract.md). All required tests gate build; build jobs compile, push the clean payload to dedicated `plesk/*` branches, and require webhook HTTP 204. All builds gate health.
4. **Configure Plesk Git:** Under the target domain, connect to the GitLab repository, select the dedicated `plesk/*` branch, enable Automatic deployment, and retrieve the Webhook URL. For `git.ntk.ir`, Git URLs must use `git@git.ntk.ir:<namespace>/<repository>.git` with approved SSH credentials.
5. **Configure GitLab Webhooks:** Register Plesk's Webhook URL in GitLab (`Settings > Webhooks`) for `Push events` on `plesk/*` branches.
6. **Authorized Release & Health:** Only with explicit push/tag/Deploy authorization, push the exact `publish` tag. Verify the three-stage graph, webhook HTTP 204, deployed commit, and every configured Swagger/Health probe. Never move an existing tag implicitly.

## Pipeline and health configuration

The following is the binding release entry condition, not a complete application pipeline:

```yaml
workflow:
  rules:
    - if: '$CI_PIPELINE_SOURCE == "push" && $CI_COMMIT_TAG == "publish"'
    - when: never
stages:
  - test
  - build
  - health
```

Keep separately authorized non-release CI separate without broadening this trigger. Audit included/child configurations and conflicting job rules. All required tests run automatically and gate **every** build; all builds/deployments gate health through normal stage barriers, without `needs` shortcuts, optional/manual required jobs or `allow_failure`.

Discover application commands from the project; `pnpm run build:prod` and `dotnet publish --runtime win-x64 -m:2` in the source are examples only where the script/runtime actually exists. Within `build`, compile, clean the payload, push only the authorized deployment branch and POST the configured webhook with an empty body, connection/request timeouts and verified TLS. Require exactly HTTP 204; do not blindly retry mutation requests. Do not log the webhook URL/query string. HTTP 204 acknowledges asynchronous work, not application readiness.

Map each API to `HEALTH_URL`, `SWAGGER_URL`, `SWAGGER_JSON_URL` and its canonical Health predicate. The [workflow contract](references/workflow-contract.md) provides the Python 3/curl probe example and exact validation behavior:

- GET all three endpoints; require HTTP 200 without following redirects, a healthy Health body, Swagger UI content and a structurally valid OpenAPI/Swagger document.
- Maximum 12 readiness attempts, 5 seconds apart; each request has a 5-second connection and 15-second overall timeout. All probes for a target pass in the same attempt.
- Missing configuration, invalid/unhealthy bodies, auth redirects, TLS/network errors and exhausted retries fail the job/pipeline. Do not use `curl -k`, `when: always`, `|| true` or suppressed failures.
- Keep production authentication intact. Use approved existing credentials without logging them. Non-API targets use their canonical smoke checks; never silently omit an API.

## Outputs and verification

Return changed CI paths, discovered test/build mapping, target-to-probe configuration keys, trigger/stage validation, required job outcomes, source tag/SHA, deployment branch SHA, webhook status, Plesk card/path/latest-commit read-back and redacted per-target probe outcomes. Record only labels/status/attempt/outcome, not credentials, raw bodies or secret-bearing URLs.

Before configuration acceptance, use GitLab CI Lint on expanded CI and inspect the graph and negative trigger matrix: branch `main`/`publish`, tags `Publish`/`publish-1`/version tags, MR, schedule, web/API and `plesk/*` pushes must not create this release pipeline. Test failure must prevent deployment; build failure must prevent health. Probe validation should cover unhealthy 200, 503, Swagger 404/invalid JSON, redirect/login, missing URL and readiness exhaustion as well as the healthy case. These are required checks, not claims that this README ran them.

Only an explicitly authorized release can provide live evidence. Read back the matching GitLab run, all three stages, Plesk branch/path/commit, webhook HTTP 204 and all required live probes. Scan diff/staged/untracked files, payloads, logs and outputs for secrets and server-owned files before publishing or claiming completion. `.gitignore` alone does not protect configuration; preserve it during copy and stale-file cleanup too.

Use `not-run` for unavailable evidence and report the access/configuration needed to resume. Completion requires the scope/cross-section/seven-domain Completion Envelope and independent `karavi-judge` acceptance, not merely CI lint or a webhook acknowledgment.

## References

- [SKILL.md](SKILL.md): operational gates, deployment architecture and authorization boundary.
- [Workflow contract](references/workflow-contract.md): exact trigger, stage barriers, executable probe example and failure matrix.
- [Runner setup](references/runner-docker-setup.md): authorized Ubuntu/Docker/runner and restricted-network configuration.
- [Plesk checklist](references/plesk-ui-checklist.md): UI read-back; apply the SSH-only rule above for `git.ntk.ir`.
- [Evidence record](references/evidence-record.md): per-deployment template, not pre-existing successful evidence.

## Changes in 1.1.0

- Added a binding agent prompt, exact `publish` tag-push rules, and migration instructions for `test -> build -> health`.
- Added Swagger UI/document and Health response validation, bounded readiness handling, trigger/failure scenarios, and per-target evidence fields.
- Removed project-specific deployment URLs from the reusable workflow reference.

## License

[Apache-2.0](LICENSE)
