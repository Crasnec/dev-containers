# Fedora Dev Container

Reusable Fedora-based development container with systemd, SSH, Docker socket access, Codex CLI, and optional GUI image support.

## Quick Start

```bash
cp .env.example .env
$EDITOR .env
./bin/dev up
./bin/dev shell
```

The first `dev up` run creates local-only files under `shared/` and `cache/`, including SSH host keys, `authorized_keys`, `known_hosts`, and a generated container SSH password.

## SSH

The container listens on port `2222`.

```bash
ssh -p 2222 dev@localhost
./bin/dev password
```

For external access, open `2222/tcp` in the host firewall only if you need it.

## Local Secrets

Do not commit these paths:

- `.env`
- `cache/`
- `shared/ssh/`
- `shared/gitconfig`

They are ignored by both Git and Docker build context.

## Optional GUI Image

```bash
docker build \
  --build-arg FEDORA_VERSION=44 \
  --build-arg DEV_USER=dev \
  -t local/dev-fedora-gui:44 \
  -f distros/fedora-44-gui/Dockerfile .
```
