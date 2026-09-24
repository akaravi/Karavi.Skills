# Command classification

Read-only: Get-*, Test-Path, git status/log/diff, docker ps, kubectl get/describe/logs (bounded), Asterisk show commands.

Mutation: file/service/registry changes, installs, git write, docker/k8s apply/delete, DB writes, Asterisk reload/originate.

Forbidden without separate override: format, diskpart, git push --force, DROP DATABASE, secrets on CLI.

When unsure → mutation.
