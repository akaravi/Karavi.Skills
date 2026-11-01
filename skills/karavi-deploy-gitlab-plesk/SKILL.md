---
name: karavi-deploy-gitlab-plesk
description: Use when automating GitLab-to-Plesk deployment via GitLab CI/CD, Docker runners, direct branch pushes, and Plesk Webhooks without zip files.
version: 1.1.0
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

## Prompt Engineering & Master Prompt Architecture

When designing, generating, refactoring, or reviewing `.gitlab-ci.yml`, adhere to the Master Prompt and specialized prompt contracts cataloged in [references/prompts.md](references/prompts.md). Read [workflow-contract.md](references/workflow-contract.md) for detailed stage barriers, DAG dependencies, health probe examples, and failure matrices.

### Topologies Supported by the Master Prompt

1. **Profile A: Monorepo Multi-Target DAG Pipeline (`validate -> test -> build -> deploy -> health-check`)**
   - Designed for repositories containing multiple application stacks: frontend SPAs (Angular admin, panel, website), backend services (.NET API, Auth, CDN), and client apps (Flutter app, agent).
   - Uses GitLab DAG (`needs:`) so independent service tracks (e.g. .NET API vs Angular Web) build, deploy, and health-check without waiting for unrelated stacks.
   - Segregates client/mobile packages (Flutter APK/binaries) to a non-Plesk `release` target, while web/API components deploy to Plesk.

2. **Profile B: Lean Strict Publish Pipeline (`test -> build -> health`)**
   - Designed for single-purpose or unified deployments triggered strictly on Git tag `$CI_COMMIT_TAG == "publish"`.
   - Zero-Zip architecture: compilation, server-config stripping, direct branch push (`plesk/*`), and webhook call happen within `build` to eliminate intermediate runner artifacts.

### Binding Architecture Matrix

| Dimension | Profile A: Monorepo Multi-Target (DAG) | Profile B: Lean Strict Publish |
|---|---|---|
| **Stages** | `validate -> test -> build -> deploy -> health-check` | `test -> build -> health` |
| **Trigger** | Tag `publish` or targeted manual/protected branch trigger | Strictly `$CI_COMMIT_TAG == "publish"` |
| **Execution Flow** | DAG via `needs:` (parallel independent pipelines) | Strict stage barriers (stage N gates stage N+1) |
| **Matrix Jobs** | Yes (`parallel: matrix` for Angular apps, .NET services, Flutter) | Single-target or uniform loop |
| **Client Apps (Flutter)** | Segregated to `release` (GitLab Package/Release Registry) | N/A (Web & API only) |
| **Plesk Deploy** | Direct push to `plesk/<slug>` + Webhook HTTP 204 | Direct push to `plesk/<slug>` + Webhook HTTP 204 |
| **Health Check** | Per-service probe jobs for API, Auth, CDN, and Web targets | Unified/per-target health probes in `health` |

**Non-Negotiable Invariants:**
- **Git Transport:** All Git connections to `git.ntk.ir` MUST use SSH scp-style (`git@git.ntk.ir:<namespace>/<repo>.git`). HTTPS Git URLs are forbidden for `git.ntk.ir`.
- **Server-Owned Config Immunity:** Payload MUST delete `appsettings*.json`, `web.config`, `NLog*.config`, and `.env*` before branch push.
- **Plesk Webhook 204:** Call with `-X POST -d ""` requiring exact HTTP 204.
- **Health & Swagger Gate:** Every deployed API must pass Health HTTP 200 (exact body contract), Swagger UI HTTP 200, and valid OpenAPI JSON parsing.

**Execution Boundary:** Generating or updating CI files is never authorization to push Git branches, create tags, or trigger live deployments. Live deployment actions require explicit user authorization.
## Prerequisites

1. **GitLab Project:** Project repository on GitLab (e.g. `git.ntk.ir/<group>/<project>`).
2. **GitLab Runner:** A runner registered with `executor = "docker"` and capable of pulling required images (.NET SDK, Node.js).
3. **Plesk Access:** Administrative or subscription access to Plesk Obsidian with Git extension installed.
4. **Git Push Credentials:** Approved SSH deploy credentials with repository write permission for `git.ntk.ir`; never embed credentials in Git URLs.
5. **Server Network Routing:** Egress from Plesk to GitLab over SSH (port 22) for `git.ntk.ir`; HTTPS remains valid for APIs and webhooks.

