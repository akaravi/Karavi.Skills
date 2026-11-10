# Validated GitLab-to-Plesk project patterns

This catalog records reusable structure observed in the signed-in GitLab
projects whose project cards showed a passing status. The green icon is only a
discovery signal; it is not proof that every security or acceptance gate is
correct. Live identifiers are intentionally omitted.

## Preferred target matrix

For a multi-surface application, model each surface independently:

| Surface | Build/payload | Plesk branch | Health gate |
|---|---|---|---|
| site/web | Angular or static output | `plesk/<site>` | public site or documented health |
| admin/panel | Angular output | `plesk/<admin>` | public admin entry |
| api | framework-dependent Windows publish | `plesk/<api>` | exact Health contract + Swagger |
| auth | identity-server publish | `plesk/<auth>` | documented discovery endpoint |
| cdn | CDN/API publish | `plesk/<cdn>` | health or documented Swagger |
| staging | environment-specific payload | `plesk/<staging>` | staging readiness |
| app | Flutter/web or other client output | `plesk/<app>` | configured client smoke |

Every row must have an explicit build input, Plesk directory read-back,
protected webhook variable, and health configuration. Do not deploy several
surfaces through one ambiguous webhook or branch.

## Reusable implementation shape

1. `validate` checks deployment manifests and target configuration.
2. `test` runs the discovered .NET and frontend tests before build jobs.
3. `build` uses matrix jobs where surfaces share a toolchain, publishes
   Windows .NET payloads as framework-dependent unless server evidence says
   otherwise, and stores short-lived artifacts.
4. `deploy` pushes only the authorized `plesk/<surface>` branch with `[skip ci]`
   metadata, then invokes that surface's webhook with an empty POST body.
5. `health` waits for asynchronous Plesk deployment with bounded retries and
   validates exact HTTP/response-body contracts.

A deployment helper may add a redacted `.plesk-deployment` metadata file with
   project label, target label, source SHA, and UTC publication time. Never put
   secrets or raw webhook URLs in that file.

## Corrections learned from the catalog

- Project cards with green status do **not** authorize copying a pipeline.
- Webhook URLs/UUIDs must never be committed as YAML variables; use protected
  CI variables. Do not put a push token in an HTTPS remote URL.
- Do not use `curl -k` when TLS verification is possible. Verify the host and
  use connection/request timeouts.
- Plesk Git webhook acceptance is exact `204`; accepting `200`, redirects, or
  arbitrary 4xx/5xx responses hides deployment failures.
- A health probe must not treat `301`, `302`, `401`, `403`, `404`, or `405` as
  success unless the target contract explicitly documents that response. API
  health must validate body semantics and Swagger/OpenAPI structure.
- Deployment and health jobs must not use `allow_failure: true`; optional
  client builds need a separately authorized non-production release path.
- Do not let a generic `main`/branch workflow bypass the exact release contract
  when the project uses the strict `publish` tag policy.