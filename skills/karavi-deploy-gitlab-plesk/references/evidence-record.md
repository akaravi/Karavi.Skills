# Deployment Evidence Record (GitLab to Plesk)

Create one record per deployment or domain migration:

This is a schema example, not observed deployment evidence. Fill outcomes from actual checks; use `not-run` for unavailable evidence. Never prefill a successful pipeline or an acceptance verdict.

```yaml
taskId: <domain-slug>-gitlab-plesk-deploy
scope:
  repository: <gitlab-host>/<group>/<project>
  domain: <domain-name>
  releaseTag: publish
  pipelineSource: push
  pleskBranch: plesk/<domain-slug>
  deploymentPath: <exact path in Plesk, e.g. \httpdocs>
  sourceRoot: <configured local root and project path>
evidence:
  gitlabPipelineId: <pipeline-id>
  pipelineStatus: <observed status or not-run>
  stages: [test, build, health]
  triggerMatrixResult: <validation result or not-run>
  testJobs:
    dotnet: <observed result or not-applicable>
    angular: <observed result or not-applicable>
  buildJobs:
    pushedBranchSha: <sha>
    webhookCalled: true
    webhookResponseHttp: 204
  healthJobs:
    - target: <canonical API target label>
      healthConfigKey: <CI variable name, not credential-bearing URL>
      swaggerUiConfigKey: <CI variable name>
      swaggerJsonConfigKey: <CI variable name>
      healthHttp: <observed status or not-run>
      healthContractResult: <observed result or not-run>
      swaggerUiHttp: <observed status or not-run>
      swaggerUiContractResult: <observed result or not-run>
      swaggerJsonHttp: <observed status or not-run>
      swaggerDocumentResult: <observed result or not-run>
      attempts: <observed count>
      outcome: <passed or failed or not-run>
  pleskRepositoryCard:
    repositoryName: <name>
    remoteUrl: <url>
    branch: plesk/<domain-slug>
    deploymentMode: Automatic
    latestCommitSha: <sha>
  sshCredential: <redacted id, scope, expiry, rotation owner; validity >=365 days>
  domainMapping: <Plesk domain/subdomain and repository card read-back>
  zeroLockLifecycle:
    hook: <installed and LF-verified or not-run>
    offlineBeforeOverwrite: <passed or not-run>
    lockFreePull: <passed or not-run>
    cleanupAfterDeployment: <passed or not-run>
  publicSmoke:
    status: 200
    checkedEndpoints:
      - https://<domain-name>/
      - https://<domain-name>/assets/version.json
  remediationNotification: <Telegram redacted update sent or not-run>
findings: []
residualRisk: none
judgeVerdict: <actual independent verdict or not-run>
```