---

## Scope and Safety Gates

Before executing, record:

| Item | Required value |
|---|---|
| In scope | `.gitlab-ci.yml`, Docker runner configuration, branch pushes (`plesk/*`), Plesk Git setup, Webhook creation, HTTP 204 test, smoke check |
| Out of scope | DNS modifications, TLS certificate purchases, database schema destruction, non-deployment refactors |
| Owner | Project canonical owner profile (`akaravi` / `NTK`) |
| Acceptance | Exact `publish` tag push runs `test -> build -> health`; all required jobs pass, Plesk card reads back clean branch/path, webhook returns HTTP 204, and configured Swagger/Health checks pass |
| Verify method | GitLab CI Lint and trigger matrix, GitLab API / Web UI stage read-back, Plesk Git read-back, and bounded GET checks against configured Swagger/Health URLs |

---

## Canonical Deployment Architecture (No Zip Files)

1. **Build Stage in CI:**
   - Compile production bundles (Angular/Vue/React via `pnpm run build:prod`, .NET via `dotnet publish --runtime win-x64 -m:2`).
   - Remove server-owned configuration files (`appsettings*.json`, `web.config`, `nlog*.config`, `.env*`).
2. **Direct Branch Push:**
   - Initialize git in the output directory, commit the clean payload, and push to the dedicated authorized Plesk branch (e.g. `plesk/<domain-slug>`). For `git.ntk.ir`, use `git@git.ntk.ir:<namespace>/<repository>.git` with approved SSH credentials and verified host keys.
   - Tag commits with `[skip ci]` to prevent recursive pipeline triggering.
3. **Plesk Webhook Call:**
   - Execute an HTTP POST to Plesk's Webhook URL with a body:
     ```bash
     code=$(curl --silent --connect-timeout 5 --max-time 15 -X POST -d "" -o /dev/null -w '%{http_code}' "$PLESK_WEBHOOK_URL" 2>/dev/null) && test "$code" = 204
     ```
   - Plesk accepts the request with **`HTTP 204 No Content`** and initiates a background `git pull` into the mapped directory (`\httpdocs`, `\httpdocs.api`, etc.).
4. **Zero Zip Overhead:**
   - No `artifacts:` archive creation or downloading, drastically speeding up pipelines and saving server storage.
5. **Health Stage in CI:**
   - After all build/deployment jobs succeed, wait for Plesk readiness with bounded retries and check each deployed API's Swagger and Health contracts.
   - HTTP 204 means the asynchronous deployment was accepted, not that the application is healthy.

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
   - Configure approved SSH credentials and verified GitLab host keys for the account actually used by Plesk. Do not change repository visibility to bypass authentication.
3. **Repository Setup in Plesk:**
   - **Repository URL for `git.ntk.ir`:** `git@git.ntk.ir:<namespace>/<repository>.git`
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
code=$(curl --silent --connect-timeout 5 --max-time 15 -X POST -d "" -o /dev/null -w '%{http_code}' "$PLESK_WEBHOOK_URL" 2>/dev/null) && test "$code" = 204
```

---

## Verification & Acceptance Checklist

- [ ] GitLab Runner is `Online (Idle)` with `executor = "docker"`.
- [ ] Only a push of the exact Git tag `publish` creates the release pipeline; negative trigger cases create none.
- [ ] The stage graph is exactly `test -> build -> health`; all required tests gate every build and every build gates health.
- [ ] Build jobs compile, strip server-owned files, push to `plesk/*` branches, and require webhook HTTP 204.
- [ ] Plesk Git card displays the latest deployment commit matching the release source.
- [ ] Every deployed API passes configured Health semantics, Swagger UI HTTP 200, and valid Swagger/OpenAPI JSON checks in `health`.
- [ ] A failed probe or readiness timeout fails the pipeline; evidence is redacted and contains no raw response bodies.
