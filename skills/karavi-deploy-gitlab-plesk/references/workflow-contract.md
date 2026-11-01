# GitLab CI/CD Workflow Contract for Plesk Deployment

## Agent instructions and discovery

Generate or migrate the project's release pipeline; do not copy application paths or domains from another project. Discover required test commands, build commands, deployment branches, canonical target URLs, and the Health response format from project configuration. Preserve server-owned files and the existing no-zip deployment architecture.

The skill supports two pipeline architectures:
1. **Profile A (Monorepo Multi-Target DAG):** `validate -> test -> build -> deploy -> health-check` for projects with multi-platform targets (Angular, .NET, Flutter). Independent tracks run via `needs:` without blocking unrelated stacks, and mobile/client builds (Flutter) are routed to release registry rather than Plesk.
2. **Profile B (Lean Strict Pipeline):** `test -> build -> health` for single-target or unified releases triggered strictly on Git tag `$CI_COMMIT_TAG == "publish"`. Publishing is work inside `build`, not a fourth stage.
## Exact publish trigger and stage barriers

Use this release configuration:

```yaml
workflow:
  rules:
    - if: '$CI_PIPELINE_SOURCE == "push" && $CI_COMMIT_TAG == "publish"'
    - when: never

stages:
  - test
  - build
  - health
```

`publish` is a case-sensitive, exact Git tag. It is not `tags: [publish]` (runner selection), a branch, a tag prefix, a version tag, or a commit-message marker. Do not add a fallback for `main`, arbitrary tags, schedules, web/API triggers, or merge requests. Remove conflicting job-level `rules`, `only`, and `except` when migrating. Audit included CI files and child pipelines for bypasses. If the project has separately authorized non-release CI, preserve it separately without broadening this release trigger.

Run all required .NET/frontend tests in `test`, using discovered commands and `pnpm` for JavaScript package management. Every required test must pass before any `build` job starts. Use normal stage barriers: omit `needs` from build and health jobs. In particular, do not copy a single-test `needs` shortcut into a multi-test deployment. Required jobs run automatically on success, with `allow_failure: false`; no manual or optional release gates.

Each `build` job compiles and publishes its own target, removes server-owned configuration from the payload, pushes only to its authorized `plesk/*` branch, and calls its configured Plesk webhook. Require exactly HTTP 204, with TLS verification and connection/request timeouts. Do not print webhook URLs or query strings. Do not retry mutation requests blindly. A successful webhook only acknowledges asynchronous deployment; readiness belongs in `health`.

For repositories hosted on `git.ntk.ir`, use only scp-style SSH Git URLs: `git@git.ntk.ir:<namespace>/<repository>.git`. Use approved CI SSH credentials and verified host keys, not tokens embedded in remote URLs. HTTPS remains valid for GitLab API and Plesk webhooks. Do not copy a live project's webhook identifier or domain into this reusable skill.

## Health job contract

Create automatic `health` jobs covering every deployed API target after **all** build/deployment jobs pass. Do not use `needs: []`, partial build dependencies, `when: always`, `allow_failure`, or failure suppression.

Read these URLs from canonical project configuration / CI variables for each target:

- `HEALTH_URL`: the actual health endpoint, commonly `/health`; path alone is not a guarantee of its response contract.
- `SWAGGER_URL`: the Swagger UI URL, commonly `/swagger/index.html`.
- `SWAGGER_JSON_URL`: the specification URL discovered from Swagger configuration, commonly `/swagger/v1/swagger.json`.

Do not guess the host, base path, document version, or credentials. Missing target configuration is a failed prerequisite, not a skipped check. Use existing authorized authentication without logging it; do not enable anonymous production Swagger access merely to satisfy CI. For non-API targets, use their configured smoke checks; never silently omit an API's Swagger/Health pair.

Use GET, not HEAD. Require exact HTTP 200 without following redirects, so login pages and redirect responses cannot appear healthy. Validate Health according to its canonical contract (for example, exact `Healthy` text or JSON `status == "Healthy"`); a 200 with an unhealthy body fails. Validate Swagger UI content and parse the JSON document, checking its OpenAPI/Swagger version and required structure rather than accepting arbitrary JSON or HTML.

