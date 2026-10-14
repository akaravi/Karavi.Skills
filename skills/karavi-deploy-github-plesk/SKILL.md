---
name: karavi-deploy-github-plesk
description: Use when automating GitHub-to-Plesk deployment. Build, configure, verify, and safely document the release path.
version: 1.0.0
author: Ali Karavi (akaravi), Hermes Agent
license: Apache-2.0
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [github, plesk, deployment, ci-cd, aspnet, angular, windows]
    related_skills: [karavi-folder, karavi-council, karavi-judge]
---

# karavi-deploy-github-plesk

Use this skill to build a repeatable GitHub Actions to Plesk deployment for a
repository and one Plesk domain. It covers repository inspection, workflow
creation, Plesk Git configuration, automatic deployment, webhook verification,
and an end-to-end publish check. It does not authorize secrets, commits,
pushes, FTP, production changes, or destructive cleanup by itself.

## When to Use

Use when the user asks to automate deployment from GitHub to a Plesk domain,
connect a repository to a Plesk site, or reuse the Karavi GitHub/Plesk pattern.
Do not use for FTP-only deployment, a provider other than Plesk, or a release
that has no repository and no authoritative domain configuration.

## Prerequisites

- A local repository path, canonical GitHub owner/repository, and target domain.
- Plesk access for the target subscription and Git extension.
- A deploy key or other repository authentication configured through the
  provider UI or `browser_vault`; never put secret values in files or chat.
- The target Plesk runtime identified from the server, not guessed. For a
  Windows x64 ASP.NET deployment, verify the compatible .NET Hosting Bundle.
- `karavi-council` for consequential architecture or release decisions and
  `karavi-judge` for the final acceptance verdict.

## Scope and Safety Gates

Before editing, record:

| Item | Required value |
|---|---|
| In scope | CI, publish workflow, Plesk Git repository, branch, path, automatic deployment, webhook, smoke verification |
| Out of scope | DNS changes, certificates, server runtime installation, database migration, unrelated refactors |
| Owner | Read from the repository's canonical owner profile and project config |
| Acceptance | Successful CI, successful publish workflow, Plesk branch/path read-back, deployment success, public smoke check |
| Verify method | `terminal`, GitHub CLI/API read-back, Plesk UI read-back, and a public HTTP check |

Use the safest in-scope option when a technical choice is inferable. Stop only
for a hard safety or authorization boundary, missing required access, or a
material user-owned choice.

## Canonical Deployment Contract

- Publish trigger: exact tag `publish`; do not use `publish-*` unless the user
  explicitly changes the contract.
- Plesk branch: a dedicated branch such as `plesk/<site-slug>`.
- Build source: the immutable published tag, not mutable `main`.
- Plesk target: the branch selected in the Plesk Git card.
- Deployment path: the value returned by Plesk's directory selector. Never infer
  `httpdocs`, `wwwroot`, or a Windows path from convention.
- Server-owned files: `appsettings*.json`, any case-insensitive `nlog*.config`
  variant including `NLog.config`, `web.config`, and `.env*`. They must be
  excluded from the publish payload and preserved by deployment helpers.
- Secrets: use GitHub Secrets, Plesk credential storage, or `browser_vault`.
  Store only `[REDACTED]` in logs, documentation, reports, and examples.

## How to Run

1. Load the relevant skills and inspect the repository with `search_files`,
   `read_file`, and `terminal`. Read project instructions, manifests, existing
   workflows, ignore rules, deployment files, and current Git status.
2. Resolve the canonical owner, repository, domain, runtime, and branch names.
   Keep the exact values in the project deployment profile, but never include
   credentials, tokens, private keys, webhook URLs, or UUIDs.
3. Add or repair CI and publish workflows using `write_file` for new files and
   `patch` for existing files. Use `pnpm` for Node projects. Build and test the
   API and frontend before packaging.
4. Publish a framework-dependent Windows x64 payload when Plesk is Windows:
   use a Windows runtime restore and publish, `SelfContained: false`, and
   `UseAppHost: false` unless the server contract proves otherwise.
5. Remove server-owned files from the payload. If a helper synchronizes files,
   maintain a manifest of managed files and preserve server-owned files both
   during copy and stale-file cleanup.
6. Push the workflow changes only when the user explicitly authorizes Git
   mutation. Create or move the exact `publish` tag only with explicit release
   authorization.
7. In Plesk, create the repository under the target domain. Prefer the SSH
   endpoint on port 443 when outbound port 22 is blocked:
   `ssh://git@ssh.github.com:443/<owner>/<repo>.git`.
   Register the Plesk deploy key in GitHub using the provider UI; do not copy
   private key material into the repository.
8. Select the dedicated Plesk branch. Read back the selected branch and the
   deployment sentence/card from Plesk. The path must be the directory-selector
   result, not a guessed path.
9. Enable automatic deployment in the Plesk Git card and read it back. Pull or
   deploy once manually to establish a known-good baseline.
10. Obtain the Plesk webhook configuration from the repository UI. Create the
    GitHub webhook for `push` only, using the secret through the UI/vault. Never
    write the URL, UUID, or secret into chat, Git, or the skill.
11. Trigger one controlled publish. Verify the GitHub Actions run, the Plesk
    latest commit, the deployment notification/log, and the public domain.
12. Run `karavi-judge` with fresh evidence. Do not claim completion until its
    verdict is `accept` and the Completion Envelope is recorded.

## Quick Reference

