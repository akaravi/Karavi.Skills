# Deployment Evidence Record (GitLab to Plesk)

Create one record per deployment or domain migration:

```yaml
taskId: <domain-slug>-gitlab-plesk-deploy
scope:
  repository: <gitlab-host>/<group>/<project>
  domain: <domain-name>
  releaseTag: <tag-or-branch>
  pleskBranch: plesk/<domain-slug>
  deploymentPath: <exact path in Plesk, e.g. \httpdocs>
evidence:
  gitlabPipelineId: <pipeline-id>
  pipelineStatus: success
  testJobs:
    dotnet: passed
    angular: passed
  buildJobs:
    pushedBranchSha: <sha>
    webhookCalled: true
    webhookResponseHttp: 204
  pleskRepositoryCard:
    repositoryName: <name>
    remoteUrl: <url>
    branch: plesk/<domain-slug>
    deploymentMode: Automatic
    latestCommitSha: <sha>
  publicSmoke:
    status: 200
    checkedEndpoints:
      - https://<domain-name>/
      - https://<domain-name>/assets/version.json
findings: []
residualRisk: none
judgeVerdict: accept
```
