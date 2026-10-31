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

## Binding Agent Prompt: Publish Pipeline

When generating, editing, or reviewing `.gitlab-ci.yml`, apply this contract before the deployment procedure. Read [workflow-contract.md](references/workflow-contract.md) for the rules, health probe example, and acceptance scenarios.

**Objective:** Produce a publish-tag pipeline with exactly `test -> build -> health`, preserving the project's application commands and deployment targets.

| Requirement | Binding instruction |
|---|---|
| Trigger | Create this release pipeline only when `$CI_COMMIT_TAG == "publish"`. `publish` means the exact Git tag, not a runner tag, branch, job name, or commit-message keyword. Reject branch pushes, other tags, MR, schedule, web, and API pipeline sources. |
| Stages | Declare exactly `test`, `build`, `health`, in that order. Migrate former `publish` jobs into `build` and former `health_check` jobs into `health`; do not add extra stages. |
| Test gate | Run every project-required test before any build/deployment starts. No `allow_failure`, manual gates, or dependency shortcuts that bypass required tests. |
| Build gate | Compile, clean the payload, push to the dedicated Plesk branch, and require webhook HTTP 204 inside `build`. Every build/deployment must succeed before `health` starts. |
| Health gate | For every deployed API, use configured canonical URLs to GET both Health and Swagger. Require HTTP 200, the project's healthy response contract, a working Swagger UI, and a valid OpenAPI/Swagger JSON document. Root-page 200 or webhook 204 alone is not success. |
| Failure | Use bounded readiness retries, connection/request timeouts, and verified TLS. Missing configuration, exhausted retries, unhealthy payloads, and invalid Swagger fail the job and pipeline. Do not use `allow_failure`, `when: always`, `curl -k`, or `|| true` to hide failures. |
| Evidence | Record the tag/source, stage graph, required job outcomes, and redacted per-target probe outcomes; never record credentials, webhook query strings, or raw response bodies. |

**Execution boundary:** This skill update or a request to generate CI is not permission to create/move the `publish` tag, push, trigger a pipeline, or Deploy. Obtain the independently required authorization before side effects.

**Output contract:** Return the changed CI paths, discovered test/build commands, target-to-probe mapping, validation results, and unresolved prerequisites. Do not claim release success until all required probes pass. Do not invent URLs or relax production authentication to make Swagger pass.

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
