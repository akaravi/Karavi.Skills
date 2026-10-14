# Deployment evidence record

Create one redacted record per configured project. This is a template, not
proof of deployment. Replace placeholders only with verified values and redact
webhook URLs, UUIDs, secrets, credentials, private keys, PII, and raw logs.

```yaml
taskId: <project-slug>-plesk-deploy
scope:
  repository: <owner>/<repo>
  domain: <domain>
  releaseTag: publish
  pleskBranch: plesk/<site-slug>
  deploymentPath: <exact path read back from Plesk UI>
evidence:
  githubRun: <run id and conclusion>
  publishedCommit: <sha>
  pleskBranchSha: <sha>
  pleskRepository: <repository name and redacted remote>
  automaticDeployment: verified
  webhook: active, push-only, URL=[REDACTED]
  serverOwnedFileScan: passed, zero matches in release payload
  publicSmoke: <status and checked endpoints>
findings: []
residualRisk: <runtime/configuration risks, or none>
judgeVerdict: <accept|needs-review|fail>
```

The record must distinguish evidence that was actually read back from generic
requirements that were only documented. `judgeVerdict: accept` is required
before reporting the deployment as complete.