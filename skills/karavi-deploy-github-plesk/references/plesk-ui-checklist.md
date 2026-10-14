# Plesk UI checklist

Use fresh read-back after every mutation. A successful click is not evidence.

## Repository

- [ ] Target domain context is correct.
- [ ] Repository remote points to the canonical GitHub repository.
- [ ] If port 22 is unavailable, SSH uses `ssh.github.com:443`.
- [ ] Plesk deploy key is registered in the GitHub repository.
- [ ] Repository clone/pull succeeds.

## Branch and path

- [ ] Dedicated branch exists in GitHub.
- [ ] The Plesk card shows the dedicated branch, not `main` or another default.
- [ ] Automatic deployment is enabled.
- [ ] Deployment path is the exact directory-selector result.
- [ ] Server-owned configuration exists on the server before first deployment.

## Deployment and webhook

- [ ] Manual Pull/Deploy succeeds for the selected branch.
- [ ] Latest commit subject and SHA agree with GitHub.
- [ ] GitHub webhook is active and limited to `push`.
- [ ] Webhook delivery is successful.
- [ ] Plesk deployment log shows the corresponding pull/deploy.
- [ ] Webhook URL, UUID, secret, credentials, and raw logs remain redacted.
