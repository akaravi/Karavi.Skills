# Plesk UI Checklist for GitLab Deployment

Read back fresh evidence from the Plesk UI after every change.

## 1. Domain & Environment Check
- [ ] Target domain context matches the subscription and domain ID in Plesk URL.
- [ ] Directory on disk exists (`\httpdocs`, `\httpdocs.api`, etc.).
- [ ] Server-owned configuration files (`appsettings.Production.json`, `web.config`, `nlog.config`) exist in the target directory and are preserved.

## 2. Git Repository Card Configuration
- [ ] Stale or failed clone directories in `D:\Inetpub\vhosts\<domain>\git\` are removed before creating a repository.
- [ ] Remote repository URL matches the canonical GitLab project: `https://<gitlab-host>/<group>/<project>.git`.
- [ ] Repository name is unique under the domain.
- [ ] Dedicated release branch (`plesk/<site-slug>`) is selected in the Branch dropdown, not `main`.
- [ ] Deployment mode is set to **Automatic**.
- [ ] Target deployment path matches the directory selector.

## 3. Webhook Integration
- [ ] Webhook URL is retrieved from Plesk Repository settings (`/modules/git/public/web-hook.php?uuid=...`).
- [ ] Webhook is registered in GitLab under `Settings > Webhooks` with `Push events` trigger.
- [ ] Webhook test from GitLab returns **HTTP 204**.
- [ ] Plesk Git card indicates the latest commit SHA matching the GitLab branch.

## 4. Live Service Verification
- [ ] Application responds with HTTP 200 on public domain.
- [ ] Deployed version endpoint (`/assets/version.json` or `/health`) matches the release version.