```text
# Normal development push
terminal(command="git add <reviewed-files> && git commit -m \"<neutral message>\" && git push origin main")

# Exact release tag (only after explicit release authorization)
terminal(command="git tag -f publish HEAD && git push origin +refs/tags/publish")

# Roll back the published payload (only with an identified known-good commit)
terminal(command="git tag -f publish <KNOWN_GOOD_COMMIT> && git push origin +refs/tags/publish")
```

The commands above are examples. Replace placeholders from repository evidence;
do not invent owner, branch, commit, or domain values.

## Workflow Requirements

A publish workflow should:

- trigger on the exact tag `publish` and optionally `workflow_dispatch`;
- check out the published tag or its resolved SHA;
- restore/build/test every relevant backend project;
- install the declared Node and `pnpm` versions and build the production SPA;
- publish for the Plesk operating system and runtime;
- remove server-owned files before creating the branch payload;
- push the dedicated Plesk branch with a least-privilege GitHub token and an
  explicit workflow permission contract such as `permissions: contents: write`;
- avoid mutable workstation state, local credentials, and local-only config;
- pin third-party actions to reviewed commit SHAs when the repository policy
  requires supply-chain pinning.

Keep API business rules and persistence out of workflow scripts. Keep release
metadata and deployment settings in a project profile under `karavi/`.

Use the validation examples in `references/workflow-contract.md` and record
fresh evidence using `references/evidence-record.md`. For a project-specific
deployment, map the GitHub run, release branch SHA, Plesk branch/path read-back,
webhook delivery, server-owned-file scan, and public smoke checks to evidence
IDs; do not claim that generic procedure text proves a live deployment.

## Plesk UI Verification

Freshly read back all of the following after every UI mutation:

- repository name and remote URL;
- selected branch, exactly matching the GitHub deployment branch;
- deployment enabled state;
- deployment path shown by the Plesk card and directory selector;
- latest commit subject/SHA or equivalent Plesk evidence;
- manual deployment result and notification;
- webhook URL/event state in GitHub, with sensitive values redacted.

A successful button click is not proof. If the UI reports an old error and a
new success, preserve both facts and identify which run the success represents.

## Failure Handling

| Failure | Safe response |
|---|---|
| SSH port 22 timeout | Retry with `ssh://git@ssh.github.com:443/...`; verify the same deploy key and remote repository |
| SSH authentication failure | Re-read the Plesk public deploy key and GitHub repository key registration; do not expose private material |
| GitHub workflow failure | Inspect the failed job log, fix the root cause in the workflow, rerun only after the diff is verified |
| Branch missing in Plesk | Verify the GitHub branch exists and run Plesk Pull; do not type a guessed branch name into a free-text path |
| Wrong deployment path | Stop deployment, re-read the Plesk directory selector, and repair the Plesk mapping before retrying |
| Server-owned config missing/overwritten | Restore from the server-owned source, fix payload filtering/preservation, and rescan before retrying |
| Webhook delivery failure | Inspect GitHub delivery status and Plesk repository logs; keep event scope to `push` |
| Public smoke failure | Check deployment result, server logs, runtime compatibility, and configuration ownership before changing code |

Do not hide a failure behind a fabricated successful deployment. Convert a
technical blocker into a decision packet with evidence, options, trade-offs,
selected safe action, owner, verification method, and residual risk.

## Security and Secret Scan

Before done, commit, package, publish, or deploy, scan the diff, staged files,
artifacts, logs, and workflow output for passwords, tokens, private keys,
connection strings, webhook secrets, PII, and raw provider logs. Confirm that
server-owned files are absent from the publish branch/payload. A real finding
remains open until containment and a fresh rescan are green.

## Verification and Completion Envelope

Collect fresh evidence for:

1. **Check 1 - scopeComplete:** CI, publish workflow, Plesk repository, branch,
   path, automatic deployment, webhook, and smoke check complete.
2. **Check 2 - crossSectionComplete:** repository, GitHub Actions, Plesk UI,
   server-owned configuration, and public site agree.
3. **Check 3 - 7ExpertSummary:** record the seven-domain relevance mask; make
   Infrastructure & Security, Backend & Architecture, and Quality & Testing
   relevant for every deployment review.
4. **JudgeVerdict:** only `accept` permits a done claim.

The final report must contain changed files, commands/tests and statuses,
Plesk branch/path evidence, GitHub run evidence, public smoke evidence, open
findings, and residual risk. Never include secret values or raw sensitive logs.

## Pitfalls

- `.gitignore` alone does not protect server-owned files from an artifact or a
  stale-file cleanup step; filter and preserve them explicitly.
- A mutable `main` checkout makes a tag release non-reproducible.
- Plesk may show a default branch such as `Deploy` or `main`; select the
  dedicated branch and read the card back before deploying.
- A repository can be created successfully while the first clone/deploy still
  fails. Verify the fresh notification, not only the repository card.
- A port-22 failure does not prove the deploy key is wrong; GitHub SSH over port
  443 may be required by the server firewall.
- Do not use FTP as an unannounced fallback. It requires the explicit `Deploy`
  command and a separately authorized credential path.

## Exit States

| State | Meaning |
|---|---|
| `pass` | All requested gates are verified and Judge accepted the result |
| `needs-review` | Technical work is complete but Judge evidence or a required read-back is pending |
| `decision-required` | A technical blocker has a safe decision packet and an in-scope next action |
| `blocked` | A hard safety/authorization stop exists, with a precise resume condition |
| `fail` | A required contract or gate failed and needs remediation |
