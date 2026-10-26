---
name: karavi-deploy-gitlab-plesk
description: Use when automating GitLab-to-Plesk deployment via GitLab CI/CD, Docker runners, direct branch pushes, and Plesk Webhooks without zip files.
version: 1.0.0
author: Ali Karavi (akaravi), Hermes Agent
license: Apache-2.0
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [gitlab, plesk, deployment, ci-cd, docker, aspnet, angular, windows, webhooks]
    related_skills: [karavi-folder, karavi-council, karavi-judge]
---

# karavi-deploy-gitlab-plesk

Use this skill to build an automated, repeatable, and fast GitLab CI/CD to Plesk deployment for single-page apps (Angular/React/Vue), .NET backends, and static sites. It covers GitLab Runner configuration in Docker mode, repository branch automation, Plesk Git integration, credential management, Plesk Webhook execution with HTTP 204 validation, and end-to-end smoke verification.

## When to Use

- Automating deployment from GitLab (cloud or self-hosted, e.g. `git.ntk.ir`) to Plesk domains or subdomains.
- Migrating existing GitHub Actions / FTP deployments to a private, self-hosted GitLab + Plesk infrastructure.
- Setting up direct Git-branch continuous deployment where Plesk automatically pulls upon webhook triggers without intermediate `.zip` artifacts.

## Prerequisites

1. **GitLab Project:** Project repository on GitLab (e.g. `git.ntk.ir/<group>/<project>`).
2. **GitLab Runner:** A runner registered with `executor = "docker"` and capable of pulling required images (.NET SDK, Node.js).
3. **Plesk Access:** Administrative or subscription access to Plesk Obsidian with Git extension installed.
4. **GitLab Push Token:** A Project Access Token or CI variable (`GITLAB_PUSH_TOKEN`) with `write_repository` permission.
5. **Server Network Routing:** Egress access from Plesk to GitLab over HTTPS (port 443) or SSH (port 22).

---

## Scope and Safety Gates

Before executing, record:

| Item | Required value |
|---|---|
| In scope | `.gitlab-ci.yml`, Docker runner configuration, branch pushes (`plesk/*`), Plesk Git setup, Webhook creation, HTTP 204 test, smoke check |
| Out of scope | DNS modifications, TLS certificate purchases, database schema destruction, non-deployment refactors |
| Owner | Project canonical owner profile (`akaravi` / `NTK`) |
| Acceptance | Pipeline passes all tests and builds, Plesk card reads back clean branch/path, Webhook returns HTTP 204, live endpoints return HTTP 200 |
| Verify method | GitLab API / Web UI read-back, Plesk Git read-back, and live `curl -I` / `curl -s` health checks |

---

## Canonical Deployment Architecture (No Zip Files)

1. **Build Stage in CI:**
   - Compile production bundles (Angular/Vue/React via `pnpm run build:prod`, .NET via `dotnet publish --runtime win-x64 -m:2`).
   - Remove server-owned configuration files (`appsettings*.json`, `web.config`, `nlog*.config`, `.env*`).
2. **Direct Branch Push:**
   - Initialize git in the output directory, commit the clean payload, and force-push to the dedicated Plesk branch (e.g. `plesk/<domain-slug>`) on GitLab using `${GITLAB_PUSH_TOKEN}`.
   - Tag commits with `[skip ci]` to prevent recursive pipeline triggering.
3. **Plesk Webhook Call:**
   - Execute an HTTP POST to Plesk's Webhook URL with a body:
     ```bash
     curl -k -s -X POST -d "" "https://<plesk-host>:8443/modules/git/public/web-hook.php?uuid=<uuid>"
     ```
   - Plesk accepts the request with **`HTTP 204 No Content`** and initiates a background `git pull` into the mapped directory (`\httpdocs`, `\httpdocs.api`, etc.).
4. **Zero Zip Overhead:**
   - No `artifacts:` archive creation or downloading, drastically speeding up pipelines and saving server storage.

---

## Runner Setup & Sanction Bypass (Iran / Restricted Networks)

When the GitLab Runner runs on an Iranian server (e.g. `s20`):

