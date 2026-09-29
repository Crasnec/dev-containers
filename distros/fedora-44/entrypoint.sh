#!/usr/bin/env bash
set -euo pipefail

DEV_USER="${DEV_USER:-}"
if [[ -z "$DEV_USER" ]] || ! getent passwd "$DEV_USER" >/dev/null; then
  DEV_USER="$(getent passwd 1000 | cut -d: -f1)"
fi
if [[ -z "$DEV_USER" ]]; then
  echo "unable to resolve the development user" >&2
  exit 1
fi

DEV_HOME="${DEV_HOME:-$(getent passwd "$DEV_USER" | cut -d: -f6)}"
GOPATH="${GOPATH:-$DEV_HOME/.cache/go}"
NPM_PREFIX="${NPM_CONFIG_PREFIX:-$DEV_HOME/.local}"

install -d -o "$DEV_USER" -g "$DEV_USER" -m 700 "$DEV_HOME/.ssh"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 700 "$DEV_HOME/.cache"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 700 "$DEV_HOME/.cache/pip"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 700 "$DEV_HOME/.cargo"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 700 "$DEV_HOME/.npm"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 755 "$NPM_PREFIX"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 755 "$NPM_PREFIX/bin"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 755 "$NPM_PREFIX/lib"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 755 "$NPM_PREFIX/lib/node_modules"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 755 "$GOPATH"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 755 /workspace

if [[ -S /var/run/docker.sock ]]; then
  sock_gid="$(stat -c '%g' /var/run/docker.sock)"
  if ! getent group "$sock_gid" >/dev/null; then
    groupadd --gid "$sock_gid" host-docker
  fi
  sock_group="$(getent group "$sock_gid" | cut -d: -f1)"
  usermod -aG "$sock_group" "$DEV_USER"
fi

ssh-keygen -A

# Bind-mounted caches may contain root-owned files after a previous `sudo npm`.
# Restore ownership before the user shell starts and remove startup-safe stale temp data.
chown -R "$DEV_USER:$DEV_USER" "$DEV_HOME/.cache" "$DEV_HOME/.cargo" "$DEV_HOME/.npm" "$NPM_PREFIX"
rm -rf "$DEV_HOME/.npm/_locks" "$DEV_HOME/.npm/_cacache/tmp"
install -d -o "$DEV_USER" -g "$DEV_USER" -m 700 "$DEV_HOME/.npm/_cacache/tmp"

# Keep global npm installs out of root-owned /usr/local.
sudo -u "$DEV_USER" env HOME="$DEV_HOME" npm config set prefix "$NPM_PREFIX" --location=user

chmod 700 "$DEV_HOME/.ssh"
find "$DEV_HOME/.ssh" -maxdepth 1 -type f -name 'id_*' -exec chmod 600 {} \; 2>/dev/null || true
chmod 600 "$DEV_HOME/.ssh/authorized_keys" 2>/dev/null || true
chmod 644 "$DEV_HOME/.ssh/known_hosts" 2>/dev/null || true

if [[ -s /opt/dev-secrets/container-password-hash ]]; then
  password_hash="$(< /opt/dev-secrets/container-password-hash)"
  printf '%s:%s\n' "$DEV_USER" "$password_hash" | chpasswd -e
fi
