# GitLab CI/CD Workflow Contract for Plesk Deployment

The `.gitlab-ci.yml` must satisfy the following contract for zero-zip, direct webhook deployments:

## 1. Stage Structure

```yaml
stages:
  - test
  - build
```

## 2. Test Stage Example (.NET & Angular)

```yaml
test:dotnet:
  stage: test
  image: mcr.microsoft.com/dotnet/sdk:10.0
  script:
    - dotnet restore src/IdentityServers/OpenIddict/Ntk.OpenIddict.IdentityServer.UnitTests/Ntk.OpenIddict.IdentityServer.UnitTests.csproj -m:2
    - dotnet test src/IdentityServers/OpenIddict/Ntk.OpenIddict.IdentityServer.UnitTests/Ntk.OpenIddict.IdentityServer.UnitTests.csproj -c Release --no-restore -m:2

test:angular:website:
  stage: test
  image: node:22
  before_script:
    - npm install -g pnpm@$PNPM_VERSION --registry=https://registry.npmmirror.com
    - pnpm config set registry https://registry.npmmirror.com
  script:
    - cd src/UIs/angular/WebSite
    - pnpm install --frozen-lockfile
    - pnpm exec jest src/app/auth/auth.service.spec.ts --coverage=false
```

## 3. Build & Deploy Stage (Direct Push + Plesk Webhook, No Zip Artifacts)

### Angular / Single-Page Application:

```yaml
build:website:
  stage: build
  image: node:22
  needs: ["test:angular:website"]
  before_script:
    - npm install -g pnpm@$PNPM_VERSION --registry=https://registry.npmmirror.com
    - pnpm config set registry https://registry.npmmirror.com
  script:
    - cd src/UIs/angular/WebSite
    - pnpm install --frozen-lockfile
    - pnpm run build:prod
    - cd dist/angular/browser
    - git init
    - git config user.name "GitLab CI"
    - git config user.email "ci@ntk.ir"
    - git checkout -b plesk/cinemasakoo-web
    - git add -A
    - git commit -m "Publish cinemasakoo.ir from commit $CI_COMMIT_SHORT_SHA [skip ci]"
    - git push --force https://ci-pusher-2027:${GITLAB_PUSH_TOKEN}@git.ntk.ir/customer/ntk-sakoo.git plesk/cinemasakoo-web
    - 'curl -k -s -X POST -d "" -o /dev/null -w "Plesk Webhook cinemasakoo.ir Status: %{http_code}\n" "https://s44.ntkhost.com:8443/modules/git/public/web-hook.php?uuid=eecc7758-e3e0-5616-d309-c42e95d4851c"'
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
    - if: '$CI_COMMIT_TAG'
```

### .NET Backend API:

```yaml
build:api:
  stage: build
  image: mcr.microsoft.com/dotnet/sdk:10.0
  needs: ["test:dotnet"]
  script:
    - dotnet restore src/ModularMonolith/Ntk.ModularMonolith.WebAPI/Ntk.ModularMonolith.WebAPI.csproj --runtime win-x64 -m:2
    - dotnet publish src/ModularMonolith/Ntk.ModularMonolith.WebAPI/Ntk.ModularMonolith.WebAPI.csproj --configuration Release --runtime win-x64 --self-contained false --no-restore --output dist/api /p:UseAppHost=false -m:2
    - cd dist/api
    - rm -f appsettings*.json web.config nlog*.config
    - git init
    - git config user.name "GitLab CI"
    - git config user.email "ci@ntk.ir"
    - git checkout -b plesk/cinemasakoo-api
    - git add -A
    - git commit -m "Publish api.cinemasakoo.ir from commit $CI_COMMIT_SHORT_SHA [skip ci]"
    - git push --force https://ci-pusher-2027:${GITLAB_PUSH_TOKEN}@git.ntk.ir/customer/ntk-sakoo.git plesk/cinemasakoo-api
    - 'curl -k -s -X POST -d "" -o /dev/null -w "Plesk Webhook api.cinemasakoo.ir Status: %{http_code}\n" "https://s44.ntkhost.com:8443/modules/git/public/web-hook.php?uuid=a304dd17-ec81-f284-3107-b1d19f9dc31c"'
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
    - if: '$CI_COMMIT_TAG'
```