1. **Do not use `get.docker.com`** (returns HTTP 403 Forbidden). Install Docker via Ubuntu's standard repository:
   ```bash
   apt-get update && apt-get install -y docker.io
   systemctl enable --now docker
   usermod -aG docker gitlab-runner
   ```
2. **Configure Docker Registry Mirrors** in `/etc/docker/daemon.json`:
   ```json
   {
     "registry-mirrors": [
       "https://docker.iranserver.com",
       "https://docker.arvancloud.ir"
     ],
     "dns": ["178.22.122.100", "185.51.200.2", "8.8.8.8"]
   }
   ```
   Restart Docker: `systemctl restart docker`.
3. **Configure Runner TOML** (`/etc/gitlab-runner/config.toml`):
   Ensure `executor = "docker"` (never empty string `""`):
   ```toml
   [[runners]]
     name = "s20"
     url = "https://git.ntk.ir"
     executor = "docker"
     [runners.docker]
       tls_verify = false
       image = "ubuntu:24.04"
       privileged = false
       volumes = ["/cache"]
   ```
   Restart Runner: `systemctl restart gitlab-runner`.
4. **NPM / Corepack Speedup:** In `.gitlab-ci.yml`, set the npm registry to a fast mirror:
   ```bash
   npm install -g pnpm@$PNPM_VERSION --registry=https://registry.npmmirror.com
   pnpm config set registry https://registry.npmmirror.com
   ```
5. **.NET Memory Bound:** Use `-m:2` on `dotnet restore` and `dotnet publish` to prevent Roslyn compiler from exhausting RAM and dying with exit code 137 (OOMKilled).

---

## Plesk Git Configuration

1. **Clean Slate:** Before adding a repository with an existing name, delete the stale directory under `D:\Inetpub\vhosts\<domain>\git\<repo-name>` via File Manager if a previous task left partial files.
2. **Windows Non-Interactive Credentials:**
   - Windows IIS runs Git under `psaadm` without an interactive terminal (`/dev/tty`).
   - If using HTTPS: Configure `_netrc` in `D:\Inetpub\vhosts\<domain>\_netrc` and `C:\Windows\System32\config\systemprofile\_netrc`:
     ```text
     machine <gitlab-host>
     login <username>
     password <token>
     ```
   - Or set project visibility on the private GitLab instance to Public/Internal.
3. **Repository Setup in Plesk:**
   - **Repository URL:** `https://<gitlab-host>/<group>/<project>.git`
   - **Repository Name:** `<app-slug>`
   - **Deployment mode:** `Automatic` (or `Manual` initially if directory has existing untracked files).
   - **Deployment directory:** Target directory (e.g. `\httpdocs`, `\httpdocs.api`).
4. **Branch Selection:** In the Plesk Git card, switch the branch from `main` to the dedicated `plesk/<slug>` branch and verify read-back.
5. **Webhook Extraction:** Open Repository settings in Plesk, copy the Webhook URL, and register it in GitLab (`Project Settings > Webhooks`) for `Push events`.

---

## Plesk Webhook Protocol Details

Plesk's Git webhook endpoint (`/modules/git/public/web-hook.php?uuid=...`):
- `GET` requests return **HTTP 404** ❌
- `POST` requests without a body return **HTTP 411 Length Required** ❌
- `POST` requests with a body (`-X POST -d ""`) return **HTTP 204 No Content** ✅

Always invoke via:
```bash
curl -k -s -X POST -d "" "https://<plesk-host>:8443/modules/git/public/web-hook.php?uuid=<uuid>"
```

---

## Verification & Acceptance Checklist

- [ ] GitLab Runner is `Online (Idle)` with `executor = "docker"`.
- [ ] `.gitlab-ci.yml` passes `test` stage (.NET unit tests, Jest tests).
- [ ] Build jobs compile, strip server-owned files, push to `plesk/*` branches, and call Plesk Webhook.
- [ ] Plesk Webhook returns HTTP 204.
- [ ] Plesk Git card displays the latest commit matching the CI commit.
- [ ] Live domain returns HTTP 200 with the new version manifest.
