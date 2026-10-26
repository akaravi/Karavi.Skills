# karavi-deploy-gitlab-plesk

Reusable procedure for a reproducible, automated GitLab CI/CD to Plesk deployment without zip archives, utilizing direct branch pushes and native Plesk webhooks.

## Supported release contract

- **Release trigger:** Push to `main` or exact tag `publish` / version tags.
- **CI/CD Host:** GitLab (cloud or self-hosted, e.g. `git.ntk.ir`).
- **Runner architecture:** GitLab Runner configured with `executor = "docker"` and registry mirrors (`docker.iranserver.com`, `docker.arvancloud.ir`).
- **Plesk branch:** Dedicated orphan deployment branches, e.g. `plesk/<site-slug>`.
- **Target path:** The directory selected and read back from Plesk UI (e.g. `\httpdocs`, `\httpdocs.api`).
- **No Zip Artifacts:** Built files are pushed directly to the dedicated branch and Plesk's Webhook is called with `POST -d ""`.
- **Server-owned files:** `appsettings*.json`, `NLog.config`, `nlog*.config`, `web.config`, and `.env*` are preserved on server and never overwritten by deployment payloads.

## Procedure

1. **Verify GitLab Runner:** Ensure the runner uses `executor = "docker"`, has Docker installed via `docker.io`, registry mirrors configured in `/etc/docker/daemon.json`, and untagged jobs enabled.
2. **Setup Project Access Token:** Create a Project Access Token with `write_repository` permission and store it in GitLab CI/CD Variables as `GITLAB_PUSH_TOKEN`.
3. **Configure .gitlab-ci.yml:** Define test and build jobs. Each build job compiles the application, pushes the clean payload to the dedicated `plesk/*` branch, and fires Plesk's Webhook via `curl -X POST -d ""`.
4. **Configure Plesk Git:** Under the target domain, connect to the GitLab repository using HTTPS or SSH, select the dedicated `plesk/*` branch, enable Automatic deployment, and retrieve the Webhook URL.
5. **Configure GitLab Webhooks:** Register Plesk's Webhook URL in GitLab (`Settings > Webhooks`) for `Push events` on `plesk/*` branches.
6. **Deploy & Smoke Test:** Push a commit or tag, verify pipeline stages, webhook delivery (HTTP 204), and check live public domain health.

See `SKILL.md` for full gates and `references/` for detailed contracts, checklists, and runner setup.
