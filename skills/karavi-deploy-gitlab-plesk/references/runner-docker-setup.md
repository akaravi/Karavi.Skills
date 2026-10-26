# GitLab Runner & Docker Setup on Linux Host

## 1. Install Docker Engine on Ubuntu (Bypassing Docker.com 403 Sanction)

Do not use `curl -fsSL https://get.docker.com | sh` as `download.docker.com` returns HTTP 403 Forbidden in Iran.

Use standard Ubuntu distribution packages:

```bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker gitlab-runner
```

## 2. Configure Iranian Docker Registry Mirrors & Shecan DNS

To prevent Docker Hub CloudFront 403 when pulling public base images (`node:22`, etc.), configure `/etc/docker/daemon.json`:

```bash
cat << 'EOF' > /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://docker.iranserver.com",
    "https://docker.arvancloud.ir"
  ],
  "dns": ["178.22.122.100", "185.51.200.2", "8.8.8.8"]
}
EOF

sudo systemctl restart docker
```

## 3. Configure GitLab Runner for Docker Executor

Edit `/etc/gitlab-runner/config.toml`:

```toml
concurrent = 4
check_interval = 0
shutdown_timeout = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "s20"
  url = "https://git.ntk.ir"
  id = 1
  token = "<RUNNER_TOKEN>"
  executor = "docker"
  [runners.custom_build_dir]
  [runners.cache]
    MaxUploadedArchiveSize = 0
  [runners.docker]
    tls_verify = false
    image = "ubuntu:24.04"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
```

Restart runner:
```bash
sudo systemctl restart gitlab-runner
```

## 4. Enable Untagged Jobs in GitLab Admin

In GitLab Admin -> CI/CD -> Runners -> Select Runner -> Edit:
Check **`Run untagged jobs`** so that jobs without specific tags are processed.