Use at most 12 readiness attempts, 5 seconds apart, with a 5-second connection timeout and 15-second total timeout per request. All probes for a target must pass in the same attempt. Exhaustion, TLS failure, connection failure, invalid bodies, or a non-200 response fails the job. Keep bodies in temporary files only and remove them on exit. Log target/probe labels, attempt, status code, and outcome; do not log URLs containing credentials, response bodies, or curl diagnostics containing secret-bearing URLs.

### Executable Python probe example

This example requires Python 3 and curl in the project's approved pinned health-job image. It supports exact text `Healthy` or JSON `status == "Healthy"`; adapt the predicate only when the project's documented contract differs. Reuse it per API target with separately mapped URLs. Do not declare success until all target invocations succeed.

```python
import json
import os
import subprocess
import tempfile
import time
from pathlib import Path

urls = {key: os.environ.get(key, "") for key in
        ("HEALTH_URL", "SWAGGER_URL", "SWAGGER_JSON_URL")}
health_format = os.environ.get("HEALTH_FORMAT", "")
if not all(urls.values()) or health_format not in ("text", "json"):
    raise SystemExit("health configuration=missing-or-invalid")

def get_200(label, url, path):
    result = subprocess.run(
        ["curl", "--silent", "--connect-timeout", "5", "--max-time", "15",
         "--output", str(path), "--write-out", "%{http_code}", url],
        capture_output=True, timeout=20,
    )
    code = result.stdout.decode("ascii", errors="replace")
    print(f"{label} http={code if code.isdigit() else 'unknown'}", flush=True)
    if result.returncode or code != "200":
        raise ValueError("probe failed")
    return path.read_text(encoding="utf-8")

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    for attempt in range(1, 13):
        print(f"readiness attempt={attempt}", flush=True)
        try:
            body = get_200("health", urls["HEALTH_URL"], root / "health")
            healthy = (body.rstrip("\r\n") == "Healthy" if health_format == "text"
                       else isinstance(value := json.loads(body), dict)
                       and value.get("status") == "Healthy")
            if not healthy:
                raise ValueError("unhealthy body")
            ui = get_200("swagger-ui", urls["SWAGGER_URL"], root / "ui")
            if "swagger-ui" not in ui.lower():
                raise ValueError("invalid Swagger UI")
            spec = json.loads(get_200(
                "swagger-json", urls["SWAGGER_JSON_URL"], root / "spec"))
            if not (isinstance(spec, dict)
                    and (str(spec.get("openapi", "")).startswith("3.")
                         or spec.get("swagger") == "2.0")
                    and isinstance(spec.get("info"), dict)
                    and isinstance(spec.get("paths"), dict)):
                raise ValueError("invalid Swagger document")
        except (ValueError, OSError, subprocess.SubprocessError):
            print("health outcome=not-ready", flush=True)
            if attempt < 12:
                time.sleep(5)
        else:
            print("health outcome=passed", flush=True)
            break
    else:
        raise SystemExit("health outcome=failed")
```

Wire the script into `health:<target>` with `stage: health`, `allow_failure: false`, no `needs`, and no overriding trigger rules. Use the project's approved image and real script path; this reference is not a complete application CI file.

## Validation and failure scenarios

Before claiming CI configuration acceptance, use GitLab CI Lint on the expanded configuration and inspect the job graph. Check this trigger matrix without creating or moving a real tag unless explicitly authorized:

| Source/ref | Expected release pipeline |
|---|---|
| `push`, exact tag `publish` | Created: `test -> build -> health` |
| `push`, branch `main` or branch `publish` | Not created |
| `push`, tag `v1.2.3`, `publish-1`, or `Publish` | Not created |
| MR, schedule, web, API, or trigger source, even at `publish` | Not created |
| Push to deployment branch `plesk/*` | Not created; no recursive publish |

Exercise the generated probe against local controlled responses: healthy Health + Swagger UI + valid spec passes; Health 503, Health 200 with unhealthy body, Swagger 404, Swagger 200 HTML instead of JSON, redirect/login page, missing URL, and readiness exhaustion fail. A test failure must prevent all build/deploy jobs; a build failure must prevent health. Do not report live release verification from static lint or local probe results.

Return changed CI paths, trigger/stage validation, required test/build mapping, target-to-URL configuration keys (redacted), probe outcomes, and any unavailable live evidence. The exact tag cannot identify multiple releases without reuse; do not delete, move, or recreate it without explicit authorization. Tag-triggered automation does not waive deployment authorization.
